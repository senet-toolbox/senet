const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

// Initialization
var sample_fetch: CodeEditor = undefined;
pub fn init() void {
    // sample_fetch.init(&Fabric.lib.allocator_global, @embedFile("sample_fetch.zig"));
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

// Render
pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("KeyStone", .{
            .font_size = 48,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Txt(
            \\KeyStone is a mini internal package maintained by Tether. KeyStone exposes a set of Auth functions for logging in and out of the 
            \\common Oauth services, such as Google, Apple, and Github. Note, Apple will only work if you use the Apple developer account set up.
        );
        Static.Text("pub fn signInWithOauth(provider: Provider) void", .{
            .font_size = 20,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Static.List(.{})({
            Static.ListItem(.{})({
                Txt(
                    \\Provider, is an enum type, exposed by KeyStone, ie .github or .google...
                );
            });
            Static.ListItem(.{})({
                Txt(
                    \\This function makes a call to the Oauth specified, and then uses the provided redirect_url as the return url from
                    \\the Oauth. The returned response contains the the url params, code, and cookie, for authenticating the user on the backend.
                );
            });
        });

        Static.Text("pub fn handleAuthExchanges() void", .{
            .font_size = 20,
            .text_color = .hex("#802BFF"),
            .font_family = "monospace",
        });
        Static.List(.{})({
            Static.ListItem(.{})({
                Custom.HtmlText(
                    \\This handler makes a call to the specified backend to exchange the token for an access token. For more details on
                    \\the backend logic, check <a href="/docs/reverb/keystone">Reverb Keystone</a>
                ,.{
                    .font_size = 18,
                });
            });
        });
    });
}
