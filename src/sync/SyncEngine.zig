const Vapor = @import("vapor");
const Box = Vapor.Box;
const Button = Vapor.Button;
const TextFmt = Vapor.TextFmt;
const Text = Vapor.Text;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const JSONEditor = @import("JsonEditor.zig");
const Vaporize = @import("vaporize");
const SyntaxHighlighter = Vaporize.SyntaxHighlighter;
const IndexedDB = @import("IndexDB.zig");
const JSONEditor1 = @import("JsonEditor1.zig");
const std = @import("std");
const TextField = Vapor.TextField;
const crud = @import("Crud.zig").crud;
const Icon = Vapor.Icon;
const Animation = Vapor.Animation;

const PendingOp = struct {
    op: enum { get, put, delete, clear, openIndexDB, queueCreateObjectStore },
    key: []const u8,
    execution_time: i64,
};

const slide_in: Animation = Animation.init("slideAndFadeIn")
    .prop(.translateY, -20, 0)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const slide_out: Animation = Animation.init("slideAndFadeOut")
    .prop(.translateY, 0, -20)
    .prop(.opacity, 1, 0)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const Error = struct {
    value: []const u8,
};

const SyncEngine = @This();
pub var pending_ops: Vapor.Array(PendingOp) = undefined;
pub var errors: Vapor.Array(Error) = undefined;

const Notification = struct {
    pub var show_notification: bool = false;

    var current_text: []const u8 = "";
    var current_options: NotificationOptions = undefined;
    pub const NotificationOptions = struct {
        title: []const u8,
    };

    pub fn show(_: *Notification, text: []const u8, options: NotificationOptions) void {
        if (options.title.len > 0) {
            show_notification = true;
            Vapor.print("{s}: {s}", .{ options.title, text });
            current_text = text;
            current_options = options;
            Vapor.registerCtxTimeout("sync_notification", 1000, toggle, .{{}});
        }
    }

    fn toggle(_: void) void {
        show_notification = false;
    }

    pub fn render() void {
        if (show_notification) {
            Box()
                .pos(.tr(.px(20), .px(18), .absolute))
                .border(.round(.transparent, .all(8)))
                .animationEnter(&slide_in)
                .animationExit(&slide_out)
                .padding(.tblr(8, 8, 8, 8))
                .width(.percent(20))
                .background(.palette(.text_color))
                .shadow(.{
                    .blur = 6,
                    .color = .transparentizeHex(.palette(.text_color), 0.2),
                    .top = 2,
                    .spread = 2,
                })
                .direction(.column)
                .spacing(8)
                .children({
                TextFmt("{s}: {s}", .{ current_options.title, current_text })
                    .font(16, 300, .white)
                    .fontFamily("system-ui, sans-serif")
                    .end();
            });
        }
    }
};

pub var notification: Notification = undefined;

pub var response: []const u8 = undefined;
var file: []const u8 = "mydata.db";

const Status = enum { idle, syncing, offline };
pub var status: Status = .offline;

pub var highlighter: SyntaxHighlighter = undefined;
var json_editor: JSONEditor1 = undefined;
pub fn init() void {
    response = Vapor.lib.getStore([]const u8, "response") orelse "";
    highlighter = SyntaxHighlighter.init(Vapor.arena(.persist));
    highlighter.parse(response) catch unreachable;

    JSONEditor.text = Vapor.lib.getStore([]const u8, "editor") orelse "";
    JSONEditor.init();
    JSONEditor.on_change = setLocalStorage;

    pending_ops = Vapor.array(PendingOp, .persist);
    errors = Vapor.array(Error, .persist);
    errors.append(.{ .value = "Error" }) catch unreachable;
    slide_in.build();
    slide_out.build();
}

fn setLocalStorage(_: *Vapor.Event) void {
    const value = JSONEditor.text;
    Vapor.lib.store("editor", value);
}

// These are provided by the host, which bridges to the cache module
extern "env" fn db_getWasm(file_ptr: [*]const u8, file_len: usize, key_ptr: [*]const u8, key_len: usize, out_ptr: [*]u8, out_max: usize) i32;
extern "env" fn db_setWasm(file_ptr: [*]const u8, file_len: usize, key_ptr: [*]const u8, key_len: usize, val_ptr: [*]const u8, val_len: usize) i32;
extern "env" fn db_clearWasm() i32;
extern "env" fn db_openWasm(filename_ptr: [*]const u8, filename_len: usize) i32;

fn openIndexDB() void {
    // Open database
    if (!IndexedDB.open("myapp", 3)) return;
    status = .idle;
}

fn queueCreateObjectStore() void {
    // Queue object store creation (before open)
    _ = IndexedDB.queueCreateObjectStore("users", "id", true);
}

pub fn open(filename: []const u8) bool {
    file = filename;
    return db_openWasm(filename.ptr, filename.len) == 0;
}

pub var input_key: []const u8 = "";
var buffer: [4096]u8 = undefined;
export fn updateResponse(response_ptr: [*:0]u8) void {
    const allocator = Vapor.arena(.persist); // or whatever allocator you're using
    const value = std.mem.span(response_ptr);
    const parsed = std.json.parseFromSlice(std.json.Value, allocator, value, .{}) catch |err| {
        Vapor.printErr("Failed to parse JSON: {any}", .{err});
        return;
    };
    var writer = std.Io.Writer.fixed(&buffer);
    const format = std.json.fmt(parsed.value, .{
        .whitespace = .indent_4,
    });
    format.format(&writer) catch unreachable;
    highlighter.parse(writer.buffer[0..writer.end]) catch unreachable;
    response = writer.buffer[0..writer.end];
}

export fn addError(ptr: [*:0]u8) void {
    const error_value = std.mem.span(ptr);
    errors.append(.{ .value = error_value }) catch |err| {
        Vapor.printErr("Failed to append to errors: {any}", .{err});
        return;
    };
}

pub fn set(key: []const u8, value: []const u8) bool {
    return db_setWasm(file.ptr, file.len, key.ptr, key.len, value.ptr, value.len) == 0;
}

export fn do_sync() i32 {
    // Example sync operation
    const yes = set("last_sync", "2024-01-15T10:30:00Z");
    if (!yes) return -1;
    return 0;
}

fn sendData() void {
    _ = SyncEngine.set("last_sync", "2024-01-15T10:30:00Z");
}

fn getData() void {
    // const value = SyncEngine.get("last_sync") orelse return;
    // highlighter.parse(value) catch unreachable;
}

fn openDB() void {
    _ = SyncEngine.open("mydata.db");
}

fn clearData() void {
    _ = db_clearWasm();
}

fn CrudButton(func: fn () void, text: []const u8) void {
    return Button(.{ .on_press = func })
        .background(.palette(.background))
        .border(.simple(.black))
        .padding(.all(8))
        .width(.px(256))
        .hoverScale()
        .children({
        Text(text)
            .font(16, 300, .palette(.text_color))
            .fontFamily("IBM Plex Sans")
            .end();
    });
}

var copied: bool = false;
fn copyValue() void {
    Vapor.print("Copying {s}", .{response});
    Vapor.Clipboard.copy(response);
    copied = true;
    Vapor.registerCtxTimeout("response_copy", 1000, toggleIcon, .{{}});
}

fn toggleIcon(_: void) void {
    copied = false;
}

fn PendingOps() void {
    TextFmt("Pending Ops {d}", .{pending_ops.items.len})
        .font(16, 600, .palette(.text_color))
        .end();
}

fn ErrorOps() void {
    Stack()
        .pos(.tr(.px(64), .percent(0), .absolute))
        .height(.fit)
        .padding(.horizontal(12))
        .layout(.right_center)
        .spacing(8)
        .children({
        Box()
            // .width(.percent(100))
            .children({
            Text("Errors")
                .font(24, 600, .palette(.text_color))
                .end();
        });
        for (errors.items) |err| {
            Box()
                .width(.fit)
                .height(.px(32))
                .spacing(8)
                .padding(.tblr(8, 8, 12, 12))
                .border(.round(.palette(.text_color), .all(4)))
                .layout(.right_center)
                .background(.palette(.danger))
                .children({
                Icon(.bug)
                    .font(16, 300, .white)
                    .end();
                TextFmt("{s}", .{err.value})
                    .font(16, 300, .white)
                    .end();
            });
        }
    });
}

pub fn CrudRender() void {
    Stack().width(.percent(100))
        .padding(.horizontal(12))
        .height(.percent(100))
        .width(.percent(100))
        .children({
        Box()
            .width(.percent(100))
            .height(.px(64))
            .layout(.x_between_center)
            .children({
            Box()
                .width(.percent(20))
                .height(.px(64))
                .layout(.left_center)
                .spacing(8)
                .children({
                Text("SYNC ENGINE")
                    .font(24, 600, .palette(.text_color))
                    .end();
                Box()
                    .padding(.tblr(2, 2, 4, 4))
                    // .border(.simple(.palette(.text_color)))
                    .children({
                    TextFmt("{any}", .{status})
                        .font(24, 600, .hex("#243D5B"))
                        .end();
                });
            });
            PendingOps();
            // ErrorOps();
            Notification.render();
        });
        Center().size(.full)
            .spacing(32)
            .children({
            Stack()
                .layout(.top_center)
                .spacing(16)
                .size(.hw_percent(80, 40)).children({
                Stack()
                    .height(.fit)
                    .width(.percent(100))
                    .children({
                    Stack()
                        .width(.percent(100))
                        .mb(8)
                        .children({
                        Box()
                            .width(.percent(100))
                            .padding(.horizontal(12))
                            .height(.px(48))
                            .background(.hex("#1e1e1e"))
                            .layout(.left_center)
                            .children({
                            Vapor.Label("Key")
                                .font(16, 700, .white)
                                .end();
                        });
                        TextField(.string).bind(&input_key)
                            .width(.percent(100))
                            .placeholder("Enter key")
                            .fontFamily("IBM Plex Sans")
                            .border(.simple(.palette(.text_color)))
                            .outline(.none)
                            .font(16, 300, .palette(.text_color))
                            .padding(.all(8))
                            .end();
                    });

                    JSONEditor.render();
                });
                crud();
                Vapor.Stack()
                    .width(.percent(100))
                    .children({
                    Box()
                        .children({
                        Text("DB OPS")
                            .font(16, 600, .palette(.text_color))
                            .end();
                    });
                    Box()
                        .layer(.grid(14, 1, .palette(.grid_color)))
                        .border(.simple(.black))
                        .padding(.all(16))
                        .width(.percent(100))
                        .spacing(8)
                        .height(.fit)
                        .layout(.x_even_center)
                        .children({
                        CrudButton(clearData, "Clear data");
                        CrudButton(openIndexDB, "Open IndexDB");
                        CrudButton(queueCreateObjectStore, "Queue Object Store");
                    });
                });
            });
            Stack()
                .width(.percent(40))
                .height(.percent(80))
                .children({
                Box()
                    .width(.percent(100))
                    .padding(.horizontal(12))
                    .height(.px(48))
                    .background(.hex("#1e1e1e"))
                    .layout(.x_between_center)
                    .children({
                    Text("Response")
                        .font(16, 600, .white)
                        .end();
                    Vapor.Button(.{ .on_press = copyValue })
                        .cursor(.pointer)
                        .background(.transparent)
                        .size(.square_px(24))
                        .children({
                        if (copied) {
                            Vapor.Image(.{ .src = "/assets/check.svg" })
                                .end();
                        } else {
                            Vapor.Image(.{ .src = "/assets/copy.svg" })
                                .end();
                        }
                    });
                });

                Box()
                    .height(.percent(80))
                    .scroll(.scroll_y())
                    .padding(.horizontal(12))
                    .border(.simple(.palette(.text_color)))
                    .children({
                    highlighter.renderAST(highlighter.root) catch unreachable;
                });
            });
        });
    });
}
