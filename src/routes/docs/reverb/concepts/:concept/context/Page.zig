const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

var code_editor: CodeEditor = undefined;
// Initialization
pub fn init() void {
    // code_editor.init(&Fabric.lib.allocator_global, @embedFile("main_sample.zig"));
}

// Deinitialization
pub fn deinit() void {}

// Render
pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 8,
        .direction = .column,
    })({
        Static.Text("Context", .{
            .font_size = 42,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text(
            \\The Context struct, holds all the information about the request and response. 
        , .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Static.Text(
            \\It is passed into every handler function, and is mutable by default.  
            \\Context values should not be used outside the handler function or taken reference to after the handler function returns.
            \\Context works similarly to the Context struct in Echo, but is a bit more flexible.
        , .{
            .font_size = 18,
            .margin = .{ .top = 8 },
        });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>fn handler(ctx: *Context) anyerror!void {}</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>STRING([]const u8)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>STRING</code> function takes a string, response, such as "SUCCESS", this will return the text data to the client.
            \\We can pass any string data we would like.
        , .{
            .font_size = 18,
        });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.STRING("SUCCESS")</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>HTML(.html)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>HTML</code> function takes a html document, and sends this to the client.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.HTML(index.html)</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>JSON([]const u8)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>JSON</code> function takes a json string, and sends this to the client.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.HTML(""{"name": "vic", "age": 32}"")</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>RAW([]const u8)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>RAW</code> function takes an http response string, and sends this to the client.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.RAW("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<h1>Hello World</h1>")</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>ERROR([]const u8)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>ERROR</code> function takes an http response code and a message, and sends this to the client.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.ERROR(404, "Not Found")</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>REDIRECT([]const u8, []const u8)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>REDIRECT</code> function takes a url and content data to redirect to, then sends this to the client to redirect.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.REDIRECT("http://github.com/", "Hello World")</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>ARRAY(comptime T, []T)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>ARRAY</code> function takes a comptime T and slice, then stringifies it, and sends it to the client.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.ARRAY(User, [_]User{.{"vic", 32}, {"vic2", 33}})</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code>Cookie</code>", .{
            .font_size = 22,
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>Cookie</code> struct used to initliaze cookies, hold expriy and other fields for session management.
        , .{
            .font_size = 18,
        });
        Custom.HtmlText("<code style='color: #802BFF'>getCookie([]const u8)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>getCookie</code> function takes a string, and returns the value of the cookie otherwise null.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.getCookie("id")</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>addCookie([]const u8)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>addCookie</code> function takes a Cookie, and adds it to the reponse. This is useful for session management.
            \\Note: Cookies are overided if the same name or added twice.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.addCookie(ctx.addCookie(.{ .name = "session-nightwatch", .value = "92307498ewfhlakfjk;alfjasf....", .secure = true, .http_only = true });)</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code>http_payload: []const u8</code>", .{
            .font_size = 22,
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>http_payload</code> contains the http body of the request.
        , .{ .font_size = 18 });
        Custom.HtmlText("<code>http_header: *HttpHeader</code>", .{
            .font_size = 22,
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>http_header</code> holds the http headers of the request.
        , .{ .font_size = 18 });

        Custom.HtmlText("<code style='color: #802BFF'>param([]const u8)</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>param</code> function takes a string, and returns the value of the param otherwise null.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.param("id")</code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Custom.HtmlText("<code style='color: #802BFF'>parseForm()</code>", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Custom.HtmlText(
            \\The <code>parseForm</code> function parses the form data, and then set the form_params internally. This needs to 
            \\be called before accessing the form data, via the <code>formParam()</code> fucntion.
        , .{ .font_size = 18 });
        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>ctx.parseForm()</code>
            , .{ .text_color = .hex("#ffffff") });
        });
    });
}
