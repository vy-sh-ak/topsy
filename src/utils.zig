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
pub const DateRange = union(enum) {
    days: i32,
    weeks: i32,
    months: i32,
    years: i32

};

fn daysInMonth(year: i32, month: i32) i32 {
    const year_u16: std.time.epoch.Year = @intCast(year);
    return switch (month) {
        1,3,5,7,8,10,12 => 31,
        4,6,9,11 => 30,
        2 => if (std.time.epoch.isLeapYear(year_u16)) 29 else 28,
        else => 30,
    };
}

fn subtractDays(year: *i32, month: *i32, day: *i32, count: i32) void {
    var remaining = if (count > 0) count else 0;
    while (remaining > 0) : (remaining -= 1) {
        if (day.* > 1) {
            day.* -= 1;
            continue;
        }

        if (month.* > 1) {
            month.* -= 1;
        } else {
            month.* = 12;
            year.* -= 1;
        }
        day.* = daysInMonth(year.*, month.*);
    }
}

pub fn subtractDuration(current_date : [10]u8, duration: DateRange) ![10] u8{
    const year  = try std.fmt.parseInt(i32, current_date[0..4], 10);
    const month = try std.fmt.parseInt(i32, current_date[5..7], 10);
    const day   = try std.fmt.parseInt(i32, current_date[8..10], 10);

    var new_year  = year;
    var new_month = month;
    var new_day   = day;

    switch (duration) {
        .days => |days_count| {
            subtractDays(&new_year, &new_month, &new_day, days_count);
        },
        .weeks => |weeks_count| {
            const days_count = if (weeks_count > 0) weeks_count * 7 else 0;
            subtractDays(&new_year, &new_month, &new_day, days_count);
        },
        .months => |months_count| {
            var remaining = if (months_count > 0) months_count else 0;
            while (remaining > 0) : (remaining -= 1) {
                if (new_month > 1) {
                    new_month -= 1;
                } else {
                    new_month = 12;
                    new_year -= 1;
                }
            }
            const max_day = daysInMonth(new_year, new_month);
            if (new_day > max_day) {
                new_day = max_day;
            }
        },
        .years => |years_count| {
            if (years_count > 0) {
                new_year -= years_count;
            }
            const max_day = daysInMonth(new_year, new_month);
            if (new_day > max_day) {
                new_day = max_day;
            }
        },
    }

    if (new_year < 0 or new_year > 9999) return error.InvalidDate;
    if (new_month < 1 or new_month > 12) return error.InvalidDate;
    if (new_day < 1 or new_day > daysInMonth(new_year, new_month)) return error.InvalidDate;

    const fmt_year: u16 = @intCast(new_year);
    const fmt_month: u8 = @intCast(new_month);
    const fmt_day: u8 = @intCast(new_day);

    var out: [10]u8 = undefined;
    _ = try std.fmt.bufPrint(
        &out,
        "{d:0>4}-{d:0>2}-{d:0>2}",
        .{
            fmt_year,
            fmt_month,
            fmt_day,
        },
    );
    return out;
}