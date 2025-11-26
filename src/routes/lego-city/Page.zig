const Vapor = @import("vapor");
const Image = Vapor.Image;
const Box = Vapor.Box;
const Compiler = @import("../../main.zig");
const Vaporize = @import("vaporize");
const Content = @import("../../components/Content.zig");
const Center = Vapor.Center;
const Text = Vapor.Text;
const std = @import("std");

var markdown: Compiler.vaporize.MarkDown(.{
    .{ .tag = "lego_city_image", .function = lego_city_image },
}) = .{};
const lego_page = @embedFile("lego_city.md");
var content: Content.new(lego_page) = undefined;

const LegoType = enum {
    sqaure,
    rectangle,
};

const LegoBlock = struct {
    type: LegoType = .rectangle,
};

const LegoBox = struct {
    pub var blocks: std.heap.MemoryPool(LegoBlock) = std.heap.MemoryPool(LegoBlock).init(Vapor.arena(.persist));
};

const LegoHouse = struct {
    lego_bricks: [16]*const LegoBlock = undefined,
};

/// Construction
const Construction = struct {
    fn buildHouse(_: *Construction) !LegoHouse {
        var lego_bricks: [16]*const LegoBlock = undefined;
        for (0..16) |i| {
            const lego_block = try LegoBox.blocks.create();
            lego_block.* = .{};
            lego_bricks[i] = lego_block;
        }
        return LegoHouse{ .lego_bricks = lego_bricks };
    }
};

var construction = Construction{};

fn component() void {
    markdown.render() catch unreachable;
}

fn lego_city_image() void {
    Image(.{ .src = "/assets/skyscraper.png" })
        .height(.percent(4))
        .pos(.tl(.percent(4), .px(140), .absolute))
        .end();
}

var lego_houses: std.array_list.Managed(LegoHouse) = undefined;

pub fn init() void {
    markdown.compile(lego_page) catch unreachable; // 👈 We changed this to a comptime array
    lego_houses = std.array_list.Managed(LegoHouse).init(Vapor.arena(.persist));

    for (0..100) |_| {
        lego_houses.append(LegoHouse{}) catch unreachable;
    }
}

pub fn render() void {
    Box().style(&.{
        .layout = .x_between,
        .direction = .column,
        .size = .square_percent(100),
    })({
        Box().style(&.{
            .padding = .horizontal(12),
            .direction = .row,
            .size = .w(.percent(100)),
        })({
            Center().style(&.{
                .size = .w(.percent(100)),
                .padding = .{ .top = 60, .bottom = 120 },
                .direction = .column,
            })({
                Box().style(&.{
                    .size = .w(.mobile_desktop_percent(100, 50)),
                    // .width = .mobile_desktop_percent(100, 64),
                    // .size = .w(.percent(100)),
                    .child_gap = 32,
                    .direction = .column,
                    .padding = .{ .bottom = 80 },
                    .margin = .tb(32, 32),
                })({
                    content.content(component);
                });
            });
        });
    });

    // Box().layout(.center).spacing(16).padding(.all(20)).size(.full)
    //     .children({
    //     Box().layout(.center).size(.square_percent(40))
    //         .pos(.relative)
    //         .children({
    //         Image(.{ .src = "/assets/skyscraper.png" })
    //             .height(.percent(100))
    //             .pos(.tl(.px(0), .px(0), .absolute))
    //             .end();
    //         Image(.{ .src = "/assets/skyscraper.png" })
    //             .height(.percent(100))
    //             .pos(.tl(.px(60), .percent(20), .absolute))
    //             .end();
    //         Image(.{ .src = "/assets/lego_house.png" })
    //             .height(.percent(45))
    //             .pos(.tl(.percent(60), .percent(-30), .absolute))
    //             .end();
    //         Image(.{ .src = "/assets/skyscraper.png" })
    //             .height(.percent(100))
    //             .pos(.tl(.percent(22), .percent(-50), .absolute))
    //             .end();
    //     });
    // });
}
