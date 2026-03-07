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
    MenuBar: bool = false,
};
pub fn begin(name: [*c]const u8, flags: ImguiWindowFlags) bool {
    var combined_flags: c.ImGuiWindowFlags = 0;
    if (flags.NoTitleBar) combined_flags |= c.ImGuiWindowFlags_NoTitleBar;
    if (flags.NoResize) combined_flags |= c.ImGuiWindowFlags_NoResize;
    if (flags.NoMove) combined_flags |= c.ImGuiWindowFlags_NoMove;
    if (flags.NoScrollbar) combined_flags |= c.ImGuiWindowFlags_NoScrollbar;
    if (flags.NoCollapse) combined_flags |= c.ImGuiWindowFlags_NoCollapse;
    if (flags.MenuBar) combined_flags |= c.ImGuiWindowFlags_MenuBar;
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

pub const ButtonVariant = enum {
    Primary,
    Secondary,
    Ternary,
};

const ButtonColors = struct {
    base: c.ImVec4,
    hover: c.ImVec4,
    active: c.ImVec4,
};

fn getButtonColors(variant: ButtonVariant) ButtonColors {
    return switch (variant) {
        .Primary => .{
            .base = .{ .x = 0.93, .y = 0.33, .z = 0.10, .w = 1.0 },
            .hover = .{ .x = 1.00, .y = 0.42, .z = 0.15, .w = 1.0 },
            .active = .{ .x = 0.82, .y = 0.27, .z = 0.08, .w = 1.0 },
        },
        .Secondary => .{
            .base = .{ .x = 0.28, .y = 0.21, .z = 0.40, .w = 1.0 },
            .hover = .{ .x = 0.36, .y = 0.28, .z = 0.50, .w = 1.0 },
            .active = .{ .x = 0.24, .y = 0.18, .z = 0.34, .w = 1.0 },
        },
        .Ternary => .{
            .base = .{ .x = 0.18, .y = 0.18, .z = 0.20, .w = 1.0 },
            .hover = .{ .x = 0.25, .y = 0.25, .z = 0.28, .w = 1.0 },
            .active = .{ .x = 0.32, .y = 0.32, .z = 0.36, .w = 1.0 },
        },
    };
}

pub fn styledButton(label: [*c]const u8) bool {
    return styledButtonVariant(label, .Secondary);
}

pub fn styledButtonVariant(label: [*c]const u8, variant: ButtonVariant) bool {
    const colors = getButtonColors(variant);

    c.igPushStyleVar_Float(c.ImGuiStyleVar_FrameRounding, 2.0);
    c.igPushStyleVar_Vec2(c.ImGuiStyleVar_FramePadding, .{ .x = 8, .y = 6 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_Button, colors.base);
    c.igPushStyleColor_Vec4(c.ImGuiCol_ButtonHovered, colors.hover);
    c.igPushStyleColor_Vec4(c.ImGuiCol_ButtonActive, colors.active);
    c.igPushStyleColor_Vec4(c.ImGuiCol_Text, .{ .x = 0.96, .y = 0.96, .z = 0.98, .w = 1.0 });

    const pressed = c.igButton(label, .{ .x = 0, .y = 0 });

    c.igPopStyleColor(4);
    c.igPopStyleVar(2);
    return pressed;
}

pub fn styledCheckbox(label: [*c]const u8, value: *bool) bool {
    return styledCheckboxVariant(label, value, .Secondary);
}

pub fn styledCheckboxVariant(label: [*c]const u8, value: *bool, variant: ButtonVariant) bool {
    const colors = getButtonColors(variant);

    c.igPushStyleVar_Float(c.ImGuiStyleVar_FrameRounding, 2.0);
    c.igPushStyleVar_Vec2(c.ImGuiStyleVar_FramePadding, .{ .x = 8, .y = 6 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBg, colors.base);
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBgHovered, colors.hover);
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBgActive, colors.active);
    c.igPushStyleColor_Vec4(c.ImGuiCol_CheckMark, .{ .x = 0.96, .y = 0.96, .z = 0.98, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_Text, .{ .x = 0.96, .y = 0.96, .z = 0.98, .w = 1.0 });

    const changed = c.igCheckbox(label, value);

    c.igPopStyleColor(5);
    c.igPopStyleVar(2);
    return changed;
}

pub fn styledPopup(id: [*c]const u8) bool {
    c.igPushStyleVar_Float(c.ImGuiStyleVar_PopupRounding, 2.0);
    c.igPushStyleVar_Vec2(c.ImGuiStyleVar_WindowPadding, .{ .x = 8, .y = 8 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_PopupBg, .{ .x = 0.16, .y = 0.16, .z = 0.18, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_Border, .{ .x = 0.28, .y = 0.21, .z = 0.40, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_Header, .{ .x = 0.28, .y = 0.21, .z = 0.40, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_HeaderHovered, .{ .x = 0.36, .y = 0.28, .z = 0.50, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_HeaderActive, .{ .x = 0.24, .y = 0.18, .z = 0.34, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_Text, .{ .x = 0.96, .y = 0.96, .z = 0.98, .w = 1.0 });

    const is_open = c.igBeginPopup(id, c.ImGuiPopupFlags_None);
    if (!is_open) {
        c.igPopStyleColor(6);
        c.igPopStyleVar(2);
    }
    return is_open;
}

pub fn styledPopupEnd() void {
    c.igEndPopup();
    c.igPopStyleColor(6);
    c.igPopStyleVar(2);
}

pub fn styledMenuItem(label: [*c]const u8, selected: bool) bool {
    return c.igMenuItem_Bool(label, null, selected, true);
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

pub const InputOnChangeFn = *const fn (value: []const u8, user_data: ?*anyopaque) void;

const InputTextCallbackCtx = struct {
    on_change: InputOnChangeFn,
    user_data: ?*anyopaque,
};

fn inputTextOnEdit(data: [*c]c.ImGuiInputTextCallbackData) callconv(.c) c_int {
    const raw_user_data = data.*.UserData orelse return 0;
    const ctx: *InputTextCallbackCtx = @ptrCast(@alignCast(raw_user_data));

    const text_len_i32 = data.*.BufTextLen;
    if (text_len_i32 <= 0) {
        ctx.on_change("", ctx.user_data);
        return 0;
    }

    const text_len: usize = @intCast(text_len_i32);
    const buf: [*]u8 = @ptrCast(data.*.Buf);
    ctx.on_change(buf[0..text_len], ctx.user_data);
    return 0;
}

//combo or dropdown
pub fn dropdown(label: [*c]const u8, options: []const []const u8, current_value: *[]const u8) void {
    const label_size = c.igCalcTextSize(label, null, true, 0.0);
    const preview_size = c.igCalcTextSize(current_value.*.ptr, null, false, 0.0);
    const dynamic_width = @max(label_size.x, preview_size.x) + 28.0;

    c.igPushStyleVar_Float(c.ImGuiStyleVar_FrameRounding, 2.0);
    c.igPushStyleVar_Vec2(c.ImGuiStyleVar_FramePadding, .{ .x = 8, .y = 6 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBg, .{ .x = 0.18, .y = 0.18, .z = 0.20, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBgHovered, .{ .x = 0.25, .y = 0.25, .z = 0.28, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBgActive, .{ .x = 0.32, .y = 0.32, .z = 0.36, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_PopupBg, .{ .x = 0.16, .y = 0.16, .z = 0.18, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_Header, .{ .x = 0.28, .y = 0.21, .z = 0.40, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_HeaderHovered, .{ .x = 0.36, .y = 0.28, .z = 0.50, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_HeaderActive, .{ .x = 0.24, .y = 0.18, .z = 0.34, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_Button, .{ .x = 0.18, .y = 0.18, .z = 0.20, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_ButtonHovered, .{ .x = 0.25, .y = 0.25, .z = 0.28, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_ButtonActive, .{ .x = 0.32, .y = 0.32, .z = 0.36, .w = 1.0 });
    c.igSetNextItemWidth(dynamic_width);
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

    c.igPopStyleColor(10);
    c.igPopStyleVar(2);
}

//styled input field
pub fn styledInput(label: [*c]const u8, value_buffer: []u8) []const u8 {
    return styledInputWithOnChange(label, value_buffer, null, null);
}

pub fn styledInputWithOnChange(label: [*c]const u8, value_buffer: []u8, on_change: ?InputOnChangeFn, user_data: ?*anyopaque) []const u8 {
    c.igPushStyleVar_Float(c.ImGuiStyleVar_FrameRounding, 2.0);
    c.igPushStyleVar_Vec2(c.ImGuiStyleVar_FramePadding, .{ .x = 8, .y = 6 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBg, .{ .x = 0.18, .y = 0.18, .z = 0.20, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBgHovered, .{ .x = 0.25, .y = 0.25, .z = 0.28, .w = 1.0 });
    c.igPushStyleColor_Vec4(c.ImGuiCol_FrameBgActive, .{ .x = 0.32, .y = 0.32, .z = 0.36, .w = 1.0 });

    const buf_ptr: [*c]u8 = @ptrCast(value_buffer.ptr);
    var flags: c.ImGuiInputTextFlags = c.ImGuiInputTextFlags_None;
    var callback: c.ImGuiInputTextCallback = null;
    var callback_user_data: ?*anyopaque = user_data;
    var callback_ctx: InputTextCallbackCtx = undefined;

    if (on_change) |on_change_fn| {
        flags |= c.ImGuiInputTextFlags_CallbackEdit;
        callback_ctx = .{ .on_change = on_change_fn, .user_data = user_data };
        callback = inputTextOnEdit;
        callback_user_data = &callback_ctx;
    }
    c.igSetNextItemWidth(100);
    _ = c.igInputText(label, buf_ptr, value_buffer.len, flags, callback, callback_user_data);

    const len = std.mem.indexOfScalar(u8, value_buffer, 0) orelse value_buffer.len;
    const updated_value = value_buffer[0..len];

    c.igPopStyleColor(3);
    c.igPopStyleVar(2);
    return updated_value;
}

pub fn separator() void {
    c.igPushStyleColor_Vec4(c.ImGuiCol_Separator, .{ .x = 0.22, .y = 0.22, .z = 0.24, .w = 1.0 });
    c.igSameLine(0, 10.0);
    c.igSeparatorEx(c.ImGuiSeparatorFlags_Vertical, 1);
    c.igPopStyleColor(1);
}