pub const Chart = @This();
id: []const u8,
type: []const u8,
data: Data,
options: Options,

pub fn createChart(chart: *Chart) void {
    const chart_config_str = std.json.stringifyAlloc(Fabric.allocator_global, chart, .{}) catch return;
    createChartWasm(chart.id.ptr, chart.id.len, chart_config_str[0..].ptr, chart_config_str[0..].len);
}
