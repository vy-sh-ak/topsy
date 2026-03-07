const std = @import("std");
const imgui = @import("../gui/imgui.zig");
const c = imgui.c;
const utils = @import("../utils.zig");


pub fn buttonGroup(current_date: [10]u8, end_date: *[10]u8) !void {
    if (imgui.styledButtonVariant("1D", .Secondary)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .days = 1 });
        std.debug.print("Selected 1D, end date: {s}\n", .{end_date.*});
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("1W", .Secondary)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .weeks = 1 });
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("1M", .Secondary)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .months = 1 });
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("6M", .Secondary)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .months = 6 });
        std.debug.print("Selected 6M, end date: {s}\n", .{end_date.*});
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("1Y", .Secondary)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .years = 1 });
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("5Y", .Secondary)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .years = 5 });
    }
}
