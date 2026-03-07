const std = @import("std");
const imgui = @import("../gui/imgui.zig");
const implot = @import("../gui/implot.zig");

const dates: [10]f64 = .{
    1704067200, // 2024-01-01
    1704153600, // 2024-01-02
    1704240000, // 2024-01-03
    1704326400, // 2024-01-04
    1704412800, // 2024-01-05
    1704499200, // 2024-01-06
    1704585600, // 2024-01-07
    1704672000, // 2024-01-08
    1704758400, // 2024-01-09
    1704844800, // 2024-01-10
};

const opens = [_]f64{ 100.0, 102.5, 101.0, 105.0, 103.5, 107.0, 106.0, 109.0, 108.0, 112.0 };
const closes = [_]f64{ 102.5, 101.0, 105.0, 103.5, 107.0, 106.0, 109.0, 108.0, 112.0, 110.5 };
const lows = [_]f64{ 99.0, 100.0, 100.5, 102.0, 103.0, 105.5, 105.0, 107.5, 107.0, 109.0 };
const highs = [_]f64{ 103.0, 103.5, 106.0, 106.0, 108.0, 108.5, 110.0, 110.5, 113.5, 113.0 };

var show_tooltip: bool = false;
var bullCol: implot.c.ImVec4 = .{ .x = 0.000, .y = 1.000, .z = 0.441, .w = 1.000 };
var bearCol: implot.c.ImVec4 = .{ .x = 0.853, .y = 0.050, .z = 0.310, .w = 1.000 };
var last_range_len: usize = 0;
var last_x_min: f64 = 0;
var last_x_max: f64 = 0;
var last_y_min: f64 = 0;
var last_y_max: f64 = 0;

pub const CandleChartData = struct {
    allocator: std.mem.Allocator,
    symbol: [:0]u8,
    dates: []f64,
    opens: []f64,
    closes: []f64,
    lows: []f64,
    highs: []f64,

    pub fn init(allocator: std.mem.Allocator, symbol: []const u8, len: usize) !CandleChartData {
        return .{
            .allocator = allocator,
            .symbol = try allocator.dupeZ(u8, symbol),
            .dates = try allocator.alloc(f64, len),
            .opens = try allocator.alloc(f64, len),
            .closes = try allocator.alloc(f64, len),
            .lows = try allocator.alloc(f64, len),
            .highs = try allocator.alloc(f64, len),
        };
    }

    pub fn deinit(self: *CandleChartData) void {
        self.allocator.free(self.symbol);
        self.allocator.free(self.dates);
        self.allocator.free(self.opens);
        self.allocator.free(self.closes);
        self.allocator.free(self.lows);
        self.allocator.free(self.highs);
    }
};

pub fn renderCandleChart(data: ?*const CandleChartData) void {
    const chart_symbol: [:0]const u8 = if (data) |d| d.symbol else "GOOGL";
    const chart_dates: []const f64 = if (data) |d| d.dates else dates[0..];
    const chart_opens: []const f64 = if (data) |d| d.opens else opens[0..];
    const chart_closes: []const f64 = if (data) |d| d.closes else closes[0..];
    const chart_lows: []const f64 = if (data) |d| d.lows else lows[0..];
    const chart_highs: []const f64 = if (data) |d| d.highs else highs[0..];
    if (chart_dates.len == 0) return;

    // imgui.c.igSameLine(0, 10.0);
    // _ = imgui.c.igColorEdit4("##Bull", &bullCol.x, imgui.c.ImGuiColorEditFlags_NoInputs);
    // imgui.c.igSameLine(0, 10.0);
    // _ = imgui.c.igColorEdit4("##Bear", &bearCol.x, imgui.c.ImGuiColorEditFlags_NoInputs);

    implot.c.ImPlot_GetStyle().*.UseLocalTime = false;

    var x_min = chart_dates[0];
    var x_max = chart_dates[0];
    for (1..chart_dates.len) |i| {
        x_min = @min(x_min, chart_dates[i]);
        x_max = @max(x_max, chart_dates[i]);
    }
    const x_span = x_max - x_min;
    var y_min = chart_lows[0];
    var y_max = chart_highs[0];
    for (1..chart_lows.len) |i| {
        y_min = @min(y_min, chart_lows[i]);
        y_max = @max(y_max, chart_highs[i]);
    }
    const x_pad = @max(x_span * 0.08, 60.0 * 60.0 * 24.0);
    const y_pad = @max((y_max - y_min) * 0.15, 1.0);
    const range_changed =
        chart_dates.len != last_range_len or
        x_min != last_x_min or
        x_max != last_x_max or
        y_min != last_y_min or
        y_max != last_y_max;

    if (range_changed) {
        last_range_len = chart_dates.len;
        last_x_min = x_min;
        last_x_max = x_max;
        last_y_min = y_min;
        last_y_max = y_max;
    }

    implot.c.ImPlot_PushStyleColor_Vec4(implot.c.ImPlotCol_PlotBg, .{ .w = 0, .x = 0, .y = 0, .z = 1 });
    const available_height = imgui.c.igGetContentRegionAvail().y;
    if (implot.c.ImPlot_BeginPlot("Candlestick Chart", .{ .x = -1, .y = available_height - 100 }, 0)) {
        // Keep axes fully interactive (pan/zoom); only set an initial centered window.
        implot.c.ImPlot_SetupAxes(null, null, 0, 0);

        // Reset view when dataset changes, otherwise keep user's current pan/zoom state.
        implot.c.ImPlot_SetupAxesLimits(
            x_min - x_pad,
            x_max + x_pad,
            y_min - y_pad,
            y_max + y_pad,
            if (range_changed) implot.c.ImPlotCond_Always else implot.c.ImPlotCond_Once,
        );

        // Use time scale on X axis (renders dates automatically)
        implot.c.ImPlot_SetupAxisScale_PlotScale(implot.c.ImAxis_X1, implot.c.ImPlotScale_Time);

        // Format Y axis as dollar values
        implot.c.ImPlot_SetupAxisFormat_Str(implot.c.ImAxis_Y1, "$%.0f");

        // Draw the candlestick chart
        const candle_width_pct: f32 = if (chart_dates.len > 1) 0.25 else 60.0 * 60.0 * 8.0;
        implot.plotCandleStick(chart_symbol.ptr, chart_dates, chart_opens, chart_closes, chart_lows, chart_highs, @intCast(chart_dates.len), show_tooltip, candle_width_pct, bullCol, bearCol);

        implot.c.ImPlot_EndPlot();
    }
    _ = imgui.c.igCheckbox("Show Tooltip", &show_tooltip);
    implot.c.ImPlot_PopStyleColor(implot.c.ImPlotCol_PlotBg);
}
