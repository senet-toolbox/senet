const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const ButtonCtx = Vapor.CtxButton;
const Button = Vapor.Button;

const Alert = @This();
var background: Vapor.Types.Color = .white;
var border_color: Vapor.Types.Color = .hex("#e4e4e4");

const animateEnter = Vapor.Animation.init("opaque-dialog-enter")
    .prop(.opacity, 0, 1)
    .prop(.scale, 0.9, 1)
    .duration(200)
    .easing(.easeInOut);

const animateExit = Vapor.Animation.init("opaque-dialog-exit")
    .prop(.opacity, 1, 0)
    .prop(.scale, 1, 0.9)
    .duration(200)
    .easing(.easeInOut);

// const animateExitBackground = Vapor.Animation.init("opaque-dialog-exit-background")
//     .prop(.opacity, 1, 0)
//     .duration(200)
//     .easing(.easeInOut);

pub fn new() void {
    animateEnter.build();
    animateExit.build();
    // animateExitBackground.build();
}

content: ?*const fn (*Alert) void,
closed: bool = true,

pub fn init(content: ?*const fn (*Alert) void) Alert {
    return Alert{
        .content = content,
    };
}

pub fn open(alert: *Alert) void {
    alert.closed = false;
}

pub fn close(alert: *Alert) void {
    alert.closed = true;
}

fn evtClose(alert: *Alert, evt: *Vapor.Event) void {
    evt.preventDefault();
    alert.closed = true;
}

pub fn render(alert: *Alert) void {
    if (alert.closed) return;
    Box()
        .blur(1)
        .size(.full)
        .pos(.tl(.px(0), .px(0), .fixed))
        .zIndex(999)
        .layout(.center)
        .children({});
    Box()
        .size(.full)
        .pos(.tl(.px(0), .px(0), .fixed))
        .zIndex(999)
        .animationEnter("opaque-dialog-enter")
        .animationExit("opaque-dialog-exit")
        .layout(.center)
        .children({
        ButtonCtx(close, .{alert})
            .size(.full)
            .pos(.tl(.px(0), .px(0), .fixed))
            .size(.full)
            .layout(.center)
            .zIndex(999)
            .children({});
        Box()
            .background(.palette(.background))
            .shadow(.glow(30, .transparentizeHex(.black, 0.1)))
            .border(.round(.hex("#e4e4e4"), .all(12)))
            .layout(.center)
            .zIndex(1000)
            .children({
            if (alert.content) |content| {
                content(alert);
            }
        });
    });
}
