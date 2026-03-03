const std = @import("std");
const imgui = @import("../gui/imgui.zig");
const hc = @import("../helpers/http_client.zig");
const config  = @import("config");

const simFinURL = config.CONFIG_SIMFIN_URL;
const simFinKey = config.CONFIG_SIMFIN_KEY;

pub fn fetchDataButton(current_symbol: []const u8, current_date: [10]u8, end_date: [10]u8) !void {
    if (imgui.button("Fetch Data")) {
        std.debug.print("Fetching data for {s} from {s} to {s}\n", .{ current_symbol, end_date, current_date });

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();

        const request_url = try std.fmt.allocPrint(
            gpa.allocator(),
            "{s}/api/v3/companies/prices/verbose?ticker={s}&start={s}&end={s}",
            .{ simFinURL, current_symbol, end_date, current_date },
        );
        defer gpa.allocator().free(request_url);

        const headers = [_]std.http.Header{
            .{ .name = "accept", .value = "application/json" },
            .{ .name = "Authorization", .value = simFinKey },
        };

        const client = hc.HttpClient{
            .url = request_url,
            .headers = &headers,
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
}
