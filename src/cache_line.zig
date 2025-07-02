const std = @import("std");

fn getCacheLineSize() usize {
    return std.atomic.cache_line;
}

fn calculateCacheLines(comptime T: type, count: usize) struct { lines: usize, efficiency: f32 } {
    const cache_line_size = getCacheLineSize();
    const struct_size = @sizeOf(T);
    const total_bytes = struct_size * count;
    const cache_lines_used = (total_bytes + cache_line_size - 1) / cache_line_size;
    const efficiency = @as(f32, @floatFromInt(total_bytes)) / @as(f32, @floatFromInt(cache_lines_used * cache_line_size));

    return .{ .lines = cache_lines_used, .efficiency = efficiency * 100 };
}

// Monster is 1 + 4 + 4 + 6 = 15, but we can't align this correctly so we add 1 bytes, to get to 16
// 16 is a multiple of 4.
const Monster = struct {
    height: u32, // 4 bytes
    weight: u32, // 4 bytes
    rider: Rider, // alignement of 2, bytes 6
    attack_type: AttackEnum, // 1 byte
};

// the rider struct is 6 bytes, and since 6 is multiple of 2 we do not need to pad
const Rider = struct {
    name: [4]u8, // 4 bytes alignment of 1
    skill_rank: u16, // 2 bytes, alignement of 2
};

// 4 + 4 + 4 + 1 = 13, but since our alignment is still 4, then we need to add 3 bytes ie 13 + 3 = 16;
// we are now wasting 3 bytes or memory
const MonsterWithPtr = struct {
    height: u32, // 4 bytes
    weight: u32, // 4 bytes
    rider: *Rider, // depending on your system, could be 32 128, or 64, we will use 32 bits for now, ie 4 bytes alignement 4
    attack_type: AttackEnum, // 1 byte
};

const AttackEnum = enum { fire, water };
// Memory layout:
// [height----][weight----][attack_type][padding][padding][padding]
//  0  1  2  3   4  5  6  7     8        9       10      11
//
// Total: 16 bytes (not 15!) because:
// - Struct alignment = max field alignment = 4 bytes
// - Size must be multiple of alignment
// - 15 rounds up to 16 (next multiple of 4)

const MonsterFire = struct {
    height: u32, // 4 bytes
    weight: u32, // 4 bytes
    rider: Rider, // alignement of 2, bytes 6
};

const MonsterWater = struct {
    height: u32, // 4 bytes
    weight: u32, // 4 bytes
    rider: Rider, // alignement of 2, bytes 6
};

fn analyzeStruct(comptime T: type) void {
    const cache_line_size = 64;
    const size = @sizeOf(T);
    const align_size = @alignOf(T);

    std.debug.print("Struct: {s}\n", .{@typeName(T)});
    std.debug.print("Size: {} bytes\n", .{size});
    std.debug.print("Alignment: {} bytes\n", .{align_size});
    std.debug.print("Structs per cache line: {}\n", .{cache_line_size / size});
    std.debug.print("Cache line efficiency per Struct: {d:.2}%\n", .{(@as(f32, @floatFromInt(size)) / @as(f32, @floatFromInt(cache_line_size))) * 100});
}

pub fn main() !void {
    analyzeStruct(Rider);
    var data = calculateCacheLines(Rider, 1024);
    std.debug.print("\nNumber of Cache lines: {}\nTotal Memory: {}\nTotal Cache Line Eff: {d:.2}%\n", .{ data.lines, data.lines * getCacheLineSize(), data.efficiency });
    std.debug.print("\n---------\n", .{});

    analyzeStruct(Monster);
    data = calculateCacheLines(Monster, 1024);
    std.debug.print("\nNumber of Cache lines: {}\nTotal Memory: {}\nTotal Cache Line Eff: {d:.2}%\n", .{ data.lines, data.lines * getCacheLineSize(), data.efficiency });
    std.debug.print("\n---------\n", .{});

    analyzeStruct(MonsterWithPtr);
    data = calculateCacheLines(MonsterWithPtr, 1024);
    std.debug.print("\nNumber of Cache lines: {}\nTotal Memory: {}\nTotal Cache Line Eff: {d:.2}%\n", .{ data.lines, data.lines * getCacheLineSize(), data.efficiency });
    std.debug.print("\n---------\n", .{});

    analyzeStruct(MonsterFire);
    data = calculateCacheLines(MonsterFire, 512);
    std.debug.print("\nNumber of Cache lines: {}\nTotal Memory: {}\nTotal Cache Line Eff: {d:.2}%\n", .{ data.lines, data.lines * getCacheLineSize(), data.efficiency });
    std.debug.print("\n---------\n", .{});

    analyzeStruct(MonsterWater);
    data = calculateCacheLines(MonsterWater, 512);
    std.debug.print("\nNumber of Cache lines: {}\nTotal Memory: {}\nTotal Cache Line Eff: {d:.2}%\n", .{ data.lines, data.lines * getCacheLineSize(), data.efficiency });
    std.debug.print("\n---------\n", .{});
}
