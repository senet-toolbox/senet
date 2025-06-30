const std = @import("std");
const Fabric = @import("fabric");
const NavBar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Page = Fabric.Page;
const Pure = Fabric.Pure;

// Initialization
pub fn init() void {
    Page(@src(), render, null, .{});
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    NavBar.render();
    Static.Center(.{
        .width = .percent(100),
        // .height = .percent(100),
        .padding = .{ .top = 120, .bottom = 80 },
    })({
        Static.FlexBox(.{
            .child_gap = 24,
            .direction = .column,
            .width = .percent(70),
            // .height = .percent(100),
        })({
            Static.Text("What is Tether?", .{
                .font_size = 48,
                .font_weight = 700,
                .text_color = .hex("#1a1a1a"),
            });
            Static.Text("To put simply, Tether is an exposed set of frameworks, that give developers the ability to Build full-stack applications with zero dependencies, zero configuration, and complete control.", .{ .font_size = 24 });

            Static.Text("Current State", .{
                .font_size = 28,
                .font_weight = 700,
                .text_color = .hex("#1a1a1a"),
            });
            Static.Text("This is in essence, the current state of Web development, it doesn't make sense, and it's just getting worse.", .{ .font_size = 18 });
            Static.Block(.{
                .width = .percent(100),
                .height = .percent(100),
            })({
                Static.Image("/assets/webdev.png", .{
                    .width = .percent(100),
                });
            });

            Static.Text("Hitting Reset", .{
                .margin = .{ .top = 24 },
                .font_size = 32,
                .font_weight = 700,
                .text_color = .hex("#1a1a1a"),
            });
            Custom.HtmlText(
                \\Tether is a toolkit first, framework second. It's a modular, flexible system that exposes all its APIs to developers. 
                \\Unlike common frameworks like <strong>React</strong> or <strong>Vue</strong>, Tether eliminates the need to deal with evolving opinions that change over time.
                \\Many frameworks have altered their core APIs and designs, leading to complexity, legacy system support burdens, 
                \\and the never-ending cycle of learning and relearning changes.
                \\developers with a toolbox of functionality they can deep dive into and customize when needed.
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\<strong style="color: #6439FF">Tether</strong> takes the approach of <strong>exposure</strong> and <strong>explicitness</strong>. 
                \\Every single component in Tether 
                \\is available to the developer. There's no transpilation engine magic, no strange state 
                \\machinery—just simple APIs you can touch and understand. 
                \\The aim is to provide developers with a toolbox of functionality they can deep dive into and customize when needed.
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\<strong>For example:</strong> Fabric's state management is a single <code style="color: #6439FF">global_rerender</code> variable of type <code style="color: #6439FF">bool</code>. 
                \\That's it. You can use the built-in Signal struct that Fabric exposes, build your own, or simply 
                \\toggle the global_rerender to update your UI. Until then, you 
                \\can utilize Tether's in-house solutions with no setup, configuration files, or complexity. Just
                \\install and start building.
            , .{ .font_size = 18 });
            Static.Text("But How?", .{
                .font_size = 32,
                .font_weight = 700,
                .text_color = .hex("#1a1a1a"),
            });
            Custom.HtmlText(
                \\Tether was built along side this Documentation website, as well as <a href="/nightwatch">NightWatch</a>. 
                \\The purpose of this was to challenge Tether, and figure out all the small annoyances that build up in our lives over time. 
                \\Tailwind, was created due to the nuisances of constant CSS churn, "display: flex; border-color: lightgrey; ...". Over, and Over again. 
                \\Within Fabric you will find and excessive number of defaults, and also the ability to create defaults or overide styles yourself. 
                \\No need for another package! 
            , .{ .font_size = 18 });
            Static.Text("Modular by Design", .{
                .font_size = 32,
                .font_weight = 700,
                .text_color = .hex("#1a1a1a"),
            });

            Custom.HtmlText(
                \\Tether's modularity means you can install Fabric, Tether, or Treehouse as independent entities. 
                \\There's no requirement to use all three or just one. The libraries themselves are modular—choose 
                \\to install OAuth, UI component libraries, or any specific functionality you need. Tether serves 
                \\as both package management system and toolkit.
            , .{ .font_size = 18 });

            Static.Text("What Tether Eliminates", .{
                .font_size = 32,
                .font_weight = 700,
                .text_color = .hex("#1a1a1a"),
            });

            Custom.HtmlText(
                \\Tether ships with <strong>zero dependencies</strong> and eliminates the need for:
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\<strong>Languages & Runtimes:</strong> No JavaScript, HTML, CSS, React, TSX, Python, Swift, Node.js
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\<strong>Frameworks & Platforms:</strong> No Vercel, Next.js, Nuxt.js, multi-language systems
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\<strong>External Services:</strong> No Clerk, NextAuth, Supabase, Stripe
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\<strong>Infrastructure:</strong> No Docker, Redis, Dragonfly
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\<strong>Package Management:</strong> No npm, pip, dependency hell
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\<strong>Build Tools:</strong> No transpilation, platform-specific code, configuration magic
            , .{ .font_size = 18 });

            Static.Text("The Core Promise", .{
                .font_size = 32,
                .font_weight = 700,
                .text_color = .hex("#1a1a1a"),
            });

            Custom.HtmlText(
                \\Tether provides the productivity benefits of modern frameworks while maintaining the control 
                \\and transparency of lower-level tools. It's built for developers who want to focus on solving 
                \\problems rather than wrestling with tooling, dependencies, and ever-changing framework opinions.
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\No tricks. No magic. Just tools you can understand and control.
            , .{ .font_size = 18 });

            Custom.HtmlText(
                \\Tether is toolkit first, framework second. 
            , .{ .font_size = 18 });
        });
    });
}
