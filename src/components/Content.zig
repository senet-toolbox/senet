const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Static.Box;
const Hooks = Vapor.Static.Hooks;
const Text = Vapor.Static.Text;
const Button = Vapor.Static.Button;
const TextFmt = Vapor.Static.TextFmt;
const Icon = Vapor.Static.Icon;
const Custom = @import("../components/Custom.zig");
const DocNavbar = @import("../components/DocNavbar.zig");
const ListItem = Vapor.ListItem;
const List = Vapor.List;
const CtxButton = Vapor.CtxButton;

pub var boxes: []BoxNumber = undefined;
// var bounds: Vapor.lib.Bounds = undefined;
const BoxNumber = struct {
    id: []const u8,
    number: usize,
    bounds: Vapor.lib.Bounds = .{},
    active: bool = true,
    link: []const u8 = "",
};

pub fn initBoxes() void {
    boxes = Vapor.arena(.view).alloc(BoxNumber, 0) catch unreachable;
}

pub fn reinitBoxes() void {
    const ids = Vapor.queryComponentIds(.Intersection) catch unreachable;
    boxes = Vapor.arena(.view).alloc(BoxNumber, ids.len) catch unreachable;
    for (ids, 0..) |id, i| {
        const bounds = Vapor.getComponentBounds(id) orelse unreachable;
        const box_id = std.fmt.allocPrint(Vapor.arena(.view), "box-{d}", .{i}) catch unreachable;
        boxes[i] = .{ .id = box_id, .number = i, .bounds = bounds };
    }
}

pub fn deinitBoxes() void {
    Vapor.arena(.view).free(boxes);
}

pub fn new(default_text: []const u8) type {
    return struct {
        const Self = @This();
        var copied: bool = false;
        var relative_path: []const u8 = "/";
        content_text: []const u8 = default_text,

        pub fn init(_: *Self) void {
            relative_path = Vapor.Kit.getWindowPath() orelse "";
        }

        fn mount() void {
            Vapor.print("Mounted ---- ", .{});
            // const ids = Vapor.queryComponentIds(.Heading) catch unreachable;
            // boxes = Vapor.lib.frame_arena.persistentAllocator().alloc(BoxNumber, ids.len) catch unreachable;
            // for (ids, 0..) |id, i| {
            //     const bounds = Vapor.getBoundingClientRect(id) orelse unreachable;
            //     const box_id = std.fmt.allocPrint(Vapor.lib.frame_arena.persistentAllocator(), "box-{d}", .{i}) catch unreachable;
            //     boxes[i] = .{ .id = box_id, .number = i, .bounds = bounds };
            // }
            // Vapor.cycle();
        }

        fn toggleIcon(_: void) void {
            copied = false;
            // Vapor.cycle();
        }

        fn copy(self: *Self) void {
            Vapor.Clipboard.copy(self.content_text);
            copied = true;
            // Vapor.cycle();
            // Vapor.registerCtxTimeout("markdown_copy", 1000, toggleIcon, .{{}});
        }

        pub fn content(self: *Self, render: *const fn () void) void {
            // const current_path = Vapor.Kit.getWindowPath();
            // if (!std.mem.eql(u8, current_path, relative_path)) {
            //     Vapor.print("Path changed current: {s} relative: {s}", .{ current_path, relative_path });
            //     Vapor.onEnd(reinit);
            // }

            // Hooks(.{ .mounted = mount })({
            Box().style(&.{
                .size = .hw(.percent(100), .percent(100)),
                .layout = .top_center,
                .padding = .horizontal(12),
                .visual = .{
                    .layer = .grid(32, 1, .transparentizeHex(.palette(.grid_color), 0.9)),
                    .border = .{
                        .thickness = .lr(1),
                        .color = .palette(.border_color_light),
                    },
                },
                .position = .relative,
            })({
                List().layout(.{}).pos(.tr(.px(0), .px(0), .absolute)).children({
                    for (boxes) |box| {
                        const color: Vapor.Types.Color = if (box.active) .palette(.tint) else .palette(.border_color_light);
                        ListItem().id(box.id)
                            // .pos(.tl(.px(box.bounds.top + (box.bounds.height - 56) / 2), .px(box.bounds.left - 56 - 12), .absolute)).zIndex(999)
                            // .pos(.tr(.px(box.bounds.top + (box.bounds.height - 56) / 2 - 90), .px(-56), .absolute)).zIndex(999)
                            .pos(.tr(.px(box.bounds.top - 80), .px(-56), .absolute)).zIndex(999)
                            .width(.px(56))
                            .height(.px(56))
                            .border(.simple(color))
                            .layout(.center)
                            .children({
                            TextFmt("{d}", .{box.number}).font(18, 300, color).end();
                        });
                    }
                });

                Box().style(&.{
                    .size = .w(.percent(100)),
                    .child_gap = 16,
                    .direction = .column,
                    .layout = .{ .x = .start, .y = .start },
                })({
                    Box().style(&.{
                        .size = .w(.percent(100)),
                        .layout = .x_between_center,
                    })({
                        Text("Getting Started").style(&.{
                            .visual = .font(16, 600, null),
                            .font_family = "IBM Plex Sans",
                            .size = .w(.grow),
                        });
                        CtxButton(copy, .{self}).style(&.{
                            .visual = .{ .background = .transparent, .cursor = .pointer },
                            .size = .w(.fit),
                            .child_gap = 12,
                            .padding = .tb(8, 8),
                            .layout = .right_center,
                            .interactive = .{ .hover = .{ .text_color = .palette(.tint) } },
                        })({
                            if (copied) {
                                Icon(.check).style(&.{
                                    .visual = .{ .font_size = 16 },
                                });
                            } else {
                                Icon(.clipboard).style(&.{
                                    .visual = .{ .font_size = 16 },
                                });
                            }
                        });
                    });
                    Box().style(&.{
                        .child_gap = 4,
                        .direction = .column,
                        .size = .hw(.percent(100), .percent(100)),
                        .layout = .{},
                    })({
                        render();
                    });
                });
            });
            // });
        }
    };
}
