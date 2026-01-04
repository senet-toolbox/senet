const std = @import("std");
const Vapor = @import("vapor");
const Page = Vapor.Page;
const Box = Vapor.Box;
const Text = Vapor.Text;
const Hooks = Vapor.Static.Hooks;
const TextArea = Vapor.TextArea;
const Vaporize = @import("vaporize");
const SyntaxHighlighter = Vaporize.SyntaxHighlighter;
const ButtonCtx = Vapor.CtxButton;

var container_height: f32 = 22.5 * 12;
var line_height: f32 = 22.5;

const JsonEditor = @This();
highlighter: SyntaxHighlighter = undefined,
buffer: [8192]u8 = undefined,
text: []const u8 = undefined,
allocator: std.mem.Allocator = undefined,
text_area: Vapor.Binded = .{},
indent_buffer: [8192]u8 = undefined,
holding_meta: bool = false,
binded_highlighter: Vapor.Binded = .{},
copied: bool = false,

pub fn init(default_text: []const u8) JsonEditor {
    const allocator = Vapor.arena(.persist);
    const highlighter = SyntaxHighlighter.init(allocator);
    var editor = JsonEditor{
        .highlighter = highlighter,
        .allocator = allocator,
        .text = default_text,
    };
    editor.parse();
    return editor;
}

var last_time: i64 = 0;
pub fn throttle() bool {
    const current_time = std.time.milliTimestamp();
    if (current_time - last_time < 60) {
        return true;
    }
    last_time = current_time;
    return false;
}

fn onChange(editor: *JsonEditor, evt: *Vapor.Event) void {
    if (throttle()) return;
    editor.text = evt.text();
    editor.parse();
}

fn parse(editor: *JsonEditor) void {
    // _ = arena.reset(.retain_capacity);
    editor.highlighter.parse(editor.text) catch unreachable;
    editor.highlighter.validateJSON() catch unreachable;
}

fn onKeyDown(editor: *JsonEditor, evt: *Vapor.Event) void {
    // if (throttle()) return;
    const key = evt.key();
    if (std.mem.eql(u8, key, "Enter")) {
        evt.preventDefault();
        editor.handleEnter();
    } else if (std.mem.eql(u8, key, "Tab")) {
        evt.preventDefault();
        editor.handleTab(evt.shiftKey());
    } else if (std.mem.eql(u8, key, "Meta") or std.mem.eql(u8, key, "Control")) {
        editor.holding_meta = true;
    } else if ((std.mem.eql(u8, key, "/") or std.mem.eql(u8, key, "?")) and editor.holding_meta) {
        // Toggle comment (Cmd+/ or Ctrl+/)
        evt.preventDefault();
        // toggleComment();
    } else if (std.mem.eql(u8, key, "d") and editor.holding_meta) {
        // Duplicate line (Cmd+D or Ctrl+D)
        evt.preventDefault();
        editor.duplicateLine();
    } else if (std.mem.eql(u8, key, "k") and editor.holding_meta) {
        // Delete line (Cmd+K or Ctrl+K)
        evt.preventDefault();
        editor.deleteLine();
    } else if (std.mem.eql(u8, key, "]") and editor.holding_meta) {
        // Indent line (Cmd+] or Ctrl+])
        evt.preventDefault();
        editor.indentCurrentLine();
    } else if (std.mem.eql(u8, key, "[") and editor.holding_meta) {
        // Outdent line (Cmd+[ or Ctrl+[)
        evt.preventDefault();
        editor.outdentCurrentLine();
    } else if (std.mem.eql(u8, key, "ArrowUp") and editor.holding_meta and evt.altKey()) {
        // Move line up (Cmd+Alt+Up)
        evt.preventDefault();
        editor.moveLineUp();
    } else if (std.mem.eql(u8, key, "ArrowDown") and editor.holding_meta and evt.altKey()) {
        // Move line down (Cmd+Alt+Down)
        evt.preventDefault();
        editor.moveLineDown();
    }
}

fn handleEnter(editor: *JsonEditor) void {
    var text_area = editor.text_area;
    var text = editor.text;
    var indent_buffer = editor.indent_buffer;
    var buffer = editor.buffer;

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
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

fn handleTab(editor: *JsonEditor, shift: bool) void {
    var text_area = editor.text_area;
    var text = editor.text;
    var buffer = editor.buffer;

    const cursor_pos = text_area.cursorPosition();
    const selection = text_area.selection() orelse return;

    Vapor.print("{any} {any}", .{ selection.start, selection.end });
    if (selection.start != selection.end) {
        // Multi-line indent/outdent
        if (shift) {
            editor.handleOutdent(selection.start, selection.end);
        } else {
            editor.handleIndent(selection.start, selection.end);
        }
    } else {
        if (shift) {
            // Outdent current line
            editor.outdentCurrentLine();
        } else {
            // Insert tab/spaces at cursor
            const indent = "  "; // 2 spaces
            const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}", .{ text[0..cursor_pos], indent, text[cursor_pos..] }) catch unreachable;
            text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
            new_cursor_pos = cursor_pos + indent.len;
            editor.parse();
            Vapor.onEndCtx(updateCursorPosition, .{editor});
        }
    }
}

fn handleIndent(editor: *JsonEditor, start: usize, end: usize) void {
    var text = editor.text;
    var buffer = editor.buffer;

    // Find line boundaries
    const line_start = if (std.mem.lastIndexOf(u8, text[0..start], "\n")) |pos| pos + 1 else 0;
    const line_end = std.mem.indexOf(u8, text[end..], "\n") orelse text.len;
    const actual_end = end + line_end;

    // Count lines and build indented text
    var result = std.array_list.Managed(u8).init(Vapor.arena(.frame));
    var line_iter = std.mem.splitSequence(u8, text[line_start..actual_end], "\n");
    var first = true;

    while (line_iter.next()) |line| {
        if (!first) result.append('\n') catch unreachable;
        first = false;
        if (line.len > 0) {
            result.appendSlice("  ") catch unreachable;
        }
        result.appendSlice(line) catch unreachable;
    }

    const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}", .{ text[0..line_start], result.items, text[actual_end..] }) catch unreachable;
    text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
    new_cursor_pos = start + 2;
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

fn handleOutdent(editor: *JsonEditor, start: usize, end: usize) void {
    var text = editor.text;
    var buffer = editor.buffer;
    // Find line boundaries
    const line_start = if (std.mem.lastIndexOf(u8, text[0..start], "\n")) |pos| pos + 1 else 0;
    const line_end = std.mem.indexOf(u8, text[end..], "\n") orelse text.len;
    const actual_end = end + line_end;

    // Count lines and build outdented text
    var result = std.array_list.Managed(u8).init(Vapor.arena(.frame));
    var line_iter = std.mem.splitSequence(u8, text[line_start..actual_end], "\n");
    var first = true;

    while (line_iter.next()) |line| {
        if (!first) result.append('\n') catch unreachable;
        first = false;

        // Remove up to 2 leading spaces
        var skip: usize = 0;
        if (line.len > 0 and line[0] == ' ') {
            skip = 1;
            if (line.len > 1 and line[1] == ' ') {
                skip = 2;
            }
        }
        result.appendSlice(line[skip..]) catch unreachable;
    }

    const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}", .{ text[0..line_start], result.items, text[actual_end..] }) catch unreachable;
    text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
    new_cursor_pos = if (start >= 2) start - 2 else start;
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

fn indentCurrentLine(editor: *JsonEditor) void {
    var text_area = editor.text_area;
    var text = editor.text;
    var buffer = editor.buffer;

    const cursor_pos = text_area.cursorPosition();
    const line_bounds = editor.getLineBounds(cursor_pos);
    const line = text[line_bounds.start..line_bounds.end];

    const indented = std.fmt.allocPrint(Vapor.arena(.frame), "  {s}", .{line}) catch unreachable;
    const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}", .{ text[0..line_bounds.start], indented, text[line_bounds.end..] }) catch unreachable;

    text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
    new_cursor_pos = cursor_pos + 2;
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

fn outdentCurrentLine(editor: *JsonEditor) void {
    var text_area = editor.text_area;
    var text = editor.text;
    var buffer = editor.buffer;

    const cursor_pos = text_area.cursorPosition();
    const line_bounds = editor.getLineBounds(cursor_pos);
    const line = text[line_bounds.start..line_bounds.end];

    // Remove up to 2 leading spaces
    var skip: usize = 0;
    if (line.len > 0 and line[0] == ' ') {
        skip = 1;
        if (line.len > 1 and line[1] == ' ') {
            skip = 2;
        }
    }

    const outdented = line[skip..];
    const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}", .{ text[0..line_bounds.start], outdented, text[line_bounds.end..] }) catch unreachable;

    text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
    new_cursor_pos = if (cursor_pos >= skip) cursor_pos - skip else cursor_pos;
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

const LineBounds = struct {
    start: usize,
    end: usize,
};

fn getLineBounds(editor: *JsonEditor, cursor_pos: usize) LineBounds {
    var text = editor.text;

    const line_start = if (std.mem.lastIndexOf(u8, text[0..cursor_pos], "\n")) |pos| pos + 1 else 0;
    const line_end = std.mem.indexOfPos(u8, text, cursor_pos, "\n") orelse text.len;
    return .{ .start = line_start, .end = line_end };
}

fn moveLineUp(editor: *JsonEditor) void {
    var text_area = editor.text_area;
    var text = editor.text;
    var buffer = editor.buffer;

    const cursor_pos = text_area.cursorPosition();
    const line_bounds = editor.getLineBounds(cursor_pos);

    // Find previous line
    if (line_bounds.start == 0) return; // Already at top

    const prev_line_end = line_bounds.start - 1;
    const prev_line_start = if (std.mem.lastIndexOf(u8, text[0..prev_line_end], "\n")) |pos| pos + 1 else 0;

    const current_line = text[line_bounds.start..line_bounds.end];
    const prev_line = text[prev_line_start..prev_line_end];

    const swapped = std.fmt.allocPrint(Vapor.arena(.frame), "{s}\n{s}", .{ current_line, prev_line }) catch unreachable;
    const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}", .{ text[0..prev_line_start], swapped, text[line_bounds.end..] }) catch unreachable;

    text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
    new_cursor_pos = prev_line_start + (cursor_pos - line_bounds.start);
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

fn moveLineDown(editor: *JsonEditor) void {
    var text_area = editor.text_area;
    var text = editor.text;
    var buffer = editor.buffer;

    const cursor_pos = text_area.cursorPosition();
    const line_bounds = editor.getLineBounds(cursor_pos);

    // Find next line
    if (line_bounds.end >= text.len) return; // Already at bottom

    const next_line_start = line_bounds.end + 1;
    const next_line_end = std.mem.indexOfPos(u8, text, next_line_start, "\n") orelse text.len;

    const current_line = text[line_bounds.start..line_bounds.end];
    const next_line = text[next_line_start..next_line_end];

    const swapped = std.fmt.allocPrint(Vapor.arena(.frame), "{s}\n{s}", .{ next_line, current_line }) catch unreachable;
    const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}", .{ text[0..line_bounds.start], swapped, text[next_line_end..] }) catch unreachable;

    text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
    new_cursor_pos = next_line_start + next_line.len + 1 + (cursor_pos - line_bounds.start);
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

fn duplicateLine(editor: *JsonEditor) void {
    var text_area = editor.text_area;
    var text = editor.text;
    var buffer = editor.buffer;

    const cursor_pos = text_area.cursorPosition();
    const line_bounds = editor.getLineBounds(cursor_pos);
    const line = text[line_bounds.start..line_bounds.end];

    const duplicated = std.fmt.allocPrint(Vapor.arena(.frame), "{s}\n{s}", .{ line, line }) catch unreachable;
    const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}{s}", .{ text[0..line_bounds.start], duplicated, text[line_bounds.end..] }) catch unreachable;

    text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
    new_cursor_pos = line_bounds.end + 1 + (cursor_pos - line_bounds.start);
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

fn deleteLine(editor: *JsonEditor) void {
    var text_area = editor.text_area;
    var text = editor.text;
    var buffer = editor.buffer;

    const cursor_pos = text_area.cursorPosition();
    const line_bounds = editor.getLineBounds(cursor_pos);

    // Include the newline character
    const delete_end = if (line_bounds.end < text.len) line_bounds.end + 1 else line_bounds.end;

    const total = std.fmt.allocPrint(Vapor.arena(.frame), "{s}{s}", .{ text[0..line_bounds.start], text[delete_end..] }) catch unreachable;
    text = std.fmt.bufPrint(&buffer, "{s}", .{total}) catch unreachable;
    new_cursor_pos = line_bounds.start;
    editor.parse();
    Vapor.onEndCtx(updateCursorPosition, .{editor});
}

// Add a second buffer for the closing brace line
var indent_buffer2: [256]u8 = undefined;

var new_cursor_pos: usize = 0;
fn updateCursorPosition(editor: *JsonEditor) void {
    var text_area = editor.text_area;
    var text = editor.text;

    text_area.setCursorPosition(new_cursor_pos);

    // Auto-scroll to cursor position
    const cursor_pos = new_cursor_pos;
    const text_before_cursor = text[0..cursor_pos];

    // Count newlines to get current line number
    var line_count: usize = 1;
    for (text_before_cursor) |c| {
        if (c == '\n') line_count += 1;
    }

    const cursor_top = @as(f32, @floatFromInt(line_count - 1)) * line_height;
    const current_scroll: f32 = @floatFromInt(text_area.scrollTop());
    const viewport_height: f32 = container_height - 48; // Your textarea height

    const padding = line_height * 2;

    // Scroll if cursor is below visible area

    if (cursor_top > current_scroll + viewport_height - padding) {
        const new_scroll = cursor_top + padding - viewport_height;
        text_area.scrollToTop(@intFromFloat(new_scroll));
    }
    // Scroll if cursor is above visible area
    else if (cursor_top < current_scroll + padding) {
        const new_scroll = @max(0, cursor_top - padding);
        text_area.scrollToTop(@intFromFloat(new_scroll));
    }
}

fn onScroll(editor: *JsonEditor, _: *Vapor.Event) void {
    var text_area = editor.text_area;
    var binded_highlighter = editor.binded_highlighter;

    const scroll_top = text_area.scrollTop();
    binded_highlighter.scrollToTop(scroll_top);
}

fn copy(editor: *JsonEditor) void {
    Vapor.Clipboard.copy(editor.text);
    editor.copied = true;
    Vapor.registerCtxTimeout("json_editor_copy", 1000, toggleIcon, .{editor});
}

fn toggleIcon(editor: *JsonEditor) void {
    editor.copied = false;
}

pub fn render(editor: *JsonEditor) void {
    Vapor.Stack()
        .height(.px(container_height + 48 + 64))
        .width(.percent(100))
        .children({
        Box()
            .width(.percent(100))
            .padding(.horizontal(12))
            .height(.px(48))
            .background(.hex("#1e1e1e"))
            .layout(.x_between_center)
            .children({
            Text("JSON")
                .font(16, 600, .white)
                .end();
            ButtonCtx(copy, .{editor})
                .cursor(.pointer)
                .background(.transparent)
                .size(.square_px(24))
                .children({
                if (editor.copied) {
                    Vapor.Image(.{ .src = "/assets/check.svg" })
                        .end();
                } else {
                    Vapor.Image(.{ .src = "/assets/copy.svg" })
                        .end();
                }
            });
        });
        Box()
            .height(.px(container_height))
            .width(.percent(100))
            .pos(.relative)
            .layout(.center)
            .spacing(16)
            .background(.palette(.background))
            // .background(.hex("#1e1e1e"))
            .children({
            Box()
                .ref(&editor.binded_highlighter)
                .height(.px(container_height))
                .width(.percent(100))
                .padding(.horizontal(12))
                .scroll(.scroll_y())
                .border(.simple(.palette(.text_color)))
                // .background(.hex("#1e1e1e"))
                .pos(.tl(.percent(0), .percent(0), .absolute)).children({
                editor.highlighter.renderAST(editor.highlighter.root) catch unreachable;
            });
            Box()
                .background(.transparent)
                .width(.percent(100))
                .height(.percent(100))
                .padding(.horizontal(12))
                .pos(.tl(.percent(0), .percent(0), .absolute)).children({
                TextArea()
                    .ref(&editor.text_area)
                    .background(.transparent)
                    .val(&editor.text)
                    .placeholder(editor.text)
                    .width(.percent(100))
                    .outline(.none)
                    .border(.none)
                    .resize(.none)
                    .border(.simple(.transparent))
                    .height(.percent(100))
                    .whitespace(.pre)
                    .padding(.tblr(12, 12, 36, 0))
                    .caret(.{ .type = .block, .color = .palette(.text_color) })
                    .font(15, null, .transparent)
                    .fontFamily("DM Mono, monospace")
                    .onEventCtx(.scroll, onScroll, editor)
                    .onEventCtx(.input, onChange, editor)
                    .onEventCtx(.keydown, onKeyDown, editor)
                    .end();
            });
        });
        Box()
            .width(.percent(100))
            .height(.px(64))
            .scroll(.scroll_y())
            .layout(.center)
            .children({
            editor.highlighter.renderErrors() catch unreachable;
        });
    });
}
