const std = @import("std");
const ws = @import("websocket");
const config = @import("config");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
const API_KEY = config.CONFIG_API_KEY;
const API_URL = config.CONFIG_API_URL;

pub const SymbolStream = struct {
    handler: *Handler,
    read_thread: std.Thread,
    allocator: Allocator,

    pub fn init(allocator: Allocator, symbol: []const u8) !*SymbolStream {
        const API_HOST = utils.getHostFromURL(API_URL);
        const handler = try allocator.create(Handler);
        handler.* = try Handler.init(allocator, API_HOST);
        errdefer {
            handler.deinit();
            allocator.destroy(handler);
        }
        const read_thread = try handler.client.readLoopInNewThread(handler);

        const msg = try std.fmt.allocPrint(allocator, "{{\"type\":\"subscribe\",\"symbol\":\"{s}\"}}", .{symbol});
        defer allocator.free(msg);
        try handler.client.write(msg);

        const self = try allocator.create(SymbolStream);
        self.* = .{
            .handler = handler,
            .read_thread = read_thread,
            .allocator = allocator,
        };
        return self;
    }

    /// Returns the latest data, or null if nothing received yet.
    /// Caller does NOT own the returned slice — it's invalidated on next update.
    pub fn getLatestData(self: *SymbolStream) ?[]const u8 {
        self.handler.mu.lock();
        defer self.handler.mu.unlock();
        return self.handler.received_data;
    }

    /// Call this only when the application is shutting down.
    pub fn deinit(self: *SymbolStream) void {
        self.handler.close();
        self.read_thread.join();
        self.handler.deinit();
        self.allocator.destroy(self.handler);
        self.allocator.destroy(self);
    }
};

const Handler = struct {
    client: ws.Client,
    allocator: Allocator,
    received_data: ?[]const u8,
    mu: std.Thread.Mutex,

    fn init(allocator: Allocator, api_host: []const u8) !Handler {
        var client = try ws.Client.init(allocator, .{ .host = api_host, .port = 443, .tls = true });
        errdefer client.deinit();

        const request_path = try std.fmt.allocPrint(allocator, "/?token={s}", .{API_KEY});
        defer allocator.free(request_path);

        const headers = try std.fmt.allocPrint(allocator, "Host: {s}\r\n", .{api_host});
        defer allocator.free(headers);

        try client.handshake(request_path, .{
            .timeout_ms = 5000,
            .headers = headers,
        });

        return .{
            .client = client,
            .allocator = allocator,
            .received_data = null,
            .mu = .{},
        };
    }

    fn deinit(self: *Handler) void {
        self.mu.lock();
        defer self.mu.unlock();
        if (self.received_data) |d| {
            self.allocator.free(d);
            self.received_data = null;
        }
        self.client.deinit();
    }

    pub fn serverMessage(self: *Handler, data: []u8, tpe: ws.MessageTextType) !void {
        switch (tpe) {
            .text => {
                std.debug.print("Current data: {s}\n", .{data});
                if (std.mem.indexOf(u8, data, "\"type\":\"ping\"") != null) {
                    return;
                }
                std.debug.print("Received text: {} bytes\n", .{data.len});
                self.mu.lock();
                defer self.mu.unlock();
                // Free previous data before storing new
                if (self.received_data) |old| {
                    self.allocator.free(old);
                }
                self.received_data = self.allocator.dupe(u8, data) catch null;
            },
            .binary => std.debug.print("Received binary: {} bytes\n", .{data.len}),
        }
    }

    pub fn close(_: *Handler) void {
        std.debug.print("Connection closed\n", .{});
    }

    pub fn serverError(_: *Handler, err: anyerror) void {
        std.debug.print("Server error: {}\n", .{err});
    }
};
