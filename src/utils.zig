const std = @import("std");

pub fn getHostFromURL(url: []const u8) []const u8 {
    const scheme_end = std.mem.indexOf(u8, url, "://") orelse return url;
    const host_start = scheme_end + 3;
    const domain_start = url[host_start..];
    const host_end = std.mem.indexOf(u8, domain_start, "/") orelse domain_start.len;
    return url[host_start .. host_start + host_end];
}
