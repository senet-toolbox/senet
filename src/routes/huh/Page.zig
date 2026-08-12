const std = @import("std");
const Vapor = @import("vapor");
const NavBar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const Style = Vapor.Style;
const Center = Vapor.Center;
const Row = Vapor.Row;
const Image = Vapor.Image;
const Text = Vapor.Text;
const Page = Vapor.Page;
const HtmlText = Vapor.Html;
const Graphic = Vapor.Graphic;
const List = Vapor.List;
const ListItem = Vapor.ListItem;

// Initialization
pub fn init() void {
    Page(.{ .src = @src() }, render, null);
}

pub fn Txt(text: []const u8) void {
    Text(text, .{
        .font_size = 18,
    });
}

const heading = &Style{
    .visual = .{
        .font_size = 32,
        .font_weight = 500,
        .text_color = .palette(.text_color),
    },
    .font_family = "IBM Plex Sans",
};

const subheading = &Style{
    .visual = .{
        .font_size = 24,
        .font_weight = 500,
        .text_color = .palette(.text_color),
    },
    .font_family = "IBM Plex Sans",
};

const body_text = &Style{
    .visual = .{
        .font_size = 16,
        .font_weight = 700,
        .text_color = .palette(.text_color),
    },
};

const muted_text = &Style{
    .visual = .{
        .font_size = 16,
        .text_color = .palette(.text_color),
    },
};

pub fn render() void {
    Center().style(&.{
        .size = .w(.percent(100)),
        .padding = .tb(120, 80),
    }).children({
        Row().style(&.{
            .child_gap = 24,
            .direction = .column,
            .size = .w(.mobile_desktop_percent(100, 60)),
            .padding = .horizontal(12),
        }).children({
            Text("What is Senet?").style(heading).end();
            Text(
                \\To put simply, Senet is a toolbox of frameworks and libraries, that give developers the ability 
                \\to Build full-stack applications with zero dependencies, zero configuration, and complete control. 
            ).style(&.{ .visual = .font(18, null, .palette(.text_color)) }).end();

            HtmlText(
                \\Senet was created out of personal frustration with the current state of web development. But also out of desire to create a solid foundation for which,
                \\future applications can be built on. You can use each component of Senet <code>[Vapor, Reverb, Canopy(coming soon)]</code> seperatley or together.
            ).style(muted_text).end();

            Text("{Vapor}").style(heading).end();
            HtmlText(
                \\Vapor is a programming first frontend framework. Instead of using gimmicks like <strong>useState</strong> or <strong>useEffect</strong>,
                \\We write normal code, with variables, functions, and types. 
                \\These functions are used to create components, and variables are used to update the state of the component.
            ).style(muted_text).end();

            Text("Vapor state persists by default, navigation does not reset state")
                .fontStyle(.italic)
                .font(18, null, .palette(.tint))
                .end();

            Text("{Reverb}").style(heading).end();
            HtmlText(
                \\Reverb is a simple, backend web framework, which exposes a a set of production grade libraries, but also gives the developer
                \\the ability to use high performance surgical tools, like the Atomic Lock-Free Thread Pool <code>[Scheduler]</code>.
            ).style(muted_text).end();

            Text("Reverb uses an express like syntax, but with a more modern feel")
                .fontStyle(.italic)
                .font(18, null, .palette(.tint))
                .end();

            Text("{Canopy} (Coming Soon)").style(heading).end();

            HtmlText(
                \\Runs as a in memory cache at the front and a persistent database at the back. By default, it uses the RESP3 protocol, and has a similar API to SQL, 
                \\for creating and managing tables. Canopy also takes a more built-in approach, to creating custom selection queries. Instead of using SQL, Canopy uses a 
                \\Canopy exposes a variety of functions that intercept different stages of a request lifecycle. This allows for developers to build custom logic within 
                \\the database itself, rather than executing within a runtime environment. This means we can write Zig to create filter, search, join, or anything else we need.
            ).style(muted_text).end();

            Text("Canopy uses Zig itself to create logic functions")
                .fontStyle(.italic)
                .font(18, null, .palette(.tint))
                .end();

            Text("{Samples}").style(heading).end();
            HtmlText(
                \\Below is a set of sample applications, that were built with Senet, they are all single file, and can be downloaded and run.
            ).style(muted_text).end();
            Vapor.Stack().spacing(32).items(.{
                Text("Sample Ecommerce App").font(18, 300, .palette(.text_color)).mt(64).border(.bottom(1, .palette(.border_color_light))),
                Image(.{ .src = "/assets/ryven.webp" }).style(&.{
                    .size = .w(.percent(100)),
                }),
                Text("Ryven Sql Editor").font(18, 300, .palette(.text_color)).mt(64).border(.bottom(1, .palette(.border_color_light))),
                Image(.{ .src = "/assets/ryven.png" }).style(&.{
                    .size = .w(.percent(100)),
                }),
                Text("UI Component Library").font(18, 300, .palette(.text_color)).mt(64).border(.bottom(1, .palette(.border_color_light))),
                Image(.{ .src = "/assets/vapor-ui.png" }).style(&.{
                    .size = .w(.percent(100)),
                }),
            });
        });
    });
}
