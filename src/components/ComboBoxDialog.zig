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
const OverlayManager = @import("OverlayManager.zig");

var background: Vapor.Types.Background = .palette(.background);
var border: Vapor.Types.BorderGrouped = .round(.palette(.border_color_light), .all(6));
var border_color: Vapor.Types.Color = .palette(.border_color_light);
var group_title_color: Vapor.Types.Color = .hex("#8C8C8C");
var text_color: Vapor.Types.Color = .palette(.text_color);
var font_family: []const u8 = "IBM Plex Sans,monospace";
var selected_background: Vapor.Types.Background = .transparentizeHex(.palette(.tint), 0.05);
var selected_border: Vapor.Types.BorderGrouped = .round(.palette(.tint), .all(6));
var checkbox_color_icon: Vapor.Types.Color = .palette(.background);
var checkbox_color: Vapor.Types.Color = .palette(.text_color);
var tint: Vapor.Types.Background = .palette(.tint);

pub const animateEnter = Vapor.Animation.init("opaque-combobox-enter")
    .prop(.opacity, 0, 1)
    .prop(.scale, 0.9, 1)
    .duration(100)
    .easing(.easeInOut);

pub const animateExit = Vapor.Animation.init("opaque-combobox-exit")
    .prop(.opacity, 1, 0)
    .prop(.scaleY, 1, 0.9)
    .duration(100)
    .easing(.easeInOut);

pub fn new() void {
    animateEnter.build();
    animateExit.build();
}

pub fn ComboBoxDialog(comptime T: type) type {
    comptime {
        if (!@hasField(T, "label")) {
            @compileError("ComboBoxDialog requires a field named 'value'");
        }
        if (!@hasField(T, "label")) {
            @compileError("ComboBoxDialog requires a field named 'label'");
        }
    }

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

        _selected_count: usize = 0,
        trigger: []const u8,
        groups: Vapor.Array(Group),
        _selected_items: std.AutoHashMap(*Item, void),
        _closed: bool = true,
        _search_box: Vapor.Binded = .{},
        ctx: ?*anyopaque = null,
        on_select: ?*const fn (item: *Item) void = null,
        on_select_ctx: ?*const fn (item: *Item, ctx: ?*anyopaque) void = null,
        on_close: ?*const fn () void = null,
        on_close_ctx: ?*const fn (ctx: ?*anyopaque) void = null,
        trigger_component: ?*const fn (self: *Self) void = null,
        render_trigger: bool = true,
        _x: f32 = 0,
        _y: f32 = 0,
        _width: f32 = 0,
        binded_combobox: Vapor.Binded = .{},
        binded_trigger: Vapor.Binded = .{},
        on_trigger: ?*const fn (combobox: *Self, ctx: ?*anyopaque) void = null,
        // binded_triggers_ptrs: Vapor.Array(Vapor.Binded),

        pub fn init(trigger: []const u8, groups: []const Group) Self {
            var alloc_groups = Vapor.array(Group, .persist);
            alloc_groups.appendSlice(groups) catch unreachable;
            return Self{
                .trigger = trigger,
                .groups = alloc_groups,
                ._selected_items = std.AutoHashMap(*Item, void).init(Vapor.arena(.persist)),
            };
        }

        pub fn fromItems(items: []T) Self {
            var alloc_groups = Vapor.array(Group, .persist);
            var alloc_items = Vapor.array(Item, .persist);

            for (items) |item| {
                const label = item.label;
                alloc_items.append(Item{ .value = item, .label = label }) catch unreachable;
            }

            // alloc_items.appendSlice(items) catch unreachable;

            alloc_groups.append(.{
                .items = alloc_items.items,
            }) catch unreachable;

            return Self{
                .trigger = "Search",
                .groups = alloc_groups,
                ._selected_items = std.AutoHashMap(*Item, void).init(Vapor.arena(.persist)),
            };
        }

        pub fn toggle(combobox: *Self) void {
            combobox._closed = !combobox._closed;
        }

        pub fn close(combobox: *Self) void {
            OverlayManager.unregister(.keydown, combobox);
            combobox._closed = true;
        }

        pub fn open(combobox: *Self) void {
            combobox._closed = false;
        }

        pub fn default(combobox: *Self, selected_item: Item) void {
            for (combobox.groups.items) |*group| {
                for (group.items) |*item| {
                    if (std.mem.eql(u8, item.label, selected_item.label)) continue;
                    item.is_selected = false;
                }
            }
            combobox._selected_item = selected_item;
        }

        fn selectItem(combobox: *Self, item: *Item) void {
            // TOGGLE logic
            item.is_selected = !item.is_selected;

            if (item.is_selected) {
                combobox._selected_count += 1;
                combobox._selected_items.put(item, {}) catch unreachable;
            } else {
                combobox._selected_count -= 1;
                _ = combobox._selected_items.remove(item);
            }

            if (combobox.on_select) |on_select| {
                on_select(item);
            }
            if (combobox.on_select_ctx) |on_select_ctx| {
                on_select_ctx(item, combobox.ctx);
            }
        }

        fn renderItem(combobox: *Self, item: *Item) void {
            if (!item._is_shown) return;
            ButtonCtx(selectItem, .{ combobox, item })
                .width(.percent(100))
                .height(.px(44))
                .background(if (item.is_selected) selected_background else background)
                .pointer()
                .layout(.left_center)
                .duration(100)
                .hover(.{
                    .background = .transparentizeHex(.palette(.tint), 0.1),
                })
                .padding(.tblr(6, 6, 6, 24))
                .border(.round(.transparent, .all(6)))
                .spacing(8)
                .children({
                // CheckBox(item.is_selected);
                if (item.icon) |icon| {
                    Icon(icon)
                        .font(14, 300, .transparentizeHex(.palette(.text_color), 0.7))
                        .end();
                }
                Text(item.label)
                    .fontFamily(font_family)
                    .font(14, 300, .transparentizeHex(.palette(.text_color), 0.7))
                    .end();
            });
        }

        fn renderGroup(combobox: *Self, group: *Group) void {
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
                    .spacing(12)
                    .children({
                    for (group.items) |*item| {
                        combobox.renderItem(item);
                    }
                });
            });
        }

        fn search(combobox: *Self, evt: *Vapor.Event) void {
            const text = evt.text();
            combobox._search_box.text = text;
            for (combobox.groups.items) |*group| {
                for (group.items) |*item| {
                    if (std.ascii.startsWithIgnoreCase(item.label, text)) {
                        item._is_shown = true;
                    } else {
                        item._is_shown = false;
                    }
                }
            }
        }

        fn clearText(combobox: *Self) void {
            combobox._search_box.text = "";
            for (combobox.groups.items) |*group| {
                for (group.items) |*item| {
                    item._is_shown = true;
                }
            }
        }

        fn mountSearchBox(combobox: *Self) void {
            OverlayManager.register(.keydown, handleKeyPresses, combobox);
            // _ = Vapor.lib.addGlobalListenerCtx(.keydown, handleKeyPresses, combobox);
            combobox._search_box.focus();
        }

        fn handleKeyPresses(combobox: *Self, evt: *Vapor.Event) void {
            evt.preventDefault();
            const key = evt.key();
            if (std.mem.eql(u8, key, "Escape")) {
                evt.preventDefault();
                combobox.close();
                if (combobox.on_close) |callback| {
                    @call(.auto, callback, .{});
                }
            }
        }

        fn createBindedTrigger(_: *Self) *Vapor.Binded {
            const binded_trigger: *Vapor.Binded = Vapor.arena(.frame).create(Vapor.Binded) catch unreachable;
            binded_trigger.* = .{};
            return binded_trigger;
        }

        fn toggleWithBindedTrigger(combobox: *Self, binded_trigger: *Vapor.Binded) void {
            const bounds = binded_trigger.getBoundingClientRect() orelse return;
            combobox._x = bounds.left;
            combobox._y = bounds.top + bounds.height + 4;
            combobox._width = bounds.width;
            Vapor.print("Bounds {any}", .{bounds});
            Vapor.print("Toggle {any} {any}", .{ combobox._x, combobox._y });
            combobox.toggle();
        }

        fn toggleWithBindedTriggerCtx(combobox: *Self, binded_trigger: *Vapor.Binded, ctx: ?*anyopaque) void {
            const bounds = binded_trigger.getBoundingClientRect() orelse return;
            combobox._x = bounds.left;
            combobox._y = bounds.top + bounds.height + 4;
            combobox._width = bounds.width;
            combobox.toggle();
            if (combobox.on_trigger) |on_trigger| {
                on_trigger(combobox, ctx);
            }
        }

        fn CheckBox(selected: bool) void {
            Box()
                .width(.px(18))
                .height(.px(18))
                .border(.round(.palette(.border_color_light), .all(4)))
                .cursor(.pointer)
                .duration(100)
                .hoverScale()
                .background(if (selected) tint else background)
                .hoverScale()
                .layout(.center)
                .children({
                Icon(.check)
                    .font(16, 300, checkbox_color_icon)
                    .end();
            });
        }

        pub fn renderComboBoxDialog(combobox: *Self) void {
            Box()
                // .pos(.tl(.percent(50), .percent(50), .fixed))
                .zIndex(999)
                .width(.percent(100))
                .children({
                Stack()
                    .width(.percent(100))
                    .padding(.tb(8, 0))
                    .children({
                    HooksCtx(.mounted, mountSearchBox, .{combobox})({
                        Box()
                            .width(.percent(100))
                            .padding(.tblr(6, 14, 12, 12))
                            .pointer()
                            .border(.bottom(border_color))
                            .layout(.x_between_center)
                            .children({
                            Icon(.search)
                                .font(14, 300, group_title_color)
                                .end();
                            TextField(.string)
                                .ref(&combobox._search_box)
                                .val(&combobox._search_box.text)
                                .placeholder("Search...")
                                .width(.percent(100))
                                .border(.none)
                                .padding(.horizontal(12))
                                .outline(.none)
                                .fontFamily(font_family)
                                .font(14, 300, group_title_color)
                                .onEventCtx(.input, search, combobox)
                                .end();
                            ButtonCtx(clearText, .{combobox})
                                .background(.transparent)
                                .pointer()
                                .children({
                                Icon(.x_lg)
                                    .font(14, 300, group_title_color)
                                    .end();
                            });
                        });
                    });
                    Stack()
                        .height(.elastic(36, 384))
                        .width(.percent(100))
                        .scroll(.scroll_y())
                        .padding(.all(8))
                        .children({
                        for (combobox.groups.items) |*group| {
                            combobox.renderGroup(group);
                        }
                    });
                    Box()
                        .width(.percent(100))
                        .height(.px(42))
                        .padding(.horizontal(12))
                        .border(.top(border_color))
                        .layout(.right_center)
                        .spacing(16)
                        .children({
                        Box()
                            .layout(.left_center)
                            .spacing(8)
                            .children({
                            Box()
                                .layout(.x_between_center)
                                .border(border)
                                .background(background)
                                .padding(.tblr(2, 2, 6, 6))
                                .duration(100)
                                .newShadow(Vapor.Types.NewShadow.init()
                                    .inset(0, -2, .transparentizeHex(.black, 0.3)))
                                .children({
                                Text("esc")
                                    .font(14, 300, .palette(.text_color))
                                    .fontFamily(font_family)
                                    .end();
                            });
                            Text("to dismiss")
                                .font(14, 300, .palette(.text_color))
                                .fontFamily(font_family)
                                .end();
                        });
                        Box()
                            .layout(.left_center)
                            .spacing(8)
                            .children({
                            Box()
                                .layout(.x_between_center)
                                .border(border)
                                .background(background)
                                .padding(.tblr(2, 2, 6, 6))
                                .duration(100)
                                .newShadow(Vapor.Types.NewShadow.init()
                                    .inset(0, -2, .transparentizeHex(.black, 0.3)))
                                .children({
                                Text("↑ ↓")
                                    .font(14, 300, .palette(.text_color))
                                    .fontFamily(font_family)
                                    .end();
                            });
                            Text("to navigate")
                                .font(14, 300, .palette(.text_color))
                                .fontFamily(font_family)
                                .end();
                        });
                        Box()
                            .layout(.left_center)
                            .spacing(8)
                            .children({
                            Box()
                                .layout(.x_between_center)
                                .border(border)
                                .background(background)
                                .padding(.tblr(2, 2, 6, 6))
                                .duration(100)
                                .newShadow(Vapor.Types.NewShadow.init()
                                    .inset(0, -2, .transparentizeHex(.black, 0.3)))
                                .children({
                                Text("return")
                                    .font(14, 300, .palette(.text_color))
                                    .fontFamily(font_family)
                                    .end();
                            });
                            Text("to select")
                                .font(14, 300, .palette(.text_color))
                                .fontFamily(font_family)
                                .end();
                        });
                    });
                });
            });
        }

        pub fn render(combobox: *Self) void {
            if (combobox._closed) return;
            Box()
                .id("combobox-background")
                // .background(.transparentizeHex(.black, 0.1))
                .blur(1)
                .size(.full)
                .pos(.full(.fixed))
                .zIndex(999)
                .children({
                ButtonCtx(close, .{combobox})
                    .size(.full)
                    .pos(.tl(.px(0), .px(0), .fixed))
                    .end();
            });
            Box()
                .pos(.tl(.percent(10), .percent(32), .fixed))
                .zIndex(999)
                .animationEnter(&animateEnter)
                .animationExit(&animateExit)
                .width(.percent(34))
                // .height(.percent(20))
                .background(.white)
                .shadow(.glow(30, .transparentizeHex(.black, 0.1)))
                .border(.round(.hex("#e4e4e4"), .all(6)))
                .layout(.top_left)
                .zIndex(1000)
                .children({
                renderComboBoxDialog(combobox);
            });
        }
    };
}
