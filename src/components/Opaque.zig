const Vapor = @import("vapor");
const std = @import("std");

const Shadow = Vapor.Types.NewShadow;
const Color = Vapor.Types.Color;

pub const look_around = Vapor.Animation.init("look-around")
    .at(0).setAll(.{ .translateX = -1.5, .translateY = 0 })
    .at(16.6).setAll(.{ .translateX = -1.5, .translateY = 0 })
    .at(25).setAll(.{ .translateX = 1.5, .translateY = 0 })
    .at(41.6).setAll(.{ .translateX = 1.5, .translateY = 0 })
    .at(50).setAll(.{ .translateX = 0, .translateY = -1.5 })
    .at(66.6).setAll(.{ .translateX = 0, .translateY = -1.5 })
    .at(75).setAll(.{ .translateX = 0, .translateY = 0 })
    .at(91.6).setAll(.{ .translateX = 0, .translateY = 0 })
    .at(100).setAll(.{ .translateX = -1.5, .translateY = 0 })
    .easing(.easeInOut)
    .duration(2400)
    .infinite();

pub const text_glitch_chromatic = Vapor.Animation.init("text-glitch-chromatic")
    .duration(100)
    .iterations(3)
    .easing(.linear)

    // 0% - clean
    .at(0)
    .set(.translateX, 0)
    .set(.opacity, 1)
    .setShadow(.textShadow, Shadow.init()) // No shadow

    // 20% - RGB split left
    .at(20)
    .set(.translateX, -8)
    .set(.skewX, -10)
    .setShadow(.textShadow, Shadow.init()
        .drop(-4, 0, 0, .red) // Red left
        .drop(4, 0, 0, .cyan) // Cyan right
    )

    // 40% - RGB split right + flicker
    .at(40)
    .set(.translateX, 10)
    .set(.opacity, 0.6)
    .setShadow(.textShadow, Shadow.init()
        .drop(6, 2, 0, .green) // Green offset
        .drop(-6, -2, 0, .magenta) // Magenta opposite
    )

    // 60% - intense split
    .at(60)
    .set(.translateX, -6)
    .set(.translateY, -4)
    .set(.opacity, 1)
    .setShadow(.textShadow, Shadow.init()
        .drop(-8, 0, 2, .red) // Red offset
        .drop(8, 0, 2, .cyan))

    // 80% - settling
    .at(80)
    .set(.translateX, 3)
    .set(.skewX, -3)
    .setShadow(.textShadow, Shadow.init()
        .drop(-2, 0, 0, .red)
        .drop(2, 0, 0, .cyan))

    // 100% - clean
    .at(100)
    .set(.translateX, 0)
    .set(.translateY, 0)
    .set(.skewX, 0)
    .set(.opacity, 1)
    .setShadow(.textShadow, Shadow.init()); // Clear shadows

// After - using setAll + autoReset
pub const text_glitch: Vapor.Animation = Vapor.Animation.init("text-glitch")
    .duration(100)
    .iterations(3)
    .at(10).setAll(.{ .translateX = -8, .skewX = -12, .opacity = 0.9 })
    .at(25).setAll(.{ .translateX = 12, .translateY = -4, .skewX = 15, .opacity = 0 })
    .at(40).setAll(.{ .translateX = -6, .translateY = 6, .skewX = -8, .opacity = 1 })
    .at(55).setAll(.{ .translateX = 4, .translateY = -2, .opacity = 0.5 })
    .at(70).setAll(.{ .translateX = -10, .skewX = 10, .opacity = 0.8 })
    .at(85).setAll(.{ .translateX = 3, .translateY = 2, .skewX = -3, .opacity = 1 })
    .autoReset(); // Automatically adds 100% with all props reset

pub const glitch = Vapor.Animation.init("glitch")
    .duration(200)
    .at(25)
    .set(.translateX, -10)
    .setColor(.backgroundColor, .red)

    // 35% { transform: translate(10px); }
    .at(35)
    .set(.translateX, 10)
    .setColor(.backgroundColor, .green)
    .set(.scaleX, 1.1)

    // 59% { opacity: 0; }
    .at(59)
    .set(.opacity, 0)
    .setColor(.backgroundColor, .blue)

    // 60% { transform: translate(-10px); filter: blur(5px); }
    .at(60)
    .set(.opacity, 1) // Reset opacity from prev frame
    .set(.translateX, -10)
    .set(.blur, 5)
    .set(.scaleX, 0.7)

    // 100% { blur: (5px); }
    .at(100)
    .set(.blur, 5)
    .setColor(.backgroundColor, .yellow);

pub const blink = Vapor.Animation.init("blink")
    .duration(100)
    .infinite()
    .at(50)
    .set(.opacity, 0);

pub const fade_in = Vapor.Animation.init("opaque-fade-in")
    .prop(.opacity, 0, 1)
    .duration(150)
    .easing(.easeInOut)
    .fill(.forwards);

pub const fade_out = Vapor.Animation.init("opaque-fade-out")
    .prop(.opacity, 1, 0)
    .duration(150)
    .easing(.easeInOut)
    .fill(.forwards);

const Opaque = @This();

pub fn initAnimations() void {
    glitch.build();
    text_glitch.build();
    blink.build();
    fade_in.build();
    fade_out.build();
    text_glitch_chromatic.build();
    look_around.build();
}
