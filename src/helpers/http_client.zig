const std = @import("std");

pub const HttpClient = struct {
    url: []const u8,
    method: std.http.Method = .GET,
    headers: []const std.http.Header = &.{},
    allocator: std.mem.Allocator,

    pub const Response = struct {
        status: std.http.Status,
        body: []const u8,
        allocator: std.mem.Allocator,

        pub fn deinit(self: *Response) void {
            self.allocator.free(self.body);
        }
    };

    pub fn send(self: *const HttpClient) !Response {
        var client = std.http.Client{ .allocator = self.allocator };
        defer client.deinit();

        var aw: std.Io.Writer.Allocating = .init(self.allocator);
        errdefer aw.deinit();

        const result = try client.fetch(.{
            .location = .{ .url = self.url },
            .method = self.method,
            .extra_headers = self.headers,
            .response_writer = &aw.writer,
        });

        return .{
            .status = result.status,
            .body = try aw.toOwnedSlice(),
            .allocator = self.allocator,
        };
    }
};
