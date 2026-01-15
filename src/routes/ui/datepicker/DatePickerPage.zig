const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const Stack = Vapor.Stack;
const Opaque = @import("../../../components/Opaque.zig");
const Vaporize = @import("vaporize");
const SyntaxHighlighter = Vaporize.SyntaxHighlighter;
const Icon = Vapor.Icon;
const Button = Opaque.Button;
const DatePicker = Opaque.DatePicker;
const DateTime = Vapor.DateTime;

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
var hl_events: SyntaxHighlighter = undefined;

// ============================================================================
// DATEPICKER INSTANCES
// ============================================================================

var basic_picker: DatePicker = undefined;
var event_picker: DatePicker = undefined;

pub fn init() void {
    const allocator = Vapor.arena(.persist);

    // Highlighters
    hl_basic = SyntaxHighlighter.init(allocator);
    hl_basic.parse(@embedFile("examples/BasicDatePicker.zig")) catch unreachable;

    hl_events = SyntaxHighlighter.init(allocator);
    hl_events.parse(@embedFile("examples/EventDatePicker.zig")) catch unreachable;

    // Instance 1: Basic (Defaults only)
    basic_picker.init();

    // Instance 2: Event Driven (Your specific logic)
    event_picker.start_date = DateTime.fromMonth(8, 1991);
    event_picker.init();
    event_picker.on_date_select = onDateSelect;
    event_picker.on_year_select = onYearSelect;
    event_picker.on_month_select = onMonthSelect;
    event_picker.on_next_month = onNextMonth;
    event_picker.on_prev_month = onPrevMonth;

    Vapor.Page(.{ .src = @src() }, render, null);
}

// ============================================================================
// CALLBACKS
// ============================================================================

fn onDateSelect(date: DateTime) void {
    const format = date.formatDate(Vapor.arena(.frame)) catch unreachable;
    Vapor.alert("Date selected: {s}", .{format});
}

fn onYearSelect(year: i32) void {
    Vapor.alert("Year selected: {d}", .{year});
}
fn onMonthSelect(month: i32) void {
    Vapor.alert("Month selected: {d}", .{month});
}
fn onNextMonth() void {
    Vapor.alert("Next Month", .{});
}
fn onPrevMonth() void {
    Vapor.alert("Prev Month", .{});
}

// ============================================================================
// UI HELPERS
// ============================================================================

fn sectionDesc(desc: []const u8) void {
    Text(desc).font(14, 400, Theme.text_muted).fontFamily("IBM Plex Mono,monospace").margin(.b(16)).end();
}

fn exampleLabel(label: []const u8) void {
    Text(label).font(14, 500, Theme.text_muted).fontFamily("IBM Plex Mono,monospace").margin(.t(24)).end();
}

fn CodeBlock(highlighter: *SyntaxHighlighter) void {
    Box().scroll(.scroll_y()).size(.hw(.fit, .percent(100))).border(.simple(Theme.border)).children({
        highlighter.render() catch unreachable;
    });
}

fn PreviewCard() Vapor.Builder(.pure) {
    return Stack()
        .background(.transparentizeHex(.palette(.background), 0.5))
        .border(.round(.palette(.border_color_light), .all(12)))
        .width(.percent(100))
        .padding(.all(24))
        .direction(.column)
        .layout(.center)
        .spacing(16);
}

// ============================================================================
// RENDER
// ============================================================================

fn render() void {
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
            Text("datepicker-ui ⇒").style(&.{
                .visual = .font(12, 500, .hex("#6f6f6f")),
                .font_family = "IBM Plex Mono,monospace",
            });
            Text("datepicker-ui")
                .font(72, 700, .palette(.text_color))
                .end();
            Text("Accessible calendar components for precise date and time selection.")
                .font(16, 300, .palette(.text_color))
                .end();
        });

        // Content
        Stack()
            .width(.percent(50))
            .spacing(32)
            .padding(.b(120))
            .children({

            // EXAMPLE 1: BASIC
            Box().direction(.column).children({
                exampleLabel("Basic DatePicker");
                sectionDesc("Default calendar view with no external dependencies or callbacks.");

                PreviewCard().children({
                    basic_picker.render();
                });
                CodeBlock(&hl_basic);
            });

            // EXAMPLE 2: EVENT DRIVEN
            Box().direction(.column).children({
                exampleLabel("Event-Driven Selection");
                sectionDesc("Hook into specific lifecycle events like year changes or month navigation.");

                PreviewCard().children({
                    event_picker.render();
                });
                CodeBlock(&hl_events);
            });

            // API REFERENCE
            Text("API Reference").font(24, 600, Theme.text).fontFamily("IBM Plex Mono,monospace").margin(.t(48)).end();

            exampleLabel("Event Callbacks");
            sectionDesc("DatePicker exposes optional function pointers for fine-grained control.");
            Box()
                .width(.percent(100))
                .padding(.all(16))
                .background(Theme.code_bg)
                .border(.round(Theme.border, .all(8)))
                .children({
                Text(
                    \\.on_date_select = fn(DateTime) void
                    \\.on_year_select = fn(i32) void
                    \\.on_month_select = fn(i32) void
                    \\.on_next_month = fn() void
                    \\.on_prev_month = fn() void
                )
                    .font(14, 400, .hex("#e4e4e7"))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });
        });
    });
}

