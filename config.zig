const std = @import("std");

const Config = struct {
    environment: []const u8,
    apiKey: []const u8,
    apiUrl: []const u8,
};

pub fn setConfig(allocator: std.mem.Allocator, exe: *std.Build.Step.Compile, path: []const u8) void {
    const config = parseConfig(allocator, path);
    const options = exe.step.owner.addOptions();
    options.addOption([]const u8, "CONFIG_ENVIRONMENT", config.environment);
    options.addOption([]const u8, "CONFIG_API_KEY", config.apiKey);
    options.addOption([]const u8, "CONFIG_API_URL", config.apiUrl);

    exe.root_module.addOptions("config", options);
}

fn parseConfig(allocator: std.mem.Allocator, path: []const u8) Config {
    const data = std.fs.cwd().readFileAlloc(allocator, path, 1024) catch unreachable;
    defer allocator.free(data);

    const parsed = std.json.parseFromSlice(Config, allocator, data, .{}) catch unreachable;
    defer parsed.deinit();

    return .{
        .environment = allocator.dupe(u8, parsed.value.environment) catch unreachable,
        .apiKey = allocator.dupe(u8, parsed.value.apiKey) catch unreachable,
        .apiUrl = allocator.dupe(u8, parsed.value.apiUrl) catch unreachable,
    };
}
