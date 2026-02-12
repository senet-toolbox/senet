const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Button = Vapor.Button;
const TextFmt = Vapor.TextFmt;
const Text = Vapor.Text;
const IndexedDB = @import("IndexDB.zig");
const SyncEngine = @import("SyncEngine.zig");
const JSONEditor = @import("JsonEditor.zig");

pub fn get() void {
    if (SyncEngine.status != .idle) {
        SyncEngine.notification.show("Get Error", .{ .title = "SyncEngine is Offline" });
        return;
    }
    var local_buffer: [4096]u8 = undefined;
    // const result = db_getWasm(file.ptr, file.len, key.ptr, key.len, &buffer, buffer.len);
    _ = IndexedDB.get("users", SyncEngine.input_key, &local_buffer) orelse return;
    // highlighter.parse("") catch unreachable;
}

fn put() void {
    if (SyncEngine.status != .idle) {
        SyncEngine.notification.show("Put Error", .{ .title = "SyncEngine is Offline" });
        return;
    }
    SyncEngine.pending_ops.append(.{
        .op = .put,
        .key = SyncEngine.input_key,
        .execution_time = std.time.milliTimestamp(),
    }) catch |err| {
        Vapor.printErr("Failed to append to pending ops: {any}", .{err});
        return;
    };
    _ = IndexedDB.put("users", null, JSONEditor.text);
}

fn delete() void {
    if (SyncEngine.status != .idle) {
        SyncEngine.notification.show("Delete Error", .{ .title = "SyncEngine is Offline" });
        return;
    }
    Vapor.print("Deleting {s}", .{SyncEngine.input_key});
    _ = IndexedDB.delete("users", SyncEngine.input_key);
}

fn getAll() void {
    if (SyncEngine.status != .idle) {
        SyncEngine.notification.show("GetAll Error", .{ .title = "SyncEngine is Offline" });
        return;
    }
    var local_buffer: [4096]u8 = undefined;
    _ = IndexedDB.getAll("users", &local_buffer) orelse return;
}

var buffer: [4096]u8 = undefined;
export fn returnAll(response_ptr: [*:0]u8) void {
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
    Vapor.print("Formatted: {s}", .{writer.buffer[0..writer.end]});
    SyncEngine.highlighter.parse(writer.buffer[0..writer.end]) catch unreachable;
    SyncEngine.response = writer.buffer[0..writer.end];
    Vapor.lib.store("response", writer.buffer[0..writer.end]);
}

fn CrudButton(func: fn () void, text: []const u8) void {
    return Button(func)
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

fn clearJson() void {
    Vapor.lib.store("editor", "");
    JSONEditor.text = "";
    JSONEditor.parse();
}

fn clearValue() void {
    Vapor.lib.store("response", "");
    SyncEngine.highlighter.parse("") catch unreachable;
}

pub fn crud() void {
    Vapor.Stack()
        .width(.percent(100))
        .children({
        Box()
            .children({
            Text("CRUD OPS")
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
            CrudButton(get, "Get");
            CrudButton(put, "Put");
            CrudButton(delete, "Delete");
            CrudButton(clearJson, "Clear JSON");
            CrudButton(clearValue, "Clear Value");
            CrudButton(getAll, "Get All");
        });
    });
}
