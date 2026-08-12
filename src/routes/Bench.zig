const std = @import("std");
const Vapor = @import("vapor");

const Row = Vapor.Row;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.CtxButton;

// --- DATA MODEL ---
const Row = struct {
    id: u32,
    label: []const u8,
    selected: bool = false,
};

// --- STATE ---
var rows: Vapor.Array(Row) = undefined;
var next_id: u32 = 0;
var selected_id: ?u32 = null;

// Timing
var last_action: []const u8 = "None";
var last_time_ms: f64 = 0;

// --- INIT ---
pub fn init() void {
    Vapor.Page(.{ .route = "/bench" }, Benchmark, null);
    rows = Vapor.array(Row, .persist);
}

// --- HELPERS ---
const adjectives = [_][]const u8{
    "pretty",      "large",   "big",       "small", "tall",      "short",    "long",
    "handsome",    "plain",   "quaint",    "clean", "elegant",   "easy",     "angry",
    "crazy",       "helpful", "mushy",     "odd",   "unsightly", "adorable", "important",
    "inexpensive", "cheap",   "expensive", "fancy",
};

const colors = [_][]const u8{
    "red",   "yellow", "blue",  "green",  "pink", "brown", "purple",
    "brown", "white",  "black", "orange",
};

const nouns = [_][]const u8{
    "table",  "chair",    "house",  "bbq",   "desk",  "car",      "pony",
    "cookie", "sandwich", "burger", "pizza", "mouse", "keyboard",
};

fn randomLabel(rng: *std.Random.DefaultPrng) []const u8 {
    const adj = adjectives[rng.random().intRangeAtMost(usize, 0, adjectives.len - 1)];
    const color = colors[rng.random().intRangeAtMost(usize, 0, colors.len - 1)];
    const noun = nouns[rng.random().intRangeAtMost(usize, 0, nouns.len - 1)];

    return Vapor.arena(.scratch).alloc(u8, adj.len + color.len + noun.len + 2) catch unreachable;
}

fn buildData(count: u32) void {
    var rng = std.Random.DefaultPrng.init(@intCast(std.time.milliTimestamp()));

    rows.clearRetainingCapacity();
    rows.ensureTotalCapacity(count) catch return;

    var i: u32 = 0;
    while (i < count) : (i += 1) {
        const adj = adjectives[rng.random().intRangeAtMost(usize, 0, adjectives.len - 1)];
        const color = colors[rng.random().intRangeAtMost(usize, 0, colors.len - 1)];
        const noun = nouns[rng.random().intRangeAtMost(usize, 0, nouns.len - 1)];

        const label = Vapor.fmtln("{s} {s} {s}", .{ adj, color, noun });

        rows.appendAssumeCapacity(.{
            .id = next_id,
            .label = label,
            .selected = false,
        });
        next_id += 1;
    }
}

// --- ACTIONS ---
fn timed(comptime name: []const u8, action: fn () void) fn () void {
    return struct {
        fn wrapper() void {
            const start = std.time.milliTimestamp();
            action();
            const end = std.time.milliTimestamp();
            last_action = name;
            last_time_ms = @floatFromInt(end - start);
        }
    }.wrapper;
}

fn create1k() void {
    const start = std.time.milliTimestamp();
    buildData(1000);
    const end = std.time.milliTimestamp();
    last_action = "Create 1,000 rows";
    last_time_ms = @floatFromInt(end - start);
}

fn create10k() void {
    const start = std.time.milliTimestamp();
    buildData(10000);
    const end = std.time.milliTimestamp();
    last_action = "Create 10,000 rows";
    last_time_ms = @floatFromInt(end - start);
}

fn append1k() void {
    const start = std.time.milliTimestamp();
    var rng = std.Random.DefaultPrng.init(@intCast(std.time.milliTimestamp()));

    var i: u32 = 0;
    while (i < 1000) : (i += 1) {
        const adj = adjectives[rng.random().intRangeAtMost(usize, 0, adjectives.len - 1)];
        const color = colors[rng.random().intRangeAtMost(usize, 0, colors.len - 1)];
        const noun = nouns[rng.random().intRangeAtMost(usize, 0, nouns.len - 1)];

        const label = Vapor.fmtln("{s} {s} {s}", .{ adj, color, noun });

        rows.append(.{
            .id = next_id,
            .label = label,
            .selected = false,
        }) catch return;
        next_id += 1;
    }

    const end = std.time.milliTimestamp();
    last_action = "Append 1,000 rows";
    last_time_ms = @floatFromInt(end - start);
}

fn updateEvery10th() void {
    const start = std.time.milliTimestamp();

    var i: usize = 0;
    while (i < rows.items.len) : (i += 10) {
        const old_label = rows.items[i].label;
        rows.items[i].label = Vapor.fmtln("{s} !!!", .{old_label});
    }

    const end = std.time.milliTimestamp();
    last_action = "Update every 10th row";
    last_time_ms = @floatFromInt(end - start);
}

fn clearRows() void {
    const start = std.time.milliTimestamp();
    rows.clearRetainingCapacity();
    selected_id = null;
    const end = std.time.milliTimestamp();
    last_action = "Clear";
    last_time_ms = @floatFromInt(end - start);
}

var counter: usize = 0;
fn swapRows() void {
    const start = std.time.milliTimestamp();

    if (rows.items.len > 998) {
        const tmp = rows.items[1];
        rows.items[1] = rows.items[998];
        rows.items[998] = tmp;
    }

    const end = std.time.milliTimestamp();
    last_action = "Swap rows";
    last_time_ms = @floatFromInt(end - start);
    counter += 1;
}

fn selectRow(id: u32) void {
    const start = std.time.milliTimestamp();

    for (rows.items) |*row| {
        row.selected = (row.id == id);
    }
    selected_id = id;

    const end = std.time.milliTimestamp();
    last_action = "Select row";
    last_time_ms = @floatFromInt(end - start);
}

fn removeRow(id: u32) void {
    const start = std.time.milliTimestamp();

    for (rows.items, 0..) |row, i| {
        if (row.id == id) {
            _ = rows.orderedRemove(i);
            break;
        }
    }

    const end = std.time.milliTimestamp();
    last_action = "Remove row";
    last_time_ms = @floatFromInt(end - start);
}

// --- COMPONENTS ---
fn ActionButton(label: []const u8, action: fn () void) void {
    Button(.{ .on_press = action })
        .background(.black)
        .padding(.tblr(8, 8, 16, 16))
        .children({
        Text(label).font(14, 600, .white).end();
    });
}

fn RowView(row: *Row) void {
    const bg: Vapor.Types.Background = if (row.selected) .vapor_blue else .white;
    const text_color: Vapor.Types.Color = if (row.selected) .white else .black;

    Row()
        .direction(.row)
        .background(bg)
        .padding(.tblr(4, 4, 8, 8))
        .spacing(12)
        .layout(.left_center)
        .children({

        // ID
        Text(row.id)
            .width(.px(60))
            .font(14, 400, text_color)
            .end();

        // Label
        Text(row.label)
            .width(.grow)
            .font(14, 400, text_color)
            .end();

        // Select
        ButtonCtx(selectRow, .{row.id})
            .padding(.tblr(4, 4, 8, 8))
            .children({
            Text("Select").font(12, 400, text_color).end();
        });
        // Delete
        ButtonCtx(removeRow, .{row.id})
            .padding(.tblr(4, 4, 8, 8))
            .children({
            Text("×").font(16, 700, .red).end();
        });
    });
}

// --- MAIN PAGE ---
fn Benchmark() void {
    Vapor.Stack()
        .layout(.top_center)
        .padding(.all(20))
        .spacing(16)
        .children({

        // Header
        Text("Vapor 10k Benchmark").font(28, 800, .black).end();

        // Stats
        Row().direction(.row).spacing(20).children({
            Text(Vapor.fmtln("Rows: {d}", .{rows.items.len}))
                .font(14, 400, .black).end();
            Text(Vapor.fmtln("Last: {s}", .{last_action}))
                .font(14, 400, .black).end();
            Text(Vapor.fmtln("Time: {d:.1}ms", .{last_time_ms}))
                .font(14, 600, .vapor_blue).end();
        });

        // Action Buttons
        Row().direction(.row).spacing(8).wrap(.wrap).children({
            ActionButton("Create 1,000", create1k);
            ActionButton("Create 10,000", create10k);
            ActionButton("Append 1,000", append1k);
            ActionButton("Update every 10th", updateEvery10th);
            ActionButton("Clear", clearRows);
            // ActionButton("Swap Rows", swapRows);
            Button(.{ .on_press = swapRows })
                .background(if (counter % 2 == 0) .red else .blue)
                .padding(.tblr(8, 8, 16, 16))
                .children({
                Text("Swap Rows").font(14, 600, .white).end();
            });
        });

        // Table
        Vapor.Stack()
            .width(.px(600))
            .height(.px(500))
            .scroll(.scroll_y())
            .border(.simple(.black))
            .spacing(1)
            .background(.hex("#eeeeee"))
            .children({
            for (rows.items) |*row| {
                RowView(row);
            }
        });
    });
}
