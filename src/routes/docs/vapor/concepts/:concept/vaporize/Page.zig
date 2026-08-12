const std = @import("std");
const Vapor = @import("vapor");
const Compiler = @import("../../../../../../main.zig");
const Fetch = Vapor.Fetch.Fetch;
const Loader = @import("components").Loader;
const Error = @import("components").Error;
const Content = @import("../../../../../../components/Content.zig");
const reinit = @import("../../../../../../components/DocNavbar.zig").reinit;
const Vaporize = @import("vaporize");
const Stack = Vapor.Stack;
const Text = Vapor.Text;
// const ComplexForm = @import("../../../../../VaporizeComplexForm.zig");

var markdown: Compiler.vaporize.MarkDown(.{
    .{ .tag = "form", .function = LoginForm },
    .{ .tag = "text_area", .function = text_area },
    .{ .tag = "realtime_markdown", .function = RealtimeMarkdown },
    .{ .tag = "complex_form", .function = ComplexForm },
    .{ .tag = "simple_form", .function = SimpleFormComponent },
}) = .{};

var page: []const u8 = "";
var f: ?*Fetch = null;
var content: Content.new("") = undefined;

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

const SimpleForm = struct {
    email: []const u8 = "",
    password: []const u8 = "",
};

const CheckoutForm = struct {
    account: struct {
        email: []const u8 = "",
        password: []const u8 = "",
        contact: struct {
            phone: []const u8 = "",
        } = .{},
    } = .{},

    shipping_details: struct {
        shipping_same_as_billing: Vaporize.Condition(CheckoutForm) = .{
            .callback = sameAsBilling,
            .target_field = "shipping",
        },
    } = .{},

    shipping: struct {
        address: []const u8 = "",
        city: []const u8 = "",
        // ...
    } = .{},
};

fn sameAsBilling(_: *CheckoutForm) void {
    // Toggle shipping section visibility
}

var complex_form: Vaporize.Form(CheckoutForm) = .{};

var simple_form: Vaporize.Form(SimpleForm) = .{};

fn SimpleFormComponent() void {
    Stack()
        .direction(.column).layout(.top_center).width(.full).height(.percent(50)).children({
        Stack()
            .width(.percent(100)).layout(.center).spacing(16)
            .background(.palette(.background))
            .border(.simple(.palette(.text_color)))
            .children({
            Stack()
                .width(.percent(100)).layout(.center).spacing(16).padding(.all(20))
                .children({
                simple_form.render();
            });
        });
    });
}

var new_form: Vaporize.Form(Form) = .{
    // .on_submit = onSubmit,
};

fn onSubmit(form: Form) void {
    Vapor.alert("Form submitted {s}", .{form.email});
}

pub fn init() void {
    // markdown.compile(vaporize_page) catch unreachable;
    f = Fetch.fetch("/documents/vaporize_page.md", .{ .method = .GET });
    f.?.handle(handlePage, .{});
    content.init();
    generated_markdown.compile(table) catch |err| {
        Vapor.printErr("Failed to compile markdown: {any} invalid input", .{err});
        return;
    };
    // ComplexForm.init();
    simple_form.compile() catch |err| {
        Vapor.printErr("Failed to compile form: {any}", .{err});
        return;
    };
    new_form.compile() catch unreachable;
    complex_form.compile() catch unreachable;
}

fn handlePage(resp: Vapor.Fetch.Result) void {
    switch (resp) {
        .ok => |data| {
            content.content_text = data.body;
            page = data.body;
            markdown.compile(page) catch |err| {
                std.log.err("Failed to compile markdown: {any}", .{err});
                return;
            };
        },
        .err => |err| {
            std.log.err("Failed to fetch: {s}", .{err.message});
            return;
        },
    }
    Vapor.onLayout(reinit, .{});
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

var table: []const u8 =
    \\| Header 1 | Header 2 | Header 3 |
    \\|----------|----------|----------|
    \\| cell 1   | cell 2   | cell 3   |
    \\| cell 4   | cell 5   | cell 6   |
;

fn text_area() void {
    Vapor.TextArea()
        .val(&table)
        .height(.px(128))
        .shadow(.card(.transparentizeHex(.palette(.tint), 0.3)))
        .border(.simple(.transparentizeHex(.palette(.tint), 0.1)))
        .outline(.none, null)
        .layer(.grid(4, 1, .palette(.grid_color)))
        .spacing(4)
        .fontFamily("IBM Plex Mono,monospace")
        .font(14, null, .palette(.text_color))
        .padding(.all(8))
        .onChange(onChange, .{})
        .end();
}

pub fn LoginForm() void {
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
                    .border(.bottom(1, .palette(.text_color)))
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

fn ComplexForm() void {
    Stack()
        .direction(.column).layout(.top_center).width(.full).height(.percent(50)).children({
        Stack()
            .width(.percent(80)).layout(.center).padding(.all(16))
            .children({
            Stack()
                .width(.percent(100))
                .children({
                Text("Checkout").font(32, 900, .palette(.text_color))
                    .padding(.horizontal(12))
                    .width(.percent(100))
                    .end();
                Stack()
                    .width(.percent(100)).layout(.center).spacing(16).padding(.horizontal(20))
                    .children({
                    complex_form.render();
                    // ComplexForm.LoginComponent();
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
    if (f) |h| {
        switch (h.state()) {
            .idle => {},
            .loading => {
                Loader.render();
            },
            .ok => {
                content.content(component);
            },
            .err => {
                Error.render();
            },
        }
    }
}
