const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;

const Signal = Fabric.Signal;
var local_copy_code: []const u8 = undefined;

const NewLine = struct {
    processed_text: []TextDetails = undefined,
};

const TextDetails = struct {
    color: [4]u8 = .{ 0, 0, 0, 255 },
    text: []const u8 = "",
};

// var text_color: [4]f32 = undefined;

const CodeEditor = @This();
allocator: *std.mem.Allocator = undefined,
processed_lines: std.array_list.Managed(NewLine) = undefined,
show_cpy_btn: Signal(bool) = undefined,
_id: []const u8 = undefined,

fn toggleIcon(code_editor: *CodeEditor) void {
    code_editor.show_cpy_btn.set(false);
}

fn copy(code_editor: *CodeEditor) void {
    Fabric.Clipboard.copy(local_copy_code);
    code_editor.show_cpy_btn.set(true);
    // Fabric.registerTimeout(2000, toggleIcon);
}

pub fn initWrapper(ptr: *anyopaque, allocator: *std.mem.Allocator, code: []const u8) void {
    const self: *CodeEditor = @ptrCast(@alignCast(ptr));
    self.init(allocator, code);
}

pub fn init(target: *CodeEditor, allocator: *std.mem.Allocator, code: []const u8) []const u8 {
    local_copy_code = code;
    // text_color = Fabric.Theme.getAttribute("text_color");
    target.* = CodeEditor{
        .allocator = allocator,
        .processed_lines = std.array_list.Managed(NewLine).init(allocator.*),
    };
    target.show_cpy_btn.init(false);
    target.tokenize(code) catch |err| {
        Fabric.println("Tokenize error {any}\n", .{err});
        return "";
    };
    Fabric.println("Tokenize success {s}\n", .{code});
    Fabric.println("Tokens {any}\n", .{target.processed_lines.items.len});
    for (target.processed_lines.items) |line| {
        for (line.processed_text) |word| {
            Fabric.println("{s}", .{word.text});
        }
    }
    // target._id = helpers.generateUUID(allocator.*) catch "";
    return target._id;
}

pub fn reinit(code_editor: *CodeEditor, code: []const u8) !void {
    local_copy_code = code;
    code_editor.processed_lines = std.array_list.Managed(NewLine).init(code_editor.allocator.*);
    try code_editor.tokenize(code);
    // for (code_editor.processed_lines.items) |line| {
    //     for (line.processed_text) |word| {
    //         Fabric.println("{s}", .{word.text});
    //     }
    // }
}

pub fn deinit(code_editor: *CodeEditor) void {
    for (code_editor.processed_lines.items) |line| {
        for (line.processed_text) |details| {
            if (!std.mem.eql(u8, details.text, "\n")) {
                code_editor.allocator.free(details.text);
            }
        }
        code_editor.allocator.free(line.processed_text);
        // line.processed_text.deinit();
    }
    code_editor.processed_lines.deinit();
    code_editor.show_cpy_btn.deinit();
}

pub fn render(code_editor: *CodeEditor, _: f32) void {
    Static.Box(.{
        // .id = code_editor._id,
        .width = .percent(100),
        .height = .percent(100),
        .overflow_y = .scroll,
        .show_scrollbar = false,
        .child_alignment = .{ .x = .start, .y = .start },
        // .background = .{ 40, 42, 54, 255 },
    })({
        Pure.Block(.{
            .width = .px(24),
            .height = .percent(100),
            .direction = .column,
            .child_alignment = .{ .x = .start, .y = .start },
            // .border_thickness = .all(1),
            // .border_color = .rgb(0, 0, 0),
            .padding = .tbrl(12, 12, 8, 0),
        })({
            for (0..code_editor.processed_lines.items.len) |i| {
                Pure.AllocText("{d}", .{i + 1}, .{
                    .font_size = 14,
                    // .text_color = .rgba( 255, 255, 255, 100 ),
                    // .font_weight = 500,
                    .font_family = "JetBrains Mono,Fira Code,Consolas,monospace",
                });
            }
        });
        Pure.Block(.{
            .width = .percent(100),
            .height = .percent(100),
            .direction = .column,
            .child_alignment = .{ .x = .start, .y = .start },
            .padding = .all(12),
        })({
            // Pure.CtxButton(copy, .{code_editor}, .{
            //     .position = .{ .type = .sticky, .top = .px(0), .right = .px(10) },
            //     .width = .px(22),
            //     .height = .px(22),
            //     .border_radius = .all(4),
            //     .cursor = .pointer,
            //     .float_type = .right,
            //     .transition = .{ .duration = 300 },
            //     .hover = .{ .background = Fabric.hexToRgba("#272727") },
            // })({
            //     if (!code_editor.show_cpy_btn.get()) {
            //         Pure.Icon("bi bi-clipboard", .{
            //             .id = "code-editor-clipboard",
            //             .text_color = text_color,
            //             .font_size = 14,
            //         });
            //     } else {
            //         Pure.Icon("bi bi-check", .{
            //             .id = "code-editor-check",
            //             .text_color = text_color,
            //             .font_size = 14,
            //         });
            //     }
            // });

            for (code_editor.processed_lines.items) |line| {
                Pure.FlexBox(.{
                    // .height = .px(18),
                    .white_space = .pre,
                    .child_alignment = .{ .x = .start, .y = .center },
                })({
                    for (line.processed_text) |word| {
                        Pure.Text(word.text, .{
                            .font_size = 14,
                            .font_family = "JetBrains Mono,Fira Code,Consolas,monospace",
                            .text_color = .rgba(word.color[0], word.color[1], word.color[2], word.color[3]),
                        });
                    }
                });
            }
        });
    });
}

const Declarations = enum {
    @"const",
    @"var",
    @"defer",
    @"while",
    @"fn",
    @"switch",
    @"try",
    @"if",
    @"else",
    @"pub",
    Static,
    Pure,
};

fn parseSubText(allocator: *std.mem.Allocator, processed_text: *std.array_list.Managed(TextDetails), sub_text: []const u8) !void {
    const start_op = std.mem.indexOfScalar(u8, sub_text, '"');

    if (start_op) |start| {
        const end_op = std.mem.indexOfScalar(u8, sub_text[start + 1 ..], '"');
        if (end_op != null and end_op.? != 0) {
            const end = end_op.?;
            const str_end = end + start + 2;
            // The info up to the start "
            const pre_text = sub_text[0..start];
            var text_deets = TextDetails{};
            text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}", .{pre_text});
            try processed_text.append(text_deets);

            // The info up of the string like "hello"
            const str_text = sub_text[start..str_end];
            var text_deets_str = TextDetails{};
            text_deets_str.color = Fabric.hexToRgba("#FF6637");
            text_deets_str.text = try std.fmt.allocPrint(allocator.*, "{s}", .{str_text});
            try processed_text.append(text_deets_str);

            // The info after
            const seq_text = sub_text[str_end..];
            var text_deets_seq = TextDetails{};
            text_deets_seq.text = try std.fmt.allocPrint(allocator.*, "{s}", .{seq_text});
            try processed_text.append(text_deets_seq);
            return;
        }
    }
    var text_deets = TextDetails{};
    text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}", .{sub_text});
    try processed_text.append(text_deets);
}

/// Returns the index of the first non-space (ASCII ≤ 0x20),
/// or `s.len` if the string is entirely space.
pub fn firstNonSpace(s: []const u8) usize {
    var i: usize = 0;
    while (i < s.len and std.ascii.isWhitespace(s[i])) : (i += 1) {}
    return i;
}

// Each ident is a block element itself
// this we we can use the column direction to organize everything
// every ident results in the text line having increased padding
pub fn tokenize(code_editor: *CodeEditor, text: []const u8) !void {
    const allocator: *std.mem.Allocator = code_editor.allocator;
    var depth: usize = 0;
    var first_word: bool = false;
    // Iterate throught the lines
    var line_itr = std.mem.splitSequence(u8, text, "\n");
    // Then we iterate through each word of the line
    outer: while (line_itr.next()) |line| {
        first_word = true;
        var word_count: usize = 0;
        var processed_texts: std.array_list.Managed(TextDetails) = std.array_list.Managed(TextDetails).init(allocator.*);

        if (line[0] == '\n') {
            var text_deets = TextDetails{};
            text_deets.text = "\n";
            try processed_texts.append(text_deets);
            const new_line = NewLine{
                .processed_text = try processed_texts.toOwnedSlice(),
            };
            try code_editor.processed_lines.append(new_line);
            continue :outer;
        }

        var word_itr = std.mem.tokenizeScalar(u8, line, ' ');
        const start = firstNonSpace(line);
        const spaces = std.mem.count(u8, line[0..start], " ");
        if (word_itr.peek() == null) {
            var text_deets = TextDetails{};
            text_deets.text = "\n";
            try processed_texts.append(text_deets);
            const new_line = NewLine{
                .processed_text = try processed_texts.toOwnedSlice(),
            };
            try code_editor.processed_lines.append(new_line);
            continue :outer;
        }

        if (line.len == 0) {
            var text_deets = TextDetails{};
            text_deets.text = "\n";
            try processed_texts.append(text_deets);
            const new_line = NewLine{
                .processed_text = try processed_texts.toOwnedSlice(),
            };
            try code_editor.processed_lines.append(new_line);
            continue :outer;
        }

        while (word_itr.next()) |word| {
            word_count += 1;
            var buf = std.array_list.Managed(u8).init(allocator.*);

            if (word.len > 2 and word_count == 1 and word[word.len - 1] == '{' and word_itr.peek() == null and word[word.len - 2] != '(' and word[word.len - 2] != '.') {
                // try buf.appendNTimes(' ', depth * 2);
            }

            //  this checks the last element of the word to be { and makes sure its the end
            if (std.mem.eql(u8, word, ".{") and word_itr.peek() == null and line.len == 6) {
                try buf.appendNTimes(' ', depth * 2);
                depth += 1;
            } else if (word.len >= 2 and word[word.len - 1] == '{' and word_itr.peek() == null and word[word.len - 2] != '(') {
                // try buf.appendNTimes(' ', depth * 2);
                depth += 1;
                first_word = true;
            } else if (std.mem.eql(u8, word, "{") and word_itr.peek() == null) {
                // try buf.appendNTimes(' ', depth * 2);
                depth += 1;
                first_word = true;
            }

            if (std.mem.eql(u8, word, "}") and word_itr.peek() == null) {
                depth -= 1;
                // try buf.appendNTimes(' ', depth * 2);
            } else if (std.mem.eql(u8, word, "},") and word_itr.peek() == null and line.len == 6) {
                depth -= 1;
                // try buf.appendNTimes(' ', depth * 2);
            } else if (std.mem.eql(u8, word, "},") and word_itr.peek() == null and first_word) {
                depth -= 1;
                // try buf.appendNTimes(' ', depth * 2);
            } else if (std.mem.eql(u8, word, "},") and word_itr.peek() != null and first_word) {
                depth -= 1;
                // try buf.appendNTimes(' ', depth * 2);
            }

            var text_deets = TextDetails{};
            if (word.len >= 2 and first_word and word[word.len - 1] != '{') {
                try buf.appendNTimes(' ', spaces);
            }

            // if (first_word) {
            //     try buf.appendNTimes(' ', spaces);
            // }

            if (word.len == 1 and first_word and word[0] != '{') {
                try buf.appendNTimes(' ', spaces);
            }

            const padding = try buf.toOwnedSlice();
            const result = try std.fmt.allocPrint(allocator.*, "{s}{s} ", .{ padding, word });
            allocator.free(padding);

            if (word[word.len - 1] != '{' and word[word.len - 1] != '(') {
                if (word[0] == '"' and word[word.len - 1] == ':') {
                    text_deets.color = Fabric.hexToRgba("#C1CFDA");
                    text_deets.text = result;
                    try processed_texts.append(text_deets);
                } else {
                    // Here we parse subtext
                    try parseSubText(allocator, &processed_texts, result);
                    allocator.free(result);
                }
            } else {
                text_deets.text = result;
                try processed_texts.append(text_deets);
            }
            first_word = false;
        }
        const new_line = NewLine{
            .processed_text = try processed_texts.toOwnedSlice(),
        };
        try code_editor.processed_lines.append(new_line);
    }
}
