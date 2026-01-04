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
var group_title_color: Vapor.Types.Color = .hex("#8C8C8C");
var text_color: Vapor.Types.Color = .palette(.text_color);
var font_family: []const u8 = "Montserrat";
var selected_background: Vapor.Types.Background = .transparentizeHex(.palette(.tint), 0.05);
var selected_border: Vapor.Types.BorderGrouped = .round(.palette(.tint), .all(12));

pub const animateEnter = Vapor.Animation.init("select-enter")
    .prop(.opacity, 0, 1)
    .prop(.scale, 0.9, 1)
    .duration(100)
    .easing(.easeInOut);

pub const animateExit = Vapor.Animation.init("select-exit")
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
        groups: Vapor.Array(Group),
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
        // binded_triggers_ptrs: Vapor.Array(Vapor.Binded),

        pub fn init(trigger: []const u8, groups: []const Group) Self {
            var alloc_groups = Vapor.array(Group, .persist);
            alloc_groups.appendSlice(groups) catch unreachable;
            return Self{
                .trigger = trigger,
                .groups = alloc_groups,
            };
        }

        pub fn fromItems(items: []const Item) Self {
            var alloc_groups = Vapor.array(Group, .persist);
            var alloc_items = Vapor.array(Item, .persist);

            alloc_items.appendSlice(items) catch unreachable;

            alloc_groups.append(.{
                .items = alloc_items.items,
            }) catch unreachable;

            return Self{
                .trigger = "Select",
                .groups = alloc_groups,
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
                .width(.percent(100))
                .height(.px(36))
                .background(background)
                .pointer()
                .layout(.left_center)
                .duration(100)
                .hoverBackground(selected_background)
                .padding(.tblr(6, 6, 6, 24))
                .border(.round(.transparent, .all(8)))
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

        fn renderGroup(select: *Self, group: *Group) void {
            Stack()
                .width(.percent(100))
                .spacing(8)
                .children({
                if (group.title) |title| {
                    Text(title)
                        .pl(6)
                        .font(14, 300, group_title_color)
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
            Vapor.print("Toggle with binded trigger {any}", .{bounds});
            select._x = 0;
            select._y = bounds.height + 4;
            Vapor.print("Rendering select {any} {any}", .{ select._x, select._y });

            select.toggle();
        }

        fn toggleWithBindedTriggerVP(select: *Self, binded_trigger: *Vapor.Binded) void {
            const bounds = binded_trigger.getBoundingClientRect() orelse return;
            Vapor.print("Toggle with binded trigger {any}", .{bounds});
            select._x = bounds.left;
            select._y = bounds.top + bounds.height + 4;
            Vapor.print("Rendering select {any} {any}", .{ select._x, select._y });

            select.toggle();
        }

        fn toggleWithBindedTriggerCtx(select: *Self, binded_trigger: *Vapor.Binded, ctx: ?*anyopaque) void {
            const bounds = binded_trigger.getBoundingClientRect() orelse return;
            select._x = bounds.left;
            select._y = bounds.top + bounds.height + 4;
            Vapor.print("Bounds {any}", .{bounds});
            select.toggle();
            if (select.on_trigger) |on_trigger| {
                on_trigger(select, ctx);
            }
        }

        pub fn renderTriggerCtx(select: *Self, ctx: ?*anyopaque) void {
            const binded_trigger = select.createBindedTrigger();
            Box()
                .width(.percent(100))
                .height(.percent(100))
                .ref(select.binded_trigger).children({
                if (select.trigger_component) |trigger| {
                    ButtonCtx(toggleWithBindedTriggerCtx, .{ select, binded_trigger, ctx })
                        .background(.transparent)
                        .width(.percent(100))
                        .height(.percent(100))
                        .children({
                        trigger(select);
                    });
                } else {
                    ButtonCtx(toggleWithBindedTrigger, .{ select, binded_trigger })
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
                    ButtonCtx(toggleWithBindedTriggerVP, .{ select, binded_trigger })
                        .background(.transparent)
                        .width(.percent(100))
                        .height(.percent(100))
                        .children({
                        trigger(select);
                    });
                } else {
                    ButtonCtx(toggleWithBindedTrigger, .{ select, binded_trigger })
                        .width(.percent(100))
                        .border(if (select._closed) border else selected_border)
                        .background(background)
                        .padding(.all(8))
                        .shadow(.{
                            .color = if (select._closed) .transparent else .transparentizeHex(.palette(.tint), 0.2),
                            .spread = 3,
                        })
                        // .shadow(.{
                        //     .color = if (select._closed) .transparentizeHex(.black, 0.05) else .transparentizeHex(.palette(.tint), 0.2),
                        //     .spread = if (select._closed) 0 else 2,
                        //     .blur = if (select._closed) 0 else 2,
                        //     .top = if (select._closed) 2 else 0,
                        // })
                        .hover(.{
                            .border = selected_border,
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
                        .animationEnter(&animateEnter)
                        .animationExit(&animateExit)
                        .width(.percent(100))
                        .border(border)
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
                            .height(.elastic(36, 256))
                            .width(.percent(100))
                            .scroll(.scroll_y())
                            .children({
                            for (select.groups.items) |*group| {
                                select.renderGroup(group);
                            }
                        });
                    });
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
                        .size(.full)
                        .pos(.tl(.px(0), .px(0), .fixed))
                        .end();
                });
            }
        }

        pub fn render(select: *Self) void {
            Stack()
                .width(.percent(100))
                .spacing(4)
                .pos(.relative)
                .children({
                select.renderTrigger();
                if (!select._closed) {
                    renderSelect(select);
                }
            });
        }
    };
}
