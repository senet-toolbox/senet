const std = @import("std");
const Fabric = @import("fabric");
const NavBar = @import("../../components/Navbar.zig");
const Custom = @import("../../components/Custom.zig");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Page = Fabric.Page;
const Pure = Fabric.Pure;

// Initialization
pub fn init() void {
    Page(@src(), render, null, .{});
}

pub fn Txt(text: []const u8) void {
    Static.Text(text, .{
        .font_size = 18,
    });
}

pub fn render() void {
    NavBar.render();
    Static.Center(.{
        .width = .percent(100),
        .height = .percent(100),
    })({
        Static.FlexBox(.{
            .margin = .{ .bottom = 32 },
            .width = .percent(82),
            .child_alignment = .{ .x = .even, .y = .center },
            // .child_alignment = .start_center,
        })({
            Static.Image("/assets/me.webp", .{
                // .position = .{ .type = .absolute, .top = .percent(10), .right = .percent(20) },
                .width = .percent(25),
                .border_radius = .all(999),
            });
            Static.Column(.{ .width = .percent(60), .child_gap = 16 })({
                Static.Text("Who am I?", .{
                    .font_size = 48,
                    .font_weight = 700,
                    .text_color = .hex("#1a1a1a"),
                });
                Custom.HtmlText(
                    \\Hi! My name is Vic-August Rokx-Nelleman, I know it's a mouthful. 
                    \\I'm currently working on my Master's Thesis at TU Delft, with a focus on Epidural Spinal Stimulation.
                    \\In my free time, I work on Tether. I started the project back in August 2025, also around the time I picked up Zig! 
                    \\Before that, I completed my Bachelor's Degree in Mechanical Engineering, and worked in web-development for about 3 years at Service Heroes
                    \\, and Heights and Minds.
                , .{
                    .font_size = 18,
                    .text_color = .hex("#1a1a1a"),
                });
                Custom.HtmlText(
                    \\I created Tether out of a deep curiosity for understanding and an even deeper frustration with modern web development.
                    \\I plan to use and continue development on Tether, as it is a tool I developed out my own selfish simplistic interest in creating apps.
                    \\Feel free to contact me on <a href="https://www.linkedin.com/in/vic-august-rokx-nellemann-7b2315229/">linkedin</a>, 
                    \\ or by email v.rokx.nellemann@gmail.com.
                , .{
                    .font_size = 18,
                    .text_color = .hex("#1a1a1a"),
                });
            });
        });
    });
}
