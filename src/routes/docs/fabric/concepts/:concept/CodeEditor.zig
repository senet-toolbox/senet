const std = @import("std");
const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
// const code = @import("code/FormCode.zig").code;

const Signal = Fabric.Signal;

const NewLine = struct {
    processed_text: []TextDetails = undefined,
};

const TextDetails = struct {
    color: [4]u8 = Fabric.hexToRgba("#F6F5FB"),
    text: []const u8 = "",
};

var text_color: [4]f32 = undefined;

const CodeEditor = @This();
allocator: *std.mem.Allocator = undefined,
processed_lines: std.ArrayList(NewLine) = undefined,
show_cpy_btn: Signal(bool) = undefined,
local_copy_code: []const u8 = undefined,

fn toggleIcon(code_editor: *CodeEditor) void {
    code_editor.show_cpy_btn.set(false);
}

fn copy(code_editor: *CodeEditor) void {
    Fabric.println("{s}", .{code_editor.local_copy_code});
    Fabric.Clipboard.copy(code_editor.local_copy_code);
    code_editor.show_cpy_btn.set(true);
    Fabric.registerCtxTimeout(500, toggleIcon, .{code_editor});
}

pub fn initWrapper(ptr: *anyopaque, allocator: *std.mem.Allocator, code: []const u8) void {
    const self: *CodeEditor = @ptrCast(@alignCast(ptr));
    self.init(allocator, code);
}

pub fn init(target: *CodeEditor, allocator: *std.mem.Allocator, code: []const u8) void {
    target.* = CodeEditor{
        .allocator = allocator,
        .processed_lines = std.ArrayList(NewLine).init(allocator.*),
    };
    target.show_cpy_btn.init(false);
    target.local_copy_code = code;
    target.tokenize(code) catch |err| {
        Fabric.println("Tokenize error {any}\n", .{err});
        return;
    };
}

pub fn reinit(code_editor: *CodeEditor, code: []const u8) !void {
    code_editor.local_copy_code = code;
    code_editor.processed_lines = std.ArrayList(NewLine).init(code_editor.allocator.*);
    try code_editor.tokenize(code);
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

pub inline fn Code() fn (void) void {
    const elem_decl = Fabric.ElementDecl{
        .dynamic = .static,
        .elem_type = .Code,
    };
    _ = Fabric.LifeCycle.open(elem_decl);
    Fabric.LifeCycle.configure(elem_decl);
    return Fabric.LifeCycle.close;
}

pub fn render(code_editor: *CodeEditor, _: f32) void {
    Static.Block(.{
        .width = .percent(100),
        .height = .percent(100),
        .overflow_y = .scroll,
        .show_scrollbar = false,
        .direction = .column,
        .child_alignment = .{ .x = .start, .y = .start },
        .background = .rgb(40, 42, 54),
        .border_radius = .all(8),
        .padding = .{ .top = 10, .bottom = 10 },
    })({
        Static.FlexBox(.{
            .child_alignment = .end_center,
            .width = .percent(100),
            .padding = .horizontal(12),
        })({
            Static.CtxButton(copy, .{code_editor}, .{
                .width = .px(22),
                .height = .px(22),
                .border_radius = .all(4),
                .display = .Center,
                .cursor = .pointer,
                .transition = .{ .duration = 300 },
                .hover = .{ .background = .hex("#2D303E") },
            })({
                if (!code_editor.show_cpy_btn.get()) {
                    Pure.Icon("bi bi-clipboard", .{
                        .font_size = 16,
                        .text_color = .hex("#cccccc"),
                        .transition = .{ .duration = 300 },
                        .hover = .{ .text_color  = .hex("#ffffff") },
                    });
                } else {
                    Pure.Icon("bi bi-check", .{
                        .font_size = 16,
                        .text_color = .hex("#cccccc"),
                        .hover = .{ .text_color = .hex("#ffffff") },
                    });
                }
            });
        });
        Code()({
            for (code_editor.processed_lines.items) |line| {
                Static.FlexBox(.{
                    .height = .px(20),
                    .white_space = .pre,
                    .child_alignment = .start_center,
                    .padding = .{
                        .left = 30,
                    },
                })({
                    for (line.processed_text) |word| {
                        Static.Text(word.text, .{
                            .font_size = 14,
                            .font_weight = 500,
                            .font_family = "JetBrains Mono,Fira Code,Consolas,monospace",
                            .text_color = .rgb(word.color[0], word.color[1], word.color[2]),
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

fn parseSubText(allocator: *std.mem.Allocator, processed_text: *std.ArrayList(TextDetails), sub_text: []const u8) !void {
    var period_itr = std.mem.tokenizeScalar(u8, sub_text, '.');
    const count = std.mem.count(u8, sub_text, ".");
    var period_counter: usize = 0;
    const count_bracket_open = std.mem.count(u8, sub_text, "(");
    const count_bracket_closed = std.mem.count(u8, sub_text, ")");
    const is_string = std.mem.count(u8, sub_text, "\"");
    // Here we chekc if the line has an open bracket and a period
    // Signal(bool).init(false, . = 1 ( = 2
    // Sl-1: Signal(bool)
    // Sl-2: init(false,
    if (count > 0 and count_bracket_open > 0) {
        while (period_itr.next()) |sub_slice| {
            var text_deets = TextDetails{};
            if (sub_slice[0] == '@') {
                text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}", .{sub_text});
                try processed_text.append(text_deets);
                return;
            }
            const includes_bracket = std.mem.indexOf(u8, sub_slice, "(");
            const includes_close_bracket = std.mem.indexOf(u8, sub_slice, ")");
            // Here we check if the subslice contains the open bracket
            if (includes_bracket != null and sub_slice[0] != '(' and includes_close_bracket != null and count_bracket_open == count_bracket_closed) {
                var split = std.mem.splitScalar(u8, sub_slice, '(');
                text_deets.color = Fabric.hexToRgba("#8D8D8D");

                if (period_itr.peek() == null and period_counter < count) {
                    text_deets.text = try std.fmt.allocPrint(allocator.*, ".{s}", .{split.next().?});
                } else {
                    text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}", .{split.next().?});
                }
                var text_deets_second = TextDetails{};
                const result_sec = try std.fmt.allocPrint(allocator.*, "({s}", .{split.next().?});
                text_deets_second.text = result_sec;
                try processed_text.append(text_deets);
                try processed_text.append(text_deets_second);
            } else if (period_itr.peek() == null and count > period_counter) {
                // Here we check if the counter inlcudes more periods if there is only one
                // we append the subsilce with a period
                text_deets.text = try std.fmt.allocPrint(allocator.*, ".{s}", .{sub_slice});
                try processed_text.append(text_deets);
                period_counter += 1;
            } else if (count > period_counter) {
                text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}.", .{sub_slice});
                try processed_text.append(text_deets);
                period_counter += 1;
            } else {
                text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}", .{sub_slice});
                try processed_text.append(text_deets);
            }
        }
    } else if (count > 0 and is_string == 0 and count_bracket_open == 0 and count_bracket_closed == 0) {
        while (period_itr.next()) |sub_slice| {
            var text_deets = TextDetails{};
            if (period_itr.peek() == null) {
                if (period_itr.peek() == null and period_counter < count) {
                    text_deets.text = try std.fmt.allocPrint(allocator.*, ".{s}", .{sub_slice});
                    period_counter += 1;
                } else {
                    text_deets.color = .{ 184, 187, 221, 255 };
                    text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}", .{sub_slice});
                }
            } else {
                period_counter += 1;
                text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}.", .{sub_slice});
            }
            try processed_text.append(text_deets);
        }
    } else {
        var text_deets = TextDetails{};
        if (period_itr.peek() == null and period_counter < count) {
            text_deets.text = try std.fmt.allocPrint(allocator.*, ".{s}", .{sub_text});
            period_counter += 1;
        } else {
            text_deets.text = try std.fmt.allocPrint(allocator.*, "{s}", .{sub_text});
        }
        try processed_text.append(text_deets);
    }
}

// Each ident is a block element itself
// this we we can use the column direction to organize everything
// every ident results in the text line having increased padding
pub fn tokenize(code_editor: *CodeEditor, text: []const u8) !void {
    const allocator: *std.mem.Allocator = code_editor.allocator;
    var depth: i32 = 0;
    var first_word: bool = false;
    var is_comment: bool = false;
    // Iterate throught the lines
    var line_itr = std.mem.splitSequence(u8, text, "\n");
    // Then we iterate through each word of the line
    outer: while (line_itr.next()) |line| {
        first_word = true;
        // var word_count: usize = 0;
        var processed_texts: std.ArrayList(TextDetails) = std.ArrayList(TextDetails).init(allocator.*);
        var word_itr = std.mem.tokenizeScalar(u8, line, ' ');
        //
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
            if (std.mem.eql(u8, word, "//") or std.mem.eql(u8, word, "///")) {
                is_comment = true;
            }
            var text_deets = TextDetails{};

            var buf = std.ArrayList(u8).init(allocator.*);
            if (std.mem.indexOf(u8, word, "}") != null) {
                depth -= 1;
            }

            if (first_word and depth > 0) {
                try buf.appendNTimes(' ', @intCast(depth * 4));
            }
            first_word = false;
            const padding = try buf.toOwnedSlice();
            const result = try std.fmt.allocPrint(allocator.*, "{s}{s} ", .{ padding, word });
            allocator.free(padding);
            const is_decl = std.meta.stringToEnum(Declarations, word);
            if (!is_comment) {
                if (is_decl) |decl| {
                    switch (decl) {
                        Declarations.@"const" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"var" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"defer" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"while" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"fn" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"switch" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"try" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"if" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"else" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.@"pub" => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.Static => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                        Declarations.Pure => {
                            text_deets.color = Fabric.hexToRgba("#E5FF54");
                        },
                    }
                    text_deets.text = result;
                    try processed_texts.append(text_deets);
                } else if (word[word.len - 1] != '{' and word[word.len - 1] != '(') {
                    // Here we parse subtext
                    try parseSubText(allocator, &processed_texts, result);
                    allocator.free(result);
                } else {
                    text_deets.text = result;
                    try processed_texts.append(text_deets);
                }
            } else {
                text_deets.text = result;
                text_deets.color = Fabric.hexToRgba("#88859D");
                try processed_texts.append(text_deets);
            }
        }
        const new_line = NewLine{
            .processed_text = try processed_texts.toOwnedSlice(),
        };
        try code_editor.processed_lines.append(new_line);

        is_comment = false;
        depth += @intCast(std.mem.count(u8, line, "{"));
    }
}
