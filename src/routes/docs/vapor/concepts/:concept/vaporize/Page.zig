const Vapor = @import("vapor");
const Compiler = @import("../../../../../../main.zig");
const Content = @import("../../../../../../components/Content.zig");
const Vaporize = @import("vaporize");
const Stack = Vapor.Stack;
const Text = Vapor.Text;

var markdown: Compiler.vaporize.MarkDown(.{
    .{ .tag = "form", .function = form },
    .{ .tag = "text_area", .function = text_area },
    .{ .tag = "realtime_markdown", .function = RealtimeMarkdown },
}) = .{};

var page: []const u8 = "";
var content: Content.new("") = undefined;
var markdown_loaded: bool = false;

var generated_markdown: Compiler.vaporize.MarkDown(.{}) = .{};

const Form = struct {
    username: []const u8 = "",
    email: []const u8 = "",
    phonenumber: []const u8 = "",
    password: []const u8 = "",
    age: u32 = 0,

    pub var __validations = .{
        .username = Vaporize.Validation{ .min = 3, .max = 10, .err = "Username must be between 3 and 10 characters" },
        .email = Vaporize.Validation{ .field_type = .email },
        .phonenumber = Vaporize.Validation{ .field_type = .telephone },
        .password = Vaporize.Validation{ .field_type = .password },
        .age = Vaporize.Validation{
            .min_value = 18,
            .max_value = 120,
            .err = "Age must be between 18 and 120",
        },
    };
};

var new_form: Compiler.vaporize.Form(Form) = undefined;

pub fn init() void {
    // markdown.compile(vaporize_page) catch unreachable;
    Vapor.Kit.fetch("/src/routes/docs/vapor/concepts/:concept/vaporize/vaporize_page.md", handlePage, .{ .method = .GET });
    generated_markdown.compile("") catch |err| {
        Vapor.printErr("Failed to compile markdown: {any} invalid input", .{err});
        return;
    };
    new_form.compile() catch unreachable;
}

fn handlePage(resp: Vapor.Kit.Response) void {
    switch (resp) {
        .ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(page) catch |err| {
                Vapor.printErr("Failed to compile markdown: {any}", .{err});
                return;
            };
            markdown_loaded = true;
        },
        .err => |err| {
            Vapor.printErr("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.cycle();
}

fn onChange(evt: *Vapor.Event) void {
    generated_markdown.compile(evt.text()) catch |err| {
        Vapor.printErr("Failed to compile markdown: {any} invalid input", .{err});
        return;
    };
}

fn RealtimeMarkdown() void {
    Stack()
        .layout(.center)
        .margin(.tb(12, 32))
    .padding(.all(8))
        .width(.percent(100))
        .border(.simple(.transparentizeHex(.palette(.tint), 0.1)))
        .children({
        generated_markdown.render() catch |err| {
            Vapor.printErr("Failed to render markdown: {any}", .{err});
            return;
        };
    });
}

fn text_area() void {
    Vapor.TextArea()
        .height(.px(128))
        .shadow(.card(.transparentizeHex(.palette(.tint), 0.3)))
        .border(.simple(.transparentizeHex(.palette(.tint), 0.1)))
        .outline(.none)
        .layer(.grid(4, 1, .palette(.grid_color)))
        .spacing(4)
        .fontFamily("IBM Plex Mono,monospace")
        .font(14, null, .palette(.text_color))
        .padding(.all(8))
        .onChange(onChange)
        .end();
}

pub fn form() void {
    Stack()
        .direction(.column).layout(.top_center).width(.full).height(.percent(50)).children({
        Stack()
            .width(.percent(80)).layout(.center).padding(.all(16))
            .border(.sharp(.tblr(1, 0, 0, 1), .palette(.text_color)))
            .children({
            Stack()
                .width(.percent(100)).layout(.center).spacing(16)
                .background(.palette(.background))
                .border(.simple(.palette(.text_color)))
                .children({
                Text("SIGN UP").font(84, 900, .palette(.text_color))
                    .padding(.horizontal(12))
                    .border(.bottom(.palette(.text_color)))
                    .layout(.center)
                    .width(.percent(100))
                    .end();
                Stack()
                    .width(.percent(100)).layout(.center).spacing(16).padding(.all(20))
                    .children({
                    new_form.render();
                });
            });
        });
    });
}

fn component() void {
    markdown.render() catch unreachable;
}

// Render
pub fn render() void {
    if (!markdown_loaded) return;
    content.content(component);
}

