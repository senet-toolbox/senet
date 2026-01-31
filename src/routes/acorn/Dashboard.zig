// Dashboard
const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const Icon = Vapor.Icon;
const Label = Vapor.Label;
const TextFmt = Vapor.TextFmt;
const TextField = Vapor.TextField;
const TextArea = Vapor.TextArea;
const Animation = Vapor.Animation;
const ButtonCtx = Vapor.CtxButton;
const toggleTheme = @import("theme").toggleTheme;
const data = @import("exception_data.zig").exceptions_data;
const traces_data = @import("traces_data.zig").traces_data;
const Overview = @import("Overview.zig");
const Database = @import("Database.zig");

const font_family: []const u8 = "Barlow";

// Import UI Components
const Opaque = @import("../../components/Opaque.zig");
const Dashboard = @This();

// ============================================================================
// TYPE ALIASES
// ============================================================================

const Select = Opaque.Select;
const Table = Opaque.Table;
const Column = Opaque.Column;
const Action = Opaque.Action;
const Row = Opaque.Row;
//  const Chart = ChartStruct;
const ChartEnhanced = Opaque.Chart;
const DatePicker = Opaque.DatePicker;
const ComboBox = Opaque.ComboBox;
const Toast = Opaque.Toast;
const Sheet = Opaque.Sheet;
const Field = Opaque.Field;
const Tooltip = Opaque.Tooltip;
const Switch = Opaque.Switch;
const Tabs = Opaque.Tabs;
const Accordion = Opaque.Accordion;
const Slider = Opaque.Slider;
const Group = Opaque.Group;
const SideBar = Opaque.SideBar;
const Button = Opaque.Button;
const ProgressCircle = Opaque.ProgressCircle;

// ============================================================================
// DATA TYPES
// ============================================================================

pub const ExceptionStatus = enum {
    completed,
    pending,
    failed,
    refunded,

    pub fn color(self: ExceptionStatus) Vapor.Types.Color {
        return switch (self) {
            .completed => .palette(.tint),
            .pending => .hex("#f59e0b"),
            .failed => .palette(.danger),
            .refunded => .hex("#8b5cf6"),
        };
    }

    pub fn label(self: ExceptionStatus) []const u8 {
        return switch (self) {
            .completed => "Completed",
            .pending => "Pending",
            .failed => "Failed",
            .refunded => "Refunded",
        };
    }
};

const User = struct {
    id: []const u8,
    name: []const u8,
    email: []const u8,
};

const Method = enum {
    GET,
    POST,
    PUT,
    DELETE,
};

pub const Exception = struct {
    id: []const u8,
    last_seen: Vapor.DateTime,
    stack_trace: []const u8 = "",
    method: Method = .GET,
    url: []const u8,
    count: i32,
    user: User,
};

pub const EventType = enum {
    pageview,
    click,
    conversion,
    err,
};

pub fn color(self: EventType) Vapor.Types.Color {
    return switch (self) {
        .pageview => .hex("#3b82f6"),
        .click => .hex("#10b981"),
        .conversion => .hex("#f59e0b"),
        .err => .hex("#ef4444"),
    };
}

pub fn icon(self: EventType) *const Vapor.IconTokens {
    return switch (self) {
        .pageview => .eye,
        .click => .cursor,
        .conversion => .graph_up_arrow,
        .err => .exclamation_triangle,
    };
}

pub const AnalyticsEvent = struct {
    id: usize,
    event_type: EventType,
    page: []const u8,
    user_id: []const u8,
    timestamp: []const u8,
    duration_ms: u32,
};

// ============================================================================
// STATE
// ============================================================================

var selected_nav: NavItem = .dashboard;
var selected_time_range: TimeRange = .last_7d;
var show_detail_sheet: bool = false;
var selected_exception: ?*const Exception = null;
var is_live_mode: bool = true;
var show_date_picker: bool = false;
var search_query: []const u8 = "";
var search_ids: []const u8 = "";
var email_query: []const u8 = "";
var chart_type: ChartType = .revenue;

const NavItem = enum {
    overview,
    dashboard,
    exceptions,
    analytics,
    database,
    settings,

    pub fn label(self: NavItem) []const u8 {
        return switch (self) {
            .overview => "Overview",
            .dashboard => "Dashboard",
            .exceptions => "Exceptions",
            .analytics => "Traces",
            .database => "Database",
            .settings => "Settings",
        };
    }

    pub fn icon(self: NavItem) *const Vapor.IconTokens {
        return switch (self) {
            .overview => .speedometer2,
            .dashboard => .grid_3x3,
            .exceptions => .credit_card,
            .analytics => .bar_chart_line,
            .database => .database,
            .settings => .gear,
        };
    }
};

const TimeRange = enum {
    today,
    last_7d,
    last_30d,
    last_90d,
    custom,

    pub fn label(self: TimeRange) []const u8 {
        return switch (self) {
            .today => "Today",
            .last_7d => "Last 7 days",
            .last_30d => "Last 30 days",
            .last_90d => "Last 90 days",
            .custom => "Custom",
        };
    }
};

const ChartType = enum {
    revenue,
    exceptions,
    database,
};

// ============================================================================
// COMPONENT INSTANCES
// ============================================================================

var exceptions_data: Vapor.Array(Exception) = undefined;
var traces_array: Vapor.Array(Trace) = undefined;
var events_data: Vapor.Array(AnalyticsEvent) = undefined;
var exceptions_table: ExceptionsTable = undefined;
var traces_table: TracesTable = undefined;
var revenue_chart: ChartEnhanced = undefined;
var requests_chart: ChartEnhanced = undefined;
var cpu_chart: ChartEnhanced = undefined;
var memory_chart: ChartEnhanced = undefined;
var error_chart: ChartEnhanced = undefined;
var detail_sheet: Sheet = undefined;
var date_picker: DatePicker = undefined;
// var status_filter: Select(ExceptionStatus) = undefined;
var time_range_select: Select(TimeRange) = undefined;

var sidebar: SideBar = .{
    .items = &menu_items,
    .title = "Vapor UI",
    .show_menu = false,
    .on_item_click = onItemClick,
};

fn onItemClick(item: *const MenuItem) void {
    selected_nav = std.meta.stringToEnum(NavItem, Vapor.utils.toLowerCase(item.title, .frame)) orelse unreachable;
    Vapor.lib.store("selected_nav", @tagName(selected_nav));
}

fn getNavItem() ?*const MenuItem {
    for (&menu_items) |*item| {
        if (std.ascii.eqlIgnoreCase(selected_nav.label(), item.title)) {
            return item;
        }
    }
    return null;
}

const GroupItem = SideBar.GroupItem;
const MenuItem = SideBar.MenuItem;

var menu_items = [_]MenuItem{
    MenuItem{
        .title = "Overview",
        .link = "/overview",
        .icon = .speedometer2,
    },

    MenuItem{
        .title = "Dashboard",
        .link = "/dashboard",
        .icon = .house,
    },
    MenuItem{
        .title = "Exceptions",
        .link = "/projects",
        .icon = .folder,
    },
    MenuItem{
        .title = "Traces",
        .link = "/routes",
        .icon = .diagram_3,
    },
    MenuItem{
        .title = "Customers",
        .link = "/treehouse",
        .icon = .tree,
    },
    MenuItem{
        .title = "Settings",
        .link = "/database",
        .icon = .database,
    },
};

// Table configuration
const exception_columns = [_]Column(Exception){
    Column(Exception){
        .title = "ID",
        .width = 10,
        .key = "id",
        .render = idRender,
    },
    Column(Exception){
        .title = "Url",
        .key = "url",
        .render = urlRender,
    },
    Column(Exception){ .title = "Last Seen", .width = 15, .key = "last_seen" },
    Column(Exception){ .title = "Count", .width = 4, .key = "count" },
    Column(Exception){
        .title = "User",
        .key = "user",
        .render = userRender,
        .width = 20,
    },
};

const trace_columns = [_]Column(Trace){
    Column(Trace){ .title = "Code", .key = "error_code", .render = codeRender },
    Column(Trace){ .title = "Severity", .key = "severity" },
    Column(Trace){ .title = "Service Name", .key = "service_name" },
    Column(Trace){ .title = "Http Status", .key = "http_status" },
    Column(Trace){ .title = "Duration", .key = "duration_ms" },
    // Column(Trace){ .title = "HostName", .key = "hostname" },
};

fn codeRender(trace: *Trace) void {
    Box()
        .background(.palette(.border_color))
        .padding(.xy(12, 8))
        .border(.round(.palette(.border_color_light), .all(4)))
        .children({
        Text(trace.error_code)
            .font(14, 300, .palette(.background))
            .end();
    });
}

fn copy(exception_id: []const u8) void {
    Vapor.Clipboard.copy(exception_id);
    Toast.success(.{ .title = "Copied", .description = "Exception ID copied to clipboard" });
}

fn idRender(exception: *Exception) void {
    ButtonCtx(copy, .{exception.id})
        .pointer()
        .scroll(.none())
        .children({
        Text(exception.id)
            .fontFamily(font_family)
            .font(16, 300, .palette(.text_color))
            .ellipsis(.dot).end();
    });
}

fn urlRender(exception: *Exception) void {
    const url = Vapor.fmtln("{s} {s}", .{ @tagName(exception.method), exception.url });
    Vapor.Code(url)
        .font(14, 300, .palette(.tint))
        .end();
}

fn userComponent(email: []const u8) void {
    Text(email)
        .font(16, 300, .palette(.text_color))
        .ellipsis(.dot).end();
}

fn UserPopUp(exception: *Exception) void {
    Box()
        .width(.px(320))
        .padding(.all(16))
        .background(Theme.bg_card)
        .border(.round(.palette(.border_color_light), .all(12)))
        .direction(.column)
        .spacing(12)
        .animationEnter("kanban-fade-scale")
        .children({
        // Header with title and priority badge
        Box()
            .layout(.x_between_center)
            .children({
            Text(exception.user.name)
                .font(14, 600, Theme.text)
                .fontFamily(font_family)
                .width(.px(180))
                .ellipsis(.dot)
                .end();
        });

        // Divider
        Vapor.Spacer(1)
            .width(.percent(100))
            .background(.{ .color = .palette(.border_color_light) })
            .end();

        // Details section
        Stack()
            .width(.percent(100))
            .children({
            // Due date
            Box()
                .width(.percent(100))
                .layout(.left_center)
                .spacing(8)
                .children({
                Box()
                    .layout(.left_center)
                    .spacing(6)
                    .children({
                    Icon(.user_circle)
                        .font(12, 400, Theme.text_muted)
                        .end();
                });
                Text(exception.user.id)
                    .font(12, 500, Theme.text)
                    .fontFamily(font_family)
                    .end();
            });
        });
    });
}

fn userRender(exception: *Exception) void {
    Tooltip.create(.{
        .background = .palette(.background),
        .stroke_color = .palette(.border_color_light),
        .border = .round(.transparent, .all(12)),
    })
        .Trigger(userComponent, .{exception.user.email})
        .Component(UserPopUp, .{exception})
        .end();
}

const ExceptionsTable = Table(Exception, &exception_columns, .{
    .actions = &[_]Action(Exception){
        .{ .label = "View", .on_action = handleViewException, .icon = .eye },
        .{ .label = "Report", .on_action = handleRefundException, .icon = .arrow_counterclockwise },
        .{ .label = "Delete", .on_action = handleDeleteException, .icon = .trash },
    },
});

const Trace = @import("traces_data.zig").Trace;

const TracesTable = Table(Trace, &trace_columns, .{
    // .actions = &[_]Action(Trace){
    //     .{ .label = "View", .on_action = handleViewTrace, .icon = .eye },
    //     .{ .label = "Report", .on_action = handleRefundTrace, .icon = .arrow_counterclockwise },
    //     .{ .label = "Delete", .on_action = handleDeleteTrace, .icon = .trash },
    // },
});

// Select options
var status_options = [_]Select(ExceptionStatus).Item{
    .{ .value = .completed, .label = "Completed" },
    .{ .value = .pending, .label = "Pending" },
    .{ .value = .failed, .label = "Failed" },
    .{ .value = .refunded, .label = "Refunded" },
};

var time_range_options = [_]Select(TimeRange).Item{
    .{ .value = .today, .label = "Today" },
    .{ .value = .last_7d, .label = "Last 7 days" },
    .{ .value = .last_30d, .label = "Last 30 days" },
    .{ .value = .last_90d, .label = "Last 90 days" },
    .{ .value = .custom, .label = "Custom Range" },
};

// ============================================================================
// ANIMATIONS
// ============================================================================

const pulse_glow = Animation.init("dashboard-pulse-glow")
    .prop(.opacity, 1, 0.5)
    .duration(2000)
    .dir(.alternate)
    .infinite();

const slide_up = Animation.init("dashboard-slide-up")
    .prop(.translateY, 20, 0)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const fade_scale = Animation.init("dashboard-fade-scale")
    .prop(.scale, 0.95, 1)
    .prop(.opacity, 0, 1)
    .duration(200)
    .easing(.easeOut)
    .fill(.forwards);

const shimmer = Animation.init("dashboard-shimmer")
    .at(0)
    .set(.opacity, 0.5)
    .at(50)
    .set(.opacity, 1)
    .at(100)
    .set(.opacity, 0.5)
    .duration(1500)
    .infinite();

// ============================================================================
// SAMPLE DATA
// ============================================================================

fn initSampleData() void {
    exceptions_data.appendSlice(data) catch |err| Vapor.printErr("Failed to append exceptions: {any}", .{err});
    traces_array.appendSlice(traces_data) catch |err| Vapor.printErr("Failed to append traces: {any}", .{err});
}

// Chart data
const revenue_points = [_]ChartEnhanced.Point{
    .{ .x = 1, .y = 12400 },
    .{ .x = 2, .y = 15800 },
    .{ .x = 3, .y = 13200 },
    .{ .x = 4, .y = 18900 },
    .{ .x = 5, .y = 22100 },
    .{ .x = 6, .y = 19500 },
    .{ .x = 7, .y = 24800 },
    .{ .x = 8, .y = 28300 },
    .{ .x = 9, .y = 25600 },
    .{ .x = 10, .y = 31200 },
    .{ .x = 11, .y = 29800 },
    .{ .x = 12, .y = 35400 },
};

const exceptions_points = [_]ChartEnhanced.Point{
    .{ .x = 1, .y = 1450 },
    .{ .x = 2, .y = 18900 },
    .{ .x = 3, .y = 1670 },
    .{ .x = 4, .y = 2129 },
    .{ .x = 5, .y = 8560 },
    .{ .x = 6, .y = 5340 },
    .{ .x = 7, .y = 12780 },
    .{ .x = 8, .y = 6120 },
    .{ .x = 9, .y = 2890 },
    .{ .x = 10, .y = 15450 },
    .{ .x = 11, .y = 3230 },
    .{ .x = 12, .y = 9890 },
};

// Define colors for each status code category
const gray = Vapor.Types.Color.hex("#212121"); // 1/2/3XX
const yellow = Vapor.Types.Color.hex("#FFBF00"); // 4XX
const red = Vapor.Types.Color.hex("#2108FF"); // 5XX
const danger = Vapor.Types.Color.palette(.danger);
const dark_red = Vapor.Types.Color.hex("#C91818");
const green = Vapor.Types.Color.hex("#22bc8b");
const light_gray = Vapor.Types.Color.hex("#D9D9D9");

// Create data points with stacked segments
// Each point represents a time bucket
const data_1xx_2xx_3xx = [_]ChartEnhanced.Point{
    .{ .x = 1, .stack = &.{ .{ .value = 50, .color = gray }, .{ .value = 30, .color = gray }, .{ .value = 15, .color = yellow }, .{ .value = 20, .color = red } } },
    .{ .x = 2, .stack = &.{ .{ .value = 40, .color = gray }, .{ .value = 25, .color = gray }, .{ .value = 25, .color = yellow }, .{ .value = 30, .color = red } } },
    .{ .x = 3, .stack = &.{ .{ .value = 60, .color = gray }, .{ .value = 35, .color = gray }, .{ .value = 10, .color = yellow }, .{ .value = 20, .color = red } } },
    .{ .x = 4, .stack = &.{ .{ .value = 45, .color = gray }, .{ .value = 20, .color = gray }, .{ .value = 30, .color = yellow }, .{ .value = 40, .color = red } } },
    .{ .x = 5, .stack = &.{ .{ .value = 55, .color = gray }, .{ .value = 28, .color = gray }, .{ .value = 18, .color = yellow }, .{ .value = 25, .color = red } } },
    .{ .x = 6, .stack = &.{ .{ .value = 70, .color = gray }, .{ .value = 40, .color = gray }, .{ .value = 12, .color = yellow }, .{ .value = 15, .color = red } } },
    .{ .x = 7, .stack = &.{ .{ .value = 35, .color = gray }, .{ .value = 22, .color = gray }, .{ .value = 28, .color = yellow }, .{ .value = 35, .color = red } } },
    .{ .x = 8, .stack = &.{ .{ .value = 48, .color = gray }, .{ .value = 32, .color = gray }, .{ .value = 20, .color = yellow }, .{ .value = 22, .color = red } } },
    .{ .x = 9, .stack = &.{ .{ .value = 62, .color = gray }, .{ .value = 38, .color = gray }, .{ .value = 8, .color = yellow }, .{ .value = 12, .color = red } } },
    .{ .x = 10, .stack = &.{ .{ .value = 42, .color = gray }, .{ .value = 18, .color = gray }, .{ .value = 35, .color = yellow }, .{ .value = 45, .color = red } } },
    .{ .x = 11, .stack = &.{ .{ .value = 58, .color = gray }, .{ .value = 33, .color = gray }, .{ .value = 14, .color = yellow }, .{ .value = 18, .color = red } } },
    .{ .x = 12, .stack = &.{ .{ .value = 75, .color = gray }, .{ .value = 45, .color = gray }, .{ .value = 10, .color = yellow }, .{ .value = 10, .color = red } } },
    .{ .x = 13, .stack = &.{ .{ .value = 30, .color = gray }, .{ .value = 15, .color = gray }, .{ .value = 40, .color = yellow }, .{ .value = 50, .color = red } } },
    .{ .x = 14, .stack = &.{ .{ .value = 52, .color = gray }, .{ .value = 30, .color = gray }, .{ .value = 22, .color = yellow }, .{ .value = 28, .color = red } } },
    .{ .x = 15, .stack = &.{ .{ .value = 65, .color = gray }, .{ .value = 42, .color = gray }, .{ .value = 15, .color = yellow }, .{ .value = 16, .color = red } } },
    .{ .x = 16, .stack = &.{ .{ .value = 38, .color = gray }, .{ .value = 24, .color = gray }, .{ .value = 32, .color = yellow }, .{ .value = 38, .color = red } } },
    .{ .x = 17, .stack = &.{.{ .value = 120, .color = red }} },
    .{ .x = 18, .stack = &.{.{ .value = 140, .color = red }} },
    .{ .x = 19, .stack = &.{.{ .value = 90, .color = red }} },
    .{ .x = 20, .stack = &.{ .{ .value = 68, .color = gray }, .{ .value = 44, .color = gray }, .{ .value = 12, .color = yellow }, .{ .value = 14, .color = red } } },
    .{ .x = 21, .stack = &.{ .{ .value = 34, .color = gray }, .{ .value = 20, .color = gray }, .{ .value = 36, .color = yellow }, .{ .value = 42, .color = red } } },
    .{ .x = 22, .stack = &.{ .{ .value = 80, .color = gray }, .{ .value = 50, .color = gray }, .{ .value = 6, .color = yellow }, .{ .value = 6, .color = red } } },
    .{ .x = 23, .stack = &.{.{ .value = 60, .color = red }} },
    .{ .x = 24, .stack = &.{.{ .value = 74, .color = red }} },
    .{ .x = 25, .stack = &.{ .{ .value = 63, .color = gray }, .{ .value = 40, .color = gray } } },
    .{ .x = 26, .stack = &.{ .{ .value = 41, .color = gray }, .{ .value = 23, .color = gray }, .{ .value = 30, .color = yellow }, .{ .value = 36, .color = red } } },
    .{ .x = 27, .stack = &.{ .{ .value = 77, .color = gray }, .{ .value = 46, .color = gray }, .{ .value = 9, .color = yellow }, .{ .value = 11, .color = red } } },
    .{ .x = 28, .stack = &.{ .{ .value = 36, .color = gray }, .{ .value = 19, .color = gray }, .{ .value = 34, .color = yellow }, .{ .value = 44, .color = red } } },
    .{ .x = 29, .stack = &.{ .{ .value = 59, .color = gray }, .{ .value = 37, .color = gray }, .{ .value = 16, .color = yellow }, .{ .value = 19, .color = red } } },
    .{ .x = 30, .stack = &.{ .{ .value = 71, .color = gray }, .{ .value = 43, .color = gray }, .{ .value = 11, .color = yellow }, .{ .value = 13, .color = red } } },
    .{ .x = 31, .stack = &.{ .{ .value = 49, .color = gray }, .{ .value = 29, .color = gray } } },
    .{ .x = 32, .stack = &.{ .{ .value = 66, .color = gray }, .{ .value = 41, .color = gray } } },
    .{ .x = 33, .stack = &.{ .{ .value = 39, .color = gray }, .{ .value = 21, .color = gray } } },
    .{ .x = 34, .stack = &.{ .{ .value = 85, .color = gray }, .{ .value = 52, .color = gray } } },
    .{ .x = 35, .stack = &.{ .{ .value = 47, .color = gray }, .{ .value = 27, .color = gray } } },
    .{ .x = 36, .stack = &.{ .{ .value = 61, .color = gray }, .{ .value = 39, .color = gray } } },
    .{ .x = 37, .stack = &.{ .{ .value = 53, .color = gray }, .{ .value = 31, .color = gray } } },
    .{ .x = 38, .stack = &.{ .{ .value = 74, .color = gray }, .{ .value = 47, .color = gray } } },
    .{ .x = 39, .stack = &.{ .{ .value = 43, .color = gray }, .{ .value = 25, .color = gray } } },
    .{ .x = 40, .stack = &.{ .{ .value = 67, .color = gray }, .{ .value = 42, .color = gray } } },
    .{ .x = 41, .stack = &.{ .{ .value = 50, .color = gray }, .{ .value = 30, .color = gray } } },
    .{ .x = 42, .stack = &.{ .{ .value = 40, .color = gray }, .{ .value = 25, .color = gray } } },
    .{ .x = 43, .stack = &.{ .{ .value = 60, .color = gray }, .{ .value = 35, .color = gray }, .{ .value = 10, .color = yellow }, .{ .value = 20, .color = red } } },
    .{ .x = 44, .stack = &.{ .{ .value = 45, .color = gray }, .{ .value = 20, .color = gray }, .{ .value = 30, .color = yellow }, .{ .value = 40, .color = red } } },
    .{ .x = 45, .stack = &.{ .{ .value = 55, .color = gray }, .{ .value = 28, .color = gray }, .{ .value = 18, .color = yellow }, .{ .value = 25, .color = red } } },
    .{ .x = 46, .stack = &.{ .{ .value = 70, .color = gray }, .{ .value = 40, .color = gray }, .{ .value = 12, .color = yellow }, .{ .value = 15, .color = red } } },
    .{ .x = 47, .stack = &.{ .{ .value = 35, .color = gray }, .{ .value = 22, .color = gray }, .{ .value = 28, .color = yellow }, .{ .value = 35, .color = red } } },
    .{ .x = 48, .stack = &.{ .{ .value = 48, .color = gray }, .{ .value = 32, .color = gray }, .{ .value = 20, .color = yellow }, .{ .value = 22, .color = red } } },
    .{ .x = 49, .stack = &.{ .{ .value = 62, .color = gray }, .{ .value = 38, .color = gray }, .{ .value = 8, .color = yellow }, .{ .value = 12, .color = red } } },
    .{ .x = 50, .stack = &.{ .{ .value = 42, .color = gray }, .{ .value = 18, .color = gray }, .{ .value = 35, .color = yellow }, .{ .value = 45, .color = red } } },
    .{ .x = 51, .stack = &.{ .{ .value = 58, .color = gray }, .{ .value = 33, .color = gray }, .{ .value = 14, .color = yellow }, .{ .value = 18, .color = red } } },
    .{ .x = 52, .stack = &.{ .{ .value = 75, .color = gray }, .{ .value = 45, .color = gray }, .{ .value = 10, .color = yellow }, .{ .value = 10, .color = red } } },
    .{ .x = 53, .stack = &.{ .{ .value = 41, .color = gray }, .{ .value = 23, .color = gray }, .{ .value = 30, .color = yellow }, .{ .value = 36, .color = red } } },
    .{ .x = 54, .stack = &.{ .{ .value = 77, .color = gray }, .{ .value = 46, .color = gray }, .{ .value = 9, .color = yellow }, .{ .value = 11, .color = red } } },
    .{ .x = 55, .stack = &.{ .{ .value = 36, .color = gray }, .{ .value = 19, .color = gray }, .{ .value = 34, .color = yellow }, .{ .value = 44, .color = red } } },
    .{ .x = 56, .stack = &.{ .{ .value = 59, .color = gray }, .{ .value = 37, .color = gray }, .{ .value = 16, .color = yellow }, .{ .value = 19, .color = red } } },
    .{ .x = 57, .stack = &.{ .{ .value = 71, .color = gray }, .{ .value = 43, .color = gray }, .{ .value = 11, .color = yellow }, .{ .value = 13, .color = red } } },
    .{ .x = 58, .stack = &.{ .{ .value = 49, .color = gray }, .{ .value = 29, .color = gray }, .{ .value = 23, .color = yellow }, .{ .value = 27, .color = red } } },
    .{ .x = 59, .stack = &.{ .{ .value = 66, .color = gray }, .{ .value = 41, .color = gray }, .{ .value = 13, .color = yellow }, .{ .value = 15, .color = red } } },
    .{ .x = 60, .stack = &.{ .{ .value = 39, .color = gray }, .{ .value = 21, .color = gray }, .{ .value = 31, .color = yellow }, .{ .value = 40, .color = red } } },
};

const data_4xx = [_]ChartEnhanced.Point{
    .{ .x = 1, .stack = &.{.{ .value = 15, .color = yellow }} },
    .{ .x = 2, .stack = &.{.{ .value = 25, .color = yellow }} },
    .{ .x = 3, .stack = &.{.{ .value = 10, .color = yellow }} },
    .{ .x = 4, .stack = &.{.{ .value = 30, .color = yellow }} },
};

const data_5xx = [_]ChartEnhanced.Point{
    .{ .x = 1, .stack = &.{.{ .value = 20, .color = red }} },
    .{ .x = 2, .stack = &.{.{ .value = 35, .color = red }} },
    .{ .x = 3, .stack = &.{.{ .value = 15, .color = red }} },
    .{ .x = 4, .stack = &.{.{ .value = 25, .color = red }} },
};

const error_1xx_2xx_3xx = [_]ChartEnhanced.Point{
    .{ .x = 1, .stack = &.{ .{ .value = 50, .color = danger }, .{ .value = 30, .color = danger }, .{ .value = 15, .color = dark_red }, .{ .value = 20, .color = gray } } },
    .{ .x = 2, .stack = &.{ .{ .value = 40, .color = danger }, .{ .value = 25, .color = danger }, .{ .value = 25, .color = dark_red }, .{ .value = 30, .color = gray } } },
    .{ .x = 3, .stack = &.{ .{ .value = 60, .color = danger }, .{ .value = 35, .color = danger }, .{ .value = 10, .color = dark_red }, .{ .value = 20, .color = gray } } },
    .{ .x = 4, .stack = &.{ .{ .value = 45, .color = danger }, .{ .value = 20, .color = danger }, .{ .value = 30, .color = dark_red }, .{ .value = 40, .color = gray } } },
    .{ .x = 5, .stack = &.{ .{ .value = 55, .color = danger }, .{ .value = 28, .color = danger }, .{ .value = 18, .color = dark_red }, .{ .value = 25, .color = gray } } },
    .{ .x = 6, .stack = &.{ .{ .value = 70, .color = danger }, .{ .value = 40, .color = danger }, .{ .value = 12, .color = dark_red }, .{ .value = 15, .color = gray } } },
    .{ .x = 7, .stack = &.{ .{ .value = 35, .color = danger }, .{ .value = 22, .color = danger }, .{ .value = 28, .color = dark_red }, .{ .value = 35, .color = gray } } },
    .{ .x = 8, .stack = &.{ .{ .value = 48, .color = danger }, .{ .value = 32, .color = danger }, .{ .value = 20, .color = dark_red }, .{ .value = 22, .color = gray } } },
    .{ .x = 9, .stack = &.{ .{ .value = 62, .color = danger }, .{ .value = 38, .color = danger }, .{ .value = 8, .color = dark_red }, .{ .value = 12, .color = gray } } },
    .{ .x = 10, .stack = &.{ .{ .value = 42, .color = danger }, .{ .value = 18, .color = danger }, .{ .value = 35, .color = dark_red }, .{ .value = 45, .color = gray } } },
    .{ .x = 11, .stack = &.{ .{ .value = 58, .color = danger }, .{ .value = 33, .color = danger }, .{ .value = 14, .color = dark_red }, .{ .value = 18, .color = gray } } },
    .{ .x = 12, .stack = &.{ .{ .value = 75, .color = danger }, .{ .value = 45, .color = danger }, .{ .value = 10, .color = dark_red }, .{ .value = 10, .color = gray } } },
    .{ .x = 13, .stack = &.{ .{ .value = 30, .color = danger }, .{ .value = 15, .color = danger }, .{ .value = 40, .color = dark_red }, .{ .value = 50, .color = gray } } },
    .{ .x = 14, .stack = &.{ .{ .value = 52, .color = danger }, .{ .value = 30, .color = danger }, .{ .value = 22, .color = dark_red }, .{ .value = 28, .color = gray } } },
    .{ .x = 15, .stack = &.{ .{ .value = 65, .color = danger }, .{ .value = 42, .color = danger }, .{ .value = 15, .color = dark_red }, .{ .value = 16, .color = gray } } },
    // .{ .x = 16, .stack = &.{ .{ .value = 38, .color = danger }, .{ .value = 24, .color = danger }, .{ .value = 32, .color = dark_red }, .{ .value = 38, .color = gray } } },
    // .{ .x = 17, .stack = &.{.{ .value = 120, .color = gray }} },
    // .{ .x = 18, .stack = &.{.{ .value = 140, .color = gray }} },
    .{ .x = 19, .stack = &.{.{ .value = 90, .color = gray }} },
    .{ .x = 20, .stack = &.{ .{ .value = 68, .color = danger }, .{ .value = 44, .color = danger }, .{ .value = 12, .color = dark_red }, .{ .value = 14, .color = gray } } },
    .{ .x = 21, .stack = &.{ .{ .value = 34, .color = danger }, .{ .value = 20, .color = danger }, .{ .value = 36, .color = dark_red }, .{ .value = 42, .color = gray } } },
    .{ .x = 22, .stack = &.{ .{ .value = 80, .color = danger }, .{ .value = 50, .color = danger }, .{ .value = 6, .color = dark_red }, .{ .value = 6, .color = gray } } },
    .{ .x = 23, .stack = &.{.{ .value = 60, .color = gray }} },
    .{ .x = 24, .stack = &.{.{ .value = 74, .color = gray }} },
    .{ .x = 25, .stack = &.{ .{ .value = 63, .color = danger }, .{ .value = 40, .color = danger } } },
    // .{ .x = 26, .stack = &.{ .{ .value = 41, .color = danger }, .{ .value = 23, .color = danger }, .{ .value = 30, .color = dark_red }, .{ .value = 36, .color = gray } } },
    .{ .x = 27, .stack = &.{ .{ .value = 77, .color = danger }, .{ .value = 46, .color = danger }, .{ .value = 9, .color = dark_red }, .{ .value = 11, .color = gray } } },
    .{ .x = 28, .stack = &.{ .{ .value = 36, .color = danger }, .{ .value = 19, .color = danger }, .{ .value = 34, .color = dark_red }, .{ .value = 44, .color = gray } } },
    .{ .x = 29, .stack = &.{ .{ .value = 59, .color = danger }, .{ .value = 37, .color = danger }, .{ .value = 16, .color = dark_red }, .{ .value = 19, .color = gray } } },
    .{ .x = 30, .stack = &.{ .{ .value = 71, .color = danger }, .{ .value = 43, .color = danger }, .{ .value = 11, .color = dark_red }, .{ .value = 13, .color = gray } } },
    .{ .x = 31, .stack = &.{ .{ .value = 49, .color = danger }, .{ .value = 29, .color = danger } } },
    .{ .x = 32, .stack = &.{ .{ .value = 66, .color = danger }, .{ .value = 41, .color = danger } } },
    .{ .x = 33, .stack = &.{ .{ .value = 39, .color = danger }, .{ .value = 21, .color = danger } } },
    .{ .x = 34, .stack = &.{ .{ .value = 85, .color = danger }, .{ .value = 52, .color = danger } } },
    .{ .x = 35, .stack = &.{ .{ .value = 47, .color = danger }, .{ .value = 27, .color = danger } } },
    .{ .x = 36, .stack = &.{ .{ .value = 61, .color = danger }, .{ .value = 39, .color = danger } } },
    .{ .x = 37, .stack = &.{ .{ .value = 53, .color = danger }, .{ .value = 31, .color = danger } } },
    .{ .x = 38, .stack = &.{ .{ .value = 74, .color = danger }, .{ .value = 47, .color = danger } } },
    .{ .x = 39, .stack = &.{ .{ .value = 43, .color = danger }, .{ .value = 25, .color = danger } } },
    .{ .x = 40, .stack = &.{ .{ .value = 67, .color = danger }, .{ .value = 42, .color = danger } } },
    .{ .x = 41, .stack = &.{ .{ .value = 50, .color = danger }, .{ .value = 30, .color = danger } } },
    .{ .x = 42, .stack = &.{ .{ .value = 40, .color = danger }, .{ .value = 25, .color = danger } } },
};

const cpu_points = [_]ChartEnhanced.Point{
    .{ .x = 1, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 2, .stack = &.{.{ .value = 30, .color = green }} },
    .{ .x = 3, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 4, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 5, .stack = &.{.{ .value = 38, .color = green }} },
    .{ .x = 6, .stack = &.{.{ .value = 28, .color = green }} },
    .{ .x = 7, .stack = &.{.{ .value = 35, .color = green }} },
    .{ .x = 8, .stack = &.{.{ .value = 32, .color = green }} },
    .{ .x = 9, .stack = &.{.{ .value = 30, .color = green }} },
    .{ .x = 10, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 11, .stack = &.{.{ .value = 25, .color = green }} },
    .{ .x = 12, .stack = &.{.{ .value = 15, .color = green }} },
    .{ .x = 13, .stack = &.{.{ .value = 10, .color = green }} },
    .{ .x = 14, .stack = &.{.{ .value = 30, .color = green }} },
    .{ .x = 15, .stack = &.{.{ .value = 20, .color = green }} },
    .{ .x = 16, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 17, .stack = &.{.{ .value = 25, .color = green }} },
    .{ .x = 18, .stack = &.{.{ .value = 15, .color = green }} },
    .{ .x = 19, .stack = &.{.{ .value = 10, .color = green }} },
    .{ .x = 20, .stack = &.{.{ .value = 30, .color = green }} },
    .{ .x = 21, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 22, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 23, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 24, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 25, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 26, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 27, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 28, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 29, .stack = &.{.{ .value = 40, .color = green }} },
    .{ .x = 30, .stack = &.{.{ .value = 20, .color = green }} },
};

// ============================================================================
// COLORS
// ============================================================================

pub const Theme = struct {
    pub const row_background = Vapor.Types.Background.hex("#FBFBF9");
    // pub const bg_base = Vapor.Types.Background.hex("#f8f7f3");
    pub const bg_base = Vapor.Types.Background.palette(.background);
    pub const bg_card = Vapor.Types.Background.palette(.background);
    pub const bg_elevated = Vapor.Types.Background.palette(.background);
    pub const bg_hover = Vapor.Types.Background.hex("#3f3f46");
    pub const border = Vapor.Types.Color.hex("#27272a");
    pub const border_light = Vapor.Types.Color.hex("#3f3f46");
    pub const text = Vapor.Types.Color.palette(.text_color);
    pub const text_secondary = Vapor.Types.Color.hex("#a1a1aa");
    pub const text_muted = Vapor.Types.Color.hex("#71717a");
    pub const accent = Vapor.Types.Color.hex("#6366f1");
    pub const accent_hover = Vapor.Types.Color.hex("#818cf8");
    pub const success = Vapor.Types.Color.hex("#10b981");
    pub const warning = Vapor.Types.Color.hex("#F5590B");
    pub const err = Vapor.Types.Color.hex("#ef4444");
    pub const gradient_start = Vapor.Types.Color.hex("#6366f1");
    pub const gradient_end = Vapor.Types.Color.hex("#8b5cf6");
};

// ============================================================================
// EVENT HANDLERS
// ============================================================================

fn selectNav(item: NavItem) void {
    Vapor.lib.store("selected_nav", @tagName(item));
    selected_nav = item;
}

fn selectTimeRange(_: *Select(TimeRange), item: *Select(TimeRange).Item) void {
    selected_time_range = item.value;
}

fn toggleLiveMode() void {
    is_live_mode = !is_live_mode;
    if (is_live_mode) {
        Toast.success(.{ .title = "Live Mode Enabled", .description = "Data will refresh automatically" });
    } else {
        Toast.info(.{ .title = "Live Mode Disabled", .description = "Data is now static" });
    }
}

fn toggleDatePicker() void {
    show_date_picker = !show_date_picker;
}

fn handleViewException(txn: *Exception) void {
    Vapor.print("handleViewException {s}", .{txn.user.email});
    selected_exception = txn;
    detail_sheet.open();
}

fn handleRefundException(_: *Exception) void {
    // txn.status = .refunded;
    // Toast.success(.{ .title = "Refund Initiated", .description = "Exception will be refunded within 3-5 business days" });
    // detail_sheet.close();
}

fn handleDeleteException(txn: *Exception) void {
    _ = txn;
    Toast.warning(.{ .title = "Exception Deleted", .description = "This action cannot be undone" });
}

fn handleTableSelect(txn: *Exception) void {
    selected_exception = txn;
}

fn closeDetailSheet() void {
    detail_sheet.close();
    selected_exception = null;
}

fn handleExport() void {
    Toast.info(.{ .title = "Exporting Data", .description = "Your report will be ready shortly" });
}

fn handleRefresh() void {
    Toast.success(.{ .title = "Data Refreshed", .description = "All metrics are up to date" });
}

fn onSearch(evt: *Vapor.Event) void {
    std.log.info("onSearch", .{});
    exceptions_table.onSearch(evt.text(), 0);
}

// ============================================================================
// INITIALIZATION
// ============================================================================

var progress_circle: ProgressCircle = undefined;
const max_progress: f64 = 78;
pub fn init() void {
    Vapor.Page(.{ .route = "/acorn/dashboard" }, render, null);

    Overview.init();
    Database.init();
    // Build animations
    pulse_glow.build();
    slide_up.build();
    fade_scale.build();
    shimmer.build();

    // Initialize data
    exceptions_data = Vapor.array(Exception, .persist);
    events_data = Vapor.array(AnalyticsEvent, .persist);
    traces_array = Vapor.array(Trace, .persist);
    initSampleData();

    // Initialize table
    exceptions_table.init(exceptions_data.items);
    exceptions_table.on_select = handleTableSelect;
    exceptions_table.row_background = Theme.row_background;
    exceptions_table.row_border = .simple(.palette(.border_color_light));
    exceptions_table.row_spacing = 4;

    traces_table.init(traces_array.items);
    // traces_table.on_select = handleTableSelect;

    // Initialize chart
    revenue_chart = ChartEnhanced.init(Vapor.arena(.persist), .{
        .height = 200,
        .width = 500,
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });

    revenue_chart.addSeries(.line, "Revenue", &revenue_points, .{ .color = .palette(.text_color) }) catch unreachable;
    revenue_chart.addSeries(.line, "Exceptions", &exceptions_points, .{ .color = .palette(.border_color_light) }) catch unreachable;
    revenue_chart.xAxis(.{ .label = "Month", .tick_count = 12 });
    revenue_chart.yAxis(.{ .label = "", .tick_count = 6 });
    revenue_chart.legend(.{ .position = .top_left, .text_color = .palette(.text_color) });
    revenue_chart.build() catch unreachable;

    cpu_chart = ChartEnhanced.init(Vapor.arena(.persist), .{
        .height = 40,
        .width = 300,
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
        .margin = .{ .top = 0, .bottom = 0, .left = 0, .right = 0 }, // Defaults
    });
    cpu_chart.addSeries(.stacked_bar, "CPU", &cpu_points, .{
        .color = light_gray,
        .bar_radius = 0,
        .shadow_color = .transparentizeHex(.hex("#000000"), 0.5),
        .show_shadow = true,
    }) catch unreachable;
    cpu_chart.build() catch unreachable;

    memory_chart = ChartEnhanced.init(Vapor.arena(.persist), .{
        .height = 40,
        .width = 300,
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
        .margin = .{ .top = 0, .bottom = 0, .left = 0, .right = 0 }, // Defaults
    });
    memory_chart.addSeries(.stacked_bar, "Memory", &cpu_points, .{
        .color = light_gray,
        .bar_radius = 0,
        .shadow_color = .transparentizeHex(.hex("#000000"), 0.5),
        .show_shadow = true,
    }) catch unreachable;
    memory_chart.build() catch unreachable;

    // Initialize chart
    requests_chart = ChartEnhanced.init(Vapor.arena(.persist), .{
        .height = 240,
        .width = 500,
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });

    requests_chart.addSeries(.stacked_bar, "1/2XX", &data_1xx_2xx_3xx, .{
        .color = gray,
        .bar_radius = 0,
        .border = .top(1, .hex("#000000")),
        .stroke = .hex("#000000"),
        .stroke_width = 0.5,
    }) catch unreachable;

    requests_chart.xAxis(.{ .label = "Time", .tick_count = 4 });
    requests_chart.yAxis(.{ .label = "Requests", .tick_count = 5 });
    requests_chart.legend(.{
        .position = .top_right,
        .direction = .row,
        .text_color = .palette(.text_color),
        .fields = &.{
            // .{ .title = "1/2/3XX", .color = gray, .background = gray },
            .{ .title = "3XX", .color = gray, .background = gray },
            .{ .title = "4XX", .color = yellow, .background = yellow },
            .{ .title = "5XX", .color = red, .background = red },
        },
    });

    requests_chart.build() catch unreachable;

    error_chart = ChartEnhanced.init(Vapor.arena(.persist), .{
        .height = 220,
        .width = 400,
        .margin = .{ .top = 20, .bottom = 0, .left = 0, .right = 0 }, // Defaults
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });
    error_chart.onendselection = onEndSelection;

    error_chart.addSeries(.stacked_bar, "1/2XX", &error_1xx_2xx_3xx, .{
        .color = danger,
        .bar_radius = 0,
        .border = .top(1, .hex("#000000")),
        .stroke = .hex("#000000"),
        .stroke_width = 0.5,
    }) catch unreachable;
    // error_chart.xAxis(.{ .label = "Time", .tick_count = 4 });
    // error_chart.yAxis(.{ .label = "Errors", .tick_count = 5 });
    error_chart.legend(.{
        .position = .top_right,
        .direction = .row,
        .text_color = .palette(.text_color),
        .fields = &.{
            // .{ .title = "1/2/3XX", .color = gray, .background = gray },
            .{ .title = "3XX", .color = danger, .background = danger },
            .{ .title = "4XX", .color = dark_red, .background = dark_red },
            .{ .title = "5XX", .color = gray, .background = gray },
        },
    });
    error_chart.build() catch unreachable;

    // status_filter = .fromItems(&status_options);
    time_range_select = .fromItems(&time_range_options);
    time_range_select.on_select = selectTimeRange;
    time_range_select.trigger = "Time Range";

    // Initialize sheet
    detail_sheet = Sheet.init(.right);
    detail_sheet.content = renderDetailSheetContent;

    progress_circle = ProgressCircle.init(Vapor.arena(.persist), .{
        .size = 120,
        .start_angle = -165,
        .track_color = .transparent,
        .rounded_caps = false,
        .color = .palette(.tint),
    });

    progress_circle.setPercent(78);

    // Initialize date picker
    date_picker.init();
}

fn onEndSelection(x_min: f64, x_max: f64, y_min: f64, y_max: f64) void {
    error_chart.updateFullSeries(&.{});
    std.log.info("onEndSelection {d} {d} {d} {d}", .{ x_min, x_max, y_min, y_max });
}

// ============================================================================
// COMPONENTS
// ============================================================================

const ICON_AREA_WIDTH = 40; // Fixed width for icon column
const SIDEBAR_COLLAPSED = 40 + 10 + 10; // icon + padding both sides = 80px
const SIDEBAR_EXPANDED = 240; // or whatever you want

fn SmallMenu() void {
    // Logo
    Box()
        .width(.percent(100))
        .layout(.left_center)
        .spacing(12)
        .children({
        Box()
            .height(.px(40))
            .width(.px(ICON_AREA_WIDTH))
            .layout(.center)
            .children({
            Icon(.flower)
                .font(20, 700, .black)
                .end();
        });
    });

    // Navigation Items
    Stack()
        .width(.percent(100))
        .layout(.left_center)
        .children({
        for (std.enums.values(NavItem)) |nav_item| {
            const is_active = selected_nav == nav_item;
            Box()
                .layout(.left_center)
                .width(.px(40))
                .height(.px(40))
                .pointer()
                .background(if (is_active) .transparentizeHex(.palette(.tint), 1) else .transparent)
                .duration(150)
                .pos(.relative)
                .children({
                Box()
                    .height(.px(40))
                    .width(.px(40))
                    .layout(.center)
                    .children({
                    Icon(nav_item.icon())
                        .font(14, 100, if (nav_item == selected_nav) .white else Theme.text_secondary)
                        .end();
                });
                if (is_active) {
                    const border_tl: Vapor.Types.BorderGrouped = if (!is_hovered) .sharp(.tblr(0, 1, 0, 1), .palette(.tint)) else .sharp(.tblr(1, 0, 1, 0), .hex("#222160"));
                    const border_tl_pos: Vapor.Types.Position = if (!is_hovered) .tl(.px(-6), .px(-6), .absolute) else .tl(.px(-1), .px(-1), .absolute);
                    Box()
                        .pos(border_tl_pos)
                        .width(.px(6))
                        .height(.px(6))
                        .border(border_tl)
                        .children({});

                    const border_tr: Vapor.Types.BorderGrouped = if (!is_hovered) .sharp(.tblr(0, 1, 1, 0), .palette(.tint)) else .sharp(.tblr(1, 0, 0, 1), .hex("#222160"));
                    const border_tr_pos: Vapor.Types.Position = if (!is_hovered) .tr(.px(-6), .px(-6), .absolute) else .tr(.px(-1), .px(-1), .absolute);

                    Box()
                        .pos(border_tr_pos)
                        .width(.px(6))
                        .height(.px(6))
                        .border(border_tr)
                        .children({});

                    const border_bl: Vapor.Types.BorderGrouped = if (!is_hovered) .sharp(.tblr(1, 0, 0, 1), .palette(.tint)) else .sharp(.tblr(0, 1, 1, 0), .hex("#222160"));
                    const border_bl_pos: Vapor.Types.Position = if (!is_hovered) .bl(.px(-6), .px(-6), .absolute) else .bl(.px(-1), .px(-1), .absolute);

                    Box()
                        .pos(border_bl_pos)
                        .width(.px(6))
                        .height(.px(6))
                        .border(border_bl)
                        .children({});

                    const border_br: Vapor.Types.BorderGrouped = if (!is_hovered) .sharp(.tblr(1, 0, 1, 0), .palette(.tint)) else .sharp(.tblr(0, 1, 0, 1), .hex("#222160"));
                    const border_br_pos: Vapor.Types.Position = if (!is_hovered) .br(.px(-6), .px(-6), .absolute) else .br(.px(-1), .px(-1), .absolute);

                    Box()
                        .pos(border_br_pos)
                        .width(.px(6))
                        .height(.px(6))
                        .border(border_br)
                        .children({});
                } else {
                    Vapor.Null();
                }
            });
        }
    });
}

fn hover(_: *Vapor.Event) void {
    sidebar.show_menu = true;
}

fn leave(_: *Vapor.Event) void {
    sidebar.show_menu = false;
}

var is_hovered: bool = false;

fn onHoverNav(is_active: bool, _: *Vapor.Event) void {
    if (is_active) {
        is_hovered = true;
    } else {
        is_hovered = false;
    }
}

fn onLeaveNav(_: *Vapor.Event) void {
    is_hovered = false;
}

fn renderNavigation() void {
    const sidebar_width: Vapor.Types.Sizing = if (sidebar.show_menu) .px(SIDEBAR_EXPANDED) else .px(SIDEBAR_COLLAPSED);
    Box()
        .pos(.tl(.percent(0), .percent(0), .relative))
        .width(sidebar_width)
        .height(.percent(100))
        .transformOrigin(.left)
        .transition(.{ .properties = &.{ .transform, .width, .opacity, .padding }, .duration = 100, .timing = .easeInOut })
        .border(.right(1, .palette(.border_color_light)))
        .onHover(hover)
        .onLeave(leave)
        .children({
        Stack()
            .pos(.tl(.percent(0), .percent(0), .absolute))
            .width(.percent(100))
            .height(.percent(100))
            .padding(.all(10))
            .spacing(4)
            .children({
            if (!sidebar.show_menu) {
                SmallMenu();
            } else {
                // Logo
                Box()
                    .layout(.left_center)
                    .spacing(12)
                    .children({
                    Box()
                        .height(.px(40))
                        .width(.px(ICON_AREA_WIDTH))
                        .layout(.center)
                        .padding(.xy(8, 4))
                        .children({
                        Icon(.flower)
                            .font(20, 700, .black)
                            .end();
                    });

                    Stack()
                        .spacing(0)
                        .children({
                        Text("Bloom")
                            .animationEnter("opaque-fade-in")
                            .animationExit("opaque-fade-out")
                            .font(20, 700, Theme.text)
                            .end();
                    });
                });

                // Navigation Items
                Stack()
                    .width(.percent(100))
                    .layout(.left_center)
                    .children({
                    for (std.enums.values(NavItem)) |nav_item| {
                        const is_active = selected_nav == nav_item;
                        ButtonCtx(selectNav, .{nav_item})
                            .pos(.relative)
                            .layout(.left_center)
                            .spacing(12)
                            .width(.percent(100))
                            .height(.px(40))
                            .pointer()
                            .duration(150)
                            .background(if (is_active) .transparentizeHex(.palette(.tint), 1) else .transparent)
                            .hover(.{
                                .background = if (is_active) .hex("#222160") else .palette(.highlight_color),
                            })
                            .onHoverCtx(onHoverNav, is_active)
                            .onLeave(onLeaveNav)
                            .children({
                            if (is_active) {
                                const border_tl: Vapor.Types.BorderGrouped = if (!is_hovered) .sharp(.tblr(0, 1, 0, 1), .palette(.tint)) else .sharp(.tblr(1, 0, 1, 0), .hex("#222160"));
                                const border_tl_pos: Vapor.Types.Position = if (!is_hovered) .tl(.px(-6), .px(-6), .absolute) else .tl(.px(-1), .px(-1), .absolute);
                                Box()
                                    .pos(border_tl_pos)
                                    .width(.px(6))
                                    .height(.px(6))
                                    .border(border_tl)
                                    .children({});

                                const border_tr: Vapor.Types.BorderGrouped = if (!is_hovered) .sharp(.tblr(0, 1, 1, 0), .palette(.tint)) else .sharp(.tblr(1, 0, 0, 1), .hex("#222160"));
                                const border_tr_pos: Vapor.Types.Position = if (!is_hovered) .tr(.px(-6), .px(-6), .absolute) else .tr(.px(-1), .px(-1), .absolute);

                                Box()
                                    .pos(border_tr_pos)
                                    .width(.px(6))
                                    .height(.px(6))
                                    .border(border_tr)
                                    .children({});

                                const border_bl: Vapor.Types.BorderGrouped = if (!is_hovered) .sharp(.tblr(1, 0, 0, 1), .palette(.tint)) else .sharp(.tblr(0, 1, 1, 0), .hex("#222160"));
                                const border_bl_pos: Vapor.Types.Position = if (!is_hovered) .bl(.px(-6), .px(-6), .absolute) else .bl(.px(-1), .px(-1), .absolute);

                                Box()
                                    .pos(border_bl_pos)
                                    .width(.px(6))
                                    .height(.px(6))
                                    .border(border_bl)
                                    .children({});

                                const border_br: Vapor.Types.BorderGrouped = if (!is_hovered) .sharp(.tblr(1, 0, 1, 0), .palette(.tint)) else .sharp(.tblr(0, 1, 0, 1), .hex("#222160"));
                                const border_br_pos: Vapor.Types.Position = if (!is_hovered) .br(.px(-6), .px(-6), .absolute) else .br(.px(-1), .px(-1), .absolute);

                                Box()
                                    .pos(border_br_pos)
                                    .width(.px(6))
                                    .height(.px(6))
                                    .border(border_br)
                                    .children({});
                            } else {
                                Vapor.Null();
                            }

                            Box()
                                .height(.px(40))
                                .width(.px(40))
                                .layout(.center)
                                .children({
                                Icon(nav_item.icon())
                                    .font(14, 100, if (nav_item == selected_nav) .white else Theme.text_secondary)
                                    .end();
                            });

                            Stack()
                                .width(.percent(100))
                                .layout(.left_center)
                                .children({
                                Text(nav_item.label())
                                    .layout(.left_center)
                                    .animationEnter("opaque-fade-in")
                                    .animationExit("opaque-fade-out")
                                    .fontFamily(font_family)
                                    .font(14, 100, if (is_active) .white else Theme.text_secondary)
                                    .end();
                            });
                        });
                    }
                });
            }
        });
    });
}

fn renderNavButton(item: NavItem) void {
    const is_active = selected_nav == item;

    ButtonCtx(selectNav, .{item})
        .width(.percent(100))
        .padding(.xy(14, 4))
        .background(if (is_active) .transparentizeHex(.palette(.tint), 0.1) else .transparent)
        .border(.r(1, if (is_active) .palette(.tint) else .transparent))
        .layer(if (is_active) .dot(0.5, 6, .transparentizeHex(.palette(.tint), 0.3)) else null)
        .layout(.left_center)
        .spacing(12)
        .pointer()
        .duration(150)
        .hover(.{
            .background = if (is_active) .transparentizeHex(.palette(.tint), 0.1) else .palette(.highlight_color),
        })
        .children({
        Box()
            .width(.px(32))
            .height(.px(32))
            .layout(.center)
            .children({
            Icon(item.icon())
                .font(16, 400, if (is_active) .palette(.tint) else Theme.text_secondary)
                .end();
        });
        Text(item.label())
            .font(14, 400, if (is_active) .palette(.tint) else Theme.text_secondary)
            .fontFamily(font_family)
            .end();
    });
}

fn renderHeader() void {
    Box()
        .width(.percent(100))
        // .height(.px(72))
        .padding(.xy(28, 10))
        .background(Theme.bg_base)
        .layout(.x_between_center)
        .children({
        // Left: Title
        Stack()
            .spacing(4)
            .layout(.left_center)
            .background(.palette(.tint))
            .padding(.horizontal(12))
            .children({
            Text(selected_nav.label())
                .fontFamily("Orbitron")
                .font(18, 500, .white)
                .end();
        });

        // Right: Controls
        Box()
            .layout(.right_center)
            .spacing(12)
            .children({

            // Time range select
            Box()
                .width(.px(160))
                .children({
                time_range_select.renderPos(.bottom);
            });

            // Live mode toggle
            Button(toggleLiveMode, .{})
                .padding(.xy(14, 9))
                .children({
                if (is_live_mode) {
                    Box()
                        .width(.px(8))
                        .height(.px(8))
                        .background(.palette(.tint))
                        .border(.round(.palette(.tint), .all(99)))
                        .animation("dashboard-pulse-glow")
                        .children({});
                }
                Text(if (is_live_mode) "Live" else "Paused")
                    .font(13, 500, if (is_live_mode) .palette(.tint) else Theme.text_secondary)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });

            Button(toggleLiveMode, .{})
                .padding(.xy(14, 9))
                .children({
                Text("Export")
                    .font(13, 500, .palette(.text_color))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Icon(.download)
                    .font(14, 400, .palette(.text_color))
                    .end();
            });

            Box()
                .width(.px(40))
                .height(.px(40))
                .pos(.relative)
                .children({
                Button(toggleDatePicker, .{})
                    .width(.px(40))
                    .height(.px(40))
                    .layout(.center)
                    .pointer()
                    .children({
                    Icon(.calendar)
                        .inheritHover(&.{.text_color})
                        .font(18, 700, .palette(.text_color))
                        .end();
                });

                if (show_date_picker) {
                    Box()
                        .pos(.tr(.px(44), .px(0), .absolute))
                        .zIndex(1000)
                        .children({
                        date_picker.render();
                    });
                }
            });

            // Refresh button
            Button(toggleLiveMode, .{})
                .width(.px(40))
                .height(.px(40))
                .layout(.center)
                .pointer()
                .children({
                Icon(.arrow_clockwise)
                    .inheritHover(&.{.text_color})
                    .font(18, 700, .palette(.text_color))
                    .end();
            });
        });
    });
}

fn renderMetricCard(
    comptime title: []const u8,
    comptime value: []const u8,
    comptime change: []const u8,
    comptime is_positive: bool,
    _: *const Vapor.IconTokens,
) void {
    Box()
        .width(.percent(25))
        .padding(.all(24))
        .direction(.column)
        .spacing(16)
        .children({
        Box()
            .layout(.x_between_center)
            .children({
            Text(title)
                .font(18, 500, Theme.text_muted)
                .fontFamily("IBM Plex Mono,monospace")
                .end();
        });

        Stack()
            .spacing(8)
            .children({
            Text(value)
                .font(32, 700, Theme.text)
                .fontFamily("IBM Plex Mono,monospace")
                .end();

            Box()
                .layout(.left_center)
                .spacing(6)
                .children({
                Box()
                    .padding(.xy(6, 3))
                    .background(.transparentizeHex(if (is_positive) Theme.success else Theme.err, 0.5))
                    .border(.round(if (is_positive) Theme.success else Theme.err, .all(4)))
                    .layout(.center)
                    .spacing(4)
                    .children({
                    Icon(if (is_positive) .arrow_up else .arrow_down)
                        .font(10, 600, if (is_positive) Theme.success else Theme.err)
                        .end();
                    Text(change)
                        .font(11, 600, if (is_positive) Theme.success else Theme.err)
                        .fontFamily("IBM Plex Mono,monospace")
                        .end();
                });
                Text("vs last period")
                    .font(12, 400, Theme.text_muted)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });
        });
    });
}

const cut_out =
    \\<svg viewBox="0 0 432 524" fill="none" xmlns="http://www.w3.org/2000/svg">
    \\<g filter="url(#filter0_d_4956_6208)">
    \\<path d="M426 502C426 508.627 420.627 514 414 514H18C11.3726 514 6 508.627 6 502V176C6 169.373 11.3726 164 18 164H156C162.627 164 168 158.627 168 152V14C168 7.37259 173.373 2 180 2H414C420.627 2 426 7.37258 426 14V502Z" />
    \\</g>
    \\<defs>
    \\<filter id="filter0_d_4956_6208" x="0" y="0" width="432" height="524" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
    \\<feFlood flood-opacity="0" result="BackgroundImageFix"/>
    \\<feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
    \\<feOffset dy="4"/>
    \\<feGaussianBlur stdDeviation="3"/>
    \\<feComposite in2="hardAlpha" operator="out"/>
    \\<feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.1 0"/>
    \\<feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow_4956_6208"/>
    \\<feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow_4956_6208" result="shape"/>
    \\</filter>
    \\</defs>
    \\</svg>
;

fn renderDashboardView() void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(28))
        .spacing(28)
        .scroll(.scroll_y())
        .children({
        Box()
            .width(.percent(100))
            .layout(.top_left)
            .direction(.column)
            .height(.percent(100))
            .spacing(20)
            .children({
            // Main chart
            Box()
                .width(.percent(100))
                .height(.percent(100))
                .padding(.all(16))
                .direction(.row)
                .layout(.x_between)
                .border(.round(.palette(.border_color_light), .all(12)))
                .background(.hex("#F8F7F2"))
                .spacing(8)
                .children({
                Stack()
                    .hw(.grow, .px(460))
                    .padding(.all(16))
                    .radius(.all(12))
                    .spacing(12)
                    .background(.hex("#FBFAF7"))
                    .newShadow(Vapor.Types.NewShadow.init()
                        .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.1)))
                    .children({
                    Text("Errors")
                        .font(14, 300, Theme.text)
                        .end();
                    TextFmt("{d} Errors found in the last 24 hours.", .{587})
                        .font(24, 600, Theme.text)
                        .end();
                    TextFmt("Error have impacted {d}", .{4131})
                        .font(18, 300, Theme.text)
                        .margin(.b(32))
                        .end();
                    Stack()
                        .width(.percent(100))
                        .layout(.right_center)
                        .children({
                        error_chart.render();
                        const date = Vapor.DateTime.now().format(Vapor.arena(.frame)) catch "";
                        Box()
                            .width(.percent(100))
                            .layout(.x_even_center)
                            .children({
                            Vapor.Code(date)
                                .font(14, 300, Theme.text_muted).end();
                            Vapor.Code(date)
                                .font(14, 300, Theme.warning).end();
                        });
                    });
                });

                Box()
                    .hw(.grow, .px(360))
                    .direction(.column)
                    .padding(.all(16))
                    .radius(.all(12))
                    .spacing(12)
                    .background(.hex("#FBFAF7"))
                    .newShadow(Vapor.Types.NewShadow.init()
                        .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.1)))
                    .children({
                    Text("Routes")
                        .font(14, 300, Theme.text)
                        .end();
                    TextFmt("{d} Routes are slower than 1000ms", .{23})
                        .font(24, 600, Theme.text)
                        .margin(.b(32))
                        .end();
                    for (0..3) |_| {
                        Box()
                            .width(.percent(100))
                            .padding(.xy(12, 10))
                            .border(.round(.palette(.border_color_light), .all(8)))
                            .hover(.{ .transform = .scaleDecimal(1.01) })
                            .layout(.x_between_center)
                            .newShadow(Vapor.Types.NewShadow.init()
                                .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.05)))
                            .children({
                            Box()
                                .direction(.column)
                                .spacing(4)
                                .children({
                                Vapor.Code("GET|HEAD")
                                    .font(14, 600, .palette(.tint)).end();

                                Vapor.Code("/api/v1/{users}").font(14, 300, Theme.text_muted).end();
                            });
                            Box()
                                .spacing(8)
                                .children({
                                Vapor.Text("P99").font(14, 100, Theme.warning).end();
                                Vapor.Text("1251ms").font(14, 100, .palette(.text_color)).end();
                            });
                        });
                    }
                });
                Box()
                    .direction(.column)
                    .spacing(8)
                    .children({
                    Box()
                        .padding(.all(16))
                        .radius(.all(12))
                        .background(.hex("#FBFAF7"))
                        .newShadow(Vapor.Types.NewShadow.init()
                            .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.1)))
                        .children({
                        revenue_chart.render();
                    });

                    Box()
                        .padding(.all(16))
                        .radius(.all(12))
                        .background(.hex("#FBFAF7"))
                        .newShadow(Vapor.Types.NewShadow.init()
                            .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.1)))
                        .children({
                        requests_chart.render();
                    });
                });
            });
        });

        Box()
            .width(.percent(100))
            .height(.percent(100))
            .padding(.all(16))
            .direction(.row)
            .layout(.x_between)
            .border(.round(.palette(.border_color_light), .all(12)))
            .background(.hex("#F8F7F2"))
            .spacing(8)
            .children({
            Stack()
                .width(.percent(100))
                .height(.percent(100))
                .layout(.right_center)
                .spacing(2)
                .children({
                const date = Vapor.DateTime.now().format(Vapor.arena(.frame)) catch "";
                Box()
                    .spacing(32)
                    .layout(.right_center)
                    .children({
                    Stack()
                        .children({
                        Vapor.Code("CPU").font(14, 300, .palette(.text_color)).end();
                        Vapor.Code("26%").font(14, 300, .palette(.text_color)).end();
                    });
                    Stack()
                        .children({
                        cpu_chart.render();
                        TextFmt("Date: {s}", .{date}).font(12, 300, .palette(.text_color)).end();
                    });
                });
                Box()
                    .spacing(32)
                    .layout(.right_center)
                    .children({
                    Stack()
                        .children({
                        Vapor.Code("MEM").font(14, 300, .palette(.text_color)).end();
                        Vapor.Code("76%").font(14, 300, .palette(.text_color)).end();
                    });
                    Stack()
                        .children({
                        memory_chart.render();
                        TextFmt("Date: {s}", .{date}).font(12, 300, .palette(.text_color)).end();
                    });
                });
            });
        });

        // Exceptions section
        Box()
            .width(.percent(100))
            .padding(.all(24))
            .direction(.column)
            .spacing(20)
            .children({
            Box()
                .layout(.x_between_center)
                .children({
                Stack()
                    .spacing(4)
                    .children({
                    Text("Exceptions")
                        .font(18, 600, Theme.text)
                        .fontFamily("IBM Plex Mono,monospace")
                        .end();
                    Text("Latest exceptions across all channels")
                        .font(13, 400, Theme.text_muted)
                        .fontFamily("IBM Plex Mono,monospace")
                        .end();
                });

                Box()
                    .layout(.right_center)
                    .width(.percent(30))
                    .spacing(12)
                    .children({
                    Field.render(.{ .label = "Search Exceptions...", .value = .{ .string = &search_query }, .on_change = onSearch, .background = Theme.bg_base });
                    // Box()
                    //     .width(.px(140))
                    //     .children({
                    //     status_filter.renderPos(.bottom);
                    // });
                    Button(selectNav, .{NavItem.exceptions})
                        .padding(.xy(14, 9))
                        .background(.palette(.tint))
                        .children({
                        Text("View All")
                            .font(13, 500, .palette(.background))
                            .fontFamily("IBM Plex Mono,monospace")
                            .end();
                        Icon(.arrow_right)
                            .font(14, 400, .palette(.background))
                            .end();
                    });
                });
            });

            Box()
                .width(.percent(100))
                // .height(.px(720))
                .layout(.top_center)
                .layer(.grid(14, 1, .transparentizeHex(.black, 0.05)))
                .children({
                // exceptions_table.render();
            });
        });
    });
}

fn renderChartTypeButton(chart_btn_type: ChartType, label: []const u8) void {
    const is_active = chart_type == chart_btn_type;
    Box()
        .padding(.xy(12, 8))
        .background(.{ .color = if (is_active) Theme.accent else .transparent })
        .border(.round(if (is_active) Theme.accent else Theme.border, .all(6)))
        .pointer()
        .children({
        Text(label)
            .font(12, 500, if (is_active) .white else Theme.text_secondary)
            .fontFamily("IBM Plex Mono,monospace")
            .end();
    });
}

fn renderProductRow(comptime name: []const u8, comptime revenue: []const u8, comptime percentage: u32) void {
    Box()
        .width(.percent(100))
        .layout(.x_between_center)
        .children({
        Stack()
            .spacing(4)
            .children({
            Text(name)
                .font(14, 500, Theme.text)
                .fontFamily("IBM Plex Mono,monospace")
                .end();
            Text(revenue)
                .font(12, 400, Theme.text_muted)
                .fontFamily("IBM Plex Mono,monospace")
                .end();
        });
        Box()
            .layout(.right_center)
            .spacing(8)
            .children({
            Box()
                .width(.px(80))
                .height(.px(6))
                .background(Theme.bg_elevated)
                .border(.round(Theme.bg_elevated.color.?, .all(99)))
                .children({
                Box()
                    .width(.percent(percentage))
                    .height(.percent(100))
                    .background(.{ .color = Theme.accent })
                    .border(.round(Theme.accent, .all(99)))
                    .children({});
            });
            TextFmt("{d}%", .{percentage})
                .font(12, 500, Theme.text_secondary)
                .fontFamily("IBM Plex Mono,monospace")
                .width(.px(32))
                .end();
        });
    });
}

fn renderFunnelStep(comptime name: []const u8, comptime value: []const u8, comptime percentage: u32) void {
    Box()
        .width(.percent(100))
        .layout(.x_between_center)
        .children({
        Box()
            .layout(.left_center)
            .spacing(12)
            .children({
            Box()
                .width(.px(percentage))
                .height(.px(8))
                .background(.{ .color = Theme.accent })
                .border(.round(Theme.accent, .all(4)))
                .children({});
            Text(name)
                .font(14, 400, Theme.text_secondary)
                .fontFamily("IBM Plex Mono,monospace")
                .end();
        });
        Text(value)
            .font(14, 600, Theme.text)
            .fontFamily("IBM Plex Mono,monospace")
            .end();
    });
}

fn renderExceptionsView() void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(28))
        .spacing(24)
        .layout(.top_center)
        .children({
        // Table
        Box()
            .width(.percent(100))
            .layer(.grid(14, 1, .transparentizeHex(.black, 0.05)))
            .children({
            // exceptions_table.render();
        });
    });
}

fn renderAnalyticsView() void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(28))
        .spacing(24)
        .children({
        Text("Analytics view - Coming soon")
            .font(18, 400, Theme.text_muted)
            .fontFamily("IBM Plex Mono,monospace")
            .end();
        Box()
            .width(.percent(100))
            .layer(.grid(14, 1, .transparentizeHex(.black, 0.05)))
            .children({
            // traces_table.render();
        });
    });
}

fn renderCustomersView() void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(28))
        .spacing(24)
        .children({
        Text("Customers view - Coming soon")
            .font(18, 400, Theme.text_muted)
            .fontFamily("IBM Plex Mono,monospace")
            .end();
    });
}

fn renderSettingsView() void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(28))
        .spacing(24)
        .children({
        // Profile settings
        Box()
            .width(.px(600))
            .padding(.all(24))
            .direction(.column)
            .spacing(20)
            .children({
            Text("Profile Settings")
                .font(18, 600, Theme.text)
                .fontFamily("IBM Plex Mono,monospace")
                .end();

            Field.render(.{ .label = "Display Name", .value = .{ .string = &search_query } });
            Field.render(.{ .label = "Email Address", .value = .{ .email = &email_query }, .type = .email });

            Box()
                .layout(.x_between_center)
                .children({
                Text("Enable Notifications")
                    .font(14, 400, Theme.text)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Switch.render("notifications-switch", Vapor.alert, .{ "{s}", .{"Im a switch"} });
            });

            Box()
                .layout(.x_between_center)
                .children({
                Text("Dark Mode")
                    .font(14, 400, Theme.text)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Switch.render("dark-mode-switch", toggleTheme, .{});
            });
        });
    });
}

fn renderDetailSheetContent(_: *Sheet) void {
    if (selected_exception) |txn| {
        Stack()
            .width(.percent(100))
            .height(.percent(100))
            .padding(.all(24))
            .spacing(24)
            .children({
            // Header
            Box()
                .layout(.x_between_center)
                .children({
                Text("Exception Details")
                    .font(20, 700, Theme.text)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Button(closeDetailSheet, .{})
                    .width(.px(36))
                    .height(.px(36))
                    .layout(.center)
                    .pointer()
                    .children({
                    Icon(.x_lg)
                        .font(16, 400, Theme.text_secondary)
                        .end();
                });
            });

            // // Amount
            // Box()
            //     .width(.percent(100))
            //     .padding(.all(20))
            //     .direction(.column)
            //     .spacing(8)
            //     .layout(.center)
            //     .children({
            //     Text("Amount")
            //         .font(12, 500, Theme.text_muted)
            //         .fontFamily("IBM Plex Mono,monospace")
            //         .end();
            //     TextFmt("${d}.00", .{txn.url})
            //         .font(36, 700, Theme.text)
            //         .fontFamily("IBM Plex Mono,monospace")
            //         .end();
            //     Box()
            //         .padding(.xy(10, 6))
            //         .children({
            //         Text(txn.status.label())
            //             .font(12, 600, txn.status.color())
            //             .fontFamily("IBM Plex Mono,monospace")
            //             .end();
            //     });
            // });

            // Details
            Stack()
                .width(.percent(100))
                .spacing(16)
                .children({
                renderDetailRow("Customer", txn.user.name);
                renderDetailRow("Email", txn.user.email);
                renderDetailRow("Date", txn.last_seen.format(Vapor.arena(.frame)) catch "");
                // renderDetailRow("Payment Method", txn.method);
                // renderDetailRowFmt("Exception ID", "TXN-{d}", .{txn.id});
            });

            // Actions
            Box()
                .width(.percent(100))
                .layout(.left_center)
                .spacing(12)
                .children({
                Button(handleRefundException, .{@constCast(txn)})
                    .padding(.xy(12, 8))
                    .background(.{ .color = Theme.warning })
                    .border(.round(Theme.warning, .all(12)))
                    .pointer()
                    .layout(.center)
                    .spacing(8)
                    .children({
                    Icon(.arrow_counterclockwise)
                        .font(16, 400, Theme.bg_base.color)
                        .end();
                    Text("Report")
                        .font(14, 500, Theme.bg_base.color)
                        .fontFamily(font_family)
                        .end();
                });
                Button(closeDetailSheet, .{})
                    .padding(.xy(12, 8))
                    .background(Theme.bg_elevated)
                    .border(.round(Theme.border, .all(12)))
                    .pointer()
                    .layout(.center)
                    .spacing(8)
                    .children({
                    Icon(.trash)
                        .font(16, 400, Theme.text_secondary)
                        .end();
                    Text("Delete")
                        .font(14, 500, Theme.text_secondary)
                        .fontFamily(font_family)
                        .end();
                });
            });
        });
    }
}

fn renderDetailRow(label: []const u8, value: []const u8) void {
    Box()
        .width(.percent(100))
        .layout(.x_between_center)
        .padding(.vertical(12))
        .border(.bottom(1, .palette(.border_color_light)))
        .children({
        Text(label)
            .font(14, 400, Theme.text_muted)
            .fontFamily(font_family)
            .end();
        Text(value)
            .font(14, 500, Theme.text)
            .fontFamily(font_family)
            .end();
    });
}

fn renderDetailRowFmt(comptime label: []const u8, comptime fmt: []const u8, args: anytype) void {
    Box()
        .width(.percent(100))
        .layout(.x_between_center)
        .padding(.vertical(12))
        .border(.bottom(1, .palette(.border_color_light)))
        .children({
        Text(label)
            .font(14, 400, Theme.text_muted)
            .fontFamily(font_family)
            .end();
        TextFmt(fmt, args)
            .font(14, 500, Theme.text)
            .fontFamily(font_family)
            .end();
    });
}

// ============================================================================
// MAIN RENDER
// ============================================================================

pub fn render() void {
    const nav = Vapor.lib.getStore([]const u8, "selected_nav") orelse "dashboard";
    selected_nav = std.meta.stringToEnum(NavItem, nav) orelse .dashboard;
    Box()
        .width(.percent(100))
        .height(.percent(100))
        .scroll(.none())
        // .background(Theme.bg_base)
        .layout(.top_left)
        // .background(.hex("#F8F7F3"))
        .children({
        // Navigation
        renderNavigation();

        // Main content area
        Stack()
            .width(.grow)
            .height(.percent(100))
            .children({
            // Header
            renderHeader();

            // Content
            Box()
                .width(.percent(100))
                .height(.percent(100))
                .scroll(.scroll_y())
                .children({
                switch (selected_nav) {
                    // .overview => Overview.render(),
                    // .dashboard => renderDashboardView(),
                    // .exceptions => renderExceptionsView(),
                    // .analytics => renderAnalyticsView(),
                    // .database => renderCustomersView(),
                    .database => Database.render(),
                    else => {},
                }
            });
        });

        // Overlays
        detail_sheet.render();
    });
    Toast.renderStackAt(.top_right);
}
