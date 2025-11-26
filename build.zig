const std = @import("std");
const builtin = @import("builtin");
fn generateHtml(b: *std.Build, run: *std.Build.Step.Run) void {
    const target = b.graph.host;

    const optimize = std.builtin.OptimizeMode.Debug;
    // Create a module for your config file
    const user_config_module = b.addModule("user_config", .{
        .root_source_file = b.path("src/my_config.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Define your build options

    const vapor = b.dependency("vapor", .{
        .target = target,
        .optimize = optimize,
    });

    const vapor_module = vapor.module("vapor");

    vapor_module.addImport("user_config", user_config_module);
    vapor_module.addImport("vapor", vapor_module);

    // Create a module for your config file
    const wasm_module = b.addModule("wasm", .{
        .root_source_file = b.path("wasm/functions.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "vapor", .module = vapor_module },
        },
    });

    vapor_module.addImport("wasm", wasm_module);

    // ADD THIS: Create a theme module that has access tovapor
    const theme_module = b.addModule("theme", .{
        .root_source_file = b.path("src/Theme.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "vapor", .module = vapor_module },
        },
    });

    vapor_module.addImport("theme", theme_module);

    const vaporize = b.dependency("vaporize", .{
        .target = target,
        .optimize = optimize,
    });
    const vaporize_module = vaporize.module("vaporize");
    vaporize_module.addImport("vapor", vapor_module);

    const generator_mod = b.createModule(.{
        .root_source_file = b.path("src/generator.zig"),
        .target = target,
        .optimize = .Debug,
        .imports = &.{
            .{ .name = "vapor", .module = vapor_module },
            .{ .name = "theme", .module = theme_module }, // ADD THIS
            .{ .name = "user_config", .module = user_config_module },
            .{ .name = "vaporize", .module = vaporize_module },
        },
    });
    const generator_exe = b.addExecutable(.{
        .name = "generator",
        .root_module = generator_mod,
    });

    run.* = b.addRunArtifact(generator_exe).*;
}

// Basic minimal vapor build.zig setup
pub fn build(b: *std.Build) void {
    var generator: std.Build.Step.Run = undefined;
    const generate = b.option(bool, "generate", "Generate HTML") orelse false;

    if (generate) {
        generateHtml(b, &generator);
    }

    const wasm_target = b.standardTargetOptions(.{
        // .default_target = .{ .cpu_arch = .x86_64, .os_tag = .macos }
        .default_target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding },
    });

    const optimize = b.standardOptimizeOption(.{
        // .preferred_optimize_mode = .ReleaseSmall,
    });

    // Create a module for your config file
    const user_config_module = b.addModule("user_config", .{
        .root_source_file = b.path("src/my_config.zig"),
        .target = wasm_target,
        .optimize = optimize,
    });

    const vapor = b.dependency("vapor", .{
        .target = wasm_target,
        .optimize = optimize,
        .static = false,
        .atomic = false,
    });

    const vapor_module = vapor.module("vapor");

    vapor_module.addImport("user_config", user_config_module);
    vapor_module.addImport("vapor", vapor_module);

    // Create a module for your config file
    const wasm_module = b.addModule("wasm", .{
        .root_source_file = b.path("wasm/functions.zig"),
        .target = wasm_target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "vapor", .module = vapor_module },
        },
    });

    vapor_module.addImport("wasm", wasm_module);

    // ADD THIS: Create a theme module that has access tovapor
    const theme_module = b.addModule("theme", .{
        .root_source_file = b.path("src/Theme.zig"),
        .target = wasm_target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "vapor", .module = vapor_module },
        },
    });

    const vaporize = b.dependency("vaporize", .{
        .target = wasm_target,
        .optimize = optimize,
    });
    const vaporize_module = vaporize.module("vaporize");
    vaporize_module.addImport("vapor", vapor_module);

    vapor_module.addImport("theme", theme_module);
    // We will also create a module for our other entry point, 'main.zig'.
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = wasm_target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "vapor", .module = vapor_module },
            .{ .name = "vaporize", .module = vaporize_module },
            .{ .name = "theme", .module = theme_module }, // ADD THIS
            .{ .name = "user_config", .module = user_config_module },
        },
    });

    const exe = b.addExecutable(.{
        .name = "vapor",
        .root_module = exe_mod,
    });

    exe.stack_size = 4 * 1024 * 1024;

    if (generate) {
        exe.step.dependOn(&generator.step);
    }

    exe.rdynamic = true;
    // exe.use_llvm = true;
    // exe.linker_allow_shlib_undefined = true;

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
