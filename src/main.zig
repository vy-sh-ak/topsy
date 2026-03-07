const std = @import("std");
const topsy = @import("topsy");
const rl = @import("raylib");
const trade = @import("trade.zig");
const glfw = @import("gui/glfw.zig");
const imgui = @import("gui/imgui.zig");
const implot = @import("gui/implot.zig");
const button_group = @import("components/button_group.zig");
const fetch_data_button = @import("components/fetch_data_button.zig");
const candle_chart = @import("components/candle_chart.zig");
const gl = @cImport({
    @cInclude("GLFW/glfw3.h");
});
const utils = @import("utils.zig");

fn onSymbolInputChange(value: []const u8, user_data: ?*anyopaque) void {
    const raw = user_data orelse return;
    const symbol_ref: *[]const u8 = @ptrCast(@alignCast(raw));
    symbol_ref.* = value;
}

fn setSymbolBuffer(symbol_buffer: []u8, symbol: []const u8) []const u8 {
    if (symbol_buffer.len == 0) return "";

    const copy_len = @min(symbol.len, symbol_buffer.len - 1);
    @memcpy(symbol_buffer[0..copy_len], symbol[0..copy_len]);
    symbol_buffer[copy_len] = 0;
    return symbol_buffer[0..copy_len];
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try glfw.init();
    defer glfw.deinit();

    const window = try glfw.createWindow(1280, 720, "Topsy");
    defer glfw.destroyWindow(window);
    glfw.setWindowIcon(window, @embedFile("assets/fire.png"));
    glfw.makeContextCurrent(window);
    glfw.swapInterval(1);

    imgui.init(window);
    defer imgui.deinit();

    implot.init();
    defer implot.deinit();

    const io = imgui.getIO();
    const interFont = imgui.setFont(io, @embedFile("assets/inter.ttf"));

    var symbol_buffer: [16]u8 = [_]u8{0} ** 16;
    var current_symbol: []const u8 = setSymbolBuffer(symbol_buffer[0..], "ADSK");
    // const symbols = [_][]const u8{ "ADSK", "AAPL" };
    const current_date = try utils.currentDateUTC();
    var end_date = try utils.subtractDuration(current_date, .{ .days = 1});
    var chart_data: ?candle_chart.CandleChartData = null;
    defer if (chart_data) |*existing_data| existing_data.deinit();

    while (!glfw.shouldClose(window)) {
        glfw.pollEvents();
        imgui.newFrame();
        const window_size = glfw.getWindowSize(window);
        imgui.setFullSize(@floatFromInt(window_size.w), @floatFromInt(window_size.h));
        if (imgui.begin("Topsy Dashboard", imgui.ImguiWindowFlags{ .NoTitleBar = true, .NoResize = true, .NoMove = true, .NoScrollbar = true, .NoCollapse = true })) {
            imgui.pushFont(interFont);
            current_symbol = imgui.styledInputWithOnChange("##symbol", symbol_buffer[0..], onSymbolInputChange, @ptrCast(&current_symbol));
            // imgui.dropdown("Symbols", &symbols, &current_symbol);
            if (current_symbol.ptr != symbol_buffer[0..].ptr) {
                current_symbol = setSymbolBuffer(symbol_buffer[0..], current_symbol);
            }
            imgui.c.igSameLine(0, 10.0);
            try button_group.buttonGroup(current_date, &end_date);
            imgui.c.igSameLine(0, 10.0);
            if (try fetch_data_button.fetchDataButton(current_symbol, current_date, end_date, allocator)) |new_data| {
                if (chart_data) |*old_data| old_data.deinit();
                chart_data = new_data;
            }
            candle_chart.renderCandleChart(if (chart_data) |*d| d else null);
            imgui.popFont();
        }
        imgui.end();
        const fb = glfw.getFramebufferSize(window);
        gl.glViewport(0, 0, fb.w, fb.h);
        gl.glClearColor(0.1, 0.1, 0.1, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        imgui.render();
        glfw.swapBuffers(window);
    }
}
