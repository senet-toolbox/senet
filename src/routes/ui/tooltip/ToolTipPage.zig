// page.zig
const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const Stack = Vapor.Stack;
const Opaque = @import("../../../components/Opaque.zig");
const Select = Opaque.Select;
const Vaporize = @import("vaporize");
const SyntaxHighlighter = Vaporize.SyntaxHighlighter;
const Tooltip = Opaque.Tooltip;
const Icon = Vapor.Icon;

// ============================================================================
// THEME
// ============================================================================

const Theme = struct {
    const text = Vapor.Types.Color.palette(.text_color);
    const text_muted = Vapor.Types.Color.hex("#71717a");
    const border = Vapor.Types.Color.palette(.border_color_light);
    const code_bg = Vapor.Types.Background.hex("#1a1a1a");
};

// ============================================================================
// SYNTAX HIGHLIGHTERS
// ============================================================================

var hl_basic: SyntaxHighlighter = undefined;
var hl_custom_tooltip: SyntaxHighlighter = undefined;
var hl_grouped: SyntaxHighlighter = undefined;
var hl_detached: SyntaxHighlighter = undefined;

// ============================================================================
// SELECT INSTANCES
// ============================================================================

// ============================================================================
// INIT
// ============================================================================

pub fn init() void {
    const allocator = Vapor.arena(.persist);

    // Initialize syntax highlighters
    hl_basic = SyntaxHighlighter.init(allocator);
    hl_basic.show_toolbar = true;
    hl_basic.parse("Tooltip.simple(\"Hover Me\",\"This is a tooltip\")") catch unreachable;

    hl_custom_tooltip = SyntaxHighlighter.init(allocator);
    hl_custom_tooltip.show_toolbar = true;
    hl_custom_tooltip.parse(@embedFile("examples/TooltipCustomTrigger.zig")) catch unreachable;

    hl_grouped = SyntaxHighlighter.init(allocator);
    hl_grouped.show_toolbar = true;
    hl_grouped.parse(@embedFile("examples/TooltipCustom.zig")) catch unreachable;
    //
    // hl_custom_tooltip = SyntaxHighlighter.init(allocator);
    // hl_basic.show_toolbar = true;
    // hl_custom_tooltip.parse(@embedFile("examples/CustomTrigger.zig")) catch unreachable;
    //
    // hl_detached = SyntaxHighlighter.init(allocator);
    // hl_basic.show_toolbar = true;
    // hl_detached.parse(@embedFile("examples/Detached.zig")) catch unreachable;

    Vapor.Page(.{ .src = @src() }, render, null);
}

// ============================================================================
// HANDLERS
// ============================================================================

// ============================================================================
// CUSTOM TRIGGER COMPONENTS
// ============================================================================

fn TooltipTrigger(title: []const u8) void {
    Box()
        .width(.fit)
        .padding(.xy(12, 8))
        .cursor(.pointer)
        .background(.palette(.background))
        .hover(.{
            .background = .palette(.tint),
            .text_color = .palette(.background),
        })
        .font(14, 300, .palette(.text_color))
        .duration(200)
        .border(.round(.transparent, .all(4)))
        .layout(.center)
        .children({
        Text(title)
            .font(14, 300, null)
            .end();
    });
}

fn TooltipContent(title: []const u8, label: []const u8, due: Vapor.DateTime) void {
    Box()
        .width(.px(280))
        .width(.px(280))
        .padding(.all(16))
        .border(.round(.palette(.border_color_light), .all(12)))
        .direction(.column)
        .spacing(12)
        .children({
        // Header with title and priority badge
        Box()
            .layout(.x_between_center)
            .children({
            Text(title)
                .font(14, 600, Theme.text)
                .fontFamily("Montserrat")
                .width(.px(180))
                .ellipsis(.dot)
                .end();
            Box()
                .padding(.xy(8, 4))
                .children({
                Text(label)
                    .font(10, 500, .palette(.tint))
                    .fontFamily("Montserrat")
                    .end();
            });
        });

        // Divider
        Box()
            .width(.percent(100))
            .height(.px(1))
            .background(.{ .color = .palette(.border_color_light) })
            .children({});

        // Details section
        Stack()
            .width(.percent(100))
            .spacing(8)
            .children({
            // Due date
            Box()
                .width(.percent(100))
                .layout(.x_between_center)
                .children({
                Box()
                    .layout(.left_center)
                    .spacing(6)
                    .children({
                    Icon(.calendar)
                        .font(12, 400, .palette(.text_color))
                        .end();
                    Text("Due date")
                        .font(12, 400, .palette(.text_color))
                        .fontFamily("Montserrat")
                        .end();
                });
                Text(due.formatDate(Vapor.arena(.frame)) catch "")
                    .font(12, 500, .palette(.text_color))
                    .fontFamily("Montserrat")
                    .end();
            });
        });
    });
}

// ============================================================================
// UI COMPONENTS
// ============================================================================

fn sectionTitle(title: []const u8) void {
    Text(title)
        .font(24, 600, Theme.text)
        .fontFamily("IBM Plex Mono,monospace")
        .margin(.t(48))
        .end();
}

fn sectionDesc(desc: []const u8) void {
    Text(desc)
        .font(14, 400, Theme.text_muted)
        .fontFamily("IBM Plex Mono,monospace")
        .margin(.b(16))
        .end();
}

fn exampleLabel(label: []const u8) void {
    Text(label)
        .font(14, 500, Theme.text_muted)
        .fontFamily("IBM Plex Mono,monospace")
        .margin(.t(24))
        .end();
}

fn PreviewCard() Vapor.Builder(.pure) {
    return Stack()
        .background(.transparentizeHex(.palette(.background), 0.5))
        .border(.round(.palette(.border_color_light), .all(12)))
        .width(.percent(100))
        .height(.px(160))
        .padding(.all(24))
        .direction(.column)
        .layout(.center)
        .spacing(16);
}

fn CodeBlock(highlighter: *SyntaxHighlighter) void {
    Box()
        .scroll(.scroll_y())
        .inlineStyle("max-height: 512px;", .{})
        .size(.w(.percent(100)))
        .border(.simple(.palette(.text_color)))
        .children({
        highlighter.render() catch unreachable;
    });
}

// ============================================================================
// RENDER
// ============================================================================

pub fn render() void {
    Box()
        .width(.percent(100))
        .layout(.top_center)
        .direction(.column)
        .children({

        // Hero
        Vapor.Stack()
            .layout(.center)
            .height(.px(512))
            .width(.percent(100))
            .children({
            Text("tooltip-ui ⇒").style(&.{
                .visual = .font(12, 500, .hex("#6f6f6f")),
                .font_family = "IBM Plex Mono,monospace",
            });
            Text("tooltip-ui")
                .font(72, 700, .palette(.text_color))
                .end();
            Text("A collection of ready-to-use tooltip components built on top of Vapor, copy and paste into your apps.")
                .font(16, 300, .palette(.text_color))
                .end();
        });

        // Content
        Stack()
            .width(.percent(50))
            .height(.percent(100))
            .spacing(12)
            .padding(.b(120))
            .children({

            // ============================================================
            // BASIC
            // ============================================================
            exampleLabel("Basic");
            sectionDesc("A simple tooltip with a Title and Content.");
            PreviewCard().children({
                Tooltip.simple("Hover Me", "This is a tooltip");
            });
            CodeBlock(&hl_basic);

            // ============================================================
            // WITH ICONS
            // ============================================================
            exampleLabel("With a Custom Trigger");
            sectionDesc("Tooltips can be triggered by a custom component.");
            PreviewCard().children({
                Tooltip.create(.{ .content = "This is a custom trigger tooltip" })
                    .Trigger(TooltipTrigger, .{"Custom Tooltip"})
                    .end();
            });
            CodeBlock(&hl_custom_tooltip);

            // ============================================================
            // GROUPED
            // ============================================================
            exampleLabel("Custom Content and Custom Trigger");
            sectionDesc("A Tooltip can have custom content and a custom trigger.");
            PreviewCard().children({
                Tooltip.create(.{ .background = .palette(.background), .stroke_color = .palette(.border_color_light) })
                    .Trigger(TooltipTrigger, .{"Custom Tooltip with Custom Content"})
                    .Component(TooltipContent, .{ "CUSTOM", "Priority", Vapor.DateTime.now() })
                    .end();
            });
            CodeBlock(&hl_grouped);

            // ============================================================
            // API REFERENCE
            // ============================================================
            sectionTitle("API Reference");

            exampleLabel("Initialization");
            sectionDesc("Two ways to create a Select:");
            Box()
                .width(.percent(100))
                .padding(.all(16))
                .background(Theme.code_bg)
                .border(.round(Theme.border, .all(8)))
                .children({
                Text(
                    \\// Flat list
                    \\var tooltip = Select(MyEnum).fromItems(&.{ ... });
                    \\
                    \\// Grouped list
                    \\var tooltip = Select(MyEnum).init("Placeholder", &.{
                    \\    Select(MyEnum).Group{ .title = "Group", .items = &.{ ... } },
                    \\});
                )
                    .font(14, 400, .hex("#e4e4e7"))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });

            exampleLabel("Item Structure");
            sectionDesc("Each item requires a value and label. Icon is optional.");
            Box()
                .width(.percent(100))
                .padding(.all(16))
                .background(Theme.code_bg)
                .border(.round(Theme.border, .all(8)))
                .children({
                Text(
                    \\.{ .value = MyEnum.option, .label = "Option Label", .icon = .icon_name }
                )
                    .font(14, 400, .hex("#e4e4e7"))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });

            exampleLabel("Properties");
            sectionDesc("Configure behavior after initialization.");
            Box()
                .width(.percent(100))
                .padding(.all(16))
                .background(Theme.code_bg)
                .border(.round(Theme.border, .all(8)))
                .children({
                Text(
                    \\tooltip.trigger = "Placeholder text";      // Custom placeholder
                    \\tooltip.trigger_component = myFn;          // Custom trigger component
                    \\tooltip.on_tooltip = handleSelect;          // Selection callback
                )
                    .font(14, 400, .hex("#e4e4e7"))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });

            exampleLabel("Render Methods");
            sectionDesc("Choose how to render the component.");
            Box()
                .width(.percent(100))
                .padding(.all(16))
                .background(Theme.code_bg)
                .border(.round(Theme.border, .all(8)))
                .children({
                Text(
                    \\tooltip.render();          // Render trigger + dropdown together
                    \\tooltip.renderTrigger();   // Render trigger only
                    \\tooltip.renderSelect();    // Render dropdown only
                )
                    .font(14, 400, .hex("#e4e4e7"))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });

            exampleLabel("Callback Signature");
            sectionDesc("The on_tooltip callback receives the tooltip instance and tooltiped item.");
            Box()
                .width(.percent(100))
                .padding(.all(16))
                .background(Theme.code_bg)
                .border(.round(Theme.border, .all(8)))
                .children({
                Text(
                    \\fn handleSelect(sel: *Select(MyEnum), item: *Select(MyEnum).Item) void {
                    \\    // item.value - the enum value
                    \\    // item.label - the display string
                    \\    // item.icon  - optional icon
                    \\}
                )
                    .font(14, 400, .hex("#e4e4e7"))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });
        });
    });
}
