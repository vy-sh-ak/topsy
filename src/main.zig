const std = @import("std");
const topsy = @import("topsy");
const rl = @import("raylib");
const trade = @import("trade.zig");
const config = @import("config");

const api_key = config.CONFIG_API_KEY;
pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });
    rl.setTargetFPS(60);
    rl.initWindow(screenWidth, screenHeight, "Topsy");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawText("api_key: " ++ api_key, 10, 10, 20, .light_gray);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
    }
}
