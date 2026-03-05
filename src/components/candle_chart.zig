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

pub fn renderCandleChart() void {
    _ = imgui.c.igCheckbox("Show Tooltip", &show_tooltip);
    imgui.c.igSameLine(0, 10.0);
    _ = imgui.c.igColorEdit4("##Bull", &bullCol.x, imgui.c.ImGuiColorEditFlags_NoInputs);
    imgui.c.igSameLine(0, 10.0);
    _ = imgui.c.igColorEdit4("##Bear", &bearCol.x, imgui.c.ImGuiColorEditFlags_NoInputs);

    implot.c.ImPlot_GetStyle().*.UseLocalTime = false;

    const x_min = dates[0];
    const x_max = dates[dates.len - 1];
    var y_min = lows[0];
    var y_max = highs[0];
    for (1..lows.len) |i| {
        y_min = @min(y_min, lows[i]);
        y_max = @max(y_max, highs[i]);
    }
    const y_pad = @max((y_max - y_min) * 0.10, 1.0);
    const min_zoom = 60.0 * 60.0 * 24.0;
    const max_zoom = x_max - x_min;
    implot.c.ImPlot_PushStyleColor_Vec4(implot.c.ImPlotCol_PlotBg, .{ .w = 0, .x = 0, .y = 0, .z = 1 });
    if (implot.c.ImPlot_BeginPlot("Candlestick Chart", .{ .x = -1, .y = 500 }, 0)) {
        // X axis: auto range; Y axis: auto-fit + range-fit
        implot.c.ImPlot_SetupAxes(null, null, 0, implot.c.ImPlotAxisFlags_AutoFit | implot.c.ImPlotAxisFlags_RangeFit);

        // Set initial view window from current data range
        implot.c.ImPlot_SetupAxesLimits(x_min, x_max, y_min - y_pad, y_max + y_pad, implot.c.ImPlotCond_Once);

        // Use time scale on X axis (renders dates automatically)
        implot.c.ImPlot_SetupAxisScale_PlotScale(implot.c.ImAxis_X1, implot.c.ImPlotScale_Time);

        // Prevent panning/zooming outside the data range
        implot.c.ImPlot_SetupAxisLimitsConstraints(implot.c.ImAxis_X1, x_min, x_max);
        implot.c.ImPlot_SetupAxisZoomConstraints(implot.c.ImAxis_X1, min_zoom, max_zoom);

        // Format Y axis as dollar values
        implot.c.ImPlot_SetupAxisFormat_Str(implot.c.ImAxis_Y1, "$%.0f");

        // Draw the candlestick chart
        implot.plotCandleStick("GOOGL", dates[0..], opens[0..], closes[0..], lows[0..], highs[0..], @intCast(dates.len), show_tooltip, 0.25, bullCol, bearCol);

        implot.c.ImPlot_EndPlot();
    }
    implot.c.ImPlot_PopStyleColor(implot.c.ImPlotCol_PlotBg);
}
