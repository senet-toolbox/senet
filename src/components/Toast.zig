const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const TextArea = Vapor.TextArea; // Renamed for clarity if strictly separating Text/TextArea
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const Icon = Vapor.Icon;
const Box = Vapor.Box;
const Animation = Vapor.Animation;
const IconTokens = @import("user_config").IconTokens;
const ButtonCtx = Vapor.CtxButton;
const TextFmt = Vapor.TextFmt;
var next_toast_id: usize = 0;

const spinner: Animation = Animation.init("spin")
    .easing(.easeInOut)
    .duration(100)
    .prop(.rotate, 0, 180);

// 1. Define specific Toast Types for better UX
pub const ToastType = enum {
    success,
    err,
    warning,
    info,
};

pub var toasts: Vapor.Array(Toast) = undefined;
pub var border: Vapor.Types.BorderGrouped = .solid(.all(1), .transparentizeHex(.white, 0.5), .all(16));
pub var background: Vapor.Types.Background = .transparentizeHex(.white, 0.2);
pub var shadow: Vapor.Types.Shadow = .{
    .blur = 8,
    .color = .transparentizeHex(.black, 0.15),
    .top = 2,
    .spread = 0,
};

const Toast = @This();
var text_color: Vapor.Types.Color = .palette(.text_color);
var total_height: f32 = 0;

// State
title: []const u8,
description: []const u8,
toast_type: ToastType = .info,
is_visible: bool = false,
auto_close: bool = true,
duration: u32 = 3000,
on_close: ?*const fn (toast: *Toast) void = null,
id: usize = 0,
top: f32 = 24,
right: f32 = 24,
width: f32 = 280,
scale_val: f16 = 1.0,
height: f32 = 52,

// Define animations (using your API style)
const anim_enter = Animation.init("opaque-toast-enter")
    .prop(.translateY, -20, 0)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const anim_exit = Animation.init("opaque-toast-exit")
    .prop(.opacity, 1, 0)
    .prop(.scale, 1, 0.95)
    .duration(200)
    .easing(.easeIn)
    .fill(.forwards);

pub fn new() void {
    anim_enter.build();
    anim_exit.build();
    spinner.build();
    toasts = Vapor.array(Toast, .persist);
}

pub const Options = struct {
    title: []const u8,
    description: []const u8,
};

pub fn movePreviousDown() void {
    if (toasts.items.len == 0) return;
    // if (toasts.items.len == previous_len) return;
    const last = toasts.items.len - 1;
    var i: usize = toasts.items.len - 1;
    var local_total_height: f32 = toasts.items[0].height;
    while (i < toasts.items.len) : (i -= 1) {
        if (toasts.items[i].is_visible) {
            toasts.items[i].top = @as(f32, @floatFromInt(last - i)) * 14.0;
            toasts.items[i].scale_val = 1.0 - (@as(f16, @floatFromInt(last - i)) * 0.04);
            local_total_height += 8;
        }
        if (i == 0) break;
    }
    total_height = local_total_height;
}

fn showToast(toast: *Toast) void {
    toast.show();
    toasts.append(toast.*) catch unreachable; // Insert at the top
    movePreviousDown();
    startToastTimeout(toast);
}

fn startToastTimeout(toast: *Toast) void {
    const id = Vapor.fmtln("remove_oldest_toast-{d}", .{toast.id});
    Vapor.lib.registerCtxTimeout(id, 5000, removeOldestToast, .{{}});
}

fn cancelToast(toast: *Toast) void {
    const id = Vapor.fmtln("remove_oldest_toast-{d}", .{toast.id});
    Vapor.lib.cancelTimeout(id);
}

pub fn success(options: Options) void {
    var toast = Toast.init(options.title, options.description, .success);
    showToast(&toast);
}

pub fn err(options: Options) void {
    var toast = Toast.init(options.title, options.description, .err);
    showToast(&toast);
}

pub fn warning(options: Options) void {
    var toast = Toast.init(options.title, options.description, .warning);
    showToast(&toast);
}

pub fn info(options: Options) void {
    var toast = Toast.init(options.title, options.description, .info);
    showToast(&toast);
}

pub fn init(title: []const u8, description: []const u8, toast_type: ToastType) Toast {
    const id = next_toast_id;
    next_toast_id += 1;

    return Toast{
        .title = title,
        .description = description,
        .toast_type = toast_type,
        .id = id,
    };
}

pub fn show(toast: *Toast) void {
    toast.is_visible = true;
    // Note: In a real implementation, you would trigger a timer here
    // to set toast.is_visible = false after toast.duration
}

pub fn hide(toast: *Toast) void {
    Vapor.print("Hiding toast", .{});
    toast.is_visible = false;
    if (toast.on_close) |callback| {
        callback(toast);
    }
    for (toasts.items, 0..) |*t, i| {
        if (t.id == toast.id) {
            _ = toasts.orderedRemove(i);
        }
    }
    showAllToasts();
}

fn movePreviousUp() void {
    if (toasts.items.len == 0) return;
    // if (toasts.items.len == previous_len) return;
    const last = toasts.items.len - 1;
    var i: usize = 0;
    while (i < toasts.items.len) : (i += 1) {
        if (toasts.items[i].is_visible) {
            toasts.items[i].top = @as(f32, @floatFromInt(last - i)) * 14.0;
            // toasts.items[i].scale_val = 1.0 - (@as(f16, @floatFromInt(last - i)) * 0.04);
            Vapor.print("Id {d}", .{toasts.items[i].id});
            // toasts.items[i].width -= 8;
        }
        if (i == last) break;
    }
}

fn removeOldestToast(_: void) void {
    // 1. Safety check to prevent panic on empty list
    if (toasts.items.len == 0) return;

    // 2. Remove the item from memory
    const toast = toasts.orderedRemove(0);
    Vapor.print("Removed {d}", .{toast.id});

    // 3. CRITICAL FIX: Recalculate positions for the remaining items
    // Since this runs on timeout, the user is likely NOT hovering,
    // so we want the "collapsed" stack view.
    movePreviousDown();
}

// Helper to get color based on type
fn getTypeColor(toast_type: ToastType) Vapor.Types.Color {
    return switch (toast_type) {
        .success => text_color, // Green
        .err => .hex("#FF4000"), // Red
        .warning => .hex("#FFB700"), // Orange
        .info => .hex("#007AFF"), // System accent
    };
}

// Helper to get icon based on type
fn getTypeIcon(toast_type: ToastType) *const IconTokens {
    return switch (toast_type) {
        .success => IconTokens.check2_all,
        .err => IconTokens.exclamation_circle,
        .warning => IconTokens.exclamation_triangle,
        .info => IconTokens.info_circle,
    };
}

fn onHover(_: *Vapor.Event) void {
    for (toasts.items) |*t| {
        cancelToast(t);
    }
    showAllToasts();
}

fn onLeave(_: *Vapor.Event) void {
    movePreviousDown();
    for (toasts.items) |*t| {
        startToastTimeout(t);
    }
}

fn showAllToasts() void {
    if (toasts.items.len == 0) return;
    // if (toasts.items.len == previous_len) return;
    const last = toasts.items.len - 1;
    var i: usize = 0;
    var local_total_height: f32 = 0;
    while (i < toasts.items.len) : (i += 1) {
        if (toasts.items[i].is_visible) {
            toasts.items[i].top = @as(f32, @floatFromInt(last - i)) * (toasts.items[i].height + 8);
            toasts.items[i].scale_val = 1;
        }
        local_total_height += toasts.items[i].height + 8;
        if (i == last) break;
    }
    total_height = local_total_height;
}

pub fn renderStack() void {
    Box()
        // Fixed Position on Screen (Top Right)
        // This is the ONLY place we use absolute positioning
        .pos(.tr(.px(24), .px(24), .fixed))
        .layout(.top_center) // Stack items downwards, align left
        .spacing(12) // Gap between toasts
        .direction(.column)
        .background(.transparent)
        .width(.px(if (toasts.items.len > 0) toasts.items[0].width else 0))
        .height(.px(total_height))
        .onHover(onHover)
        .onLeave(onLeave)
        .zIndex(9999) // Ensure it floats above everything
        .children({
        // Iterate and Render
        // We use a mutable slice because we might modify state
        for (toasts.items, 0..) |*t, i| {
            render(t, i);
        }
    });
}

// We render but control visibility via Opacity/Animation

pub fn render(toast: *Toast, index: usize) void {
    // We render but control visibility via Opacity/Animation
    // or return early depending on engine requirements.
    // if (!toast.is_visible) return;

    // 1. Scale: Front is 1.0, behind is 0.96, then 0.92

    // 2. Vertical Offset: Front is 0, behind moves down by 10px, etc.
    // This creates the "peeking out from bottom" effect
    const z_index: i16 = @as(i16, @intCast(100 + index));

    // 3. Opacity: Cards deeper in stack fade out slightly
    // (Optional, but looks nice. If index 0 -> 1.0, index 1 -> 0.9)
    // const opacity_val: f32 = if (index == 0) 1.0 else 0.5;

    Box()
        .id(Vapor.fmtln("opaque-toast-{d}", .{toast.id}))
        .newShadow(
            Vapor.Types.NewShadow.init()
                .inset(0, -2, .transparentizeHex(.black, 0.1))
                .drop(0, 1, 3, .transparentizeHex(.black, 0.2)),
        )
        // .border(.solid(.all(1), .transparentizeHex(.white, 0.5), .specific(20, 18, 21, 22)))
        .border(border)
        // Position: Top Right, fixed/absolute
        .pos(.tr(.px(toast.top), .px(0), .absolute))
        // Animation applied here
        .animationEnter(&anim_enter)
        .animationExit(&anim_exit)
        .zIndex(z_index)
        .transition(.{
            .properties = &.{ .top, .scale, .opacity, .transform },
            .duration = 200,
            .timing = .easeInOut,
        })
        .scale(toast.scale_val)

        // Container Styling
        .height(.px(toast.height))
        .blur(12)
        .width(.px(toast.width)) // Fixed width usually looks better than % for toasts
        .background(background)

        // Improved Shadow for "Pop"
        // .shadow(shadow)

        // Layout: Row (Icon -> Content -> Close)
        .layout(.x_between_center) // Vertically center items
        .padding(.all(8))
        .spacing(8)
        .children({
        // 1. Semantic Icon
        Center()
            // .border(.round(getTypeColor(toast.toast_type), .all(4)))
            .width(.px(32))
            .height(.px(32))
            // .background()
            .children({
            Icon(getTypeIcon(toast.toast_type))
                .font(18, 700, text_color)
                .end();
        });
        // 2. Text Content (Stacked Vertically)
        Box()
            // .spacing(8)
            .direction(.column)
            .layout(.left_center)
            .width(.grow) // Take up remaining space
            .children({
            // Title

            Text(toast.title)
                .font(14, 600, text_color)
                .end();

            // Description
            Text(toast.description)
                .font(13, 400, text_color)
                // .lineHeight(1.4)
                .end();
        });

        // 3. Close Button
        ButtonCtx(hide, .{toast})
            .class("toast-close")
            .cursor(.pointer)
            .padding(.all(4))
            .duration(100)
            .hover(.{
                .text_color = .transparentizeHex(.black, 0.5),
            })
            .children({
            Icon(.x_lg)
                .font(16, 700, text_color)
                // .inheritHover(&.{.text_color})
                .hover(.{
                    .text_color = .transparentizeHex(.black, 0.5),
                    // .animation = &spinner,
                })
                .end();
        });
    });
}
