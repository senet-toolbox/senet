// Theme.zig
const std = @import("std");
const Fabric = @import("fabric");
const Color = Fabric.Types.Color;
pub const Mode = enum {
    light,
    dark,
};

pub const Colors = struct {
    border_color: Color,
    text_color: Color,
    background: Color,
    primary: Color,
    secondary: Color,
    font_family: []const u8,
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
    border_color_light: Color,
    grid_color: Color,
    code_text_color: Color,
    code_function_color: Color,
    code_keyword_color: Color,
    disabled: Color,
};

pub const Blue = Colors{
    .border_color = .white,
    .text_color = .white,
    .background = .hex("#0400ff"),
    .primary = .rgba(255, 255, 255, 255),
    .secondary = .rgba(0, 0, 0, 255),
    .font_family = "Montserrat",
    .btn_color = .white,
    .tint = .hex("#0400ff"),
    .text_tint_color = .white,
    .alternate_tint = .white,
    .btn_tint = .hex("#FF3838"),
    .dark_text = .hex("#ffffff"),
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
    .code_background = .hex("#FAFAFA"),
    .highlight_color = .hex("#EDEDED"),
    .border_color_light = .hex("#e4e4e4"),
    .grid_color = .hex("#f6f6f6"),
    .code_text_color = .hex("#262626"),
    .code_function_color = .hex("#0074c2"),
    .code_keyword_color = .hex("#D4883C"),
    .disabled = .hex("#A2A2A2"),
};



pub const Light = Colors{
    .border_color = .hex("#262626"),
    .text_color = .rgba(0, 0, 0, 255),
    .background = .white,
    .primary = .rgba(255, 255, 255, 255),
    .secondary = .rgba(0, 0, 0, 255),
    .font_family = "Montserrat",
    .btn_color = .hex("#2108FF"),
    .tint = .hex("#2108FF"),
    .text_tint_color = .white,
    .alternate_tint = .hex("#2108FF"),
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
    .code_background = .hex("#FAFAFA"),
    .highlight_color = .hex("#EDEDED"),
    .border_color_light = .hex("#e4e4e4"),
    .grid_color = .hex("#f6f6f6"),
    .code_text_color = .hex("#262626"),
    .code_function_color = .hex("#0074c2"),
    .code_keyword_color = .hex("#d97706"),
    .disabled = .hex("#A2A2A2"),
};

pub const Dark = Colors{
    .border_color = .hex("#27272a"),
    .text_color = .hex("#EAEAEA"),
    .background = .hex("#0F0F0F"),
    .primary = .rgba(0, 0, 0, 255),
    .secondary = .rgba(255, 255, 255, 1),
    .font_family = "Montserrat",
    .btn_color = .hex("#FBFB28"),
    .tint = .hex("#FBFB28"),
    .text_tint_color = .hex("#FBFB28"),
    .alternate_tint = .hex("#6338FF"),
    .btn_tint = .hex("#FF3838"),
    .dark_text = .hex("#0B0B0B"),
    .form_input_border_color = .hex("#27272a"),
    .danger = .rgba(255, 78, 51, 1),
    .alternate_background = .hex("#000000"),
    .alternate_border_color = .white,
    .alternate_text_color = .hex("#FBFB28"),
    .logo = .hex("#0F0F0F"),
    .gradient_start_0stop_color = .hex("#EEFF00"),
    .gradient_start_100stop_color = .hex("#ccff00"),
    .gradient_end_0stop_color = .hex("#FFFFFF"),
    .gradient_end_100stop_color = .hex("#ffffff"),
    .icon_color = .hex("#484848"),
    .image_bg = .hex("#0F0F0F"),
    .code_background = .hex("#181818"),
    .highlight_color = .hex("#27272a"),
    .border_color_light = .hex("#1E1E1E"),
    .grid_color = .hex("#1E1E1E"),
    .code_text_color = .hex("#F6F5FB"),
    .code_function_color = .hex("#0074c2"),
    .code_keyword_color = .hex("#d43008"),
    .disabled = .hex("#A2A2A2"),
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

pub fn getDefaultThemeColors(self: ColorTheme) Colors {
    return switch (self.theme) {
        .light => Light,
        .dark => Dark,
    };
}

pub fn getThemeColors(self: ColorTheme) Colors {
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
