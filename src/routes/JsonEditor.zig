const std = @import("std");
const Vapor = @import("vapor");
const Page = Vapor.Page;
const Box = Vapor.Box;
const Text = Vapor.Text;
const Hooks = Vapor.Static.Hooks;
const TextArea = Vapor.TextArea;
const Compiler = @import("../main.zig");
const Vaporize = @import("vaporize");
const SyntaxHighlighter = Vaporize.SyntaxHighlighter;

var highlighter: SyntaxHighlighter = undefined;

var buffer: [8192]u8 = undefined;
var text: []const u8 =
    \\pub fn main() void {
    \\    const x = 42;
    \\}
;
var arena: std.heap.ArenaAllocator = undefined;
pub fn init() void {
    arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
    highlighter = SyntaxHighlighter.init(arena.allocator());
    parse();

    text = std.fmt.bufPrint(&buffer, "{s}", .{text}) catch unreachable;

    Page(.{ .src = @src() }, render, null);
}

var text_area: Vapor.Binded = .{};

fn onChange(evt: *Vapor.Event) void {
    text = evt.text();
    parse();
}

fn parse() void {
    _ = arena.reset(.retain_capacity);
    highlighter.parse(text) catch unreachable;
}

var indent_buffer: [8192]u8 = undefined;
fn onKeyDown(evt: *Vapor.Event) void {
    const key = evt.key();
    if (std.mem.eql(u8, key, "Enter")) {
        evt.preventDefault();
        const cursor_pos = text_area.cursorPosition();

        // Find the start of the current line
        const line_start = std.mem.lastIndexOf(u8, text[0..cursor_pos], "\n") orelse 0;
        const actual_line_start = if (line_start == 0) 0 else line_start + 1;

        // Extract the current line up to cursor
        const current_line = text[actual_line_start..cursor_pos];

        // Calculate current indentation
        var indent_count: usize = 0;
        for (current_line) |c| {
            if (c == ' ' or c == '\t') {
                indent_count += 1;
            } else {
                break;
            }
        }

        // Check if we need to increase indent (line ends with { or [)
        var extra_indent: usize = 0;
        var prev_char: ?u8 = null;
        if (cursor_pos > 0) {
            // Look backwards for the last non-whitespace character
            var i: usize = cursor_pos;
            while (i > 0) : (i -= 1) {
                const c = text[i - 1];
                if (c != ' ' and c != '\t' and c != '\n') {
                    prev_char = c;
                    if (c == '{' or c == '[') {
                        extra_indent = 2;
                    }
                    break;
                }
            }
        }

        // Check if next character is closing brace/bracket
        var next_char: ?u8 = null;
        if (cursor_pos < text.len) {
            var i: usize = cursor_pos;
            while (i < text.len) : (i += 1) {
                const c = text[i];
                if (c != ' ' and c != '\t' and c != '\n') {
                    next_char = c;
                    break;
                }
            }
        }

        // Special case: pressing Enter between {} or []
        const is_between_pairs = (prev_char == '{' and next_char == '}') or
            (prev_char == '[' and next_char == ']');

        // Build the new indentation
        const total_indent = indent_count + extra_indent;
        @memset(indent_buffer[0..total_indent], ' ');

        var insert: []const u8 = undefined;

        if (is_between_pairs) {
            // Insert two lines: one indented, one at current level for closing brace
            @memset(indent_buffer2[0..indent_count], ' ');
            insert = std.fmt.allocPrint(Vapor.arena(.frame), "\n{s}\n{s}", .{ indent_buffer[0..total_indent], indent_buffer2[0..indent_count] }) catch unreachable;
            new_cursor_pos = cursor_pos + 1 + total_indent; // Position on the indented line
        } else {
            // Normal Enter behavior
            insert = std.fmt.allocPrint(Vapor.arena(.frame), "\n{s}", .{indent_buffer[0..total_indent]}) catch unreachable;
            new_cursor_pos = cursor_pos + insert.len;
        }

        const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}{s}", .{ text[0..actual_line_start], current_line, insert, text[cursor_pos..] }) catch unreachable;

        text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
        parse();
        Vapor.onEnd(updateCursorPosition);
    }
}

// Add a second buffer for the closing brace line
var indent_buffer2: [256]u8 = undefined;

var new_cursor_pos: usize = 0;
fn updateCursorPosition() void {
    text_area.setCursorPosition(new_cursor_pos);
}

fn render() void {
    Box()
        .pos(.relative)
        .width(.percent(100))
        .height(.percent(100))
        .size(.full).layout(.center).spacing(16).padding(.all(20)).children({
        Box()
            .width(.percent(40))
            .height(.percent(40))
            .pos(.tl(.percent(0), .percent(0), .absolute)).children({
            highlighter.renderAST(highlighter.root) catch unreachable;
        });
        Box()
            .zIndex(999)
            .background(.transparent)
            .width(.percent(40))
            .height(.percent(40))
            .pos(.tl(.percent(0), .percent(0), .absolute)).children({
            TextArea()
                .ref(&text_area)
                .background(.transparent)
                .bind(&text)
                .placeholder(text)
                .width(.percent(100))
                .height(.percent(100))
                .whitespace(.pre)
                .padding(.tblr(20, 8, 24, 8))
                .caret(.{ .type = .block, .color = .palette(.text_color) })
                .font(15, null, .transparent)
                .fontFamily("DM Mono, monospace")
                .onChange(onChange)
                .onKeyDown(onKeyDown).end();
        });
    });
}
