const std = @import("std");
const Vapor = @import("vapor");
const RootPage = @import("routes/Page.zig");
const Navbar = @import("components/Navbar.zig");
const DocsNavbar = @import("components/DocNavbar.zig");
const VaporDocs = @import("routes/docs/vapor/Page.zig");
const VaporDocsConcepts = @import("routes/docs/vapor/concepts/:concept/Page.zig");
const MetalDocs = @import("routes/docs/metal/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const Install = @import("routes/install/Page.zig");
const Error = @import("routes/error/Page.zig");
const Theme = @import("theme");
const Vaporize = @import("vaporize");
const Opaque = @import("opaque-ui");
const Loader = @import("components").Loader;
const LoaderText = @import("components").LoaderText;

const OverlayManager = @import("components/OverlayManager.zig");
const Fetch = Vapor.Fetch.Fetch;


fn registerLayouts() !void {
    initLayouts();
    try Vapor.registerLayout("/", layout, .{});
    try Vapor.registerLayout("/docs", layoutDocs, .{ .reset = true });
    _ = Vapor.registerHook("/docs", before, .before);
    _ = Vapor.registerHook("/docs", after, .after);
}

fn before(ctx: Vapor.lib.HookContext) void {
    std.log.info("Before hook called {s}", .{ctx.to_path});
}

fn after(ctx: Vapor.lib.HookContext) void {
    std.log.info("After hook called {s}", .{ctx.to_path});
}

fn initLayouts() void {
    Navbar.init();
    DocsNavbar.init();
}

pub fn layout(page: *const fn () void) void {
    page();
    Navbar.render();
}

pub fn layoutDocs(page: *const fn () void) void {
    page();
    DocsNavbar.render();
}

fn TestPage() void {
    Vapor.Text("Hello, world!").end();
}

fn ReverbPage() void {
    Vapor.Center().size(.full).children({
        Vapor.Text("Comming Soon").end();
    });
}

fn initPages() void {
    RootPage.init();
    Error.init();
    Vapor.Page(.{ .route = "/docs/reverb" }, ReverbPage, null);
    VaporDocs.init();
    VaporDocsConcepts.init();
    MetalDocs.init();
    Huh.init();
    Install.init();
}

const style_config = Vaporize.StyleConfig{
    .code_style = .{ .visual = .{
        .text_color = .palette(.tint),
        .background = .palette(.background),
        .border = .simple(.palette(.text_color)),
    } },
    .text_style = .{
        .visual = .{ .text_color = .palette(.text_color) },
    },
    .heading_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
    .text_field_style = .{
        .size = .hw(.px(38), .percent(100)),
        .padding = .tblr(4, 4, 8, 8),
        .transition = .{ .duration = 100 },
        .visual = .{
            .outline = .none,
            .border = .simple(.palette(.text_color)),
            .background = .palette(.background),
            .font_size = 18,
        },
        .interactive = .{
            .hover = .{
                .border = .simple(.palette(.tint)),
            },
        },
        .font_family = "Montserrat",
    },
    .struct_style = .{
        .layout = .left_center,
        .direction = .column,
        .child_gap = 8,
        .size = .hw(.fit, .percent(100)),
    },
    .list_style = .{ .layout = .left_center, .direction = .column, .child_gap = 8 },
    .button_style = .{
        .layout = .center,
        .size = .hw(.px(52), .percent(50)),
        .visual = .{
            .border = .none,
            .background = .palette(.text_color),
            .cursor = .pointer,
            .font_size = 18,
            .text_color = .white,
        },
        .transition = .{ .duration = 100 },
        .interactive = .{ .hover = .{ .transform = .scale(), .background = .palette(.tint), .text_color = .white } },
        .child_gap = 8,
        .font_family = "Montserrat",
    },
    .submit_style = .{
        .layout = .center,
        .size = .w(.percent(100)),
        .margin = .{ .top = 32 },
        .visual = .{
            .border = .round(.transparentizeHex(.palette(.alternate_background), 0.5), .all(4)),
            .background = .transparentizeHex(.palette(.alternate_background), 0.9),
            .cursor = .pointer,
            .font_size = 16,
            .text_color = .white,
            .new_shadow = Vapor.Types.NewShadow.init()
                .inset(0, -2, .transparentizeHex(.palette(.alternate_background), 0.5))
                .drop(0, 1, 3, .transparentizeHex(.palette(.alternate_background), 0.1)),
        },
        .transition = .{ .duration = 100 },
        .interactive = .{
            .hover = .{
                .new_shadow = Vapor.Types.NewShadow.init()
                    .inset(0, -2, .transparentizeHex(.black, 0))
                    .drop(0, 1, 3, .transparentizeHex(.black, 0)),
            },
        },
        .padding = .tblr(4, 4, 8, 8),
        .child_gap = 8,
        .font_family = "IBM Plex Sans,monospace",
    },
    .table_header_style = Vapor.Types.Style{
        .size = .w(.percent(100)),
        .direction = .row,
        .layout = .left_center,
        .visual = .{
            .background = .palette(.tint),
            .border = .bottom(1, .palette(.border_color)),
            .text_color = .palette(.alternate_text_color),
        },
    },
    .table_row_style = Vapor.Types.Style{
        .size = .w(.percent(100)),
        .direction = .row,
        .layout = .left_center,
        .visual = .{
            .background = .transparent,
            .border = .bottom(1, .palette(.border_color)),
            .text_color = .palette(.text_color),
        },
    },
};

pub var vaporize: Vaporize.Compiler = undefined;

pub export fn init() void {
    // InitializeVapor
    Vapor.init(.{});
    Vapor.Animation.new();
    Vapor.Edges.new();
    Vapor.Polygons.new();
    Fetch.init();
    Loader.init();
    LoaderText.init();

    vaporize = Vaporize.init(Vapor.persist.arena(), style_config) catch unreachable; // this causes issues


    OverlayManager.init();
    Opaque.initAnimations();
    Opaque.new();

    // Global style variables
    Vapor.setGlobalStyleVariables(.{ // Adds 11kb
        .themes = &.{
            Vapor.ThemeDefinition{ .name = "light", .theme = Theme.Light, .default = true },
            Vapor.ThemeDefinition{ .name = "dark", .theme = Theme.Dark },
        },
    });

    // Initialize your root component or app
    registerLayouts() catch |err| {
        Vapor.lib.printlnSrcErr("Failed to register layout {any}", .{err}, @src());
    };
    initPages();
}

pub const std_options = std.Options{
    .log_level = .debug,
    .logFn = Vapor.lib.log,
};
