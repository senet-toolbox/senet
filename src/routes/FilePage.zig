const Vapor = @import("vapor");
const std = @import("std");
const Box = Vapor.Box;
const Text = Vapor.Text;
const TextField = Vapor.TextField;
const RedirectLink = Vapor.RedirectLink;
const Image = Vapor.Image;
const Button = Vapor.Button;
const Icon = Vapor.Icon;

var file_reader: Vapor.FileReader = undefined;
var image_src: []const u8 = "";
var draggable: Vapor.Draggable = .{
    .on_drag_start = onDragStart,
    .on_drag = onDrag,
};
var width: f32 = 420;
var height: f32 = 420;
var lastX: f32 = 0;
var lastY: f32 = 0;
var key_down_listener: u32 = 0;
var key_up_listener: u32 = 0;
pub fn init() void {
    key_down_listener = Vapor.lib.eventListener(.keydown, shift) orelse unreachable;
    key_up_listener = Vapor.lib.eventListener(.keyup, unshift) orelse unreachable;
    Vapor.Page(.{ .route = "/file" }, render, null);
}

pub fn removeListener() void {
    _ = Vapor.removeGlobalListener(key_down_listener);
}

var shifted: bool = false;
pub fn shift(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Shift")) {
        shifted = true;
    }
}

pub fn unshift(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Shift")) {
        shifted = false;
    }
}

fn onDragStart(_: *Vapor.Draggable, evt: *Vapor.Event) void {
    lastX = evt.clientX();
    lastY = evt.clientY();
}

var last_time: i64 = 0;
pub fn throttle() bool {
    const current_time = std.time.milliTimestamp();
    if (current_time - last_time < 16) {
        return true;
    }
    last_time = current_time;
    return false;
}

fn onDrag(_: *Vapor.Draggable, evt: *Vapor.Event) void {
    if (throttle()) return;
    const deltaX = evt.clientX() - lastX;
    const deltaY = evt.clientY() - lastY;

    if (shifted) {
        // 1. Calculate the current Aspect Ratio
        // Ensure you cast to float if these are integers
        const aspectRatio = width / height;

        // 2. Check which axis has the greater movement (Dominant Axis)
        // We use @abs because the movement could be negative (shrinking)
        if (@abs(deltaX) > @abs(deltaY)) {
            // Mouse is moving mostly horizontal
            width += deltaX;
            height = width / aspectRatio;
        } else {
            // Mouse is moving mostly vertical
            height += deltaY;
            width = height * aspectRatio;
        }
    } else {
        width += deltaX;
        height += deltaY;
    }

    lastX = evt.clientX();
    lastY = evt.clientY();
    Vapor.cycle();
}

fn upload(evt: *Vapor.Event) void {
    Vapor.print("Upload", .{});
    file_reader = .init(evt);

    const info = file_reader.fileInfo(0) catch |err| {
        Vapor.printErr("Failed to get file info: {any}", .{err});
        return;
    };

    Vapor.print("File: {s}", .{info.type});

    image_src = file_reader.createURLfromFile(0) catch |err| {
        Vapor.printErr("Failed to create object URL: {any}", .{err});
        return;
    };
    Vapor.print("Image URL: {s}", .{image_src});
}

pub fn download() void {
    Vapor.FileReader.downloadFile("index.html", "<div>Hello World</div>", .@"text/html");
}

fn onFileRead(text: []const u8) void {
    Vapor.print("File read: {s}", .{text});
}

fn render() void {
    Box().children({
        Text("File Page").font(72, 700, .palette(.text_color)).end();
        TextField(.file)
            .onChange(upload)
            .placeholder("File Path").end();
    });
    Box()
        .pos(.relative)
        .class("box")
        .width(.px(width))
        .height(.px(height))
        .border(.simple(.black))
        .layout(.center)
        .children({
        if (image_src.len > 0) {
            Image(.{ .src = image_src })
                // .class("image")
                .width(.percent(100))
                .height(.percent(100))
                .end();
        }
        Box()
            .pos(.br(.px(-24), .px(-24), .absolute))
            .height(.px(24))
            .width(.px(24))
            .createDraggable(&draggable)
            .layout(.center)
            .cursor(.pointer)
            .children({
            Icon(.grip_horizontal)
                .font(20, 700, .black)
                .end();
        });
    });
    Button(.{ .on_press = download }).children({
        Text("Download").end();
    });
}
