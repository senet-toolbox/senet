const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const ButtonCtx = Vapor.CtxButton;
const Stack = Vapor.Stack;
const Components = @import("Components.zig");
const TableContainer = Components.Table;
const TableRow = Components.TableRow;
const TableCell = Components.TableCell;
const TableBody = Components.TableBody;
const TableHeader = Components.TableHeader;
const TableHead = Components.TableHead;
const Button = Vapor.Button;
const Select = @import("../Select.zig").Select;

pub const Sort = enum {
    none,
    asc,
    desc,
};

pub const Align = enum {
    none,
    left,
    center,
    right,
};

var border_color: Vapor.Types.Color = .hex("#e4e4e4");
var tint: Vapor.Types.Background = .hex("#5926FF");

pub fn Row(comptime T: type) type {
    return struct {
        value: T,
    };
}

pub fn Column(comptime T: type) type {
    return struct {
        title: []const u8,
        width: f32 = 0,
        alignment: ?Align = .none,
        sort: ?Sort = .none,
        render: ?*const fn (*Row(T)) void = null,
    };
}

pub fn Table(comptime T: type) type {
    return struct {
        const Self = @This();
        columns: []Column(T),
        data: []T,

        var action_width: f32 = 5;
        var row_height: f32 = 48;
        var row_width: f32 = 95;
        var show_actions: bool = false;
        var action_select: Select(usize) = undefined;
        var action_top_pos: f16 = 0;
        var action_right_pos: f16 = 0;
        var binded_rows: []Vapor.Binded = &.{};

        pub fn init(columns: []Column(T), data: []T) Self {
            action_select = .fromItems(&.{
                .{ .value = 0, .label = "Action 1" },
                .{ .value = 1, .label = "Action 2" },
                .{ .value = 2, .label = "Action 3" },
            });
            // action_select.render_trigger = false;
            binded_rows = Vapor.arena(.persist).alloc(Vapor.Binded, data.len) catch |err| blk: {
                Vapor.printErr("Failed to allocate binded rows: {any}", .{err});
                break :blk &.{};
            };
            for (0..data.len) |i| {
                binded_rows[i] = .{};
            }

            return Self{
                .columns = columns,
                .data = data,
            };
        }

        fn toggleActions(index: usize) void {
            show_actions = !show_actions;
            action_top_pos = @as(f16, @floatCast(row_height)) * @as(f16, @floatFromInt(index + 1));
            const bounds = binded_rows[index].getBoundingClientRect() orelse {
                Vapor.printErr("Failed to get bounding client rect", .{});
                return;
            };
            action_top_pos = @floatCast(bounds.top + bounds.height + 4);
            action_right_pos = @floatCast(-bounds.left);
            action_select.toggle();
        }

        pub fn Actions(_: *Self) void {
            Stack()
                .width(.percent(100))
                .spacing(8)
                .children({
                Text("Actions").end();
            });
        }

        fn Rows(table: *Self) void {
            Stack()
                .width(.percent(100))
                .children({
                Box()
                    // .transform(.translate(action_right_pos, action_top_pos, .px))
                    .inlineStyle("transform: translate({d}px, {d}px)", .{ action_right_pos, action_top_pos })
                    .pos(.tr(.px(0), .px(0), .absolute))
                    .width(.percent(10))
                    .children({
                    action_select.render();
                });
                const fields = @typeInfo(T).@"struct".fields;
                for (table.data, 0..) |row, i| {
                    const last_row = table.data.len - 1 == i;
                    Box()
                        .width(.percent(100))
                        .height(.px(row_height))
                        .padding(.horizontal(8))
                        .border(.bottom(if (!last_row) border_color else .transparent))
                        .layout(.x_between_center).children({
                        Box()
                            .ref(&binded_rows[i])
                            .width(.percent(row_width))
                            .layout(.x_even_center).children({
                            inline for (fields) |field| {
                                const name = field.name;
                                const value = @field(row, name);
                                // const last_item = fields.len - 1 == j;
                                Box()
                                    .width(.percent(100))
                                    .layout(.left_center)
                                    .children({
                                    switch (@typeInfo(field.type)) {
                                        .int => Text(value).end(),
                                        .@"enum" => Text(value).end(),
                                        .pointer => |ptr| {
                                            if (ptr.size == .slice) {
                                                Text(value).end();
                                            }
                                        },
                                        else => {},
                                    }
                                });
                            }
                        });
                        Box()
                            .width(.percent(action_width))
                            .layout(.right_center)
                            .children({
                            ButtonCtx(toggleActions, .{i})
                                .width(.px(24))
                                .height(.px(24))
                                .cursor(.pointer)
                                .hover(.{
                                    .background = tint,
                                    .text_color = .white,
                                })
                                .duration(200)
                                .border(.round(.transparent, .all(4)))
                                .children({
                                Vapor.Icon(.three_dots).end();
                            });
                        });
                    });
                }
            });
        }

        pub fn render(table: *Self) void {
            Stack()
                .width(.percent(100))
                .height(.percent(100))
                .direction(.column)
                .children({
                Box()
                    .border(.bottom(border_color))
                    .padding(.horizontal(8))
                    .width(.percent(100))
                    .children({
                    Box()
                        .width(.percent(row_width))
                        .height(.px(row_height))
                        .layout(.x_even_center).children({
                        for (table.columns) |column| {
                            Box()
                                .width(.percent(100))
                                .layout(.left_center)
                                .children({
                                Text(column.title).font(16, null, null).end();
                            });
                        }
                    });
                });
                table.Rows();
            });
        }
    };
}
