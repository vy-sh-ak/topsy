const std = @import("std");

pub fn getHostFromURL(url: []const u8) []const u8 {
    const scheme_end = std.mem.indexOf(u8, url, "://") orelse return url;
    const host_start = scheme_end + 3;
    const domain_start = url[host_start..];
    const host_end = std.mem.indexOf(u8, domain_start, "/") orelse domain_start.len;
    return url[host_start .. host_start + host_end];
}

pub fn currentDateUTC() ![10]u8 {
    const ts = std.time.timestamp();
    const uts: u64 = @intCast(ts);
    const epoach_seconds = std.time.epoch.EpochSeconds{ .secs = uts };
    const epoach_day = epoach_seconds.getEpochDay();
    const year_day = epoach_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();

    const year = year_day.year;
    const month = month_day.month.numeric();
    const day = month_day.day_index + 1;

    var out: [10]u8 = undefined;

    _ = try std.fmt.bufPrint(
        &out,
        "{d:0>4}-{d:0>2}-{d:0>2}",
        .{
            year,
            month,
            day,
        },
    );

    return out;
}