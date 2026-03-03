const std = @import("std");
const imgui = @import("../gui/imgui.zig");
const c = imgui.c;
const utils = @import("../utils.zig");


pub fn buttonGroup(current_date: [10]u8, end_date: *[10]u8) !void {
    if (c.igButton("1D", .{ .x = 0, .y = 0 })) {
        end_date.* = try utils.subtractDuration(current_date, .{ .days = 1 });
        std.debug.print("Selected 1D, end date: {s}\n", .{end_date.*});
    }
    c.igSameLine(0, 20.0);
    if (c.igButton("1W", .{ .x = 0, .y = 0 })) {
        end_date.* = try utils.subtractDuration(current_date, .{ .weeks = 1 });
    }
    c.igSameLine(0, 20.0);
    if (c.igButton("1M", .{ .x = 0, .y = 0 })) {
        end_date.* = try utils.subtractDuration(current_date, .{ .months = 1 });
    }
    c.igSameLine(0, 20.0);
    if (c.igButton("6M", .{ .x = 0, .y = 0 })) {
        end_date.* = try utils.subtractDuration(current_date, .{ .months = 6 });
        std.debug.print("Selected 6M, end date: {s}\n", .{end_date.*});
    }
    c.igSameLine(0, 20.0);
    if (c.igButton("1Y", .{ .x = 0, .y = 0 })) {
        end_date.* = try utils.subtractDuration(current_date, .{ .years = 1 });
    }
    c.igSameLine(0, 20.0);
    if (c.igButton("5Y", .{ .x = 0, .y = 0 })) {
        end_date.* = try utils.subtractDuration(current_date, .{ .years = 5 });
    }
}
