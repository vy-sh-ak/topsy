const std = @import("std");
pub const c = @cImport({
    @cInclude("GLFW/glfw3.h");
    @cInclude("stb_image.h");
});

pub const Window = *c.GLFWwindow;

pub fn init() !void {
    if (c.glfwInit() == c.GLFW_FALSE) {
        return error.GlfwInitFailed;
    }
}

pub fn deinit() void {
    c.glfwTerminate();
}

pub fn createWindow(width: c_int, height: c_int, title: [*c]const u8) !Window {
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    return c.glfwCreateWindow(width, height, title, null, null) orelse
        return error.WindowCreationFailed;
}

pub fn setWindowIcon(window: Window, data: []const u8) void {
    var width: c_int = 0;
    var height: c_int = 0;
    var channels: c_int = 0;
    const pixels = c.stbi_load_from_memory(
        data.ptr,
        @intCast(data.len),
        &width,
        &height,
        &channels,
        4,
    );
    if (pixels == null) return;
    defer c.stbi_image_free(pixels);
    const images = [1]c.GLFWimage{
        .{
            .width = width,
            .height = height,
            .pixels = pixels,
        },
    };
    c.glfwSetWindowIcon(window, 1, &images);
}

pub fn destroyWindow(window: Window) void {
    c.glfwDestroyWindow(window);
}

pub fn makeContextCurrent(window: Window) void {
    c.glfwMakeContextCurrent(window);
}

pub fn swapInterval(interval: c_int) void {
    c.glfwSwapInterval(interval);
}

pub fn shouldClose(window: Window) bool {
    return c.glfwWindowShouldClose(window) != 0;
}

pub fn pollEvents() void {
    c.glfwPollEvents();
}

pub fn swapBuffers(window: Window) void {
    c.glfwSwapBuffers(window);
}

pub fn getFramebufferSize(window: Window) struct { w: c_int, h: c_int } {
    var w: c_int = 0;
    var h: c_int = 0;
    c.glfwGetFramebufferSize(window, &w, &h);
    return .{ .w = w, .h = h };
}
