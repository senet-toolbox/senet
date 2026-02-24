const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const ButtonCtx = Vapor.CtxButton;
const Button = Vapor.Button;
const TextFmt = Vapor.TextFmt;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const Icon = Vapor.Icon;
const HooksCtx = Vapor.Static.HooksCtx;

var background: Vapor.Types.Background = .palette(.background);
var border: Vapor.Types.BorderGrouped = .round(.palette(.border_color_light), .all(12));
var group_title_color: Vapor.Types.Color = .transparentizeHex(.palette(.text_color), 0.8);
var text_color: Vapor.Types.Color = .palette(.text_color);
// var font_family: []const u8 = "Barlow";
var font_family: []const u8 = "Montserrat";
const selected_background: Vapor.Types.Background = .transparentizeHex(.palette(.tint), 0.05);
const selected_border: Vapor.Types.BorderGrouped = .round(.palette(.tint), .all(12));

const Position = enum { top, bottom };

pub const animateEnter = Vapor.Animation.init("opaque-select-enter")
    .prop(.opacity, 0, 1)
    .prop(.scale, 0.9, 1)
    .duration(100)
    .easing(.easeInOut);

pub const animateExit = Vapor.Animation.init("opaque-select-exit")
    .prop(.opacity, 1, 0)
    .prop(.scaleY, 1, 0.9)
    .duration(100)
    .easing(.easeInOut);

pub fn new() void {
    animateEnter.build();
    animateExit.build();
}

pub fn Select(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const Group = struct {
            title: ?[]const u8 = null,
            items: []const Item,
        };

        const ClonedGroup = struct {
            title: ?[]const u8 = null,
            items: []Item,
        };

        pub const Item = struct {
            value: T,
            label: []const u8,
            icon: ?*const Vapor.IconTokens = null,
            is_selected: bool = false,
            _is_shown: bool = true,
        };

        trigger: []const u8,
        groups: Vapor.Array(ClonedGroup),
        _selected_item: ?Item = null,
        _closed: bool = true,
        _searchable: bool = false,
        _search_box: Vapor.Binded = .{},
        ctx: ?*anyopaque = null,
        on_select: ?*const fn (select: *Self, item: *Item) void = null,
        on_select_ctx: ?*const fn (item: *Item, ctx: ?*anyopaque) void = null,
        trigger_component: ?*const fn (self: *Self) void = null,
        render_trigger: bool = true,
        _x: f32 = 0,
        _y: f32 = 0,
        binded_select: Vapor.Binded = .{},
        binded_trigger: Vapor.Binded = .{},
        on_trigger: ?*const fn (select: *Self, ctx: ?*anyopaque) void = null,
        _did_initialize: bool = false,
        max_height: f32 = 256,
        is_detached: bool = false,
        _position: Position = .bottom,
        total_items: usize = 0,
        border: Vapor.Types.BorderGrouped = .round(.palette(.border_color_light), .all(12)),
        selected_border: Vapor.Types.BorderGrouped = .round(.palette(.tint), .all(12)),
        shadow: Vapor.Types.Shadow = .{ .color = .transparentizeHex(.palette(.tint), 0.2), .spread = 3 },
        height: Vapor.Types.Sizing = .px(36),
        // binded_triggers_ptrs: Vapor.Array(Vapor.Binded),

        pub fn init(trigger: []const u8, groups: []const Group) Self {
            var alloc_groups = Vapor.array(ClonedGroup, .persist);

            var total_items: usize = 0;
            for (groups) |group| {
                var cloned_group: ClonedGroup = .{ .title = group.title, .items = &.{} };
                var alloc_items = Vapor.array(Item, .persist);
                for (group.items) |item| {
                    alloc_items.append(item) catch unreachable;
                    total_items += 1;
                }
                cloned_group.items = alloc_items.items;
                alloc_groups.append(cloned_group) catch unreachable;
            }

            var max_height: f32 = 256;
            if (total_items > 12) {
                max_height = 512;
            }

            return Self{
                .trigger = trigger,
                .groups = alloc_groups,
                ._did_initialize = true,
                .max_height = max_height,
                .total_items = total_items,
            };
        }

        pub fn fromItems(items: []const Item) Self {
            var alloc_groups = Vapor.array(ClonedGroup, .persist);
            var alloc_items = Vapor.array(Item, .persist);

            alloc_items.appendSlice(items) catch unreachable;

            var total_items: usize = 0;
            total_items += items.len;

            var max_height: f32 = 256;
            if (total_items > 12) {
                max_height = 512;
            }

            alloc_groups.append(.{
                .items = alloc_items.items,
            }) catch unreachable;

            return Self{
                .trigger = "Select",
                .groups = alloc_groups,
                ._did_initialize = true,
                .max_height = max_height,
                .total_items = total_items,
            };
        }

        pub fn toggle(select: *Self) void {
            select._closed = !select._closed;
        }

        pub fn close(select: *Self) void {
            select._closed = true;
        }

        pub fn default(select: *Self, selected_item: Item) void {
            for (select.groups.items) |*group| {
                for (group.items) |*item| {
                    if (std.mem.eql(u8, item.label, selected_item.label)) continue;
                    item.is_selected = false;
                }
            }
            select._selected_item = selected_item;
        }

        fn selectItem(select: *Self, selected_item: *Item) void {
            for (select.groups.items) |*group| {
                for (group.items) |*item| {
                    if (item == selected_item) continue;
                    item.is_selected = false;
                }
            }
            selected_item.is_selected = !selected_item.is_selected;
            if (!selected_item.is_selected) {
                select._selected_item = null;
            } else {
                select._selected_item = selected_item.*;
            }

            if (select.on_select) |on_select| {
                on_select(select, selected_item);
            }
            if (select.on_select_ctx) |on_select_ctx| {
                on_select_ctx(selected_item, select.ctx);
            }

            select.close();
        }

        fn renderItem(select: *Self, item: *Item) void {
            if (!item._is_shown) return;
            ButtonCtx(selectItem, .{ select, item })
                .ariaLabel("Select Dropdown")
                .width(.percent(100))
                .height(.px(36))
                .background(background)
                .pointer()
                .layout(.left_center)
                .duration(100)
                .hoverBackground(selected_background)
                .padding(.tblr(6, 6, 6, 24))
                .border(.round(.transparent, if (select.border.radius) |radius| radius else .all(8)))
                .spacing(8)
                .children({
                if (item.icon) |icon| {
                    Icon(icon)
                        .font(14, 300, text_color)
                        .end();
                }
                Text(item.label)
                    .fontFamily(font_family)
                    .font(14, 300, text_color)
                    .end();
            });
        }

        fn renderGroup(select: *Self, group: *ClonedGroup) void {
            Stack()
                .width(.percent(100))
                .children({
                if (group.title) |title| {
                    Text(title)
                        .padding(.all(6))
                        .font(12, 300, group_title_color)
                        .end();
                }
                Stack()
                    .width(.percent(100))
                    .children({
                    for (group.items) |*item| {
                        select.renderItem(item);
                    }
                });
            });
        }

        fn search(select: *Self, evt: *Vapor.Event) void {
            const text = evt.text();
            select._search_box.text = text;
            for (select.groups.items) |*group| {
                for (group.items) |*item| {
                    if (std.ascii.startsWithIgnoreCase(item.label, text)) {
                        item._is_shown = true;
                    } else {
                        item._is_shown = false;
                    }
                }
            }
        }

        fn clearText(select: *Self) void {
            select._search_box.text = "";
            for (select.groups.items) |*group| {
                for (group.items) |*item| {
                    item._is_shown = true;
                }
            }
        }

        fn mountSearchBox(select: *Self) void {
            select._search_box.focus();
        }

        fn createBindedTrigger(_: *Self) *Vapor.Binded {
            const binded_trigger: *Vapor.Binded = Vapor.arena(.frame).create(Vapor.Binded) catch unreachable;
            binded_trigger.* = .{};
            return binded_trigger;
        }

        fn toggleWithBindedTrigger(select: *Self, binded_trigger: *Vapor.Binded) void {
            const bounds = binded_trigger.getBoundingClientRect() orelse return;
            if (select._position == .top) {
                Vapor.print("toggleWithBindedTriggerVP", .{});
                const offsets = binded_trigger.getOffsets() orelse return;
                select._x = offsets.offset_left;
                select._y = offsets.offset_top - (@as(f32, @floatFromInt(select.total_items)) * 36) - 16;
                Vapor.print("Rendering select {any} {any}", .{ (@as(f32, @floatFromInt(select.total_items)) * 36), select._y });
            } else {
                select._x = 0;
                select._y = bounds.height + 4;
            }

            select.toggle();
        }

        fn toggleWithBindedTriggerVP(select: *Self, binded_trigger: *Vapor.Binded) void {
            if (select.is_detached) {
                select.toggle();
                return;
            }
            const offsets = binded_trigger.getOffsets() orelse return;
            if (select._position == .top) {
                select._x = offsets.offset_left;
                select._y = offsets.offset_top - @as(f32, @floatFromInt(select.total_items)) * 36;
            } else {
                select._x = offsets.offset_left;
                select._y = offsets.offset_top + offsets.offset_height + 4;
            }
            Vapor.print("Rendering select {any} {any}", .{ select._x, select._y });

            select.toggle();
        }

        fn toggleWithBindedTriggerVPCtx(select: *Self, binded_trigger: *Vapor.Binded, callback: anytype, args: anytype) void {
            if (select.is_detached) {
                select.toggle();
                return;
            }
            const offsets = binded_trigger.getOffsets() orelse return;
            select._x = offsets.offset_left;
            select._y = offsets.offset_top + offsets.offset_height + 4;
            select.toggle();
            @call(.auto, callback, args);
        }

        pub fn renderTriggerCtx(select: *Self, callback: anytype, args: anytype) void {
            const binded_trigger = select.createBindedTrigger();
            Box()
                .width(.percent(100))
                .height(.percent(100))
                .ref(binded_trigger).children({
                if (select.trigger_component) |trigger| {
                    ButtonCtx(toggleWithBindedTriggerVPCtx, .{ select, binded_trigger, callback, args })
                        .ariaLabel("Select Dropdown")
                        .background(.transparent)
                        .width(.percent(100))
                        .height(.percent(100))
                        .children({
                        trigger(select);
                    });
                } else {
                    ButtonCtx(toggleWithBindedTrigger, .{ select, binded_trigger })
                        .ariaLabel("Select Dropdown")
                        .width(.percent(100))
                        .border(if (select._closed) border else selected_border)
                        .background(background)
                        .padding(.all(8))
                        .shadow(.{
                            .color = if (select._closed) .transparent else .transparentizeHex(.palette(.tint), 0.2),
                            .spread = 3,
                        })
                        // .shadow(.{
                        //     .color = if (is_focused) .transparentizeHex(.palette(.tint), 0.2) else .transparent,
                        //     .spread = 3,
                        // })
                        .children({
                        Box()
                            .width(.percent(100))
                            .layout(.x_between_center)
                            .children({
                            Text(if (select._selected_item) |item| item.label else select.trigger)
                                .fontFamily(font_family)
                                .font(16, 300, group_title_color)
                                .end();
                            Icon(if (select._closed) .chevron_down else .chevron_up)
                                .fontFamily(font_family)
                                .font(14, 300, group_title_color)
                                .end();
                        });
                    });
                }
            });
        }

        pub fn renderTrigger(select: *Self) void {
            const binded_trigger = select.createBindedTrigger();
            Box()
                .width(.percent(100))
                .height(.percent(100))
                .ref(binded_trigger).children({
                if (select.trigger_component) |trigger| {
                    ////////////////////////////////////////////////////////////////////////////////////
                    // THIS IS THE NEW WAY i switch toggleWithBindedTriggerVP to toggleWithBindedTrigger
                    ////////////////////////////////////////////////////////////////////////////////////
                    ButtonCtx(toggleWithBindedTriggerVP, .{ select, binded_trigger })
                        .ariaLabel("Select Dropdown")
                        .background(.transparent)
                        .width(.percent(100))
                        .height(.percent(100))
                        .children({
                        trigger(select);
                    });
                } else {
                    ButtonCtx(toggleWithBindedTrigger, .{ select, binded_trigger })
                        .ariaLabel("Select Dropdown")
                        .width(.percent(100))
                        .height(select.height)
                        .border(if (select._closed) select.border else select.selected_border)
                        .background(background)
                        .padding(.xy(8, 0))
                        .shadow(if (!select._closed) select.shadow else .{
                            .color = .transparent,
                            .spread = 3,
                        })
                        // .shadow(.{
                        //     .color = if (select._closed) .transparentizeHex(.black, 0.05) else .transparentizeHex(.palette(.tint), 0.2),
                        //     .spread = if (select._closed) 0 else 2,
                        //     .blur = if (select._closed) 0 else 2,
                        //     .top = if (select._closed) 2 else 0,
                        // })
                        .hover(.{
                            .border = select.selected_border,
                        })
                        .children({
                        Box()
                            .width(.percent(100))
                            .layout(.x_between_center)
                            .children({
                            Text(if (select._selected_item) |item| item.label else select.trigger)
                                .fontFamily(font_family)
                                .padding(.horizontal(8))
                                .border(.{
                                    .thickness = .none,
                                    .radius = .all(4),
                                })
                                .font(14, 300, group_title_color)
                                .end();
                            Icon(if (select._closed) .chevron_down else .chevron_up)
                                .fontFamily(font_family)
                                .font(14, 300, group_title_color)
                                .end();
                        });
                    });
                }
            });
        }

        pub fn renderSelect(select: *Self) void {
            Box()
                .pos(.tl(.px(0), .percent(0), .absolute))
                .width(.percent(100))
                .zIndex(1000)
                .inlineStyle("transform: translate({d}px, {d}px)", .{ select._x, select._y })
                .children({
                if (!select._closed) {
                    Stack()
                        .transformOrigin(.top_center)
                        .animationEnter("opaque-select-enter")
                        .animationExit("opaque-select-exit")
                        .width(.percent(100))
                        .border(select.border)
                        .background(background)
                        .padding(.all(4))
                        .shadow(.{
                            .top = 4,
                            .spread = 2,
                            .blur = 6,
                            .color = .transparentizeHex(.black, 0.05),
                        })
                        .children({
                        Stack()
                            .height(.elastic(36, select.max_height))
                            .width(.percent(100))
                            .scroll(.scroll_y())
                            .children({
                            for (select.groups.items) |*group| {
                                select.renderGroup(group);
                            }
                        });
                    });
                } else {
                    Vapor.Null();
                }
            });
            if (!select._closed) {
                Box()
                    .id("select-background")
                    .background(.transparent)
                    .size(.full)
                    .pos(.full(.fixed))
                    .zIndex(999)
                    .children({
                    ButtonCtx(toggle, .{select})
                        .ariaLabel("Close Select Dropdown")
                        .size(.full)
                        .pos(.tl(.px(0), .px(0), .fixed))
                        .end();
                });
            } else {
                Vapor.Null();
            }
        }

        pub fn renderPos(select: *Self, position: Position) void {
            select._position = position;
            if (!select._did_initialize) {
                Vapor.printErr("Error: Select component not initialized\n Call Select.init(...) or Select.fromItems(...) before rendering", .{});
                return;
            }
            Stack()
                .width(.percent(100))
                .spacing(4)
                .pos(.relative)
                .children({
                select.renderTrigger();
                // if (!select._closed) {
                select.renderSelect();
                // } else {
                // Vapor.Null();
                // }
            });
        }

        pub fn render(select: *Self) void {
            if (!select._did_initialize) {
                Vapor.printErr("Error: Select component not initialized\n Call Select.init(...) or Select.fromItems(...) before rendering", .{});
                return;
            }
            Stack()
                .width(.percent(100))
                .spacing(4)
                .pos(.relative)
                .children({
                select.renderTrigger();
                // if (!select._closed) {
                select.renderSelect();
                // } else {
                // Vapor.Null();
                // }
            });
        }
        pub fn renderSelectByComponent(select: *Self, component: *const fn (select: *Self) void) void {
            Box()
                .pos(.tl(.px(0), .percent(0), .absolute))
                // .width(.percent(100))
                .zIndex(1000)
                .inlineStyle("transform: translate({d}px, {d}px)", .{ select._x, select._y })
                .children({
                if (!select._closed) {
                    Stack()
                        .transformOrigin(.top_center)
                        .animationEnter("opaque-select-enter")
                        .animationExit("opaque-select-exit")
                        // .width(.percent(100))
                        .border(select.border)
                        .background(background)
                        .padding(.all(4))
                        .shadow(.{
                            .top = 4,
                            .spread = 2,
                            .blur = 6,
                            .color = .transparentizeHex(.black, 0.05),
                        })
                        .children({
                        Stack()
                            .height(.elastic(36, select.max_height))
                            .width(.percent(100))
                            .scroll(.scroll_y())
                            .children({
                            component(select);
                        });
                    });
                } else {
                    Vapor.Null();
                }
            });
            if (!select._closed) {
                Box()
                    .id("select-background")
                    .background(.transparent)
                    .size(.full)
                    .pos(.full(.fixed))
                    .zIndex(999)
                    .children({
                    ButtonCtx(toggle, .{select})
                        .ariaLabel("Close Select Dropdown")
                        .size(.full)
                        .pos(.tl(.px(0), .px(0), .fixed))
                        .end();
                });
            } else {
                Vapor.Null();
            }
        }
    };
}
