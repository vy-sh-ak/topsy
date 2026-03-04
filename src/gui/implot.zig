pub const c = @cImport({
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    @cInclude("cimgui.h");
    @cInclude("cimplot.h");
});
const algos = @import("../helpers/algos.zig");
pub fn init() void {
    _ = c.ImPlot_CreateContext();
}

pub fn deinit() void {
    c.ImPlot_DestroyContext(null);
}

pub fn beginPlot(title: [*c]const u8) bool {
    return c.ImPlot_BeginPlot(title, .{ .x = -1, .y = 0 }, 0);
}

pub fn endPlot() void {
    c.ImPlot_EndPlot();
}

pub fn plotLineFloat(label: [*c]const u8, values: []const f32) void {
    const spec: c.ImPlotSpec_c = .{};
    c.ImPlot_PlotLine_FloatPtrInt(
        label,
        values.ptr,
        @as(c_int, @intCast(values.len)),
        1.0,
        0.0,
        spec,
    );
}

pub fn plotBarsFloat(label: [*c]const u8, values: []const f32) void {
    const spec: c.ImPlotSpec_c = .{};
    c.ImPlot_PlotBars_FloatPtrInt(
        label,
        values.ptr,
        @as(c_int, @intCast(values.len)),
        0.67,
        0.0,
        spec,
    );
}

pub fn setupAxes(x_label: [*c]const u8, y_label: [*c]const u8) void {
    c.ImPlot_SetupAxes(x_label, y_label, 0, 0);
}

pub fn showDemoWindow() void {
    c.ImPlot_ShowDemoWindow(null);
}


fn imCol32(r: u8, g: u8, b: u8, a: u8) c.ImU32 {
    return (@as(c.ImU32, a) << 24) | (@as(c.ImU32, b) << 16) | (@as(c.ImU32, g) << 8) | @as(c.ImU32, r);
}

pub fn plotCandleStick(label: [*c]const u8, xs: []const f64, opens: []const f64, closes: []const f64, lows: []const f64, highs: []const f64, count: i32, tooltip: bool, width_percent: f32, bullCol: c.ImVec4, bearCol: c.ImVec4) void {
    if (count <= 0) return;

    const requested_count: usize = @intCast(count);
    const n = @min(@min(@min(@min(xs.len, opens.len), closes.len), lows.len), highs.len);
    const item_count = @min(requested_count, n);
    if (item_count == 0) return;

    const draw_list = c.ImPlot_GetPlotDrawList();
    const half_width: f64 = if (item_count > 1) (xs[1] - xs[0]) * @as(f64, @floatCast(width_percent)) else @as(f64, @floatCast(width_percent));

    if (c.ImPlot_IsPlotHovered() and tooltip) {
        var mouse = c.ImPlot_GetPlotMousePos(c.IMPLOT_AUTO, c.IMPLOT_AUTO);
        var rounded_time = c.ImPlot_RoundTime(c.ImPlotTime_FromDouble(mouse.x), c.ImPlotTimeUnit_Day);
        mouse.x = c.ImPlotTime_ToDouble(&rounded_time);

        const tool_l = c.ImPlot_PlotToPixels_double(mouse.x - @as(f64, @floatCast(half_width * 1.5)), mouse.y, c.IMPLOT_AUTO, c.IMPLOT_AUTO).x;
        const tool_r = c.ImPlot_PlotToPixels_double(mouse.x + @as(f64, @floatCast(half_width * 1.5)), mouse.y, c.IMPLOT_AUTO, c.IMPLOT_AUTO).x;
        const tool_t = c.ImPlot_GetPlotPos().y;
        const tool_b = tool_t + c.ImPlot_GetPlotSize().y;

        c.ImPlot_PushPlotClipRect(0);
        c.ImDrawList_AddRectFilled(draw_list, .{ .x = tool_l, .y = tool_t }, .{ .x = tool_r, .y = tool_b }, imCol32(128, 128, 128, 64), 0, 0);
        c.ImPlot_PopPlotClipRect();

        const idx = algos.binarySearch(f64, xs[0..item_count], 0, @as(i32, @intCast(item_count - 1)), mouse.x);
        if (idx != -1) {
            const i: usize = @intCast(idx);
            _ = c.igBeginTooltip();

            var buff: [32]u8 = undefined;
            _ = c.ImPlot_FormatDate(
                c.ImPlotTime_FromDouble(xs[i]),
                &buff,
                @intCast(buff.len),
                c.ImPlotDateFmt_DayMoYr,
                c.ImPlot_GetStyle().*.UseISO8601,
            );
            c.igText("Day:   %s", &buff);
            c.igText("Open:  $%.2f", @as(f64, @floatCast(opens[i])));
            c.igText("Close: $%.2f", @as(f64, @floatCast(closes[i])));
            c.igText("Low:   $%.2f", @as(f64, @floatCast(lows[i])));
            c.igText("High:  $%.2f", @as(f64, @floatCast(highs[i])));
            c.igEndTooltip();
        }
    }

    const spec: c.ImPlotSpec_c = .{};
    if (c.ImPlot_BeginItem(label, spec, .{ .x = 0, .y = 0, .z = 0, .w = 0 }, c.ImPlotMarker_None)) {
        const current_item = c.ImPlot_GetCurrentItem();
        if (current_item != null) {
            current_item.*.Color = imCol32(64, 64, 64, 255);
        }

        if (c.ImPlot_FitThisFrame()) {
            for (0..item_count) |i| {
                c.ImPlot_FitPoint(.{ .x = xs[i], .y = lows[i] });
                c.ImPlot_FitPoint(.{ .x = xs[i], .y = highs[i] });
            }
        }

        for (0..item_count) |i| {
            const open_pos = c.ImPlot_PlotToPixels_double(xs[i] - half_width, opens[i], c.IMPLOT_AUTO, c.IMPLOT_AUTO);
            const close_pos = c.ImPlot_PlotToPixels_double(xs[i] + half_width, closes[i], c.IMPLOT_AUTO, c.IMPLOT_AUTO);
            const low_pos = c.ImPlot_PlotToPixels_double(xs[i], lows[i], c.IMPLOT_AUTO, c.IMPLOT_AUTO);
            const high_pos = c.ImPlot_PlotToPixels_double(xs[i], highs[i], c.IMPLOT_AUTO, c.IMPLOT_AUTO);

            const color = c.igGetColorU32_Vec4(if (opens[i] > closes[i]) bearCol else bullCol);
            c.ImDrawList_AddLine(draw_list, low_pos, high_pos, color, 1.0);

            const body_min_y = @min(open_pos.y, close_pos.y);
            const body_max_y = @max(open_pos.y, close_pos.y);
            c.ImDrawList_AddRectFilled(
                draw_list,
                .{ .x = @min(open_pos.x, close_pos.x), .y = body_min_y },
                .{ .x = @max(open_pos.x, close_pos.x), .y = body_max_y },
                color,
                0,
                0,
            );
        }

        c.ImPlot_EndItem();
    }
}