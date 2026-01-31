const std = @import("std");
const fs = std.fs;
const Allocator = std.mem.Allocator;

/// Concatenates multiple markdown files into a single output file
/// Files are processed in the order they are provided
pub fn concatMarkdownFiles(
    allocator: Allocator,
    file_paths: []const []const u8,
    output_path: []const u8,
) !void {
    var content = std.array_list.Managed(u8).init(allocator);
    defer content.deinit();

    for (file_paths, 0..) |path, i| {
        const file = fs.cwd().openFile(path, .{}) catch |err| {
            std.debug.print("Warning: Could not open '{s}': {}\n", .{ path, err });
            continue;
        };
        defer file.close();

        const file_content = try file.readToEndAlloc(allocator, 10 * 1024 * 1024); // 10MB max per file
        defer allocator.free(file_content);

        try content.appendSlice(file_content);

        // Add separator between files (skip after last file)
        if (i < file_paths.len - 1) {
            try content.appendSlice("\n\n");
        }
    }

    // Ensure output directory exists
    if (std.fs.path.dirname(output_path)) |dir| {
        fs.cwd().makePath(dir) catch {};
    }

    const output_file = try fs.cwd().createFile(output_path, .{});
    defer output_file.close();

    try output_file.writeAll(content.items);
}

// Example usage
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Pass your files in order
    const files = [_][]const u8{
        "src/routes/docs/vapor/vapor_page.md",
        "src/routes/docs/vapor/concepts/:concept/basics/basics_page.md",
        "src/routes/docs/vapor/concepts/:concept/components/components_page.md",
        "src/routes/docs/vapor/concepts/:concept/dont-know-zig/dont_know_zig_page.md",
        "src/routes/docs/vapor/concepts/:concept/project/project_page.md",
        "src/routes/docs/vapor/concepts/:concept/routing/routing_page.md",
        "src/routes/docs/vapor/concepts/:concept/styling/styling_page.md",
        "src/routes/docs/vapor/concepts/:concept/reactivity/reactivity_page.md",
        "src/routes/docs/vapor/concepts/:concept/common-patterns/common_patterns_page.md",
        "src/routes/docs/vapor/concepts/:concept/gotchas/gotchas_page.md",
        "src/routes/docs/vapor/concepts/:concept/vaporize/vaporize_page.md",
        "src/routes/docs/vapor/concepts/:concept/animation/animation_page.md",
        "src/routes/docs/vapor/concepts/:concept/new-to-zig/new_to_zig_page.md",
        "src/routes/docs/vapor/concepts/:concept/api/api_page.md",
    };

    try concatMarkdownFiles(allocator, &files, "output/vapor_docs.md");

    std.debug.print("Combined markdown written to output/vapor_docs.md\n", .{});
}

test "concat empty list" {
    const allocator = std.testing.allocator;
    const files = [_][]const u8{};
    try concatMarkdownFiles(allocator, &files, "/tmp/test_output.md");
}

