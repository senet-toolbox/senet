const Vapor = @import("vapor");
const std = @import("std");
const Opaque = @import("Opaque.zig");
const Button = Opaque.Button;
const Box = Vapor.Box;
const Text = Vapor.Text;
const Field = Opaque.Field;
const Stack = Vapor.Stack;
const Toast = Opaque.Toast;
const Tooltip = Opaque.Tooltip;

var peristant_tabs: std.StringHashMap(*Tabs) = undefined;

const Tabs = @This();
active_tab: ?[]const u8 = null,
names: []const []const u8,
// tabs: std.array_list.Managed(Tab),

pub fn new() void {
    peristant_tabs = std.StringHashMap(*Tabs).init(Vapor.arena(.persist));
}

const Tab = struct {
    title: []const u8,
    content: []const u8,
    tag: []const u8,
};

fn getTab(tabs: *Tabs, name: []const u8) ?Tab {
    for (tabs.tabs.items) |tab| {
        if (std.mem.eql(u8, tab.tag, name)) {
            return tab;
        }
    }
    return null;
}

pub fn Trigger(tag: []const u8) void {
    const tabs = peristant_tabs.get(tag) orelse blk: {
        const tabs = Vapor.arena(.persist).create(Tabs) catch unreachable;
        peristant_tabs.put(tag, tabs) catch unreachable;
        break :blk tabs;
    };

    const tab = getTab(tabs, tag) orelse blk: {
        const tab = Vapor.arena(.persist).create(Tab) catch unreachable;
        tab.* = .{ .tag = tag };
        tabs.tabs.append(tab) catch unreachable;
        break :blk tab;
    };

    Button(switchTabs, .{ tabs, tab })
        .children({
        Text(tag)
            .font(16, 300, .palette(.text_color))
            .end();
    });
}

fn component() void {
    Vapor.print("component", .{});
}

fn closeTabs(_: void) void {
    Vapor.print("closeTabs", .{});
}

pub fn Content(tag: []const u8) *const fn (void) void {
    Vapor.print("Content", .{});
    const tabs = peristant_tabs.get(tag) orelse blk: {
        const tabs = Vapor.arena(.persist).create(Tabs) catch unreachable;
        peristant_tabs.put(tag, tabs) catch unreachable;
        break :blk tabs;
    };
    const current_tab = if (tabs.active_tab == null) tag else tabs.active_tab.?;
    // 2. Default to index 0 if nothing is selected
    // (You might want to store 'active_index: usize' instead of strings for O(1) lookups)

    if (std.mem.eql(u8, current_tab, tag)) {
        return closeTabs;
    }
    return closeTabs;
}

pub fn switchToTab(tag: []const u8, index: usize) void {
    const tabs = peristant_tabs.get(tag) orelse blk: {
        const t = Vapor.arena(.persist).create(Tabs) catch unreachable;
        t.* = .{}; // Initialize list
        peristant_tabs.put(tag, t) catch unreachable;
        break :blk t;
    };
    tabs.active_tab = tabs.names[index];
}

pub fn NavBar(tag: []const u8, names: []const []const u8) usize {
    // 1. Retrieve or Create State
    const tabs = peristant_tabs.get(tag) orelse blk: {
        const t = Vapor.arena(.persist).create(Tabs) catch unreachable;
        t.* = .{
            .names = names,
        }; // Initialize list
        peristant_tabs.put(tag, t) catch unreachable;
        break :blk t;
    };

    // 2. Default to index 0 if nothing is selected
    // (You might want to store 'active_index: usize' instead of strings for O(1) lookups)
    var active_idx: usize = 0;

    // logic to find current active index based on stored string
    if (tabs.active_tab) |active_name| {
        for (names, 0..) |name, i| {
            if (std.mem.eql(u8, active_name, name)) {
                active_idx = i;
                break;
            }
        }
    }

    Nav(tabs, names, active_idx);

    return active_idx;
}

const NavBtnCtx = struct {
    tabs: *Tabs,
    name: []const u8,
    active_idx: usize,
    i: usize,
};

fn NavBtn(ctx: ?*anyopaque) void {
    if (ctx == null) return;
    const nav_btn_ctx: *NavBtnCtx = @ptrCast(@alignCast(ctx));
    const tabs = nav_btn_ctx.tabs;
    const name = nav_btn_ctx.name;
    const active_idx = nav_btn_ctx.active_idx;
    const i = nav_btn_ctx.i;
    Button(switchTabs, .{ tabs, name })
        .background(if (active_idx == i) .transparentizeHex(.palette(.tint), 0.7) else .transparent)
        .border(.round(.palette(.tint), .all(4)))
        .padding(.tblr(4, 4, 8, 8))
        .children({
        Text(name)
            .fontFamily("IBM Plex Sans,monospace")
            .font(14, 300, if (active_idx == i) .white else .palette(.text_color))
            .end();
    });
}

fn Nav(tabs: *Tabs, names: []const []const u8, active_idx: usize) void {
    Box()
        // .width(.percent(100))
        .layout(.left_center)
        .background(.transparentizeHex(.palette(.tint), 0.1))
        .padding(.all(2))
        .border(.round(.transparent, .all(4)))
        .spacing(8)
        .children({
        for (names, 0..) |name, i| {
            const ctx = Vapor.arena(.frame).create(NavBtnCtx) catch unreachable;
            ctx.* = NavBtnCtx{ .tabs = tabs, .name = name, .active_idx = active_idx, .i = i };
            // Tooltip.renderCtx(.{
            //     .name = Vapor.fmtln("{s}", .{name}),
            //     .title = Vapor.fmtln("{s}", .{name}),
            //     .content = "This is a tooltip",
            //     .trigger_ctx = NavBtn,
            //     .ctx = @ptrCast(@alignCast(ctx)),
            // });
            NavBtn(@ptrCast(@alignCast(ctx)));
        }
    });
}

fn switchTabs(tabs: *Tabs, name: []const u8) void {
    tabs.active_tab = name;
}

var first_name: []const u8 = "";
var username: []const u8 = "";
var password: []const u8 = "";
var current_password: []const u8 = "";
var new_password: []const u8 = "";
var email: []const u8 = "";
var phonenumber: []const u8 = "";
var address: []const u8 = "";
var last_name: []const u8 = "";
var credit_card: []const u8 = "";

fn Card() Vapor.Builder(.pure) {
    return Stack()
        .background(.transparentizeHex(.palette(.background), 0.5))
        .border(.round(.palette(.border_color_light), .all(12)))
        .width(.percent(100))
        .padding(.all(16))
        .layout(.top_left)
        .spacing(16);
}

fn Btn(title: []const u8, description: []const u8, icon: *const Vapor.IconTokens) void {
    const hash = Vapor.utils.hash(title);
    const id = Vapor.fmtln("btn-{d}", .{hash});
    const icon_id = Vapor.fmtln("icon-{d}", .{hash});
    Button(Toast.success, .{Toast.Options{ .title = title, .description = description }})
        .id(id)
        .animation("glitch")
        .background(.transparentizeHex(.black, 0.8))
        .border(.round(.black, .all(8)))
        .padding(.all(6))
        .children({
        Text(title)
            .font(14, 300, .white)
            .fontFamily("IBM Plex Sans,monospace")
            .end();
        Vapor.Icon(icon)
            .id(icon_id)
            .font(16, 700, .white)
            .end();
    });
}

fn onChange(evt: *Vapor.Event) void {
    evt.preventDefault();
    Vapor.print("onChange {s}", .{evt.text()});
}

pub fn render() void {
    Box()
        .size(.full)
        .layout(.center)
        .children({
        Box()
            .width(.percent(100))
            .direction(.column)
            .layout(.top_left)
            .spacing(8)
            .children({
            const active_index = Tabs.NavBar("main_tabs", &.{ "Login", "Reset Password", "Account" });
            switch (active_index) {
                0 => {
                    Card().children({
                        Stack()
                            .width(.percent(100))
                            .spacing(8)
                            .children({
                            Text("Login")
                                .font(16, 700, .palette(.text_color))
                                .end();
                            Text("Login to your account here. Click login when you're done.")
                                .font(14, 300, .palette(.text_color))
                                .end();
                        });
                        Stack()
                            .width(.percent(100))
                            .spacing(16)
                            .children({
                            Field.render(.{ .label = "Username", .value = .{ .string = &username } });
                            Field.render(.{ .label = "Password", .value = .{ .password = &password } });
                        });
                        Box()
                            .layout(.right_center)
                            .width(.percent(100))
                            .children({
                            // Btn("Login", "Logged in successfully", .send);
                            Button(Toast.success, .{Toast.Options{ .title = "Login", .description = "Logged in successfully" }})
                                .animation("glitch")
                                .background(.transparentizeHex(.black, 0.8))
                                .border(.round(.black, .all(8)))
                                .padding(.all(6))
                                .children({
                                Text("Login")
                                    .font(14, 300, .white)
                                    .fontFamily("IBM Plex Sans,monospace")
                                    .end();
                                Vapor.Icon(.send)
                                    .font(16, 700, .white)
                                    .end();
                            });
                            // Button(Toast.err, .{Toast.Options{ .title = "Error Login", .description = "Error Logging In" }})
                            //     .animation(&glitch)
                            //     .background(.transparentizeHex(.black, 0.8))
                            //     .border(.round(.black, .all(8)))
                            //     .padding(.all(6))
                            //     .children({
                            //     Text("Error")
                            //         .font(14, 300, .white)
                            //         .fontFamily("IBM Plex Sans,monospace")
                            //         .end();
                            //     Vapor.Icon(.bug)
                            //         .font(16, 700, .white)
                            //         .end();
                            // });
                        });
                    });
                },
                1 => {
                    Card().children({
                        Stack()
                            .width(.percent(100))
                            .spacing(8)
                            .children({
                            Text("Reset Password")
                                .font(16, 700, .palette(.text_color))
                                .end();
                            Text("Reset your password here. Click save when you're done.")
                                .font(14, 300, .palette(.text_color))
                                .end();
                        });
                        Stack()
                            .width(.percent(100))
                            .spacing(16)
                            .children({
                            Field.render(.{ .label = "Current Password", .value = .{ .password = &current_password }, .trans_label = true });
                            Field.render(.{ .label = "New Password", .value = .{ .password = &new_password }, .trans_label = true });
                        });
                        Box()
                            .layout(.right_center)
                            .width(.percent(100))
                            .children({
                            Btn("Save Password", "Your password has been reset", .lock);
                        });
                    });
                },
                2 => {
                    Card().children({
                        Stack()
                            .width(.percent(100))
                            .spacing(8)
                            .children({
                            Text("Account Details")
                                .font(16, 700, .palette(.text_color))
                                .end();
                            Text("Update your account details here. Click save when you're done.")
                                .font(14, 300, .palette(.text_color))
                                .end();
                        });
                        Stack()
                            .width(.percent(100))
                            .spacing(16)
                            .children({
                            Field.render(.{ .label = "First Name", .value = .{ .string = &first_name }, .on_change = onChange });
                            Field.render(.{ .label = "Last Name", .value = .{ .string = &last_name } });
                            Field.render(.{ .label = "Email", .value = .{ .email = &email } });
                            Field.render(.{ .label = "Phone Number", .value = .{ .telephone = &phonenumber } });
                            Field.render(.{ .label = "Address", .value = .{ .string = &address } });
                            Field.render(.{ .label = "Credit Card", .value = .{ .credit_card = &credit_card } });
                        });
                        Box()
                            .layout(.right_center)
                            .width(.percent(100))
                            .children({
                            Btn("Save Account", "Your account details have been updated", .account);
                        });
                    });
                },
                else => {},
            }
        });
    });
}
