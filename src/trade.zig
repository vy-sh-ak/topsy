const std = @import("std");
const ws = @import("websocket");
const Allocator = std.mem.Allocator;
const API_KEY = "d6abic9r01qqjvbpqusgd6abic9r01qqjvbpqut0";
const API_URL = "wss://ws.finnhub.io";
const API_HOST = "ws.finnhub.io";

pub fn getSymbolData(allocator: Allocator, symbol: []const u8) ![]const u8 {
    var handler = try Handler.init(allocator);
    defer handler.deinit();

    // Start reading in a background thread
    const read_thread = try handler.client.readLoopInNewThread(&handler);
    defer read_thread.detach();

    // Build subscribe message: {"type":"subscribe","symbol":"<symbol>"}
    const msg = try std.fmt.allocPrint(allocator, "{{\"type\":\"subscribe\",\"symbol\":\"{s}\"}}", .{symbol});
    defer allocator.free(msg);
    try handler.client.write(msg);

    // Wait for the first response (with 10s timeout)
    handler.data_event.timedWait(10 * std.time.ns_per_s) catch
        return error.Timeout;

    // Return the received data (caller owns the memory)
    handler.mu.lock();
    defer handler.mu.unlock();
    if (handler.received_data) |data| {
        return data;
    }
    return error.NoData;
}

pub fn tradeDemo() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const data = try getSymbolData(allocator, "ADSK");
    defer allocator.free(data);
    std.debug.print("Got data: {s}\n", .{data});
}

const Handler = struct {
    client: ws.Client,
    allocator: Allocator,
    received_data: ?[]const u8,
    data_event: std.Thread.ResetEvent,
    mu: std.Thread.Mutex,

    fn init(allocator: Allocator) !Handler {
        var client = try ws.Client.init(allocator, .{ .host = API_HOST, .port = 443, .tls = true });
        errdefer client.deinit();
        const request_path = "/?token=" ++ API_KEY;
        try client.handshake(request_path, .{
            .timeout_ms = 5000,
            .headers = "Host: " ++ API_HOST ++ "\r\n",
        });

        return .{
            .client = client,
            .allocator = allocator,
            .received_data = null,
            .data_event = .{},
            .mu = .{},
        };
    }

    fn deinit(self: *Handler) void {
        self.client.deinit();
    }

    pub fn serverMessage(self: *Handler, data: []u8, tpe: ws.MessageTextType) !void {
        switch (tpe) {
            .text => {
                self.mu.lock();
                defer self.mu.unlock();
                // Only capture the first message
                if (self.received_data == null) {
                    self.received_data = self.allocator.dupe(u8, data) catch null;
                    self.data_event.set();
                }
            },
            .binary => std.debug.print("Received binary: {} bytes\n", .{data.len}),
        }
    }

    pub fn close(_: *Handler) void {
        std.debug.print("Connection closed\n", .{});
    }
};
