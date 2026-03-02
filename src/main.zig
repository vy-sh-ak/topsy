const std = @import("std");
const topsy = @import("topsy");
const rl = @import("raylib");
const trade = @import("trade.zig");
const glfw = @import("gui/glfw.zig");
const imgui = @import("gui/imgui.zig");
const implot = @import("gui/implot.zig");
const hc = @import("data/http_client.zig");
const gl = @cImport({
    @cInclude("GLFW/glfw3.h");
});
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
    // Sample data
    const price_data = [_]f32{ 100.0, 102.5, 101.0, 105.0, 103.5, 107.0, 106.0, 110.0, 108.5, 112.0 };
    // const volume_data = [_]f32{ 1500, 2300, 1800, 3200, 2700, 3500, 2100, 4000, 3100, 2800 };

    // var show_imgui_demo = false;
    // var show_implot_demo = false;
    var current_item: []const u8 = "ADSK";
    const symbols = [_][]const u8{"ADSK", "AAPL"};
    while (!glfw.shouldClose(window)) {
        glfw.pollEvents();
        imgui.newFrame();
        const window_size = glfw.getWindowSize(window);
        imgui.setFullSize(@floatFromInt(window_size.w), @floatFromInt(window_size.h));
        if (imgui.begin("Topsy Dashboard", imgui.ImguiWindowFlags{ .NoTitleBar = true, .NoResize = true, .NoMove = true, .NoScrollbar = true, .NoCollapse = true })) {
            imgui.pushFont(interFont);
            imgui.dropdown("Symbols", &symbols, &current_item);
            imgui.buttonGroup();

            

            if (imgui.button("Fetch Data")) {
                var gpa = std.heap.GeneralPurposeAllocator(.{}){};
                defer _ = gpa.deinit();

                const client = hc.HttpClient{
                    .url = "http://httpbin.org/headers",
                    .allocator = gpa.allocator(),
                };
                if (client.send()) |*response| {
                    defer @constCast(response).deinit();
                    std.debug.print("Status: {s}\nBody: {s}\n", .{
                        @tagName(response.status),
                        response.body,
                    });
                } else |err| {
                    std.debug.print("Fetch failed: {}\n", .{err});
                }
            }
            // Price chart
            if (implot.beginPlot("Price")) {
                implot.setupAxes("Time", "Price ($)");
                implot.plotBarsFloat("BTC/USD", &price_data);
                implot.endPlot();
            }
            // Volume chart
            // if (implot.beginPlot("Volume")) {
            //     implot.setupAxes("Time", "Volume");
            //     implot.plotBarsFloat("Volume", &volume_data);
            //     implot.endPlot();
            // }
            imgui.popFont();
        }
        imgui.end();
        // if (show_imgui_demo) imgui.showDemoWindow();
        // if (show_implot_demo) implot.showDemoWindow();
        // Render
        const fb = glfw.getFramebufferSize(window);
        gl.glViewport(0, 0, fb.w, fb.h);
        gl.glClearColor(0.1, 0.1, 0.1, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        imgui.render();
        glfw.swapBuffers(window);
    }
}
