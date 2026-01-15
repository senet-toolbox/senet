const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const ButtonCtx = Vapor.CtxButton;
const Button = Vapor.Button;

var background: Vapor.Types.Background = .palette(.background);
var border_color: Vapor.Types.Color = .hex("#e4e4e4");
var tooltips: std.AutoHashMap(usize, *TooltipOptions) = undefined;
var alternate_text_color: Vapor.Types.Color = .palette(.alternate_text_color);
var border: Vapor.Types.BorderGrouped = .round(.palette(.border_color_light), .all(6));

pub const animateEnter = Vapor.Animation.init("opaque-tooltip-enter")
    .prop(.opacity, 0, 1)
    .prop(.scale, 0.9, 1)
    .duration(200)
    .easing(.easeInOut);

pub const animateExit = Vapor.Animation.init("opaque-tooltip-exit")
    .prop(.opacity, 1, 0)
    .prop(.scaleY, 1, 0.9)
    .duration(100)
    .easing(.easeInOut);

pub fn new() void {
    tooltips = std.AutoHashMap(usize, *TooltipOptions).init(Vapor.arena(.persist));
    animateEnter.build();
    animateExit.build();
    const allocator = Vapor.arena(.persist);
    corner_svg = std.fmt.allocPrint(allocator, svg, .{"--alternate_background"}) catch unreachable;
}

const svg: []const u8 =
    \\<svg style="position:absolute; transform: translate(-50%, 50%) rotate(45deg);
    \\bottom: 0;
    \\left: 50%;
    \\fill: rgba(var({s}))" xmlns="http://www.w3.org/2000/svg" width="10" height="8" class="bi bi-square-fill" viewBox="0 0 16 16">
    \\  <path d="M0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2z"/>
    \\</svg>
;

var corner_svg: []const u8 = "";

const ToolTip = @This();
component: ?*const fn () void = null,

const TooltipOptions = struct {
    stable_id: usize = 0,
    show: bool = false,
    timeout_key: []const u8 = "",
    show_timeout_key: []const u8 = "",
};

fn onHover(options: *TooltipOptions, _: *Vapor.Event) void {
    Vapor.lib.cancelTimeout(options.timeout_key);
    Vapor.lib.registerCtxTimeout(options.show_timeout_key, 300, show, .{options});
}

fn show(options: *TooltipOptions) void {
    options.show = true;
}

fn onLeave(options: *TooltipOptions, _: *Vapor.Event) void {
    Vapor.lib.cancelTimeout(options.show_timeout_key);
    Vapor.lib.registerCtxTimeout(options.timeout_key, 150, close, .{options});
}

fn close(options: *TooltipOptions) void {
    options.show = false;
}

fn destroy(options: *TooltipOptions) void {
    defer Vapor.arena(.persist).destroy(options);
    _ = tooltips.remove(options.stable_id);
}

const Options = struct {
    id: []const u8 = "",
    name: []const u8,
    title: []const u8 = "",
    content: []const u8 = "",
    trigger: ?*const fn () void = null,
    component: ?*const fn () void = null,
    ctx: ?*anyopaque = null,
    trigger_ctx: ?*const fn (ctx: ?*anyopaque) void = null,
};

fn HoverBox() Vapor.Builder(.pure) {
    return Box()
        .width(.fit)
        .height(.fit);
}

pub fn renderCtx(tooltip_options: Options) void {
    const hover_box = HoverBox();
    const uuid = hover_box.getUUID();
    const hash = Vapor.utils.hashKey(uuid);
    // const id_hash = if (tooltip_options.id.len > 0) Vapor.utils.hashKey(tooltip_options.id) else 0;
    // var stable_id = @as(usize, @intCast(Vapor.utils.hashKey(tooltip_options.name) + id_hash));
    const stable_id = hash;

    const timeout_key = Vapor.fmtln("tt_timer_{d}", .{stable_id});
    const show_timeout_key = Vapor.fmtln("show_tt_timer_{d}", .{stable_id});

    const options = tooltips.get(stable_id) orelse blk: {
        const options = Vapor.arena(.persist).create(TooltipOptions) catch unreachable;
        options.* = .{
            .stable_id = stable_id,
            .show = false,
            .timeout_key = timeout_key,
            .show_timeout_key = show_timeout_key,
        };

        tooltips.put(stable_id, options) catch unreachable;
        break :blk options;
    };

    const anchor_name = if (tooltip_options.id.len > 0) tooltip_options.id else uuid;
    hover_box
        .onEventCtx(.pointerenter, onHover, options)
        .onEventCtx(.pointerleave, onLeave, options)
        .inlineStyle("anchor-name: --{s};", .{anchor_name})
        .children({
        if (tooltip_options.trigger_ctx) |trigger| {
            @call(.auto, trigger, .{tooltip_options.ctx});
        } else {
            Box()
                .padding(.tblr(4, 4, 12, 12))
                .background(background)
                .duration(100)
                .hover(.{
                    .transform = .scale(),
                })
                .border(border)
                .children({
                Text(tooltip_options.title).font(14, 300, .palette(.text_color)).end();
            });
        }
    });
    Box()
        .transformOrigin(.bottom_center)
        .onEventCtx(.pointerenter, onHover, options)
        .onEventCtx(.pointerleave, onLeave, options)
        .inlineStyle(
            \\position: fixed; /* Fixed is better for Top Layer anchors */
            \\position-anchor: --{s}; 
            \\bottom: anchor(top);
            \\justify-self: anchor-center;
            \\margin-bottom: 8px; /* Handle gap here */
        , .{anchor_name})
        .children({
        Vapor.Static.HooksCtx(.destroy, destroy, .{options})({
            if (options.show) {
                Box()
                    .transformOrigin(.bottom_center)
                    .animationEnter("opaque-tooltip-enter")
                    .animationExit("opaque-tooltip-exit")
                    .border(.round(.transparent, .all(6)))
                    .zIndex(1000)
                    .layout(.center)
                    .direction(.column)
                    .children({
                    Box()
                        .background(.palette(.alternate_background))
                        .padding(.tblr(6, 6, 12, 12))
                        .border(.round(.transparent, .all(6)))
                        .layout(.center)
                        .direction(.column)
                        .children({
                        if (tooltip_options.component) |component| {
                            @call(.auto, component, .{});
                        } else {
                            Text(tooltip_options.content).font(14, 300, alternate_text_color).end();
                        }
                    });
                    Vapor.Svg(.{ .svg = corner_svg })
                        .end();
                });
                Box()
                    .inlineStyle(
                        \\position: absolute;
                        \\top: 100%;       /* Push it below the tooltip */
                        \\left: 0;
                        \\width: 100%;     /* Match tooltip width */
                        \\height: 10px;    /* 8px gap + 2px buffer */
                        \\background: transparent; /* Invisible but catches mouse events */
                        \\z-index: 999;
                    , .{})
                    .children({});
            }
        });
    });
}

pub fn render(tooltip_options: Options) void {
    const hover_box = HoverBox();
    const uuid = hover_box.getUUID();
    const hash = Vapor.utils.hashKey(uuid);
    const id_hash = if (tooltip_options.id.len > 0) Vapor.utils.hashKey(tooltip_options.id) else 0;
    var stable_id = @as(usize, @intCast(Vapor.utils.hashKey(tooltip_options.name) + id_hash));
    stable_id +%= hash;

    const timeout_key = Vapor.fmtln("tt_timer_{d}", .{stable_id});

    const options = tooltips.get(stable_id) orelse blk: {
        const options = Vapor.arena(.persist).create(TooltipOptions) catch unreachable;
        options.* = .{
            .stable_id = stable_id,
            .show = false,
            .timeout_key = timeout_key,
        };

        tooltips.put(stable_id, options) catch unreachable;
        break :blk options;
    };

    const anchor_name = if (tooltip_options.id.len > 0) tooltip_options.id else uuid;
    hover_box
        .onEventCtx(.pointerenter, onHover, options)
        .onEventCtx(.pointerleave, onLeave, options)
        // .inlineStyle("anchor-name: --{s}-{s};", .{ tooltip_options.name, anchor_name })
        .anchorSource(anchor_name)
        .children({
        if (tooltip_options.trigger) |trigger| {
            @call(.auto, trigger, .{});
        } else {
            Box()
                .padding(.tblr(4, 4, 12, 12))
                .background(background)
                .duration(100)
                .hover(.{
                    .transform = .scale(),
                })
                .border(border)
                .children({
                Text(tooltip_options.title).font(14, 300, .palette(.text_color)).end();
            });
        }
    });
    Box()
        .transformOrigin(.bottom_center)
        .onEventCtx(.pointerenter, onHover, options)
        .onEventCtx(.pointerleave, onLeave, options)
        .inlineStyle(
            \\position: fixed; /* Fixed is better for Top Layer anchors */
            \\position-anchor: --{s}-{s}; 
            // \\bottom: anchor(top);
            // \\justify-self: anchor-center;
            \\margin-bottom: 32px; /* Handle gap here */
        , .{ tooltip_options.name, anchor_name })
        .children({
        Vapor.Static.HooksCtx(.destroy, destroy, .{options})({
            if (options.show) {
                Box()
                    .transformOrigin(.bottom_center)
                    .animationEnter("opaque-tooltip-enter")
                    .animationExit("opaque-tooltip-exit")
                    .border(.round(.transparent, .all(6)))
                    .zIndex(1000)
                    .layout(.center)
                    .direction(.column)
                    .children({
                    Box()
                        .background(.palette(.alternate_background))
                        .padding(.tblr(6, 6, 12, 12))
                        .border(.round(.transparent, .all(6)))
                        .layout(.center)
                        .direction(.column)
                        .children({
                        if (tooltip_options.component) |component| {
                            @call(.auto, component, .{});
                        } else {
                            Text(tooltip_options.content).font(14, 300, alternate_text_color).end();
                        }
                    });
                    Vapor.Svg(.{ .svg = corner_svg })
                        .end();
                });
                Box()
                    .inlineStyle(
                        \\position: absolute;
                        \\top: 100%;       /* Push it below the tooltip */
                        \\left: 0;
                        \\width: 100%;     /* Match tooltip width */
                        \\height: 10px;    /* 8px gap + 2px buffer */
                        \\background: transparent; /* Invisible but catches mouse events */
                        \\z-index: 999;
                    , .{})
                    .children({});
            }
        });
    });
}
