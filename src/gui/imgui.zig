const std = @import("std");
pub const c = @cImport({
    @cDefine("CIMGUI_USE_GLFW", "");
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    @cDefine("CIMGUI_USE_OPENGL3", "");
    @cInclude("cimgui.h");
    @cInclude("cimgui_impl.h");
});

pub const ImVec2 = c.ImVec2;
pub const ImVec4 = c.ImVec4;

pub fn init(window: *anyopaque) void {
    _ = c.igCreateContext(null);
    c.igStyleColorsDark(null);
    _ = c.ImGui_ImplGlfw_InitForOpenGL(@ptrCast(window), true);
    _ = c.ImGui_ImplOpenGL3_Init("#version 130");
}
pub fn deinit() void {
    c.ImGui_ImplOpenGL3_Shutdown();
    c.ImGui_ImplGlfw_Shutdown();
    c.igDestroyContext(null);
}
pub fn newFrame() void {
    c.ImGui_ImplOpenGL3_NewFrame();
    c.ImGui_ImplGlfw_NewFrame();
    c.igNewFrame();
}
pub fn render() void {
    c.igRender();
    c.ImGui_ImplOpenGL3_RenderDrawData(c.igGetDrawData());
}
pub const ImguiWindowFlags = struct {
    NoTitleBar: bool,
    NoResize: bool,
    NoMove: bool,
    NoScrollbar: bool,
    NoCollapse: bool,
};
pub fn begin(name: [*c]const u8, flags: ImguiWindowFlags) bool {
    var combined_flags: c.ImGuiWindowFlags = 0;
    if (flags.NoTitleBar) combined_flags |= c.ImGuiWindowFlags_NoTitleBar;
    if (flags.NoResize) combined_flags |= c.ImGuiWindowFlags_NoResize;
    if (flags.NoMove) combined_flags |= c.ImGuiWindowFlags_NoMove;
    if (flags.NoScrollbar) combined_flags |= c.ImGuiWindowFlags_NoScrollbar;
    if (flags.NoCollapse) combined_flags |= c.ImGuiWindowFlags_NoCollapse;
    return c.igBegin(name, null, combined_flags);
}
pub fn end() void {
    c.igEnd();
}
pub fn text(txt: [*c]const u8) void {
    c.igTextUnformatted(txt, null);
}
pub fn button(label: [*c]const u8) bool {
    return c.igButton(label, .{ .x = 0, .y = 0 });
}

pub fn sliderFloat(label: [*c]const u8, v: *f32, min: f32, max: f32) bool {
    return c.igSliderFloat(label, v, min, max, "%.3f", 0);
}

pub fn showDemoWindow() void {
    c.igShowDemoWindow(null);
}

pub fn setFullSize(w: f32, h: f32) void {
    c.igSetNextWindowPos(ImVec2{ .x = 0, .y = 0 }, c.ImGuiCond_Always, ImVec2{ .x = 0, .y = 0 });
    c.igSetNextWindowSize(ImVec2{ .x = w, .y = h }, c.ImGuiCond_Always);
}

pub fn getIO() [*c]c.struct_ImGuiIO {
    return c.igGetIO_Nil();
}
// font controls
pub fn setFont(io: [*c]c.struct_ImGuiIO, font_data: []const u8) [*c]c.struct_ImFont {
    _ = c.ImFontAtlas_AddFontDefault(io.*.Fonts, null);
    const cfg = c.ImFontConfig_ImFontConfig();
    defer c.ImFontConfig_destroy(cfg);
    cfg.*.FontDataOwnedByAtlas = false;
    return c.ImFontAtlas_AddFontFromMemoryTTF(
        io.*.Fonts,
        @constCast(font_data.ptr),
        @intCast(font_data.len),
        18.5,
        cfg,
        null,
    );
}

pub fn pushFont(font: [*c]c.struct_ImFont) void {
    c.igPushFont(font, 18.5);
}

pub fn popFont() void {
    c.igPopFont();
}

//combo or dropdown
pub fn dropdown(label: [*c]const u8, options: []const []const u8, current_value: *[]const u8) void {
    c.igSetNextItemWidth(100.0);
    if (c.igBeginCombo(label, current_value.*.ptr, c.ImGuiComboFlags_HeightLarge)) {
        for (options) |option| {
            const is_selected = std.mem.eql(u8, current_value.*, option);
            if (c.igSelectable_Bool(option.ptr, is_selected, c.ImGuiSelectableFlags_None, .{ .x = 0, .y = 0 })) {
                current_value.* = option;
            }
            if (is_selected) {
                c.igSetItemDefaultFocus();
            }
        }
        c.igEndCombo();
    }
}

pub fn buttonGroup() void {
    if (c.igButton("1D", .{ .x = 0, .y = 0 })) {
        std.debug.print("1D button clicked\n", .{});
    }
    c.igSameLine(0, 20.0);
    if (c.igButton("1W", .{ .x = 0, .y = 0 })) {
        std.debug.print("1W button clicked\n", .{});
    }
    c.igSameLine(0, 20.0);
    if (c.igButton("1M", .{ .x = 0, .y = 0 })) {
        std.debug.print("1M button clicked\n", .{});
    }   
    c.igSameLine(0, 20.0);
    if (c.igButton("1Y", .{ .x = 0, .y = 0 })) {
        std.debug.print("1Y button clicked\n", .{});
    }
    c.igSameLine(0, 20.0);
    if (c.igButton("5Y", .{ .x = 0, .y = 0 })) {
        std.debug.print("5Y button clicked\n", .{});
    }
}