const std = @import("std");
const rl = @import("raylib");

const Candle = struct { open: f32, high: f32, low: f32, close: f32 };

fn priceToScreen(price: f32, min_price: f32, max_price: f32, screen_h: f32) f32 {
    return screen_h - ((price - min_price) / (max_price - min_price)) * screen_h;
}

pub fn drawCandle(candle: Candle, x: i32, width: i32, min_price: f32, max_price: f32, screen_height: i32) void {
    const sh: f32 = @floatFromInt(screen_height);
    const price_range = max_price - min_price;

    // Map price to screen Y (inverted: high price = top of screen)
    const high_y: i32 = @intFromFloat((1.0 - (candle.high - min_price) / price_range) * sh);
    const low_y: i32 = @intFromFloat((1.0 - (candle.low - min_price) / price_range) * sh);
    const open_y: i32 = @intFromFloat((1.0 - (candle.open - min_price) / price_range) * sh);
    const close_y: i32 = @intFromFloat((1.0 - (candle.close - min_price) / price_range) * sh);

    const body_top = @min(open_y, close_y);
    const body_bottom = @max(open_y, close_y);
    const body_height = body_bottom - body_top;

    const is_bullish = candle.close > candle.open;
    const body_color = if (is_bullish) rl.Color.green else rl.Color.red;
    const wick_color = rl.Color.white;

    const center_x = x + @divTrunc(width, 2);

    // Draw wick (thin vertical line from high to low)
    rl.drawLine(center_x, high_y, center_x, low_y, wick_color);

    // Draw body (filled rectangle)
    rl.drawRectangle(x, body_top, width, if (body_height < 1) 1 else body_height, body_color);
}

pub const dummy_candles = [_]Candle{
    .{ .open = 500, .close = 540, .high = 560, .low = 480 }, // bullish
    .{ .open = 540, .close = 510, .high = 570, .low = 500 }, // bearish
    .{ .open = 510, .close = 570, .high = 590, .low = 490 }, // bullish
    .{ .open = 570, .close = 530, .high = 580, .low = 510 }, // bearish
    .{ .open = 530, .close = 580, .high = 600, .low = 520 }, // bullish
    .{ .open = 580, .close = 550, .high = 610, .low = 540 }, // bearish
    .{ .open = 550, .close = 600, .high = 620, .low = 530 }, // bullish
    .{ .open = 600, .close = 560, .high = 630, .low = 550 }, // bearish
    .{ .open = 560, .close = 610, .high = 640, .low = 540 }, // bullish
    .{ .open = 610, .close = 580, .high = 650, .low = 560 }, // bearish
    .{ .open = 580, .close = 620, .high = 660, .low = 570 }, // bullish
    .{ .open = 620, .close = 590, .high = 640, .low = 575 }, // bearish
};

fn getPriceRange(candles: []const Candle) struct { min: f32, max: f32 } {
    var min: f32 = candles[0].low;
    var max: f32 = candles[0].high;
    for (candles) |c| {
        if (c.low < min) min = c.low;
        if (c.high > max) max = c.high;
    }
    return .{ .min = min, .max = max };
}
