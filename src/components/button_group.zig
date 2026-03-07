const std = @import("std");
const imgui = @import("../gui/imgui.zig");
const c = imgui.c;
const utils = @import("../utils.zig");

fn getVariantForDuration(current_date: [10]u8, end_date: [10]u8, duration: utils.DateRange) !imgui.ButtonVariant {
    const target_date = try utils.subtractDuration(current_date, duration);
    if (std.mem.eql(u8, end_date[0..], target_date[0..])) {
        return .Secondary;
    }
    return .Ternary;
}

pub fn buttonGroup(current_date: [10]u8, end_date: *[10]u8) !void {
    const v_1d = try getVariantForDuration(current_date, end_date.*, .{ .days = 1 });
    const v_1w = try getVariantForDuration(current_date, end_date.*, .{ .weeks = 1 });
    const v_1m = try getVariantForDuration(current_date, end_date.*, .{ .months = 1 });
    const v_6m = try getVariantForDuration(current_date, end_date.*, .{ .months = 6 });
    const v_1y = try getVariantForDuration(current_date, end_date.*, .{ .years = 1 });
    const v_5y = try getVariantForDuration(current_date, end_date.*, .{ .years = 5 });

    if (imgui.styledButtonVariant("1D", v_1d)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .days = 1 });
        std.debug.print("Selected 1D, end date: {s}\n", .{end_date.*});
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("1W", v_1w)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .weeks = 1 });
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("1M", v_1m)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .months = 1 });
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("6M", v_6m)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .months = 6 });
        std.debug.print("Selected 6M, end date: {s}\n", .{end_date.*});
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("1Y", v_1y)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .years = 1 });
    }
    c.igSameLine(0, 10.0);
    if (imgui.styledButtonVariant("5Y", v_5y)) {
        end_date.* = try utils.subtractDuration(current_date, .{ .years = 5 });
    }
}
