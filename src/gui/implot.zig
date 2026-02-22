pub const c = @cImport({
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    @cInclude("cimgui.h");
    @cInclude("cimplot.h");
});

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
