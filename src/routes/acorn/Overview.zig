// Dashboard
const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const Icon = Vapor.Icon;
const Label = Vapor.Label;
const TextFmt = Vapor.TextFmt;
const TextField = Vapor.TextField;
const TextArea = Vapor.TextArea;
const Animation = Vapor.Animation;
const ButtonCtx = Vapor.CtxButton;
const toggleTheme = @import("theme").toggleTheme;
const data = @import("exception_data.zig").exceptions_data;
const traces_data = @import("traces_data.zig").traces_data;
const Dashboard = @import("Dashboard.zig");
const Theme = Dashboard.Theme;
const Opaque = @import("../../components/Opaque.zig");
const Field = Opaque.Field;
const Tooltip = Opaque.Tooltip;
const Button = Opaque.Button;
const Chart = Opaque.Chart;
const Tabs = Opaque.Tabs;
const Table = Opaque.Table;
const Column = Opaque.Column;
const Action = Opaque.Action;

// ============================================================================
// DATA TYPES
// ============================================================================

// ============================================================================
// INITIALIZATION
// ============================================================================

var rest_chart: Chart = undefined;
const rest_requests = [_]Chart.Point{
    .{ .x = 1, .y = 10 },
    .{ .x = 2, .y = 4 },
    .{ .x = 3, .y = 0 },
    .{ .x = 4, .y = 18 },
    .{ .x = 5, .y = 12 },
    .{ .x = 6, .y = 19 },
    .{ .x = 7, .y = 24 },
    .{ .x = 8, .y = 43 },
    .{ .x = 9, .y = 25 },
    .{ .x = 10, .y = 15 },
    .{ .x = 11, .y = 29 },
    .{ .x = 12, .y = 9 },
    .{ .x = 13, .y = 9 },
    .{ .x = 14, .y = 10 },
    .{ .x = 15, .y = 30 },
    .{ .x = 16, .y = 20 },
    .{ .x = 17, .y = 35 },
    .{ .x = 18, .y = 25 },
    .{ .x = 19, .y = 10 },
    .{ .x = 20, .y = 30 },
    .{ .x = 21, .y = 35 },
    .{ .x = 22, .y = 25 },
    .{ .x = 23, .y = 30 },
};

var auth_chart: Chart = undefined;
const auth_requests = [_]Chart.Point{
    .{ .x = 1, .y = 30 },
    .{ .x = 2, .y = 24 },
    .{ .x = 3, .y = 10 },
    .{ .x = 4, .y = 0 },
    .{ .x = 5, .y = 12 },
    .{ .x = 6, .y = 24 },
    .{ .x = 7, .y = 20 },
    .{ .x = 8, .y = 100 },
    .{ .x = 9, .y = 80 },
    .{ .x = 10, .y = 74 },
    .{ .x = 11, .y = 32 },
    .{ .x = 12, .y = 18 },
    .{ .x = 13, .y = 1 },
    .{ .x = 14, .y = 20 },
    .{ .x = 15, .y = 10 },
    .{ .x = 16, .y = 20 },
    .{ .x = 17, .y = 25 },
    .{ .x = 18, .y = 25 },
    .{ .x = 19, .y = 20 },
    .{ .x = 20, .y = 40 },
    .{ .x = 21, .y = 15 },
    .{ .x = 22, .y = 45 },
    .{ .x = 23, .y = 20 },
};

var storage_chart: Chart = undefined;
const storage_requests = [_]Chart.Point{
    .{ .x = 1, .y = 30 },
    .{ .x = 2, .y = 24 },
    .{ .x = 3, .y = 10 },
    .{ .x = 4, .y = 0 },
    .{ .x = 5, .y = 12 },
    .{ .x = 6, .y = 24 },
    .{ .x = 7, .y = 20 },
    .{ .x = 8, .y = 100 },
    .{ .x = 9, .y = 80 },
    .{ .x = 10, .y = 74 },
    .{ .x = 11, .y = 32 },
    .{ .x = 12, .y = 18 },
    .{ .x = 13, .y = 1 },
    .{ .x = 14, .y = 20 },
    .{ .x = 15, .y = 10 },
    .{ .x = 16, .y = 20 },
    .{ .x = 17, .y = 25 },
    .{ .x = 18, .y = 25 },
    .{ .x = 19, .y = 20 },
    .{ .x = 20, .y = 40 },
    .{ .x = 21, .y = 15 },
    .{ .x = 22, .y = 45 },
    .{ .x = 23, .y = 20 },
};

var error_chart: Chart = undefined;
const error_requests = [_]Chart.Point{
    .{ .x = 1, .y = 30 },
    .{ .x = 2, .y = 24 },
    .{ .x = 3, .y = 10 },
    .{ .x = 4, .y = 0 },
    .{ .x = 5, .y = 12 },
    .{ .x = 6, .y = 24 },
    .{ .x = 7, .y = 20 },
    .{ .x = 8, .y = 100 },
    .{ .x = 9, .y = 80 },
    .{ .x = 10, .y = 74 },
    .{ .x = 11, .y = 32 },
    .{ .x = 12, .y = 18 },
    .{ .x = 13, .y = 1 },
    .{ .x = 14, .y = 20 },
    .{ .x = 15, .y = 10 },
    .{ .x = 16, .y = 20 },
    .{ .x = 17, .y = 25 },
    .{ .x = 18, .y = 25 },
    .{ .x = 19, .y = 20 },
    .{ .x = 20, .y = 40 },
    .{ .x = 21, .y = 15 },
    .{ .x = 22, .y = 45 },
    .{ .x = 23, .y = 20 },
};

const put_color = Vapor.Types.Color.hex("#f59e0b");
const delete_color = Vapor.Types.Color.hex("#f59e0b");
const head_color = Vapor.Types.Color.hex("#f59e0b");
const options_color = Vapor.Types.Color.hex("#f59e0b");

const get_color = Vapor.Types.Color.hex("#3344FF");
const post_color = Vapor.Types.Color.hex("#2BBCFF");
const patch_color = Vapor.Types.Color.hex("#8ADBAA");

var http_chart: Chart = undefined;
var response_times_chart: Chart = undefined;

const http_requests = [_]Chart.Point{
    Chart.Point{ .x = 1, .stack = &.{ .{ .value = 52, .color = get_color }, .{ .value = 11, .color = post_color }, .{ .value = 9, .color = patch_color } } },
    Chart.Point{ .x = 2, .stack = &.{ .{ .value = 48, .color = get_color }, .{ .value = 13, .color = post_color }, .{ .value = 10, .color = patch_color } } },
    Chart.Point{ .x = 3, .stack = &.{ .{ .value = 55, .color = get_color }, .{ .value = 12, .color = post_color }, .{ .value = 11, .color = patch_color } } },
    Chart.Point{ .x = 4, .stack = &.{ .{ .value = 20, .color = get_color }, .{ .value = 14, .color = post_color }, .{ .value = 12, .color = patch_color } } },
    Chart.Point{ .x = 5, .stack = &.{ .{ .value = 48, .color = get_color }, .{ .value = 13, .color = post_color }, .{ .value = 12, .color = patch_color } } },
    Chart.Point{ .x = 6, .stack = &.{ .{ .value = 62, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 7, .stack = &.{ .{ .value = 85, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 8, .stack = &.{ .{ .value = 83, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 9, .stack = &.{ .{ .value = 31, .color = get_color }, .{ .value = 14, .color = post_color }, .{ .value = 12, .color = patch_color } } },
    Chart.Point{ .x = 10, .stack = &.{ .{ .value = 49, .color = get_color }, .{ .value = 13, .color = post_color }, .{ .value = 11, .color = patch_color } } },

    Chart.Point{ .x = 11, .stack = &.{ .{ .value = 44, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 12, .stack = &.{ .{ .value = 36, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 13, .stack = &.{ .{ .value = 88, .color = get_color }, .{ .value = 17, .color = post_color }, .{ .value = 15, .color = patch_color } } },
    Chart.Point{ .x = 14, .stack = &.{ .{ .value = 20, .color = get_color }, .{ .value = 18, .color = post_color }, .{ .value = 16, .color = patch_color } } },
    Chart.Point{ .x = 15, .stack = &.{ .{ .value = 72, .color = get_color }, .{ .value = 19, .color = post_color }, .{ .value = 17, .color = patch_color } } },

    Chart.Point{ .x = 16, .stack = &.{ .{ .value = 61, .color = get_color }, .{ .value = 18, .color = post_color }, .{ .value = 16, .color = patch_color } } },
    Chart.Point{ .x = 17, .stack = &.{ .{ .value = 19, .color = get_color }, .{ .value = 17, .color = post_color }, .{ .value = 15, .color = patch_color } } },
    Chart.Point{ .x = 18, .stack = &.{ .{ .value = 37, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 19, .stack = &.{ .{ .value = 65, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 20, .stack = &.{ .{ .value = 93, .color = get_color }, .{ .value = 14, .color = post_color }, .{ .value = 12, .color = patch_color } } },

    Chart.Point{ .x = 21, .stack = &.{ .{ .value = 36, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 22, .stack = &.{ .{ .value = 88, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 23, .stack = &.{ .{ .value = 90, .color = get_color }, .{ .value = 17, .color = post_color }, .{ .value = 15, .color = patch_color } } },
    Chart.Point{ .x = 24, .stack = &.{ .{ .value = 92, .color = get_color }, .{ .value = 18, .color = post_color }, .{ .value = 16, .color = patch_color } } },
    Chart.Point{ .x = 25, .stack = &.{ .{ .value = 24, .color = get_color }, .{ .value = 19, .color = post_color }, .{ .value = 17, .color = patch_color } } },

    Chart.Point{ .x = 26, .stack = &.{ .{ .value = 93, .color = get_color }, .{ .value = 18, .color = post_color }, .{ .value = 16, .color = patch_color } } },
    Chart.Point{ .x = 27, .stack = &.{ .{ .value = 51, .color = get_color }, .{ .value = 17, .color = post_color }, .{ .value = 15, .color = patch_color } } },
    Chart.Point{ .x = 28, .stack = &.{ .{ .value = 49, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 29, .stack = &.{ .{ .value = 77, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 30, .stack = &.{ .{ .value = 65, .color = get_color }, .{ .value = 14, .color = post_color }, .{ .value = 12, .color = patch_color } } },

    Chart.Point{ .x = 31, .stack = &.{ .{ .value = 68, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 32, .stack = &.{ .{ .value = 70, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 33, .stack = &.{ .{ .value = 72, .color = get_color }, .{ .value = 17, .color = post_color }, .{ .value = 15, .color = patch_color } } },
    Chart.Point{ .x = 34, .stack = &.{ .{ .value = 74, .color = get_color }, .{ .value = 18, .color = post_color }, .{ .value = 16, .color = patch_color } } },
    Chart.Point{ .x = 35, .stack = &.{ .{ .value = 76, .color = get_color }, .{ .value = 19, .color = post_color }, .{ .value = 17, .color = patch_color } } },

    Chart.Point{ .x = 36, .stack = &.{ .{ .value = 95, .color = get_color }, .{ .value = 18, .color = post_color }, .{ .value = 16, .color = patch_color } } },
    Chart.Point{ .x = 37, .stack = &.{ .{ .value = 93, .color = get_color }, .{ .value = 17, .color = post_color }, .{ .value = 15, .color = patch_color } } },
    Chart.Point{ .x = 38, .stack = &.{ .{ .value = 41, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 39, .stack = &.{ .{ .value = 39, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 40, .stack = &.{ .{ .value = 67, .color = get_color }, .{ .value = 14, .color = post_color }, .{ .value = 12, .color = patch_color } } },

    Chart.Point{ .x = 41, .stack = &.{ .{ .value = 40, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 42, .stack = &.{ .{ .value = 82, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 43, .stack = &.{ .{ .value = 34, .color = get_color }, .{ .value = 17, .color = post_color }, .{ .value = 15, .color = patch_color } } },
    Chart.Point{ .x = 44, .stack = &.{ .{ .value = 46, .color = get_color }, .{ .value = 18, .color = post_color }, .{ .value = 16, .color = patch_color } } },
    Chart.Point{ .x = 45, .stack = &.{ .{ .value = 28, .color = get_color }, .{ .value = 19, .color = post_color }, .{ .value = 17, .color = patch_color } } },

    Chart.Point{ .x = 46, .stack = &.{ .{ .value = 77, .color = get_color }, .{ .value = 18, .color = post_color }, .{ .value = 16, .color = patch_color } } },
    Chart.Point{ .x = 47, .stack = &.{ .{ .value = 85, .color = get_color }, .{ .value = 17, .color = post_color }, .{ .value = 15, .color = patch_color } } },
    Chart.Point{ .x = 48, .stack = &.{ .{ .value = 63, .color = get_color }, .{ .value = 16, .color = post_color }, .{ .value = 14, .color = patch_color } } },
    Chart.Point{ .x = 49, .stack = &.{ .{ .value = 91, .color = get_color }, .{ .value = 15, .color = post_color }, .{ .value = 13, .color = patch_color } } },
    Chart.Point{ .x = 50, .stack = &.{ .{ .value = 29, .color = get_color }, .{ .value = 14, .color = post_color }, .{ .value = 12, .color = patch_color } } },
};

const api_color = Vapor.Types.Color.hex("#595959"); // green
const auth_color = Vapor.Types.Color.hex("#787878"); // blue
const db_color = Vapor.Types.Color.hex("#939393"); // amber
const cache_color = Vapor.Types.Color.hex("#C4C4C4"); // purple
const worker_color = Vapor.Types.Color.hex("#EECC42"); // red

// zig fmt: off
const api_response_time = [_]Chart.Point{
    .{ .x=1, .y=12 }, .{ .x=2, .y=18 }, .{ .x=3, .y=21 }, .{ .x=4, .y=24 }, .{ .x=5, .y=22 },
    .{ .x=6, .y=126 }, .{ .x=7, .y=29 }, .{ .x=8, .y=27 }, .{ .x=9, .y=25 }, .{ .x=10, .y=23 },
    .{ .x=11, .y=28 }, .{ .x=12, .y=30 }, .{ .x=13, .y=42 }, .{ .x=14, .y=54 }, .{ .x=15, .y=67 },
    .{ .x=16, .y=35 }, .{ .x=17, .y=33 }, .{ .x=18, .y=41 }, .{ .x=19, .y=29 }, .{ .x=20, .y=47 },
    .{ .x=21, .y=40 }, .{ .x=22, .y=43 }, .{ .x=23, .y=46 }, .{ .x=24, .y=59 }, .{ .x=25, .y=42 },
    .{ .x=26, .y=40 }, .{ .x=27, .y=38 }, .{ .x=28, .y=36 }, .{ .x=29, .y=34 }, .{ .x=30, .y=32 },
    .{ .x=31, .y=35 }, .{ .x=32, .y=138 }, .{ .x=33, .y=341 }, .{ .x=34, .y=344 }, .{ .x=35, .y=347 },
    .{ .x=36, .y=45 }, .{ .x=37, .y=43 }, .{ .x=38, .y=41 }, .{ .x=39, .y=39 }, .{ .x=40, .y=37 },
    .{ .x=41, .y=40 }, .{ .x=42, .y=42 }, .{ .x=43, .y=45 }, .{ .x=44, .y=47 }, .{ .x=45, .y=50 },
    .{ .x=46, .y=48 }, .{ .x=47, .y=46 }, .{ .x=48, .y=44 }, .{ .x=49, .y=42 }, .{ .x=50, .y=40 },
    .{ .x=51, .y=38 }, .{ .x=52, .y=35 }, .{ .x=53, .y=33 }, .{ .x=54, .y=31 }, .{ .x=55, .y=29 },
    .{ .x=56, .y=32 }, .{ .x=57, .y=36 }, .{ .x=58, .y=39 }, .{ .x=59, .y=42 }, .{ .x=60, .y=45 },
    .{ .x=61, .y=48 }, .{ .x=62, .y=52 }, .{ .x=63, .y=189 }, .{ .x=64, .y=56 }, .{ .x=65, .y=53 },
    .{ .x=66, .y=49 }, .{ .x=67, .y=46 }, .{ .x=68, .y=43 }, .{ .x=69, .y=40 }, .{ .x=70, .y=38 },
    .{ .x=71, .y=36 }, .{ .x=72, .y=34 }, .{ .x=73, .y=32 }, .{ .x=74, .y=30 }, .{ .x=75, .y=28 },
    .{ .x=76, .y=31 }, .{ .x=77, .y=34 }, .{ .x=78, .y=37 }, .{ .x=79, .y=40 }, .{ .x=80, .y=43 },
    .{ .x=81, .y=46 }, .{ .x=82, .y=49 }, .{ .x=83, .y=52 }, .{ .x=84, .y=55 }, .{ .x=85, .y=58 },
    .{ .x=86, .y=245 }, .{ .x=87, .y=267 }, .{ .x=88, .y=54 }, .{ .x=89, .y=51 }, .{ .x=90, .y=48 },
    .{ .x=91, .y=45 }, .{ .x=92, .y=42 }, .{ .x=93, .y=39 }, .{ .x=94, .y=36 }, .{ .x=95, .y=33 },
    .{ .x=96, .y=30 }, .{ .x=97, .y=28 }, .{ .x=98, .y=26 }, .{ .x=99, .y=24 }, .{ .x=100, .y=22 },
    .{ .x=101, .y=25 }, .{ .x=102, .y=28 }, .{ .x=103, .y=31 }, .{ .x=104, .y=34 }, .{ .x=105, .y=37 },
    .{ .x=106, .y=40 }, .{ .x=107, .y=43 }, .{ .x=108, .y=46 }, .{ .x=109, .y=49 }, .{ .x=110, .y=52 },
    .{ .x=111, .y=55 }, .{ .x=112, .y=58 }, .{ .x=113, .y=61 }, .{ .x=114, .y=64 }, .{ .x=115, .y=67 },
    .{ .x=116, .y=312 }, .{ .x=117, .y=298 }, .{ .x=118, .y=62 }, .{ .x=119, .y=59 }, .{ .x=120, .y=56 },
    .{ .x=121, .y=53 }, .{ .x=122, .y=50 }, .{ .x=123, .y=47 }, .{ .x=124, .y=44 }, .{ .x=125, .y=41 },
    .{ .x=126, .y=38 }, .{ .x=127, .y=35 }, .{ .x=128, .y=32 }, .{ .x=129, .y=29 }, .{ .x=130, .y=26 },
    .{ .x=131, .y=29 }, .{ .x=132, .y=32 }, .{ .x=133, .y=35 }, .{ .x=134, .y=38 }, .{ .x=135, .y=41 },
    .{ .x=136, .y=44 }, .{ .x=137, .y=47 }, .{ .x=138, .y=50 }, .{ .x=139, .y=53 }, .{ .x=140, .y=56 },
    .{ .x=141, .y=59 }, .{ .x=142, .y=156 }, .{ .x=143, .y=65 }, .{ .x=144, .y=68 }, .{ .x=145, .y=71 },
    .{ .x=146, .y=68 }, .{ .x=147, .y=65 }, .{ .x=148, .y=62 }, .{ .x=149, .y=59 }, .{ .x=150, .y=56 },
    .{ .x=151, .y=53 }, .{ .x=152, .y=50 }, .{ .x=153, .y=47 }, .{ .x=154, .y=44 }, .{ .x=155, .y=41 },
    .{ .x=156, .y=38 }, .{ .x=157, .y=35 }, .{ .x=158, .y=32 }, .{ .x=159, .y=29 }, .{ .x=160, .y=26 },
    .{ .x=161, .y=29 }, .{ .x=162, .y=32 }, .{ .x=163, .y=35 }, .{ .x=164, .y=38 }, .{ .x=165, .y=41 },
    .{ .x=166, .y=44 }, .{ .x=167, .y=47 }, .{ .x=168, .y=50 }, .{ .x=169, .y=53 }, .{ .x=170, .y=56 },
    .{ .x=171, .y=423 }, .{ .x=172, .y=387 }, .{ .x=173, .y=65 }, .{ .x=174, .y=62 }, .{ .x=175, .y=59 },
    .{ .x=176, .y=56 }, .{ .x=177, .y=53 }, .{ .x=178, .y=50 }, .{ .x=179, .y=47 }, .{ .x=180, .y=44 },
    .{ .x=181, .y=41 }, .{ .x=182, .y=38 }, .{ .x=183, .y=35 }, .{ .x=184, .y=32 }, .{ .x=185, .y=29 },
    .{ .x=186, .y=32 }, .{ .x=187, .y=35 }, .{ .x=188, .y=38 }, .{ .x=189, .y=41 }, .{ .x=190, .y=44 },
    .{ .x=191, .y=47 }, .{ .x=192, .y=50 }, .{ .x=193, .y=53 }, .{ .x=194, .y=56 }, .{ .x=195, .y=59 },
    .{ .x=196, .y=62 }, .{ .x=197, .y=58 }, .{ .x=198, .y=54 }, .{ .x=199, .y=50 }, .{ .x=200, .y=46 },
};

const auth_response_time = [_]Chart.Point{
    .{ .x=1, .y=90 }, .{ .x=2, .y=92 }, .{ .x=3, .y=91 }, .{ .x=4, .y=93 }, .{ .x=5, .y=94 },
    .{ .x=6, .y=95 }, .{ .x=7, .y=97 }, .{ .x=8, .y=96 }, .{ .x=9, .y=95 }, .{ .x=10, .y=94 },
    .{ .x=11, .y=96 }, .{ .x=12, .y=98 }, .{ .x=13, .y=99 }, .{ .x=14, .y=100 }, .{ .x=15, .y=102 },
    .{ .x=16, .y=101 }, .{ .x=17, .y=100 }, .{ .x=18, .y=99 }, .{ .x=19, .y=98 }, .{ .x=20, .y=97 },
    .{ .x=21, .y=99 }, .{ .x=22, .y=101 }, .{ .x=23, .y=103 }, .{ .x=24, .y=105 }, .{ .x=25, .y=107 },
    .{ .x=26, .y=106 }, .{ .x=27, .y=104 }, .{ .x=28, .y=102 }, .{ .x=29, .y=101 }, .{ .x=30, .y=100 },
    .{ .x=31, .y=102 }, .{ .x=32, .y=104 }, .{ .x=33, .y=106 }, .{ .x=34, .y=108 }, .{ .x=35, .y=110 },
    .{ .x=36, .y=109 }, .{ .x=37, .y=107 }, .{ .x=38, .y=105 }, .{ .x=39, .y=104 }, .{ .x=40, .y=103 },
    .{ .x=41, .y=105 }, .{ .x=42, .y=107 }, .{ .x=43, .y=109 }, .{ .x=44, .y=111 }, .{ .x=45, .y=113 },
    .{ .x=46, .y=112 }, .{ .x=47, .y=110 }, .{ .x=48, .y=108 }, .{ .x=49, .y=106 }, .{ .x=50, .y=105 },
    .{ .x=51, .y=103 }, .{ .x=52, .y=101 }, .{ .x=53, .y=99 }, .{ .x=54, .y=97 }, .{ .x=55, .y=95 },
    .{ .x=56, .y=94 }, .{ .x=57, .y=93 }, .{ .x=58, .y=92 }, .{ .x=59, .y=91 }, .{ .x=60, .y=90 },
    .{ .x=61, .y=92 }, .{ .x=62, .y=94 }, .{ .x=63, .y=96 }, .{ .x=64, .y=98 }, .{ .x=65, .y=100 },
    .{ .x=66, .y=102 }, .{ .x=67, .y=104 }, .{ .x=68, .y=106 }, .{ .x=69, .y=108 }, .{ .x=70, .y=110 },
    .{ .x=71, .y=108 }, .{ .x=72, .y=106 }, .{ .x=73, .y=104 }, .{ .x=74, .y=102 }, .{ .x=75, .y=100 },
    .{ .x=76, .y=98 }, .{ .x=77, .y=96 }, .{ .x=78, .y=94 }, .{ .x=79, .y=92 }, .{ .x=80, .y=90 },
    .{ .x=81, .y=91 }, .{ .x=82, .y=93 }, .{ .x=83, .y=95 }, .{ .x=84, .y=97 }, .{ .x=85, .y=99 },
    .{ .x=86, .y=101 }, .{ .x=87, .y=103 }, .{ .x=88, .y=105 }, .{ .x=89, .y=107 }, .{ .x=90, .y=109 },
    .{ .x=91, .y=111 }, .{ .x=92, .y=113 }, .{ .x=93, .y=115 }, .{ .x=94, .y=113 }, .{ .x=95, .y=111 },
    .{ .x=96, .y=109 }, .{ .x=97, .y=107 }, .{ .x=98, .y=105 }, .{ .x=99, .y=103 }, .{ .x=100, .y=101 },
    .{ .x=101, .y=99 }, .{ .x=102, .y=97 }, .{ .x=103, .y=95 }, .{ .x=104, .y=93 }, .{ .x=105, .y=91 },
    .{ .x=106, .y=90 }, .{ .x=107, .y=89 }, .{ .x=108, .y=88 }, .{ .x=109, .y=89 }, .{ .x=110, .y=90 },
    .{ .x=111, .y=92 }, .{ .x=112, .y=94 }, .{ .x=113, .y=96 }, .{ .x=114, .y=98 }, .{ .x=115, .y=100 },
    .{ .x=116, .y=102 }, .{ .x=117, .y=104 }, .{ .x=118, .y=106 }, .{ .x=119, .y=108 }, .{ .x=120, .y=110 },
    .{ .x=121, .y=112 }, .{ .x=122, .y=110 }, .{ .x=123, .y=108 }, .{ .x=124, .y=106 }, .{ .x=125, .y=104 },
    .{ .x=126, .y=102 }, .{ .x=127, .y=100 }, .{ .x=128, .y=98 }, .{ .x=129, .y=96 }, .{ .x=130, .y=94 },
    .{ .x=131, .y=92 }, .{ .x=132, .y=90 }, .{ .x=133, .y=91 }, .{ .x=134, .y=93 }, .{ .x=135, .y=95 },
    .{ .x=136, .y=97 }, .{ .x=137, .y=99 }, .{ .x=138, .y=101 }, .{ .x=139, .y=103 }, .{ .x=140, .y=105 },
    .{ .x=141, .y=107 }, .{ .x=142, .y=109 }, .{ .x=143, .y=111 }, .{ .x=144, .y=113 }, .{ .x=145, .y=115 },
    .{ .x=146, .y=113 }, .{ .x=147, .y=111 }, .{ .x=148, .y=109 }, .{ .x=149, .y=107 }, .{ .x=150, .y=105 },
    .{ .x=151, .y=103 }, .{ .x=152, .y=101 }, .{ .x=153, .y=99 }, .{ .x=154, .y=97 }, .{ .x=155, .y=95 },
    .{ .x=156, .y=93 }, .{ .x=157, .y=91 }, .{ .x=158, .y=90 }, .{ .x=159, .y=89 }, .{ .x=160, .y=88 },
    .{ .x=161, .y=90 }, .{ .x=162, .y=92 }, .{ .x=163, .y=94 }, .{ .x=164, .y=96 }, .{ .x=165, .y=98 },
    .{ .x=166, .y=100 }, .{ .x=167, .y=102 }, .{ .x=168, .y=104 }, .{ .x=169, .y=106 }, .{ .x=170, .y=108 },
    .{ .x=171, .y=110 }, .{ .x=172, .y=112 }, .{ .x=173, .y=114 }, .{ .x=174, .y=112 }, .{ .x=175, .y=110 },
    .{ .x=176, .y=108 }, .{ .x=177, .y=106 }, .{ .x=178, .y=104 }, .{ .x=179, .y=102 }, .{ .x=180, .y=100 },
    .{ .x=181, .y=98 }, .{ .x=182, .y=96 }, .{ .x=183, .y=94 }, .{ .x=184, .y=92 }, .{ .x=185, .y=90 },
    .{ .x=186, .y=91 }, .{ .x=187, .y=93 }, .{ .x=188, .y=95 }, .{ .x=189, .y=97 }, .{ .x=190, .y=99 },
    .{ .x=191, .y=101 }, .{ .x=192, .y=103 }, .{ .x=193, .y=105 }, .{ .x=194, .y=107 }, .{ .x=195, .y=109 },
    .{ .x=196, .y=107 }, .{ .x=197, .y=105 }, .{ .x=198, .y=103 }, .{ .x=199, .y=101 }, .{ .x=200, .y=99 },
};

const db_response_time = [_]Chart.Point{
    .{ .x=1, .y=42 }, .{ .x=2, .y=44 }, .{ .x=3, .y=43 }, .{ .x=4, .y=45 }, .{ .x=5, .y=46 },
    .{ .x=6, .y=48 }, .{ .x=7, .y=47 }, .{ .x=8, .y=45 }, .{ .x=9, .y=43 }, .{ .x=10, .y=41 },
    .{ .x=11, .y=40 }, .{ .x=12, .y=42 }, .{ .x=13, .y=44 }, .{ .x=14, .y=46 }, .{ .x=15, .y=48 },
    .{ .x=16, .y=50 }, .{ .x=17, .y=49 }, .{ .x=18, .y=47 }, .{ .x=19, .y=45 }, .{ .x=20, .y=43 },
    .{ .x=21, .y=41 }, .{ .x=22, .y=39 }, .{ .x=23, .y=38 }, .{ .x=24, .y=40 }, .{ .x=25, .y=42 },
    .{ .x=26, .y=44 }, .{ .x=27, .y=46 }, .{ .x=28, .y=48 }, .{ .x=29, .y=50 }, .{ .x=30, .y=52 },
    .{ .x=31, .y=51 }, .{ .x=32, .y=49 }, .{ .x=33, .y=47 }, .{ .x=34, .y=45 }, .{ .x=35, .y=43 },
    .{ .x=36, .y=41 }, .{ .x=37, .y=39 }, .{ .x=38, .y=37 }, .{ .x=39, .y=36 }, .{ .x=40, .y=38 },
    .{ .x=41, .y=40 }, .{ .x=42, .y=42 }, .{ .x=43, .y=44 }, .{ .x=44, .y=46 }, .{ .x=45, .y=48 },
    .{ .x=46, .y=50 }, .{ .x=47, .y=52 }, .{ .x=48, .y=54 }, .{ .x=49, .y=52 }, .{ .x=50, .y=50 },
    .{ .x=51, .y=48 }, .{ .x=52, .y=46 }, .{ .x=53, .y=44 }, .{ .x=54, .y=42 }, .{ .x=55, .y=40 },
    .{ .x=56, .y=38 }, .{ .x=57, .y=36 }, .{ .x=58, .y=35 }, .{ .x=59, .y=37 }, .{ .x=60, .y=39 },
    .{ .x=61, .y=41 }, .{ .x=62, .y=43 }, .{ .x=63, .y=45 }, .{ .x=64, .y=47 }, .{ .x=65, .y=49 },
    .{ .x=66, .y=51 }, .{ .x=67, .y=53 }, .{ .x=68, .y=55 }, .{ .x=69, .y=53 }, .{ .x=70, .y=51 },
    .{ .x=71, .y=49 }, .{ .x=72, .y=47 }, .{ .x=73, .y=45 }, .{ .x=74, .y=43 }, .{ .x=75, .y=41 },
    .{ .x=76, .y=39 }, .{ .x=77, .y=37 }, .{ .x=78, .y=36 }, .{ .x=79, .y=38 }, .{ .x=80, .y=40 },
    .{ .x=81, .y=42 }, .{ .x=82, .y=44 }, .{ .x=83, .y=46 }, .{ .x=84, .y=48 }, .{ .x=85, .y=50 },
    .{ .x=86, .y=52 }, .{ .x=87, .y=54 }, .{ .x=88, .y=52 }, .{ .x=89, .y=50 }, .{ .x=90, .y=48 },
    .{ .x=91, .y=46 }, .{ .x=92, .y=44 }, .{ .x=93, .y=42 }, .{ .x=94, .y=40 }, .{ .x=95, .y=38 },
    .{ .x=96, .y=36 }, .{ .x=97, .y=35 }, .{ .x=98, .y=37 }, .{ .x=99, .y=39 }, .{ .x=100, .y=41 },
    .{ .x=101, .y=43 }, .{ .x=102, .y=45 }, .{ .x=103, .y=47 }, .{ .x=104, .y=49 }, .{ .x=105, .y=51 },
    .{ .x=106, .y=53 }, .{ .x=107, .y=55 }, .{ .x=108, .y=53 }, .{ .x=109, .y=51 }, .{ .x=110, .y=49 },
    .{ .x=111, .y=47 }, .{ .x=112, .y=45 }, .{ .x=113, .y=43 }, .{ .x=114, .y=41 }, .{ .x=115, .y=39 },
    .{ .x=116, .y=37 }, .{ .x=117, .y=36 }, .{ .x=118, .y=38 }, .{ .x=119, .y=40 }, .{ .x=120, .y=42 },
    .{ .x=121, .y=44 }, .{ .x=122, .y=46 }, .{ .x=123, .y=48 }, .{ .x=124, .y=50 }, .{ .x=125, .y=52 },
    .{ .x=126, .y=54 }, .{ .x=127, .y=52 }, .{ .x=128, .y=50 }, .{ .x=129, .y=48 }, .{ .x=130, .y=46 },
    .{ .x=131, .y=44 }, .{ .x=132, .y=42 }, .{ .x=133, .y=40 }, .{ .x=134, .y=38 }, .{ .x=135, .y=36 },
    .{ .x=136, .y=35 }, .{ .x=137, .y=37 }, .{ .x=138, .y=39 }, .{ .x=139, .y=41 }, .{ .x=140, .y=43 },
    .{ .x=141, .y=45 }, .{ .x=142, .y=47 }, .{ .x=143, .y=49 }, .{ .x=144, .y=51 }, .{ .x=145, .y=53 },
    .{ .x=146, .y=55 }, .{ .x=147, .y=53 }, .{ .x=148, .y=51 }, .{ .x=149, .y=49 }, .{ .x=150, .y=47 },
    .{ .x=151, .y=45 }, .{ .x=152, .y=43 }, .{ .x=153, .y=41 }, .{ .x=154, .y=39 }, .{ .x=155, .y=37 },
    .{ .x=156, .y=36 }, .{ .x=157, .y=38 }, .{ .x=158, .y=40 }, .{ .x=159, .y=42 }, .{ .x=160, .y=44 },
    .{ .x=161, .y=46 }, .{ .x=162, .y=48 }, .{ .x=163, .y=50 }, .{ .x=164, .y=52 }, .{ .x=165, .y=54 },
    .{ .x=166, .y=52 }, .{ .x=167, .y=50 }, .{ .x=168, .y=48 }, .{ .x=169, .y=46 }, .{ .x=170, .y=44 },
    .{ .x=171, .y=42 }, .{ .x=172, .y=40 }, .{ .x=173, .y=38 }, .{ .x=174, .y=36 }, .{ .x=175, .y=35 },
    .{ .x=176, .y=37 }, .{ .x=177, .y=39 }, .{ .x=178, .y=41 }, .{ .x=179, .y=43 }, .{ .x=180, .y=45 },
    .{ .x=181, .y=47 }, .{ .x=182, .y=49 }, .{ .x=183, .y=51 }, .{ .x=184, .y=53 }, .{ .x=185, .y=55 },
    .{ .x=186, .y=53 }, .{ .x=187, .y=51 }, .{ .x=188, .y=49 }, .{ .x=189, .y=47 }, .{ .x=190, .y=45 },
    .{ .x=191, .y=43 }, .{ .x=192, .y=41 }, .{ .x=193, .y=39 }, .{ .x=194, .y=37 }, .{ .x=195, .y=36 },
    .{ .x=196, .y=38 }, .{ .x=197, .y=40 }, .{ .x=198, .y=42 }, .{ .x=199, .y=44 }, .{ .x=200, .y=46 },
};
const cache_response_time = [_]Chart.Point{
    .{ .x=1, .y=35 }, .{ .x=2, .y=36 }, .{ .x=3, .y=35 }, .{ .x=4, .y=37 }, .{ .x=5, .y=36 },
    .{ .x=6, .y=38 }, .{ .x=7, .y=39 }, .{ .x=8, .y=38 }, .{ .x=9, .y=37 }, .{ .x=10, .y=36 },
    .{ .x=11, .y=38 }, .{ .x=12, .y=39 }, .{ .x=13, .y=40 }, .{ .x=14, .y=41 }, .{ .x=15, .y=42 },
    .{ .x=16, .y=41 }, .{ .x=17, .y=40 }, .{ .x=18, .y=39 }, .{ .x=19, .y=38 }, .{ .x=20, .y=37 },
    .{ .x=21, .y=39 }, .{ .x=22, .y=41 }, .{ .x=23, .y=43 }, .{ .x=24, .y=45 }, .{ .x=25, .y=47 },
    .{ .x=26, .y=46 }, .{ .x=27, .y=44 }, .{ .x=28, .y=42 }, .{ .x=29, .y=40 }, .{ .x=30, .y=39 },
    .{ .x=31, .y=41 }, .{ .x=32, .y=43 }, .{ .x=33, .y=45 }, .{ .x=34, .y=47 }, .{ .x=35, .y=49 },
    .{ .x=36, .y=48 }, .{ .x=37, .y=46 }, .{ .x=38, .y=44 }, .{ .x=39, .y=42 }, .{ .x=40, .y=41 },
    .{ .x=41, .y=43 }, .{ .x=42, .y=45 }, .{ .x=43, .y=47 }, .{ .x=44, .y=49 }, .{ .x=45, .y=51 },
    .{ .x=46, .y=50 }, .{ .x=47, .y=48 }, .{ .x=48, .y=46 }, .{ .x=49, .y=44 }, .{ .x=50, .y=42 },
    .{ .x=51, .y=40 }, .{ .x=52, .y=38 }, .{ .x=53, .y=36 }, .{ .x=54, .y=35 }, .{ .x=55, .y=37 },
    .{ .x=56, .y=39 }, .{ .x=57, .y=41 }, .{ .x=58, .y=43 }, .{ .x=59, .y=45 }, .{ .x=60, .y=47 },
    .{ .x=61, .y=49 }, .{ .x=62, .y=51 }, .{ .x=63, .y=50 }, .{ .x=64, .y=48 }, .{ .x=65, .y=46 },
    .{ .x=66, .y=44 }, .{ .x=67, .y=42 }, .{ .x=68, .y=40 }, .{ .x=69, .y=38 }, .{ .x=70, .y=36 },
    .{ .x=71, .y=35 }, .{ .x=72, .y=37 }, .{ .x=73, .y=39 }, .{ .x=74, .y=41 }, .{ .x=75, .y=43 },
    .{ .x=76, .y=45 }, .{ .x=77, .y=47 }, .{ .x=78, .y=49 }, .{ .x=79, .y=51 }, .{ .x=80, .y=53 },
    .{ .x=81, .y=52 }, .{ .x=82, .y=50 }, .{ .x=83, .y=48 }, .{ .x=84, .y=46 }, .{ .x=85, .y=44 },
    .{ .x=86, .y=42 }, .{ .x=87, .y=40 }, .{ .x=88, .y=38 }, .{ .x=89, .y=36 }, .{ .x=90, .y=35 },
    .{ .x=91, .y=37 }, .{ .x=92, .y=39 }, .{ .x=93, .y=41 }, .{ .x=94, .y=43 }, .{ .x=95, .y=45 },
    .{ .x=96, .y=47 }, .{ .x=97, .y=49 }, .{ .x=98, .y=51 }, .{ .x=99, .y=53 }, .{ .x=100, .y=55 },
    .{ .x=101, .y=53 }, .{ .x=102, .y=51 }, .{ .x=103, .y=49 }, .{ .x=104, .y=47 }, .{ .x=105, .y=45 },
    .{ .x=106, .y=43 }, .{ .x=107, .y=41 }, .{ .x=108, .y=39 }, .{ .x=109, .y=37 }, .{ .x=110, .y=35 },
    .{ .x=111, .y=36 }, .{ .x=112, .y=38 }, .{ .x=113, .y=40 }, .{ .x=114, .y=42 }, .{ .x=115, .y=44 },
    .{ .x=116, .y=46 }, .{ .x=117, .y=48 }, .{ .x=118, .y=50 }, .{ .x=119, .y=52 }, .{ .x=120, .y=54 },
    .{ .x=121, .y=52 }, .{ .x=122, .y=50 }, .{ .x=123, .y=48 }, .{ .x=124, .y=46 }, .{ .x=125, .y=44 },
    .{ .x=126, .y=42 }, .{ .x=127, .y=40 }, .{ .x=128, .y=38 }, .{ .x=129, .y=36 }, .{ .x=130, .y=35 },
    .{ .x=131, .y=37 }, .{ .x=132, .y=39 }, .{ .x=133, .y=41 }, .{ .x=134, .y=43 }, .{ .x=135, .y=45 },
    .{ .x=136, .y=47 }, .{ .x=137, .y=49 }, .{ .x=138, .y=51 }, .{ .x=139, .y=53 }, .{ .x=140, .y=55 },
    .{ .x=141, .y=53 }, .{ .x=142, .y=51 }, .{ .x=143, .y=49 }, .{ .x=144, .y=47 }, .{ .x=145, .y=45 },
    .{ .x=146, .y=43 }, .{ .x=147, .y=41 }, .{ .x=148, .y=39 }, .{ .x=149, .y=37 }, .{ .x=150, .y=35 },
    .{ .x=151, .y=36 }, .{ .x=152, .y=38 }, .{ .x=153, .y=40 }, .{ .x=154, .y=42 }, .{ .x=155, .y=44 },
    .{ .x=156, .y=46 }, .{ .x=157, .y=48 }, .{ .x=158, .y=50 }, .{ .x=159, .y=52 }, .{ .x=160, .y=54 },
    .{ .x=161, .y=52 }, .{ .x=162, .y=50 }, .{ .x=163, .y=48 }, .{ .x=164, .y=46 }, .{ .x=165, .y=44 },
    .{ .x=166, .y=42 }, .{ .x=167, .y=40 }, .{ .x=168, .y=38 }, .{ .x=169, .y=36 }, .{ .x=170, .y=35 },
    .{ .x=171, .y=37 }, .{ .x=172, .y=39 }, .{ .x=173, .y=41 }, .{ .x=174, .y=43 }, .{ .x=175, .y=45 },
    .{ .x=176, .y=47 }, .{ .x=177, .y=49 }, .{ .x=178, .y=51 }, .{ .x=179, .y=53 }, .{ .x=180, .y=55 },
    .{ .x=181, .y=53 }, .{ .x=182, .y=51 }, .{ .x=183, .y=49 }, .{ .x=184, .y=47 }, .{ .x=185, .y=45 },
    .{ .x=186, .y=43 }, .{ .x=187, .y=41 }, .{ .x=188, .y=39 }, .{ .x=189, .y=37 }, .{ .x=190, .y=35 },
    .{ .x=191, .y=36 }, .{ .x=192, .y=38 }, .{ .x=193, .y=40 }, .{ .x=194, .y=42 }, .{ .x=195, .y=44 },
    .{ .x=196, .y=46 }, .{ .x=197, .y=48 }, .{ .x=198, .y=50 }, .{ .x=199, .y=48 }, .{ .x=200, .y=46 },
};
const worker_response_time = [_]Chart.Point{
    .{ .x=1, .y=65 }, .{ .x=2, .y=67 }, .{ .x=3, .y=69 }, .{ .x=4, .y=71 }, .{ .x=5, .y=73 },
    .{ .x=6, .y=75 }, .{ .x=7, .y=74 }, .{ .x=8, .y=72 }, .{ .x=9, .y=70 }, .{ .x=10, .y=68 },
    .{ .x=11, .y=66 }, .{ .x=12, .y=64 }, .{ .x=13, .y=62 }, .{ .x=14, .y=60 }, .{ .x=15, .y=62 },
    .{ .x=16, .y=64 }, .{ .x=17, .y=66 }, .{ .x=18, .y=68 }, .{ .x=19, .y=70 }, .{ .x=20, .y=72 },
    .{ .x=21, .y=74 }, .{ .x=22, .y=76 }, .{ .x=23, .y=78 }, .{ .x=24, .y=80 }, .{ .x=25, .y=82 },
    .{ .x=26, .y=80 }, .{ .x=27, .y=78 }, .{ .x=28, .y=76 }, .{ .x=29, .y=74 }, .{ .x=30, .y=72 },
    .{ .x=31, .y=70 }, .{ .x=32, .y=68 }, .{ .x=33, .y=66 }, .{ .x=34, .y=64 }, .{ .x=35, .y=62 },
    .{ .x=36, .y=60 }, .{ .x=37, .y=62 }, .{ .x=38, .y=64 }, .{ .x=39, .y=66 }, .{ .x=40, .y=68 },
    .{ .x=41, .y=70 }, .{ .x=42, .y=72 }, .{ .x=43, .y=74 }, .{ .x=44, .y=76 }, .{ .x=45, .y=78 },
    .{ .x=46, .y=80 }, .{ .x=47, .y=82 }, .{ .x=48, .y=84 }, .{ .x=49, .y=82 }, .{ .x=50, .y=80 },
    .{ .x=51, .y=78 }, .{ .x=52, .y=76 }, .{ .x=53, .y=74 }, .{ .x=54, .y=72 }, .{ .x=55, .y=70 },
    .{ .x=56, .y=68 }, .{ .x=57, .y=66 }, .{ .x=58, .y=64 }, .{ .x=59, .y=62 }, .{ .x=60, .y=60 },
    .{ .x=61, .y=62 }, .{ .x=62, .y=64 }, .{ .x=63, .y=66 }, .{ .x=64, .y=68 }, .{ .x=65, .y=70 },
    .{ .x=66, .y=72 }, .{ .x=67, .y=74 }, .{ .x=68, .y=76 }, .{ .x=69, .y=78 }, .{ .x=70, .y=80 },
    .{ .x=71, .y=82 }, .{ .x=72, .y=84 }, .{ .x=73, .y=85 }, .{ .x=74, .y=83 }, .{ .x=75, .y=81 },
    .{ .x=76, .y=79 }, .{ .x=77, .y=77 }, .{ .x=78, .y=75 }, .{ .x=79, .y=73 }, .{ .x=80, .y=71 },
    .{ .x=81, .y=69 }, .{ .x=82, .y=67 }, .{ .x=83, .y=65 }, .{ .x=84, .y=63 }, .{ .x=85, .y=61 },
    .{ .x=86, .y=60 }, .{ .x=87, .y=62 }, .{ .x=88, .y=64 }, .{ .x=89, .y=66 }, .{ .x=90, .y=68 },
    .{ .x=91, .y=70 }, .{ .x=92, .y=72 }, .{ .x=93, .y=74 }, .{ .x=94, .y=76 }, .{ .x=95, .y=78 },
    .{ .x=96, .y=80 }, .{ .x=97, .y=82 }, .{ .x=98, .y=84 }, .{ .x=99, .y=85 }, .{ .x=100, .y=83 },
    .{ .x=101, .y=81 }, .{ .x=102, .y=79 }, .{ .x=103, .y=77 }, .{ .x=104, .y=75 }, .{ .x=105, .y=73 },
    .{ .x=106, .y=71 }, .{ .x=107, .y=69 }, .{ .x=108, .y=67 }, .{ .x=109, .y=65 }, .{ .x=110, .y=63 },
    .{ .x=111, .y=61 }, .{ .x=112, .y=60 }, .{ .x=113, .y=62 }, .{ .x=114, .y=64 }, .{ .x=115, .y=66 },
    .{ .x=116, .y=68 }, .{ .x=117, .y=70 }, .{ .x=118, .y=72 }, .{ .x=119, .y=74 }, .{ .x=120, .y=76 },
    .{ .x=121, .y=78 }, .{ .x=122, .y=80 }, .{ .x=123, .y=82 }, .{ .x=124, .y=84 }, .{ .x=125, .y=85 },
    .{ .x=126, .y=83 }, .{ .x=127, .y=81 }, .{ .x=128, .y=79 }, .{ .x=129, .y=77 }, .{ .x=130, .y=75 },
    .{ .x=131, .y=73 }, .{ .x=132, .y=71 }, .{ .x=133, .y=69 }, .{ .x=134, .y=67 }, .{ .x=135, .y=65 },
    .{ .x=136, .y=63 }, .{ .x=137, .y=61 }, .{ .x=138, .y=60 }, .{ .x=139, .y=62 }, .{ .x=140, .y=64 },
    .{ .x=141, .y=66 }, .{ .x=142, .y=68 }, .{ .x=143, .y=70 }, .{ .x=144, .y=72 }, .{ .x=145, .y=74 },
    .{ .x=146, .y=76 }, .{ .x=147, .y=78 }, .{ .x=148, .y=80 }, .{ .x=149, .y=82 }, .{ .x=150, .y=84 },
    .{ .x=151, .y=85 }, .{ .x=152, .y=83 }, .{ .x=153, .y=81 }, .{ .x=154, .y=79 }, .{ .x=155, .y=77 },
    .{ .x=156, .y=75 }, .{ .x=157, .y=73 }, .{ .x=158, .y=71 }, .{ .x=159, .y=69 }, .{ .x=160, .y=67 },
    .{ .x=161, .y=65 }, .{ .x=162, .y=63 }, .{ .x=163, .y=61 }, .{ .x=164, .y=60 }, .{ .x=165, .y=62 },
    .{ .x=166, .y=64 }, .{ .x=167, .y=66 }, .{ .x=168, .y=68 }, .{ .x=169, .y=70 }, .{ .x=170, .y=72 },
    .{ .x=171, .y=74 }, .{ .x=172, .y=76 }, .{ .x=173, .y=78 }, .{ .x=174, .y=80 }, .{ .x=175, .y=82 },
    .{ .x=176, .y=84 }, .{ .x=177, .y=85 }, .{ .x=178, .y=83 }, .{ .x=179, .y=81 }, .{ .x=180, .y=79 },
    .{ .x=181, .y=77 }, .{ .x=182, .y=75 }, .{ .x=183, .y=73 }, .{ .x=184, .y=71 }, .{ .x=185, .y=69 },
    .{ .x=186, .y=67 }, .{ .x=187, .y=65 }, .{ .x=188, .y=63 }, .{ .x=189, .y=61 }, .{ .x=190, .y=60 },
    .{ .x=191, .y=62 }, .{ .x=192, .y=64 }, .{ .x=193, .y=66 }, .{ .x=194, .y=68 }, .{ .x=195, .y=70 },
    .{ .x=196, .y=72 }, .{ .x=197, .y=74 }, .{ .x=198, .y=76 }, .{ .x=199, .y=74 }, .{ .x=200, .y=72 },
};

// zig fmt: on

const Route = struct {
    id: []const u8,
    url: []const u8,
    total: f32,
};

const routes_columns = [_]Column(Route){
    Column(Route){
        .title = "ID",
        .key = "id",
        .width = 20,
    },
    Column(Route){
        .title = "URL",
        .key = "url",
    },
    Column(Route){
        .title = "Total",
        .key = "total",
        .render = renderTotal,
    },
};

fn renderTotal(route: *Route) void {
    TextFmt("{d}K", .{route.total})
        .end();
}

const RoutesTable = Table(Route, &routes_columns, .{
    // .actions = &[_]Action(Route){
    //     .{ .label = "View", .on_action = handleViewException, .icon = .eye },
    //     .{ .label = "Report", .on_action = handleRefundException, .icon = .arrow_counterclockwise },
    //     .{ .label = "Delete", .on_action = handleDeleteException, .icon = .trash },
    // },
});

var routes_table: RoutesTable = undefined;

var routes = [_]Route{
    .{ .id = "5a58cf5b-3c1f-492c-9eb9-a21909f466fe", .url = "/docs/vapor", .total = 1.1 },
    .{ .id = "dfc3eeba-77bd-4428-98fb-1b102b51c3a2", .url = "/senet/products/{uuid}", .total = 1.4 },
    .{ .id = "48afd232-a053-45d5-908d-6f64548c8608", .url = "/ui/components", .total = 1.2 },
    .{ .id = "2a7d203b-530d-4ab8-b08a-a6c81e5e73bc", .url = "/kyber", .total = 3.2 },
    .{ .id = "c686f2c9-c878-46e2-93e2-2bad28ff18cc", .url = "https://github.com/vic-augustrokx-nellemann/tether-website", .total = 9.2 },
    .{ .id = "273da50d-ae9c-45b9-b15e-d05869366676", .url = "https://github.com/vic-augustrokx-nellemann/tether-website", .total = 2.2 },
    .{ .id = "64264523-77dc-4d90-bc10-16a341a4c903", .url = "https://github.com/vic-augustrokx-nellemann/tether-website", .total = 1.2 },
    .{ .id = "05607b6f-937b-4d30-a901-400d99647589", .url = "https://github.com/vic-augustrokx-nellemann/tether-website", .total = 1.2 },
    .{ .id = "5d2b6812-902f-424b-8523-cbbb1b953268", .url = "https://github.com/vic-augustrokx-nellemann/tether-website", .total = 1.2 },
    .{ .id = "b3ab0c88-7f37-4b4d-8796-e889f1a3d15a", .url = "https://github.com/vic-augustrokx-nellemann/tether-website", .total = 1.2 },
};

pub fn init() void {
    const chart_color: Vapor.Types.Color = .transparentize(.palette(.tint), 0.5);
    const shadow_color: Vapor.Types.Color = .transparentize(.palette(.tint), 0.3);
    const hovered_color: Vapor.Types.Color = .hex("#222160");

    const series_options = Chart.SeriesOptions{
        .color = chart_color,
        .show_shadow = true,
        .shadow_color = shadow_color,
        .hovered_color = hovered_color,
    };

    rest_chart = .init(Vapor.arena(.persist), .{
        .height = 220,
        .width = 280,
        .margin = .{ .top = 20, .bottom = 0, .left = 0, .right = 0 }, // Defaults
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });
    rest_chart.addSeries(.bar, "REST", &rest_requests, series_options) catch unreachable;
    rest_chart.build() catch unreachable;

    auth_chart = .init(Vapor.arena(.persist), .{
        .height = 220,
        .width = 280,
        .margin = .{ .top = 20, .bottom = 0, .left = 0, .right = 0 }, // Defaults
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });
    auth_chart.addSeries(.bar, "Auth", &auth_requests, series_options) catch unreachable;
    auth_chart.build() catch unreachable;

    storage_chart = .init(Vapor.arena(.persist), .{
        .height = 220,
        .width = 280,
        .margin = .{ .top = 20, .bottom = 0, .left = 0, .right = 0 }, // Defaults
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });
    storage_chart.addSeries(.bar, "Storage", &storage_requests, series_options) catch unreachable;
    storage_chart.build() catch unreachable;

    error_chart = .init(Vapor.arena(.persist), .{
        .height = 220,
        .width = 280,
        .margin = .{ .top = 20, .bottom = 0, .left = 0, .right = 0 }, // Defaults
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });
    error_chart.addSeries(.bar, "Error", &error_requests, series_options) catch unreachable;
    error_chart.build() catch unreachable;

    http_chart = .init(Vapor.arena(.persist), .{
        .height = 320,
        .width = 720,
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });
    http_chart.addSeries(.stacked_bar, "GET", &http_requests, .{
        .color = get_color,
        .bar_radius = 0,
    }) catch unreachable;
    http_chart.xAxis(.{ .label = "Time", .tick_count = 4 });
    http_chart.yAxis(.{ .label = "Requests", .tick_count = 5 });

    http_chart.legend(.{
        .position = .top_right,
        .direction = .row,
        .text_color = .palette(.text_color),
        .fields = &.{
            // .{ .title = "1/2/3XX", .color = gray, .background = gray },
            // .{ .title = "GET", .color = get_color, .background = get_color },
            .{ .title = "POST", .color = post_color, .background = post_color },
            .{ .title = "PATCH", .color = patch_color, .background = patch_color },
        },
    });

    http_chart.build() catch unreachable;

    response_times_chart = .init(Vapor.arena(.persist), .{
        .height = 320,
        .width = 600,
        .palette = .{ .colors = &.{ "#6366f1", "#10b981", "#f59e0b" } },
    });
    response_times_chart.addSeries(.line, "GET", &api_response_time, .{
        .color = api_color,
        .bar_radius = 0,
        .show_dots = false,
        .stroke_width = 1,
    }) catch unreachable;

    response_times_chart.addSeries(.line, "POST", &auth_response_time, .{
        .color = auth_color,
        .bar_radius = 0,
        .show_dots = false,
        .stroke_width = 1,
    }) catch unreachable;

    response_times_chart.addSeries(.line, "PATCH", &db_response_time, .{
        .color = db_color,
        .bar_radius = 0,
        .show_dots = false,
        .stroke_width = 1,
    }) catch unreachable;

    response_times_chart.addSeries(.line, "CACHE", &cache_response_time, .{
        .color = cache_color,
        .bar_radius = 0,
        .show_dots = false,
        .stroke_width = 1,
    }) catch unreachable;

    response_times_chart.addSeries(.line, "WORKER", &worker_response_time, .{
        .color = worker_color,
        .bar_radius = 0,
        .show_dots = false,
        .stroke_width = 1,
    }) catch unreachable;

    response_times_chart.xAxis(.{ .tick_count = 12, .show_axis_line = false });
    response_times_chart.yAxis(.{ .tick_count = 5, .show_axis_line = false });
    response_times_chart.build() catch unreachable;

    routes_table.init(&routes);
}

// Import UI Components

fn Panel(title: []const u8, description: []const u8, chart: *Chart, icon: *const Vapor.IconTokens) void {
    Stack()
        .hw(.grow, .grow)
        .padding(.all(16))
        .radius(.all(12))
        .spacing(12)
        .background(.hex("#fbfbfc"))
        .border(.simple(.palette(.border_color_light)))
        // .newShadow(Vapor.Types.NewShadow.init()
        //     .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.1)))
        .children({
        Box()
            .layout(.left_center)
            .spacing(8)
            .children({
            Icon(icon)
                .height(.px(32))
                .width(.px(32))
                .layout(.center)
                .background(.hex("#1C1917"))
                .font(14, 300, .white)
                .end();
            Text(title)
                .font(14, 300, Theme.text)
                .end();
        });
        Text(description)
            .fontFamily("IBM Plex Mono,monospace")
            .font(22, 100, Theme.text)
            .end();
        Stack()
            .width(.percent(100))
            .layout(.center)
            .children({
            chart.render();
            const date = Vapor.DateTime.now().format(Vapor.arena(.frame)) catch "";
            Box()
                .width(.percent(100))
                .layout(.x_even_center)
                .children({
                Vapor.Code(date)
                    .font(14, 300, Theme.text_muted).end();
                // Vapor.Code(date)
                //     .font(14, 300, Theme.warning).end();
            });
        });
    });
}

fn Trigger(_: *Tabs, name: []const u8, is_active: bool) void {
    TextFmt("{{{s}}}", .{Vapor.utils.toLowerCase(name, .frame)})
        .pointer()
        .fontFamily("IBM Plex Sans,monospace")
        .font(16, 300, if (is_active) Theme.text else Theme.text_secondary)
        .end();
}

fn Issues() void {
    Stack()
        .width(.grow)
        .height(.px(256))
        .layout(.top_left)
        .spacing(16)
        .children({
        Vapor.Html("ISSUES that need <code style=\"color: rgba(var(--danger))\">attention</code>")
            .font(16, 300, Theme.text)
            .end();
        Stack()
            .width(.percent(100))
            .height(.percent(100))
            .layout(.top_left)
            .padding(.all(8))
            .spacing(16)
            .children({
            const index = Tabs.create("issues", &.{ "Errors", "Warnings", "Info" })
                .Trigger(Trigger);
            switch (index) {
                0 => {
                    Box()
                        .pos(.relative) // parent wrapper
                        .width(.percent(100))
                        .height(.px(256))
                        .children({
                        // Scrolling content
                        Stack()
                            .width(.percent(100))
                            .height(.percent(100))
                            .layout(.top_left)
                            .padding(.horizontal(8))
                            .spacing(4)
                            .scroll(.scroll_y())
                            .children({
                            for (0..16) |_| {
                                Box()
                                    .width(.percent(100))
                                    .padding(.xy(12, 10))
                                    .border(.round(.palette(.border_color_light), .all(8)))
                                    .hover(.{ .transform = .scaleDecimal(1.01) })
                                    .layout(.x_between_center)
                                    // .newShadow(Vapor.Types.NewShadow.init()
                                    //     .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.05)))
                                    .children({
                                    Box()
                                        .direction(.column)
                                        .spacing(4)
                                        .children({
                                        Vapor.Code("GET|HEAD")
                                            .font(14, 600, .palette(.tint)).end();
                                        Vapor.Code("/api/v1/{users}").font(14, 300, Theme.text_muted).end();
                                    });
                                });
                            }
                        });
                        // Gradient overlay - sibling to scroll, not child
                        Box()
                            .pos(.bl(.px(0), .px(0), .absolute)) // bottom-left
                            .width(.percent(100))
                            .height(.px(72)) // just the fade height, not 100%
                            .layer(.gradient(.linear, .to_bottom, &.{ .transparent, .palette(.background) }))
                            .inlineStyle("pointer-events: none;", .{})
                            .children({});
                    });
                },
                1 => {
                    Box()
                        .pos(.relative) // parent wrapper
                        .width(.percent(100))
                        .height(.px(256))
                        .children({
                        // Scrolling content
                        Stack()
                            .width(.percent(100))
                            .height(.percent(100))
                            .layout(.top_left)
                            .padding(.horizontal(8))
                            .spacing(4)
                            .scroll(.scroll_y())
                            .children({
                            for (0..16) |_| {
                                Box()
                                    .width(.percent(100))
                                    .padding(.xy(12, 10))
                                    .border(.round(.palette(.border_color_light), .all(8)))
                                    .hover(.{ .transform = .scaleDecimal(1.01) })
                                    .layout(.x_between_center)
                                    // .newShadow(Vapor.Types.NewShadow.init()
                                    //     .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.05)))
                                    .children({
                                    Box()
                                        .direction(.column)
                                        .spacing(4)
                                        .children({
                                        Vapor.Code("GET|HEAD")
                                            .font(14, 600, .palette(.tint)).end();
                                        Vapor.Code("/api/v1/{users}").font(14, 300, Theme.text_muted).end();
                                    });
                                });
                            }
                        });
                        // Gradient overlay - sibling to scroll, not child
                        Box()
                            .pos(.bl(.px(0), .px(0), .absolute)) // bottom-left
                            .width(.percent(100))
                            .height(.px(72)) // just the fade height, not 100%
                            .layer(.gradient(.linear, .to_bottom, &.{ .transparent, .palette(.background) }))
                            .inlineStyle("pointer-events: none;", .{})
                            .children({});
                    });
                },

                else => unreachable,
            }
        });
    });
}

fn SlowQueries() void {
    Stack()
        .width(.grow)
        .height(.px(256))
        .layout(.top_left)
        .spacing(16)
        .children({
        Text("Slow Queries")
            .font(16, 300, Theme.text)
            .end();
        Stack()
            .background(.transparentize(.palette(.border_color_light), 0.1))
            .border(.round(.palette(.border_color_light), .all(12)))
            .width(.percent(100))
            .height(.percent(100))
            .layout(.top_left)
            .spacing(16)
            .children({
            Stack()
                .width(.percent(100))
                .height(.percent(100))
                .layout(.top_left)
                .spacing(4)
                .scroll(.scroll_y())
                .children({
                for (0..16) |_| {
                    Box()
                        .width(.percent(100))
                        .padding(.xy(12, 10))
                        .border(.bottom(1, .palette(.border_color_light)))
                        .hover(.{ .transform = .scaleDecimal(1.01) })
                        .layout(.left_center)
                        .spacing(12)
                        // .newShadow(Vapor.Types.NewShadow.init()
                        //     .drop(0, 4, 6, .transparentizeHex(.palette(.text_color), 0.05)))
                        .children({
                        Icon(.columns)
                            .font(14, 100, .palette(.text_color))
                            .end();
                        Text("insert into public.children (child_id,first_name,date_of_birth,sex,birth_weight,birth_length,number_of_older_siblings,name_of_other_parent,hub_id,date_of_registry,mom_id,code) select child_id,first_name,date_of_birth,sex,birth_weight,birth_length,number_of_older_siblings,name_of_other_parent,hub_id,date_of_registry,mom_id,code from jsonb_populate_recordset($1::public.children, $2)")
                            .ellipsis(.dot)
                            .font(14, 100, .palette(.text_color)).end();
                    });
                }
            });
        });
    });
}

fn Count() void {
    const Token = struct {
        pub fn render(title: []const u8, comptime fmt: []const u8, args: anytype) void {
            Stack()
                .layout(.left_center)
                .children({
                Stack()
                    .pos(.relative)
                    .children({
                    Stack()
                        .inlineStyle("-webkit-text-stroke: 2px black;", .{})
                        .spacing(4)
                        .layout(.left_center)
                        .children({
                        TextFmt(fmt, args)
                            .fontFamily("Montserrat")
                            .font(76, 600, Theme.text).end();
                    });

                    Stack()
                        .pos(.tl(.px(0), .px(0), .absolute))
                        .spacing(4)
                        .layout(.left_center)
                        .children({
                        TextFmt(fmt, args)
                            .fontFamily("Montserrat")
                            .font(76, 600, Theme.bg_base.color).end();
                    });
                });
                Text(title)
                    .fontFamily("Montserrat")
                    .font(18, 300, Theme.text).end();
            });
        }
    }.render;

    Box()
        .width(.percent(100))
        .padding(.all(16))
        .border(.tb(.palette(.border_color_light)))
        .layer(.dot(0.5, 4, .hex("#d8d8dc")))
        .layout(.x_even_center)
        .spacing(16)
        .children({
        Token("Total Users", "{d}", .{13129});
        Token("Active Users", "{d}", .{13129});
        Token("Websocket Conns", "{d}", .{3459});
        Token("Unresolved Errors", "{d}", .{131});
    });
}
pub fn render() void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(28))
        .spacing(64)
        // .layer(.dot(0.5, 14, .palette(.grid_color)))
        // .scroll(.scroll_y())
        .children({
        Box()
            .width(.percent(100))
            .layout(.top_left)
            .direction(.column)
            .spacing(20)
            .children({
            // Main chart
            Box()
                .width(.percent(100))
                // .height(.percent(100))
                .padding(.all(16))
                .direction(.row)
                .layout(.x_between)
                // .border(.round(.palette(.border_color_light), .all(12)))
                .background(Theme.bg_base)
                .spacing(8)
                .children({
                const databse_description = Vapor.fmtln("{d}", .{2093});
                Panel("Database", databse_description, &rest_chart, .database);

                const auth_description = Vapor.fmtln("{d}", .{343});
                Panel("Auth", auth_description, &auth_chart, .lock);

                const storage_description = Vapor.fmtln("{d}", .{3300});
                Panel("Storage", storage_description, &storage_chart, .database);

                const error_description = Vapor.fmtln("{d}", .{132});
                Panel("Error", error_description, &error_chart, .bug);
            });
        });

        Count();

        Box()
            .width(.percent(100))
            .height(.percent(40))
            .padding(.all(16))
            .direction(.column)
            // .layout(.x_between)
            .border(.round(.palette(.border_color_light), .all(12)))
            .spacing(8)
            .children({
            Box()
                .width(.percent(100))
                .height(.percent(100))
                .layout(.x_even_center)
                .children({
                Stack()
                    .layout(.left_center)
                    .spacing(2)
                    .children({
                    Text("HTTP Traffic by Method")
                        .font(16, 300, Theme.text)
                        .end();
                    http_chart.render();
                });
                Stack()
                    .layout(.left_center)
                    .spacing(2)
                    .children({
                    Text("RESPONSE Times by Method")
                        .font(16, 300, Theme.text)
                        .end();
                    response_times_chart.render();
                });
            });
        });
        Box()
            .width(.percent(100))
            .height(.px(512))
            .layout(.center)
            .spacing(32)
            .children({
            Issues();
            SlowQueries();
        });
        Vapor.Spacer(64).end();

        Stack()
            .width(.percent(100))
            .layout(.top_left)
            .spacing(16)
            .border(.round(.palette(.border_color_light), .all(12)))
            .children({
            Stack()
                .background(.transparentize(.palette(.border_color_light), 0.3))
                .width(.percent(100))
                .padding(.all(8))
                .border(.bottom(1, .palette(.border_color_light)))
                .radius(.toplr(10, 10))
                .children({
                Text("Top Routes Hit")
                    .font(16, 300, Theme.text)
                    .end();
            });
            // routes_table.render();
        });
    });
}
