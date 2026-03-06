const std = @import("std");
const imgui = @import("../gui/imgui.zig");
const hc = @import("../helpers/http_client.zig");
const candle_chart = @import("candle_chart.zig");
const config  = @import("config");

const simFinURL = config.CONFIG_SIMFIN_URL;
const simFinKey = config.CONFIG_SIMFIN_KEY;

const PriceRow = struct {
    Date: []const u8,
    @"Opening Price": f64,
    @"Last Closing Price": f64,
    @"Lowest Price": f64,
    @"Highest Price": f64,
};

fn parseDateToUnixSeconds(date: []const u8) !f64 {
    if (date.len != 10 or date[4] != '-' or date[7] != '-') return error.InvalidDate;

    const year = try std.fmt.parseInt(i64, date[0..4], 10);
    const month = try std.fmt.parseInt(i64, date[5..7], 10);
    const day = try std.fmt.parseInt(i64, date[8..10], 10);

    var adjusted_year = year;
    if (month <= 2) adjusted_year -= 1;

    const era = @divFloor(adjusted_year, 400);
    const year_of_era = adjusted_year - era * 400;
    const month_prime = month + (if (month > 2) @as(i64, -3) else @as(i64, 9));
    const day_of_year = @divFloor(153 * month_prime + 2, 5) + day - 1;
    const day_of_era = year_of_era * 365 + @divFloor(year_of_era, 4) - @divFloor(year_of_era, 100) + day_of_year;
    const days_since_unix_epoch = era * 146097 + day_of_era - 719468;

    return @as(f64, @floatFromInt(days_since_unix_epoch * 86400));
}

pub fn fetchDataButton(current_symbol: []const u8, current_date: [10]u8, end_date: [10]u8, allocator: std.mem.Allocator) !?candle_chart.CandleChartData {
    if (!imgui.button("Fetch Data")) return null;

    std.debug.print("Fetching data for {s} from {s} to {s}\n", .{ current_symbol, end_date, current_date });

    const request_url = try std.fmt.allocPrint(
        allocator,
        "{s}/api/v3/companies/prices/verbose?ticker={s}&start={s}&end={s}",
        .{ simFinURL, current_symbol, end_date, current_date },
    );
    defer allocator.free(request_url);

    const headers = [_]std.http.Header{
        .{ .name = "accept", .value = "application/json" },
        .{ .name = "Authorization", .value = simFinKey },
    };

    const client = hc.HttpClient{
        .url = request_url,
        .headers = &headers,
        .allocator = allocator,
    };

    if (client.send()) |*response| {
        defer @constCast(response).deinit();
        std.debug.print("Status: {s}\n", .{@tagName(response.status)});

        const ParsedCompany = struct {
            ticker: []const u8,
            data: []const PriceRow,
        };
        var parsed = try std.json.parseFromSlice([]ParsedCompany, allocator, response.body, .{
            .ignore_unknown_fields = true,
        });
        defer parsed.deinit();
        std.debug.print("Parsed {d} companies from response\n", .{parsed.value.len});
        // print entire parsed data for debugging
        for (parsed.value) |company| {
            std.debug.print("Company: {s}, Price Rows: {d}\n", .{company.ticker, company.data.len});
            for (company.data) |row| {
                std.debug.print(
                    "  Date: {s}, Open: {}, Close: {}, Low: {}, High: {}\n",
                    .{ row.Date, row.@"Opening Price", row.@"Last Closing Price", row.@"Lowest Price", row.@"Highest Price" },
                );
            }
        }
        if (parsed.value.len == 0 or parsed.value[0].data.len == 0) {
            std.debug.print("No candle data in response\n", .{});
            return null;
        }

        const candles = parsed.value[0].data;
        var chart_data = try candle_chart.CandleChartData.init(allocator, parsed.value[0].ticker, candles.len);
        errdefer chart_data.deinit();

        for (candles, 0..) |row, i| {
            chart_data.dates[i] = try parseDateToUnixSeconds(row.Date);
            chart_data.opens[i] = row.@"Opening Price";
            chart_data.closes[i] = row.@"Last Closing Price";
            chart_data.lows[i] = row.@"Lowest Price";
            chart_data.highs[i] = row.@"Highest Price";
        }

        var i: usize = 1;
        while (i < chart_data.dates.len) : (i += 1) {
            var j = i;
            while (j > 0 and chart_data.dates[j - 1] > chart_data.dates[j]) : (j -= 1) {
                std.mem.swap(f64, &chart_data.dates[j - 1], &chart_data.dates[j]);
                std.mem.swap(f64, &chart_data.opens[j - 1], &chart_data.opens[j]);
                std.mem.swap(f64, &chart_data.closes[j - 1], &chart_data.closes[j]);
                std.mem.swap(f64, &chart_data.lows[j - 1], &chart_data.lows[j]);
                std.mem.swap(f64, &chart_data.highs[j - 1], &chart_data.highs[j]);
            }
        }

        return chart_data;
    } else |err| {
        std.debug.print("Fetch failed: {}\n", .{err});
        return null;
    }
}
