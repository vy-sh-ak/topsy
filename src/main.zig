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
pub fn main() !void {
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

    var current_symbol: []const u8 = "ADSK";
    const symbols = [_][]const u8{ "ADSK", "AAPL" };
    const current_date = try utils.currentDateUTC();
    var end_date = try utils.subtractDuration(current_date, .{ .days = 1});
    while (!glfw.shouldClose(window)) {
        glfw.pollEvents();
        imgui.newFrame();
        const window_size = glfw.getWindowSize(window);
        imgui.setFullSize(@floatFromInt(window_size.w), @floatFromInt(window_size.h));
        if (imgui.begin("Topsy Dashboard", imgui.ImguiWindowFlags{ .NoTitleBar = true, .NoResize = true, .NoMove = true, .NoScrollbar = true, .NoCollapse = true })) {
            imgui.pushFont(interFont);
            imgui.dropdown("Symbols", &symbols, &current_symbol);
            try button_group.buttonGroup(current_date, &end_date);
            try fetch_data_button.fetchDataButton(current_symbol,current_date, end_date);
            candle_chart.renderCandleChart();
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
