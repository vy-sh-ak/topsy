const std = @import("std");

// Env Configuration
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

// GLFW
pub fn setGLFW(b: *std.Build) *std.Build.Step.Compile {
    const glfw = b.addLibrary(.{ .name = "glfw", .root_module = b.createModule(.{ .target = b.graph.host, .link_libc = true }) });
    const glfw_src = "libs/glfw/src/";
    glfw.root_module.addCSourceFiles(.{
        .files = &.{
            glfw_src ++ "context.c",
            glfw_src ++ "init.c",
            glfw_src ++ "input.c",
            glfw_src ++ "monitor.c",
            glfw_src ++ "platform.c",
            glfw_src ++ "vulkan.c",
            glfw_src ++ "window.c",
            glfw_src ++ "egl_context.c",
            glfw_src ++ "osmesa_context.c",
            glfw_src ++ "null_init.c",
            glfw_src ++ "null_monitor.c",
            glfw_src ++ "null_window.c",
            glfw_src ++ "null_joystick.c",
            glfw_src ++ "win32_init.c",
            glfw_src ++ "win32_joystick.c",
            glfw_src ++ "win32_module.c",
            glfw_src ++ "win32_monitor.c",
            glfw_src ++ "win32_time.c",
            glfw_src ++ "win32_thread.c",
            glfw_src ++ "win32_window.c",
            glfw_src ++ "wgl_context.c",
        },
        .flags = &.{"-D_GLFW_WIN32"},
    });
    glfw.root_module.addIncludePath(b.path("libs/glfw/include"));
    glfw.root_module.addIncludePath(b.path("libs/glfw/src"));
    glfw.root_module.linkSystemLibrary("gdi32", .{});
    glfw.root_module.linkSystemLibrary("user32", .{});
    glfw.root_module.linkSystemLibrary("shell32", .{});
    glfw.root_module.linkSystemLibrary("opengl32", .{});
    return glfw;
}

pub fn setCimgui(b: *std.Build) *std.Build.Step.Compile {
    const cimgui = b.addLibrary(.{ .name = "cimgui", .root_module = b.createModule(.{ .target = b.graph.host, .link_libcpp = true }) });
    cimgui.root_module.addCSourceFiles(.{
        .files = &.{
            "libs/cimgui/cimgui.cpp",
            "libs/cimgui/imgui/imgui.cpp",
            "libs/cimgui/imgui/imgui_demo.cpp",
            "libs/cimgui/imgui/imgui_draw.cpp",
            "libs/cimgui/imgui/imgui_tables.cpp",
            "libs/cimgui/imgui/imgui_widgets.cpp",
            "libs/cimgui/imgui/backends/imgui_impl_glfw.cpp",
            "libs/cimgui/imgui/backends/imgui_impl_opengl3.cpp",
        },
        .flags = &.{
            "-DIMGUI_IMPL_API=extern \"C\"",
        },
    });
    cimgui.root_module.addIncludePath(b.path("libs/cimgui"));
    cimgui.root_module.addIncludePath(b.path("libs/cimgui/imgui"));
    cimgui.root_module.addIncludePath(b.path("libs/cimgui/imgui/backends"));
    cimgui.root_module.addIncludePath(b.path("libs/glfw/include"));
    cimgui.root_module.linkSystemLibrary("opengl32", .{});
    return cimgui;
}

pub fn setCimplot(b: *std.Build) *std.Build.Step.Compile {
    const cimplot = b.addLibrary(.{ .name = "cimplot", .root_module = b.createModule(.{ .target = b.graph.host, .link_libcpp = true }) });
    cimplot.root_module.addCSourceFiles(.{
        .files = &.{
            "libs/cimplot/cimplot.cpp",
            "libs/cimplot/implot/implot.cpp",
            "libs/cimplot/implot/implot_items.cpp",
            "libs/cimplot/implot/implot_demo.cpp",
        },
        .flags = &.{},
    });
    cimplot.root_module.addIncludePath(b.path("libs/cimplot"));
    cimplot.root_module.addIncludePath(b.path("libs/cimplot/implot"));
    cimplot.root_module.addIncludePath(b.path("libs/cimgui"));
    cimplot.root_module.addIncludePath(b.path("libs/cimgui/imgui"));
    return cimplot;
}

pub fn setStbi(b: *std.Build) *std.Build.Step.Compile {
    const stbi = b.addLibrary(.{ .name = "stbi", .root_module = b.createModule(.{ .target = b.graph.host, .link_libc = true }) });
    stbi.root_module.addCSourceFiles(.{
        .files = &.{
            "libs/stbi/stbi_impl.c",
        },
        .flags = &.{},
    });
    stbi.root_module.addIncludePath(b.path("libs/stbi"));
    return stbi;
}