// Theme.zig
const std = @import("std");
const Fabric = @import("fabric");
const Background = Fabric.Types.Background;
pub const Theme = enum {
    light,
    dark,
};

pub const ThemeColors = struct {
    border_color: Background,
    text_color: Background,
    background: Background,
    primary: Background,
    secondary: Background,
    font_family: []const u8,
    shadow: Background,
    border_cache_color: Background,
    btn_color: Background,
    tint: Background,
    text_tint_color: Background,
    alternate_tint: Background,
    btn_tint: Background,
    dark_text: Background,
    form_input_border_color: Background,
    danger: Background,
};

pub const Light = ThemeColors{
    .border_color = .hex("#E9E9E9"),
    .text_color = .rgba(0, 0, 0, 255),
    .background = .rgba(255, 255, 255, 255),
    .primary = .rgba(255, 255, 255, 255),
    .secondary = .rgba(0, 0, 0, 255),
    .shadow = .rgba(0, 0, 0, 15),
    .border_cache_color = .rgba(0, 0, 0, 40),
    .font_family = "Montserrat",
    .btn_color = .rgba(67, 64, 240, 255),
    .tint = .rgba(67, 64, 240, 255),
    .text_tint_color = .rgba(255, 255, 255, 255),
    .alternate_tint = .rgba(67, 64, 240, 255),
    .btn_tint = .hex("#FF3838"),
    .dark_text = .hex("#8C8C8C"),
    .form_input_border_color = .hex("#E9E9E9"),
    .danger = .rgba(255, 78, 51, 255),
};

pub const Dark = ThemeColors{
    .border_color = .hex("#27272a"),
    .text_color = .rgba(255, 255, 255, 255),
    .background = .rgba(0, 0, 0, 255),
    .primary = .rgba(0, 0, 0, 255),
    .secondary = .rgba(255, 255, 255, 255),
    .shadow = .rgba(255, 255, 255, 30),
    .border_cache_color = .rgba(255, 255, 255, 40),
    .font_family = "Montserrat",
    .btn_color = .hex("#E5FF54"),
    .tint = .hex("#6338FF"),
    .text_tint_color = .rgba(255, 255, 255, 255),
    // .tint = .hex("#E5FF54"),
    .alternate_tint = .hex("#6338FF"),
    .btn_tint = .hex("#FF3838"),
    .dark_text = .hex("#8C8C8C"),
    .form_input_border_color = .hex("#27272a"),
    .danger = .rgba(255, 78, 51, 255),
};

const Color = @This();
theme: Theme = .light,
switched_theme: bool = false,

pub fn getDefaultThemeColors(self: Color) ThemeColors {
    return switch (self.theme) {
        .light => Light,
        .dark => Dark,
    };
}

pub fn getThemeColors(self: *Color) ThemeColors {
    return switch (self.theme) {
        .light => Light,
        .dark => Dark,
    };
}

pub fn switchTheme(self: *Color, theme_type: Theme) void {
    self.theme = theme_type;
    self.switched_theme = true;
    Fabric.global_rerender = true;
}

pub fn getAttribute(self: *Color, comptime attribute: []const u8) Background {
    const theme = self.getThemeColors();
    return @field(theme, attribute);
}

pub fn getDefaultAttribute(self: Color, comptime attribute: []const u8) [4]f32 {
    const theme = self.getDefaultThemeColors();
    return @field(theme, attribute);
}
