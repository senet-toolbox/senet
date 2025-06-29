const std = @import("std");
const Fabric = @import("fabric");
const Element = Fabric.Element;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Binded = Fabric.Binded;
const Style = Fabric.Style;

var primary: [4]u8 = undefined;
var secondary: [4]u8 = undefined;
var border_color: [4]u8 = undefined;
var text_color: [4]u8 = undefined;
var tint: [4]u8 = undefined;
var styles: Styles = undefined;

pub fn Sheet(comptime T: type, component: *const fn (T) void) type {
    return struct {
        const Self = @This();
        var sheet_element: Element = undefined;
        var sheet_backdrop_element: Element = undefined;
        var offset_height: f32 = 0;
        var drag_listener: usize = 0;
        var drag_end_listener: usize = 0;
        var drag_leave_listener: usize = 0;
        var current_translate: f32 = 0;
        var start_pos: f32 = 0;
        var is_drag: bool = false;
        var offset_perc: f32 = 70;
        var min: f32 = 0;
        var max: f32 = 50;
        allocator: *std.mem.Allocator,

        pub fn init(
            sheet: *Sheet(T, component).Self,
            allocator: *std.mem.Allocator,
        ) void {
            styles = Styles.init();
            sheet.* = .{
                .allocator = allocator,
            };
            sheet_element = Element{};
            sheet_backdrop_element = Element{};
        }

        pub fn deinit(_: *Sheet(component).Self) void {}

        pub fn toggle(_: *Self) void {
            sheet_element.mutateStyle("transition", .{ .string = "transform 0.2s ease-in" });
            const translation = Fabric.fmtln("translate3d({d}%, 0, 0)", .{min});
            sheet_element.mutateStyle("transform", .{ .string = translation });
            const translation_backdrop = Fabric.fmtln("translate3d({d}%, 0, 0)", .{0});
            sheet_backdrop_element.mutateStyle("transform", .{ .string = translation_backdrop });
            offset_perc = min;
        }

        fn show() void {
            sheet_element.mutateStyle("transition", .{ .string = "transform 0.2s ease-in" });
            const translation = Fabric.fmtln("translate3d({d}%, 0, 0)", .{min});
            sheet_element.mutateStyle("transform", .{ .string = translation });
            const translation_backdrop = Fabric.fmtln("translate3d({d}%, 0, 0)", .{0});
            sheet_backdrop_element.mutateStyle("transform", .{ .string = translation_backdrop });
            offset_perc = min;
        }

        fn close(_: *Fabric.Event) void {
            sheet_element.mutateStyle("transition", .{ .string = "transform 0.2s ease" });
            const translation = Fabric.fmtln("translate3d({d}%, 0, 0)", .{-100});
            sheet_element.mutateStyle("transform", .{ .string = translation });
            const translation_backdrop = Fabric.fmtln("translate3d({d}%, 0, 0)", .{-100});
            sheet_backdrop_element.mutateStyle("transform", .{ .string = translation_backdrop });
        }

        fn mount() void {
            _ = sheet_backdrop_element.addListener(.click, close);
        }

        pub fn render(_: *Self, inst: T) void {
            Static.Hooks(.{ .mounted = mount }, .{})({
                Binded.FlexBox(&sheet_backdrop_element, styles.outer_container)({});
                Binded.FlexBox(&sheet_element, styles.container)({
                    Static.Block(.{
                        .position = .{
                            .type = .fixed,
                        },
                        .width = .percent(100),
                        .height = .percent(100),
                    })({
                        Static.FlexBox(.{
                            .width = .percent(100),
                            .height = .percent(100),
                            .z_index = 1005,
                            .child_alignment = .{ .x = .start, .y = .start },
                        })({
                            @call(.auto, component, .{inst});
                        });
                    });
                });
            });
        }
    };
}

const Styles = struct {
    const Self = @This();
    container: Style,
    outer_container: Style,

    pub fn init() Self {
        return .{
            .outer_container = Style{
                .position = .{
                    .type = .absolute,
                    .bottom = .fixed(0),
                    .left = .fixed(0),
                    .top = .fixed(0),
                },
                .width = .percent(100),
                .height = .percent(100),
                .background = .rgba(0, 0, 0, 100),
                .transform = .{ .type = .translateX, .percent = -100 },
                .transition = .{ .properties = &.{.transform}, .duration = 0 },
                .z_index = 1100,
            },
            .container = Style{
                .direction = .column,
                .position = .{
                    .type = .fixed,
                    .bottom = .fixed(0),
                    .left = .fixed(0),
                    .top = .fixed(0),
                },
                .width = .percent(18),
                .height = .percent(100),
                .will_change = .transform,
                .backface_visibility = "hidden",
                .transform = .{ .type = .translateX, .percent = -100 },
                .border_thickness = .{ .right = 1 },
                // .border_color = border_color,
                // .background = primary,
                .z_index = 1100,
            },
        };
    }
};
