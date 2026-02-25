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

    glfw.makeContextCurrent(window);
    glfw.swapInterval(1);

    imgui.init(window);
    defer imgui.deinit();

    implot.init();
    defer implot.deinit();
    // Sample data
    const price_data = [_]f32{ 100.0, 102.5, 101.0, 105.0, 103.5, 107.0, 106.0, 110.0, 108.5, 112.0 };
    const volume_data = [_]f32{ 1500, 2300, 1800, 3200, 2700, 3500, 2100, 4000, 3100, 2800 };

    // var show_imgui_demo = false;
    // var show_implot_demo = false;

    while (!glfw.shouldClose(window)) {
        glfw.pollEvents();
        imgui.newFrame();

        if (imgui.begin("Topsy Dashboard")) {
            imgui.text("Welcome to Topsy Trading Dashboard!");

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
                implot.plotLineFloat("BTC/USD", &price_data);
                implot.endPlot();
            }
            // Volume chart
            if (implot.beginPlot("Volume")) {
                implot.setupAxes("Time", "Volume");
                implot.plotBarsFloat("Volume", &volume_data);
                implot.endPlot();
            }
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
