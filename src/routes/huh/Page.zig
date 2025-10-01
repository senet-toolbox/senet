const std = @import("std");
const Fabric = @import("fabric");
const NavBar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Chain = Fabric.Chain;
const ChainClose = Fabric.ChainClose;
const Center = Chain.Center;
const Box = Chain.Box;
const Image = ChainClose.Image;
const Text = ChainClose.Text;
const Page = Fabric.Page;
const Pure = Fabric.Pure;
const HtmlText = Custom.Chain.HtmlText;
const Graphic = Chain.Graphic;

// Initialization
pub fn init() void {
    Page(@src(), render, null, &.{});
}

pub fn Txt(text: []const u8) void {
    Text(text, .{
        .font_size = 18,
    });
}

const heading = &Style{
    .visual = .{
        .font_size = 48,
        .font_weight = 700,
        .text_color = .palette(.text_color),
    },
};

const subheading = &Style{
    .visual = .{
        .font_size = 32,
        .font_weight = 700,
        .text_color = .palette(.text_color),
    },
};

const body_text = &Style{
    .visual = .{
        .font_size = 24,
        .font_weight = 700,
        .text_color = .palette(.text_color),
    },
};

const muted_text = &Style{
    .visual = .{
        .font_size = 18,
        .text_color = .palette(.text_color),
    },
};

pub fn render() void {
    Center.style(&.{
        .size = .w(.percent(100)),
        .padding = .{ .top = 120, .bottom = 80 },
    })({
        Box.style(&.{
            .child_gap = 24,
            .direction = .column,
            .size = .w(.mobile_desktop_percent(100, 70)),
            .padding = .horizontal(12),
        })({
            Text("What is Tether?").style(heading);
            Text("To put simply, Tether is an exposed set of frameworks, that gives developers the ability to Build full-stack applications with zero dependencies, zero configuration, and complete control. ").style(&.{ .visual = .font(24, null, .palette(.text_color)) });

            Center.style(&.{})({
                Graphic(.{ .src = "src/assets/tether.svg" }).style(&.{
                    .size = .hw(.percent(100), .percent(50)),
                    .visual = .{ .text_color = .palette(.text_color) },
                })({});
            });

            Text("How the Internet works").style(heading);
            HtmlText(
                \\At their core every website is just a text document. We store this document on the server and send it to the client, when they ask for it.
                \\Your browser takes this document which is in a langauge known as <a href="https://developer.mozilla.org/en-US/docs/Web/HTML">HTML</a> 
                \\and then draws the boxes, rectangles, and text onto your screen. This is how it worked in the beginning.
            ).style(muted_text);
            // Image(.{ .src = "/assets/theinternet.webp" }).style(&.{
            //     .size = .w(.percent(100)),
            // });
            Graphic(.{ .src = "src/assets/theinternet.svg" }).style(&.{
                .size = .hw(.percent(100), .percent(100)),
                .visual = .{ .text_color = .palette(.text_color) },
            })({});

            Text("And then theres today...").style(&.{
                .visual = heading.visual,
                .margin = .{ .top = 100 },
            });
            Text("This is in essence, the current state of Web development, it doesn't make sense, and it's just getting worse. ").style(muted_text);
            Center.style(&.{ .size = .hw_percent(100, 100) })({
                Graphic(.{ .src = "src/assets/webdev.svg" }).style(&.{
                    .size = .hw(.percent(100), .percent(100)),
                    .visual = .{ .text_color = .palette(.text_color) },
                })({});
            });

            Text("Hitting Reset").style(&.{
                .margin = .{ .top = 24 },
                .visual = subheading.visual,
            });
            HtmlText(
                \\Tether is a toolkit first, framework second. It's a modular, flexible system that exposes all its APIs to developers. 
                \\Unlike common frameworks like <strong>React</strong> or <strong>Vue</strong>, Tether eliminates the need to deal with evolving opinions that change over time.
                \\Many frameworks have altered their core APIs and designs, leading to complexity, legacy system support burdens, 
                \\and the never-ending cycle of learning and relearning changes.
            ).style(muted_text);

            HtmlText(
                \\<strong style="color: #6439FF">Tether</strong> takes the approach of <strong>exposure</strong> and <strong>explicitness</strong>. 
                \\Every single component in Tether 
                \\is available to the developer. There's no transpilation engine magic, no strange state 
                \\machinery—just simple APIs you can touch and understand. 
                \\The aim is to provide developers with a toolbox of functionality they can deep dive into and customize when needed.
            ).style(muted_text);

            HtmlText(
                \\<strong>For example:</strong> Fabric's state management is a single <code style="color: #6439FF">global_rerender</code> variable of type <code style="color: #6439FF">bool</code>. 
                \\That's it. You can use the built-in <strong>Signal Struct</strong> that Fabric exposes, build your own, or simply 
                \\toggle the <code style="color: #6439FF">global_rerender</code> to update your UI. Until then, you 
                \\can utilize Tether's in-house solutions with no setup, configuration files, or complexity. Just
                \\install and start building.
            ).style(muted_text);
            Text("But How?").style(subheading);
            HtmlText(
                \\Tether was built along side this Documentation website, as well as <a href="/nightwatch">NightWatch</a>. 
                \\The purpose of this was to challenge Tether, and figure out all the small annoyances that build up in our lives over time. 
                \\Tailwind, was created due to the nuisances of constant CSS churn, "display: flex; border-color: lightgrey; ...". Over, and Over again. 
                \\Within Fabric you will find and excessive number of defaults, and also the ability to create defaults or overide styles yourself. 
                \\No need for another package! 
            ).style(muted_text);
            Text("Modular by Design").style(subheading);

            HtmlText(
                \\Tether's modularity means you can install Fabric, Tether, or Treehouse as independent entities. 
                \\There's no requirement to use all three or just one. The libraries themselves are modular—choose 
                \\to install OAuth, UI component libraries, or any specific functionality you need. Tether serves 
                \\as both package management system and toolkit.
            ).style(muted_text);

            Text("What Tether Eliminates").style(subheading);

            HtmlText(
                \\Tether ships with <strong>zero dependencies</strong> and eliminates the need for:
            ).style(muted_text);

            HtmlText(
                \\<strong>Languages & Runtimes:</strong> No JavaScript, HTML, CSS, React, TSX, Python, Swift, Node.js
            ).style(muted_text);

            HtmlText(
                \\<strong>Frameworks & Platforms:</strong> No Vercel, Next.js, Nuxt.js, multi-language systems
            ).style(muted_text);

            HtmlText(
                \\<strong>External Services:</strong> No Clerk, NextAuth, Supabase, Stripe
            ).style(muted_text);

            HtmlText(
                \\<strong>Infrastructure:</strong> No Docker, Redis, Dragonfly
            ).style(muted_text);

            HtmlText(
                \\<strong>Package Management:</strong> No npm, pip, dependency hell
            ).style(muted_text);

            HtmlText(
                \\<strong>Build Tools:</strong> No transpilation, platform-specific code, configuration magic
            ).style(muted_text);

            Text("But that doesn't mean you can't...").style(subheading);

            HtmlText(
                \\<strong>Install Libs:</strong> Use your favorite JS Library if you want, This is even done in NightWatch with chart.js 
                \\<a href="/docs/fabric/concepts/jslibs">NightWatch Example</a>
            ).style(muted_text);

            HtmlText(
                \\<strong>Use C or Objc:</strong> Embed your favorite C or Objc Libs, or even Zig itself
            ).style(muted_text);

            HtmlText(
                \\<strong>Adapt and Build:</strong> Scrap it all and use the core codebase to build your own Renderer, and Web Server 
            ).style(muted_text);

            Text("The Core Promise ").style(&.{ .visual = .font(32, 700, .palette(.text_color)), .margin = .{ .top = 64 } });

            HtmlText(
                \\Tether provides the productivity benefits of modern frameworks while maintaining the control 
                \\and transparency of lower-level tools. It's built for developers who want to focus on solving 
                \\problems rather than wrestling with tooling, dependencies, and ever-changing framework opinions.
            ).style(muted_text);

            Center.style(&.{ .size = .w(.percent(100)), .direction = .column, .child_gap = 32, .margin = .{ .top = 32 } })({
                HtmlText(
                    \\No tricks. No magic. Just tools you can understand and control.
                ).style(body_text);

                HtmlText(
                    \\Tether is toolkit first, framework second. 
                ).style(body_text);
                // HtmlText(
                //     \\Designed for the long game, not the next big thing!
                // , .{ .font_size = 28, .font_weight = 700 });
            });
        });
    });
}
