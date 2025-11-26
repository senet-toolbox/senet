const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;
const Page = Vapor.Page;
const Custom = @import("../../../../../../components/Custom.zig");
const Kit = Vapor.Kit;
const CodeEditor = @import("../CodeEditor.zig");
const Content = @import("../../../../../../components/Content.zig");
const Vaporize = @import("vaporize");

var scaffold_code_editor: CodeEditor = undefined;
var register_code_editor: CodeEditor = undefined;
var grid_code_editor: CodeEditor = undefined;
var wire_code_editor: CodeEditor = undefined;
var assetso_code_editor: CodeEditor = undefined;
var assetsx_code_editor: CodeEditor = undefined;
var extend_code_editor: CodeEditor = undefined;
var update_code_editor: CodeEditor = undefined;
var checkwin_code_editor: CodeEditor = undefined;
var selectbox_code_editor: CodeEditor = undefined;
var winner_code_editor: CodeEditor = undefined;
var full_code_editor: CodeEditor = undefined;
var content: Content.new(@embedFile("tictactoe.md")) = undefined;
var tutorials_page: *Vaporize.Node = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("tictactoe.md"));
    tutorials_page = parser.parse() catch unreachable;
    // scaffold_code_editor.init(&Vapor.lib.allocator_global, @embedFile("scaffold.zig"));
    // register_code_editor.init(&Vapor.lib.allocator_global, @embedFile("register.zig"));
    // grid_code_editor.init(&Vapor.lib.allocator_global, @embedFile("grid.zig"));
    // wire_code_editor.init(&Vapor.lib.allocator_global, @embedFile("wire.zig"));
    // assetso_code_editor.init(&Vapor.lib.allocator_global, @embedFile("assetsO.zig"));
    // assetsx_code_editor.init(&Vapor.lib.allocator_global, @embedFile("assetsX.zig"));
    // extend_code_editor.init(&Vapor.lib.allocator_global, @embedFile("extend.zig"));
    // update_code_editor.init(&Vapor.lib.allocator_global, @embedFile("update.zig"));
    // checkwin_code_editor.init(&Vapor.lib.allocator_global, @embedFile("checkwin.zig"));
    // selectbox_code_editor.init(&Vapor.lib.allocator_global, @embedFile("selectbox.zig"));
    // winner_code_editor.init(&Vapor.lib.allocator_global, @embedFile("winner.zig"));
    // full_code_editor.init(&Vapor.lib.allocator_global, @embedFile("full.zig"));
}

fn component() void {
    Vaporize.traverse(tutorials_page, .{
        .code_style = .{ .visual = .{ .text_color = .palette(.tint) } },
        .text_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
        .heading_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
    }, void, null) catch unreachable;
}

pub fn render() void {
    content.content(component);
}
