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
const Dashboard = @import("Dashboard.zig");
const Theme = Dashboard.Theme;
const Opaque = @import("../../components/Opaque.zig");
const Field = Opaque.Field;
const Tooltip = Opaque.Tooltip;
const Button = Opaque.Button;
const Chart = Opaque.Chart;
const Tabs = Opaque.Tabs;
const Table = Opaque.Table;
const Column = Opaque.Column;
const Action = Opaque.Action;
const DynamicTable = Opaque.DynamicTable;
const DynamicRow = Opaque.DynamicRow;
const PopOver = Opaque.PopOver;
const DataColumn = Opaque.DataColumn;
const ColumnType = Opaque.ColumnType;
const Value = Opaque.Value;
const RyvenButton = @import("../../components/RyvenButton.zig").Button;
const Wrap = @import("../../components/RyvenButton.zig").Wrap;

const Select = Opaque.Select;

// ============================================================================
// DATA TYPES
// ============================================================================

// ============================================================================
// INITIALIZATION
// ============================================================================

const columns: []const DataColumn = &.{
    DataColumn{
        .name = "ID",
        .primary = true,
        .type = .uuid,
    },
    DataColumn{
        .name = "Name",
        .type = .string,
    },
    DataColumn{
        .name = "Email",
        .type = .string,
    },
    DataColumn{
        .name = "Age",
        .type = .int,
    },
    DataColumn{
        .name = "Salary",
        .type = .float,
    },
    DataColumn{
        .name = "Is Active",
        .type = .boolean,
    },
    DataColumn{
        .name = "Created At",
        .type = .datetime,
    },
    DataColumn{
        .name = "Updated At",
        .type = .datetime,
    },
    DataColumn{
        .name = "equipment",
        .type = .array,
    },
};
var table: DynamicTable(columns, .{}) = undefined;
var search_query: []const u8 = "";
var query: []const u8 = "";
var select_columns: Select([]const u8) = undefined;
var search_select_columns: Select([]const u8) = undefined;

var filter_columns: Select([]const u8) = undefined;

var popover: PopOver = .{ .trigger = "Popover" };

const Insert = struct {
    title: []const u8,
    description: []const u8,
    icon: *const Vapor.IconTokens,
};

var insert_columns: Select(Insert) = undefined;

var data: Vapor.Array(DynamicRow) = undefined;

pub fn init() void {
    data = Vapor.array(DynamicRow, .persist);

    select_columns = .fromItems(&.{
        .{ .value = "ID", .label = "ID" },
        .{ .value = "Name", .label = "Name" },
        .{ .value = "Email", .label = "Email" },
    });

    select_columns.border = .sharp(.tblr(1, 1, 1, 1), .palette(.border_color_light));
    select_columns.selected_border = .sharp(.tblr(1, 1, 1, 1), .palette(.tint));
    select_columns.shadow = .{ .color = .transparent };
    select_columns.height = .px(32);

    select_columns.on_select = onSelect;
    select_columns.trigger = "Column...";

    search_select_columns = .fromItems(&.{
        .{ .value = "ID", .label = "ID" },
        .{ .value = "Name", .label = "Name" },
        .{ .value = "Email", .label = "Email" },
    });

    search_select_columns.border = .sharp(.tblr(1, 1, 1, 1), .palette(.border_color_light));
    search_select_columns.selected_border = .sharp(.tblr(1, 1, 1, 1), .palette(.tint));
    search_select_columns.shadow = .{ .color = .transparent };
    search_select_columns.height = .px(32);

    search_select_columns.on_select = onSelect;
    search_select_columns.trigger = "Column...";

    insert_columns = .fromItems(&.{
        .{ .value = Insert{ .title = "Insert Row", .description = "Insert a new row", .icon = .view_stacked }, .label = "Insert" },
        .{ .value = Insert{ .title = "Insert Column", .description = "Delete a row", .icon = .view_stacked }, .label = "Delete" },
    });

    insert_columns.height = .px(32);

    insert_columns.border = .sharp(.tblr(1, 1, 1, 1), .palette(.border_color_light));
    insert_columns.selected_border = .sharp(.tblr(1, 1, 1, 1), .palette(.tint));
    insert_columns.shadow = .{ .color = .transparent };

    for (0..30) |i| {
        var row: DynamicRow = undefined;
        // std.StringHashMap(Value).init(Vapor.arena(.persist));
        row = DynamicRow.init(Vapor.arena(.persist));
        // row.put("ID", .{ .string = Vapor.fmtln("{d}", .{i}) }) catch unreachable;
        // row.put("Name", .{ .string = Vapor.fmtln("Vic {d}", .{i}) }) catch unreachable;
        // row.put("Email", .{ .string = Vapor.fmtln("vic{d}@example.com", .{i}) }) catch unreachable;

        const id = std.fmt.allocPrint(Vapor.arena(.persist), "{d}", .{i}) catch unreachable;
        row.put("ID", .{ .string = id }) catch unreachable;

        const name = std.fmt.allocPrint(Vapor.arena(.persist), "Vic {d}", .{i}) catch unreachable;
        row.put("Name", .{ .string = name }) catch unreachable;

        const email = std.fmt.allocPrint(Vapor.arena(.persist), "vic{d}@example.com", .{i}) catch unreachable;
        row.put("Email", .{ .string = email }) catch unreachable;

        row.put("Age", .{ .int = @intCast(i) }) catch unreachable;
        row.put("Salary", .{ .float = @floatFromInt(i) }) catch unreachable;
        row.put("Is Active", .{ .boolean = true }) catch unreachable;
        row.put("Created At", .{ .datetime = Vapor.DateTime.now() }) catch unreachable;
        row.put("Updated At", .{ .datetime = Vapor.DateTime.now() }) catch unreachable;
        row.put("equipment", .{ .array = &[_]Value{ .{ .string = "laptop" }, .{ .string = "desktop" } } }) catch unreachable;
        data.append(row) catch unreachable;
    }

    table.init(data.items);
    table.per_page = 18;
    // table.display_mode = .virtual;
}

var selected_column: usize = 0;
fn onSearch(evt: *Vapor.Event) void {
    std.log.info("onSearch", .{});
    table.onSearch(evt.text(), selected_column);
}

fn onSelect(_: *Select([]const u8), item: *Select([]const u8).Item) void {
    for (columns, 0..) |column, i| {
        if (std.mem.eql(u8, column.name, item.value)) {
            selected_column = i;
        }
    }
}

fn FieldComp(field: *Field) Vapor.Builder(.pure) {
    const is_focused = field.is_focused;
    return Stack()
        .width(.percent(100))
        .spacing(8)
        .pos(.relative)
        .height(.px(32))
        .border(.sharp(.all(1), if (is_focused) .palette(.tint) else .palette(.border_color_light)))
        .background(field.background);
}

fn InsertComponent(select: *Select(Insert)) void {
    for (select.groups.items) |*group| {
        for (group.items) |*item| {
            const rotation: f16 = if (std.mem.indexOf(u8, item.value.title, "Column") == null) 0 else 90;
            std.log.info("rotation {d}", .{rotation});
            Box()
                .width(.px(320))
                .hover(.{
                    .background = .palette(.tint),
                    .text_color = .palette(.background),
                })
                .padding(.xy(12, 8))
                .spacing(8)
                .layout(.left_center)
                .children({
                Icon(item.value.icon)
                    .transform(.rotateXYZ(0, 0, rotation))
                    .font(14, 300, null)
                    .end();
                Stack()
                    .width(.percent(100))
                    .children({
                    Text(item.value.title)
                        .font(12, 300, null)
                        .end();
                    Text(item.value.description)
                        .font(10, 400, null)
                        .end();
                });
            });
        }
    }
}

fn FilterBtn() void {
    Box()
        .background(.transparent)
        .children({
        Box()
            .width(.px(32))
            .height(.px(32))
            .background(if (filtering) .hex("#222160") else .transparent)
            .edges("divider")
            .border(.sharp(.all(1), .palette(.border_color_light)))
            .textColor(if (filtering) .white else .palette(.text_color))
            .layout(.center)
            .hover(.{
                .background = .palette(.tint),
                .text_color = .palette(.background),
                .border_color = .palette(.tint),
            })
            // .edges("button")
            .children({
            Icon(.funnel)
                .font(14, 300, null)
                .end();
        });
    });
}

var current_filter: []const u8 = "=";

const options: []const []const u8 = &.{ "=", "<", ">", "<=", ">=", "!=" };

fn FilterIcon() void {
    Box()
        .width(.px(32))
        .height(.px(32))
        .border(.sharp(.all(1), .palette(.border_color_light)))
        .layout(.center)
        .hover(.{
            .background = .palette(.tint),
            .text_color = .palette(.background),
        })
        .children({
        Text(current_filter)
            .font(14, 300, null)
            .end();
    });
}

fn FilterSelectComponent() void {
    Box()
        .border(.sharp(.all(1), .palette(.border_color_light)))
        .background(.palette(.background))
        .width(.fit)
        .children({
        Box()
            .width(.percent(100))
            .padding(.xy(12, 8))
            .spacing(8)
            .layout(.left_center)
            .children({
            for (options) |option| {
                Box()
                    .width(.px(32))
                    .height(.px(32))
                    .background(.transparent)
                    // .border(.sharp(.all(1), .palette(.border_color_light)))
                    .layout(.center)
                    .hover(.{
                        .background = .palette(.tint),
                        .text_color = .palette(.background),
                    })
                    // .edges("button")
                    .children({
                    Text(option)
                        .layout(.left_center)
                        .font(14, 300, null)
                        .end();
                });
            }
        });
    });
}

fn FilterComponent() void {
    Box()
        // .border(.sharp(.all(1), .palette(.border_color_light)))
        .background(.palette(.background))
        .margin(.l(-32))
        .width(.px(400))
        .children({
        Box()
            .width(.percent(100))
            .padding(.xy(12, 8))
            .spacing(8)
            .layout(.left_center)
            .children({
            Box().width(.percent(30)).children({
                select_columns.render();
            });

            PopOver.create(.{ .position = .bottom })
                .Trigger(FilterIcon, .{})
                .Component(FilterSelectComponent, .{})
                .end();

            Box().width(.grow).children({
                Field.create(.{ .label = "value", .value = .{ .string = &query }, .on_change = onSearch })
                    .Component(FieldComp);
            });
        });
    });
}

var filtering: bool = false;
fn onFilterTrigger() void {
    filtering = !filtering;
}

// ============================================================================
// COMPONENTS
// ============================================================================
pub fn render() void {
    Stack()
        .width(.percent(100))

        // .height(.percent(50))
        .padding(.all(28))
        .scroll(.none())
        .spacing(8)
        .children({
        Box()
            .width(.percent(30))
            .layout(.left_center)
            .spacing(8)
            .children({
            PopOver.create(.{ .position = .bottom_right, .on_trigger = onFilterTrigger })
                .Trigger(FilterBtn, .{})
                .Component(FilterComponent, .{})
                .end();

            Box()
                .width(.percent(50))
                .layout(.left_center)
                .children({
                Field.create(.{ .label = "Search...", .value = .{ .string = &search_query }, .on_change = onSearch })
                    .Component(FieldComp);
            });
            Box()
                .width(.percent(30))
                .spacing(8)
                .children({
                search_select_columns.render();
                Stack()
                    .width(.percent(100))
                    .spacing(4)
                    .pos(.relative)
                    .children({
                    insert_columns.renderTrigger();
                    insert_columns.renderSelectByComponent(InsertComponent);
                });
            });
        });
        table.render();
    });
}
