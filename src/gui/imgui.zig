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
pub fn begin(name: [*c]const u8) bool {
    return c.igBegin(name, null, 0);
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
