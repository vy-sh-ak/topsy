const imgui = @import("../gui/imgui.zig");

pub const CandleChartOptions = struct {
    showToolTip: bool,

    pub fn render(self: *CandleChartOptions) void {

        if (imgui.styledButtonVariant("Options", .Ternary)) {
            imgui.c.igOpenPopup_Str("candle_chart_options", imgui.c.ImGuiPopupFlags_None);
        }
        if (imgui.styledPopup("candle_chart_options")) {
            if (imgui.styledMenuItem("Show Tooltip", self.showToolTip)) {
                self.showToolTip = !self.showToolTip;
            }
            imgui.styledPopupEnd();
        }
    }
};
