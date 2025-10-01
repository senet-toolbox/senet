// Theme.zig
const std = @import("std");
const Fabric = @import("fabric");
const Color = Fabric.Types.Color;
pub const Mode = enum {
    light,
    dark,
};

pub const ThemeColors = struct {
    border_color: Color,
    text_color: Color,
    background: Color,
    primary: Color,
    secondary: Color,
    font_family: []const u8,
    border_cache_color: Color,
    btn_color: Color,
    tint: Color,
    text_tint_color: Color,
    alternate_tint: Color,
    btn_tint: Color,
    dark_text: Color,
    form_input_border_color: Color,
    danger: Color,
    alternate_background: Color,
    alternate_border_color: Color,
    alternate_text_color: Color,
    logo: Color,
    gradient_start_0stop_color: Color,
    gradient_start_100stop_color: Color,
    gradient_end_0stop_color: Color,
    gradient_end_100stop_color: Color,
    icon_color: Color,
    image_bg: Color,
    code_background: Color,
    highlight_color: Color,
};

pub const Light = ThemeColors{
    .border_color = .hex("#262626"),
    .text_color = .rgba(0, 0, 0, 255),
    .background = .white,
    .primary = .rgba(255, 255, 255, 255),
    .secondary = .rgba(0, 0, 0, 255),
    .border_cache_color = .rgba(0, 0, 0, 40),
    .font_family = "Montserrat",
    .btn_color = .rgba(67, 64, 240, 255),
    .tint = .rgba(67, 64, 240, 255),
    .text_tint_color = .white,
    .alternate_tint = .rgba(67, 64, 240, 255),
    .btn_tint = .hex("#FF3838"),
    .dark_text = .hex("#FDFDFD"),
    .form_input_border_color = .hex("#E9E9E9"),
    .danger = .rgba(255, 78, 51, 255),
    .alternate_background = .hex("#262626"),
    .alternate_border_color = .hex("#262626"),
    .alternate_text_color = .hex("#ffffff"),
    .logo = .hex("#ffffff"),
    .gradient_start_0stop_color = .hex("#4800FF"),
    .gradient_start_100stop_color = .hex("#7A38FF"),
    .gradient_end_0stop_color = .hex("#FFE09E"),
    .gradient_end_100stop_color = .hex("#FFFFFF"),
    .icon_color = .hex("#A2A2A2"),
    .image_bg = .hex("#ffffff"),
    .code_background = .hex("#1A1B2B"),
    .highlight_color = .hex("#EDEDED"),
};

pub const Dark = ThemeColors{
    .border_color = .hex("#27272a"),
    .text_color = .rgba(255, 255, 255, 255),
    .background = .hex("#0F0F0F"),
    .primary = .rgba(0, 0, 0, 255),
    .secondary = .rgba(255, 255, 255, 255),
    .border_cache_color = .rgba(255, 255, 255, 40),
    .font_family = "Montserrat",
    .btn_color = .hex("#E5FF54"),
    .tint = .hex("#E5FF54"),
    .text_tint_color = .hex("#E5FF54"),
    .alternate_tint = .hex("#6338FF"),
    .btn_tint = .hex("#FF3838"),
    .dark_text = .hex("#0B0B0B"),
    .form_input_border_color = .hex("#27272a"),
    .danger = .rgba(255, 78, 51, 255),
    .alternate_background = .hex("#000000"),
    .alternate_border_color = .white,
    .alternate_text_color = .hex("#262626"),
    .logo = .hex("#121212"),
    .gradient_start_0stop_color = .hex("#EEFF00"),
    .gradient_start_100stop_color = .hex("#ccff00"),
    .gradient_end_0stop_color = .hex("#FFFFFF"),
    .gradient_end_100stop_color = .hex("#ffffff"),
    .icon_color = .hex("#484848"),
    .image_bg = .hex("#0F0F0F"),
    .code_background = .hex("#0A0B11"),
    .highlight_color = .hex("#27272a"),
};

const ColorTheme = @This();
switched_theme: bool = false,
pub var mode: Mode = .light;
pub var border_color: Color = .hex("#262626");
pub var text_color: Color = .rgba(0, 0, 0, 255);
pub var background: Color = Light.background;
pub var primary: Color = .rgba(255, 255, 255, 255);
pub var secondary: Color = .rgba(0, 0, 0, 255);
pub var shadow: Color = .rgba(0, 0, 0, 15);
pub var border_cache_color: Color = .rgba(0, 0, 0, 40);
pub var font_family: []const u8 = "Montserrat";
pub var btn_color: Color = .rgba(67, 64, 240, 255);
pub var tint: Color = .rgba(67, 64, 240, 255);
pub var text_tint_color: Color = .rgba(255, 255, 255, 255);
pub var alternate_tint: Color = .rgba(67, 64, 240, 255);
pub var btn_tint: Color = .hex("#FF3838");
pub var dark_text: Color = .hex("#8C8C8C");
pub var form_input_border_color: Color = .hex("#E9E9E9");
pub var danger: Color = .rgba(255, 78, 51, 255);

pub fn getDefaultThemeColors(self: ColorTheme) ThemeColors {
    return switch (self.theme) {
        .light => Light,
        .dark => Dark,
    };
}

pub fn getThemeColors(self: ColorTheme) ThemeColors {
    return switch (self.theme) {
        .light => Light,
        .dark => Dark,
    };
}

pub fn setTheme() void {
    mode = switch (mode) {
        .dark => .light,
        .light => .dark,
    };
    Fabric.lib.toggleTheme();
}

pub fn getTheme() void {
    const string_mode = Fabric.lib.getPersistBytes("theme") orelse return;
    mode = std.meta.stringToEnum(Mode, string_mode).?;
}

pub fn toggleTheme() void {
    // const theme = switch (mode) {
    //     .dark => Light,
    //     .light => Dark,
    // };

    mode = switch (mode) {
        .dark => .light,
        .light => .dark,
    };
    Fabric.println("New toggleTheme {any}", .{mode});
    Fabric.lib.setLocalStorageString("theme", @tagName(mode));

    // border_color = theme.border_color;
    // text_color = theme.text_color;
    // background = theme.background;
    // primary = theme.primary;
    // secondary = theme.secondary;
    // border_cache_color = theme.border_cache_color;
    // font_family = theme.font_family;
    // btn_color = theme.btn_color;
    // tint = theme.tint;
    // text_tint_color = theme.text_tint_color;
    // alternate_tint = theme.alternate_tint;
    // btn_tint = theme.btn_tint;
    // dark_text = theme.dark_text;
    // form_input_border_color = theme.form_input_border_color;
    // danger = theme.danger;
    // Fabric.lib.forceEverything();
    Fabric.lib.toggleTheme();
}

pub fn switchTheme(target_theme: Mode) void {
    Fabric.println("switchTheme {any}", .{mode});
    const theme = switch (target_theme) {
        .light => Light,
        .dark => Dark,
    };
    border_color = theme.border_color;
    text_color = theme.text_color;
    background = theme.background;
    primary = theme.primary;
    secondary = theme.secondary;
    border_cache_color = theme.border_cache_color;
    btn_color = theme.btn_color;
    tint = theme.tint;
    text_tint_color = theme.text_tint_color;
    alternate_tint = theme.alternate_tint;
    btn_tint = theme.btn_tint;
    dark_text = theme.dark_text;
    form_input_border_color = theme.form_input_border_color;
    danger = theme.danger;
    Fabric.lib.forceEverything();
}

// pub fn getAttribute(self: ColorTheme, comptime attribute: []const u8) Color {
//     const theme = self.getThemeColors();
//     return @field(theme, attribute);
// }
//
// pub fn getDefaultAttribute(self: ColorTheme, comptime attribute: []const u8) [4]f32 {
//     const theme = self.getDefaultThemeColors();
//     return @field(theme, attribute);
// }
