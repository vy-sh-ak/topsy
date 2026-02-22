const std = @import("std");
const topsy = @import("topsy");
const rl = @import("raylib");
const trade = @import("trade.zig");
const candle_chart = @import("candlestick_chart.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open persistent WebSocket stream
    var stream = try trade.SymbolStream.init(allocator, "ADSK");
    defer stream.deinit(); // only cleaned up when app exits

    const screenWidth = 800;
    const screenHeight = 450;
    const candle_width = 10;
    const gap = 5;

    rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });
    rl.initWindow(screenWidth, screenHeight, "Topsy");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawText("Symbol: ADSK", 20, 20, 20, rl.Color.dark_gray);
        if (stream.getLatestData()) |data| {
            const data_z = allocator.dupeZ(u8, data) catch null;
            if (data_z) |dz| {
                defer allocator.free(dz);
                std.debug.print("Latest data: {s}\n", .{dz});
                rl.drawText("dz.ptr", 20, 60, 16, rl.Color.gray);
            }
        } else {
            rl.drawText("Waiting for data...", 20, 60, 16, rl.Color.gray);
        }

        for (candle_chart.dummy_candles, 0..) |candle, i| {
            const idx: i32 = @intCast(i);
            const x: i32 = 50 + idx * (candle_width + gap);
            candle_chart.drawCandle(candle, x, candle_width, 400, 700, screenHeight);
        }
    }
}
