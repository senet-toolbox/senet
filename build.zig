const std = @import("std");

// Basic minimal fabric build.zig setup
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{ .cpu_arch = .wasm32, .os_tag = .wasi },
    });

    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    // Create a module for your config file
    const user_config_module = b.addModule("user_config", .{
        .root_source_file = b.path("src/my_config.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create a module for your config file
    const wasm_module = b.addModule("wasm", .{
        .root_source_file = b.path("wasm/functions.zig"),
        .target = target,
        .optimize = optimize,
    });

    const fabric = b.dependency("fabric", .{
        .target = target,
        .optimize = optimize,
    });

    const fabric_module = fabric.module("fabric");

    fabric_module.addImport("user_config", user_config_module);
    fabric_module.addImport("wasm", wasm_module);
    fabric_module.addImport("fabric", fabric_module);

    // ADD THIS: Create a theme module that has access to fabric
    const theme_module = b.addModule("theme", .{
        .root_source_file = b.path("src/Theme.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "fabric", .module = fabric_module },
        },
    });

    // We will also create a module for our other entry point, 'main.zig'.
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "fabric", .module = fabric_module },
            .{ .name = "theme", .module = theme_module }, // ADD THIS
        },
    });

    const exe = b.addExecutable(.{
        .name = "fabric",
        .root_module = exe_mod,
    });

    exe.root_module.addImport("user_config", b.addModule("user_config", .{
        .root_source_file = b.path("src/my_config.zig"),
    }));
    exe.rdynamic = true;

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
