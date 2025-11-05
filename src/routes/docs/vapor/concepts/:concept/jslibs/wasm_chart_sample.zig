const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Static = Fabric.Static;

/// Reusable dataset shape
pub const Dataset = struct {
    label: []const u8,
    data: []const f64,
    pointBackgroundColor: []const u8,
};

/// `data` block in Chart.js
pub const Data = struct {
    labels: []const []const u8,
    datasets: []const Dataset,
};

/// options.interaction
pub const Interaction = struct {
    mode: []const u8,
    intersect: bool,
};

/// options.plugins.title
pub const TitlePlugin = struct {
    display: bool,
    text: []const u8,
};

/// options.plugins.tooltip
pub const TooltipPlugin = struct {
    enabled: bool,
    mode: []const u8,
    intersect: bool,
    backgroundColor: []const u8,
    bodyColor: []const u8,
    titleColor: []const u8,
};

/// options.plugins.legend
pub const LegendPlugin = struct {
    display: bool,
};

/// options.plugins
pub const Plugins = struct {
    title: TitlePlugin,
    tooltip: TooltipPlugin,
    legend: LegendPlugin,
};

/// options.scales.y
pub const YScale = struct {
    beginAtZero: bool,
};

/// options.scales
pub const Scales = struct {
    y: YScale,
};

/// Top‐level `options` block
pub const Options = struct {
    responsive: bool,
    maintainAspectRatio: bool,
    interaction: Interaction,
    plugins: Plugins,
    scales: Scales,
};

pub const Chart = @This();
id: []const u8,
type: []const u8,
data: Data,
options: Options,

// ✌️ Here is where we add our createChartWasm function
pub extern fn createChartWasm(id_ptr: [*]const u8, id_len: usize, config_ptr: [*]const u8, config_len: usize) void;

pub fn createChart(chart: *Chart) void {
    const chart_config_str = std.json.stringifyAlloc(Fabric.allocator_global, chart, .{}) catch return;
    createChartWasm(chart.ptr, chart.len, chart_config_str[0..].ptr, chart_config_str[0..].len);
}

fn mountChart(chart: *Chart) void {
    chart.createChart();
}

// ✌️ Now in render we first pass our chart struct we instantiated, then add our canvas element to the DOM, and finally
// call mountChart, to attach the Chart to the canvas element.
pub fn render(chart: *Chart) void {
    // This only gets called when Canvas has been added to the dom.
    Static.CtxHooks(.mounted, mountChart, .{chart})({
        Static.Canvas(.{
            .id = chart.id,
        });
    });
}
