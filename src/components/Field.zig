const Vapor = @import("vapor");
const std = @import("std");
const Box = Vapor.Box;
const Text = Vapor.Text;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const Icon = Vapor.Icon;
const Label = Vapor.Label;
const utils = Vapor.utils;

const default_font_family = "Barlow";

pub const FieldType = enum {
    string,
    number,
    password,
    email,
    credit_card,
    telephone,
    cvv,
    expiry,
    float,
};

// var background: Vapor.Types.Background = .palette(.background);

const FieldValue = union(enum) {
    string: *[]const u8,
    password: *[]const u8,
    number: *i32,
    bool: *bool,
    email: *[]const u8,
    credit_card: *[]const u8,
    telephone: *[]const u8,
    float: *f32,
};

pub fn new() void {
    focus_states = std.StringHashMap(bool).init(Vapor.arena(.persist));
    field_values = std.StringHashMap(FieldValue).init(Vapor.arena(.persist));
    fields = std.StringHashMap(*Field).init(Vapor.arena(.persist));
}

// Change the map type
var focus_states: ?std.StringHashMap(bool) = null;

var field_values: std.StringHashMap(FieldValue) = undefined;

var fields: std.StringHashMap(*Field) = undefined;

// Helper to extract the unique ID from the input value
fn getPtrId(val: FieldValue) usize {
    return switch (val) {
        .string => |ptr| @intFromPtr(ptr),
        .number => |ptr| @intFromPtr(ptr),
        .bool => |ptr| @intFromPtr(ptr),
        .password => |ptr| @intFromPtr(ptr),
        .email => |ptr| @intFromPtr(ptr),
        .credit_card => |ptr| @intFromPtr(ptr),
        .telephone => |ptr| @intFromPtr(ptr),
        .float => |ptr| @intFromPtr(ptr),
    };
}

fn toggleFocus(id: []const u8, _: *Vapor.Event) void {
    if (focus_states == null) return;
    // We only track the currently focused item, so we can just put it
    // If you want to support multi-focus, use get/put logic
    focus_states.?.put(id, true) catch unreachable;
}

/// Format credit card: "1234567890123456" -> "1234 5678 9012 3456"
pub fn formatCreditCard(input: []const u8, buf: []u8) []u8 {
    var digits: [16]u8 = undefined;
    var digit_count: usize = 0;

    // Extract only digits (max 16)
    for (input) |c| {
        if (c >= '0' and c <= '9') {
            if (digit_count < 16) {
                digits[digit_count] = c;
                digit_count += 1;
            }
        }
    }

    // Format with spaces every 4 digits
    var out_idx: usize = 0;
    for (digits[0..digit_count], 0..) |c, i| {
        if (i > 0 and i % 4 == 0) {
            buf[out_idx] = ' ';
            out_idx += 1;
        }
        buf[out_idx] = c;
        out_idx += 1;
    }

    return buf[0..out_idx];
}

pub fn creditCardCallback(callback: Callback, evt: *Vapor.Event) void {
    const credit_card_buf = callback.value.credit_card;
    credit_card_buf.* = evt.text();
    const text = evt.text();
    if (text.len == 0) return;
    if (text.len > 16) return;
    var buf: [32]u8 = undefined;
    const formatted = formatCreditCard(evt.text(), buf[0..]);
    credit_card_buf.* = Vapor.fmtln("{s}", .{formatted});
}

pub fn formatPhone(input: []const u8, buf: []u8) []u8 {
    var digits: [10]u8 = undefined;
    var digit_count: usize = 0;

    // Extract only digits (max 10)
    for (input) |c| {
        if (c >= '0' and c <= '9') {
            if (digit_count < 10) {
                digits[digit_count] = c;
                digit_count += 1;
            }
        }
    }

    var out_idx: usize = 0;

    if (digit_count >= 1) {
        buf[out_idx] = '(';
        out_idx += 1;
    }

    // First 3 digits
    for (digits[0..@min(digit_count, 3)]) |c| {
        buf[out_idx] = c;
        out_idx += 1;
    }

    if (digit_count >= 3) {
        buf[out_idx] = ')';
        out_idx += 1;
        buf[out_idx] = ' ';
        out_idx += 1;
    }

    // Next 3 digits
    if (digit_count > 3) {
        for (digits[3..@min(digit_count, 6)]) |c| {
            buf[out_idx] = c;
            out_idx += 1;
        }
    }

    if (digit_count >= 6) {
        buf[out_idx] = '-';
        out_idx += 1;
    }

    // Last 4 digits
    if (digit_count > 6) {
        for (digits[6..digit_count]) |c| {
            buf[out_idx] = c;
            out_idx += 1;
        }
    }

    return buf[0..out_idx];
}

fn telephoneCallback(callback: Callback, evt: *Vapor.Event) void {
    const telephone_buf = callback.value.telephone;
    telephone_buf.* = evt.text();
    const text = evt.text();
    if (text.len == 0) return;
    if (text.len > 10) return;
    var buf: [32]u8 = undefined;
    const formatted = formatPhone(evt.text(), buf[0..]);
    telephone_buf.* = Vapor.fmtln("{s}", .{formatted});
    if (callback.on_change) |on_change| {
        on_change(evt);
    }
}

fn stringCallback(callback: Callback, evt: *Vapor.Event) void {
    const string_buf = callback.value.string;
    const text = evt.text();
    string_buf.* = text;

    if (callback.on_change) |on_change| {
        on_change(evt);
    }
}

fn stringEnterCallback(callback: Callback, evt: *Vapor.Event) void {
    const key = evt.key();
    if (std.mem.eql(u8, key, "Enter")) {
        evt.preventDefault();
        evt.stopPropagation();
        if (callback.on_enter) |on_enter| {
            on_enter(evt);
        }
    }
}

fn passwordCallback(callback: Callback, evt: *Vapor.Event) void {
    const password_buf = callback.value.password;
    const text = evt.text();
    password_buf.* = text;

    if (callback.on_change) |on_change| {
        on_change(evt);
    }
}

fn emailCallback(callback: Callback, evt: *Vapor.Event) void {
    const email_buf = callback.value.email;
    const text = evt.text();
    email_buf.* = text;

    if (callback.on_change) |on_change| {
        on_change(evt);
    }
}

fn numberCallback(callback: Callback, evt: *Vapor.Event) void {
    const number_buf = callback.value.number;
    const number = evt.number() catch 0;
    number_buf.* = number;

    if (callback.on_change) |on_change| {
        on_change(evt);
    }
}

fn floatCallback(callback: Callback, evt: *Vapor.Event) void {
    const float_buf = callback.value.float;
    const float = evt.float() catch 0;
    float_buf.* = float;

    if (callback.on_change) |on_change| {
        on_change(evt);
    }
}

const Field = @This();
label: ?[]const u8 = null,
field_name: []const u8 = "",
type: FieldType = .string,
trans_label: bool = false,
/// Field must be a stable pointer, do not use a pointer within a render function, this is considered unsafe undefined behavior.
value: ?FieldValue = null,
config: Vapor.Types.TextFieldConfig = .{},
default_value: ?DefaultValue = null,
on_change: ?*const fn (evt: *Vapor.Event) void = null,
on_enter: ?*const fn (evt: *Vapor.Event) void = null,
id: ?[]const u8 = null,
placeholder: ?DefaultValue = null,
background: Vapor.Types.Background = .palette(.background),
_container: ?Vapor.Builder(.pure) = null,
is_focused: bool = false,

fn handleFocus(id: []const u8, _: *Vapor.Event) void {
    Vapor.print("Focus: {s}\n", .{id});
    if (focus_states != null) {
        // We only track the active focus.
        // Optional: You could clear other keys here if you want strictly one focus.
        focus_states.?.put(id, true) catch unreachable;
    }
}

fn handleBlur(id: []const u8, _: *Vapor.Event) void {
    Vapor.print("Blur: {s}\n", .{id});
    if (focus_states != null) {
        focus_states.?.put(id, false) catch unreachable;
    }
}

fn getFieldType(field_value: FieldType) Vapor.Types.InputTypes {
    return switch (field_value) {
        .string => .string,
        .number => .int,
        .password => .password,
        .email => .email,
        .credit_card => .string,
        .telephone => .string,
        .float => .float,
        else => .string,
    };
}

fn getFieldTypeFromValue(field_value: FieldValue) FieldType {
    return switch (field_value) {
        .email => .email,
        .string => .string,
        .telephone => .telephone,
        .number => .number,
        .password => .password,
        .credit_card => .credit_card,
        .float => .float,
        else => .string,
    };
}

fn ErasedField(field: Field, field_id: []const u8) Vapor.TextFieldBuilder(.pure) {
    const field_type = getFieldType(field.type);

    return TextField(field_type)
        .id(field_id)
        .fieldName(field.field_name)
        .height(.percent(100))
        .padding(.horizontal(12))
        // .padding(.tblr(8, 8, 12, 12))
        .outline(.none)
        .background(.transparent)
        .fontFamily(default_font_family)
        .font(14, 300, .palette(.text_color));
}

fn destroy(stable_id: []const u8) void {
    _ = focus_states.?.fetchRemove(stable_id); // Don't early return

    const field_value = field_values.fetchRemove(stable_id) orelse return;
    Vapor.arena(.persist).free(field_value.key);

    // Destroy the inner allocated pointer
    switch (field_value.value) {
        .string => |ptr| Vapor.arena(.persist).destroy(ptr),
        .password => |ptr| Vapor.arena(.persist).destroy(ptr),
        .email => |ptr| Vapor.arena(.persist).destroy(ptr),
        .credit_card => |ptr| Vapor.arena(.persist).destroy(ptr),
        .telephone => |ptr| Vapor.arena(.persist).destroy(ptr),
        .number => |ptr| Vapor.arena(.persist).destroy(ptr),
        .bool => |ptr| Vapor.arena(.persist).destroy(ptr),
        .float => |ptr| Vapor.arena(.persist).destroy(ptr),
    }
}

fn checkLength(value: FieldValue) bool {
    switch (value) {
        .string, .telephone, .credit_card, .email, .password => |v| {
            if (v.*.len > 0) {
                return true;
            }
        },
        .number => |v| {
            if (v.* > 0) {
                return true;
            }
        },
        .float => |v| {
            if (v.* > 0) {
                return true;
            }
        },
        else => {},
    }
    return false;
}

fn Container() Vapor.Builder(.pure) {
    return Stack()
        .width(.percent(100));
}

pub const DefaultValue = union(enum) {
    string: []const u8,
    number: i32,
    bool: bool,
    float: f32,
};

fn insertValue(stable_id: []const u8, value: FieldValue) void {
    _ = field_values.get(stable_id) orelse {
        const stable_id_alloc = Vapor.arena(.persist).alloc(u8, stable_id.len) catch unreachable;
        @memcpy(stable_id_alloc, stable_id);
        field_values.put(stable_id_alloc, value) catch unreachable;
        focus_states.?.put(stable_id_alloc, false) catch unreachable;
    };
}

fn createValue(stable_id: []const u8, field_type: FieldType, default_value: ?DefaultValue) FieldValue {
    Vapor.print("createValue {s}", .{stable_id});
    return field_values.get(stable_id) orelse {
        const stable_id_alloc = Vapor.arena(.persist).alloc(u8, stable_id.len) catch unreachable;
        @memcpy(stable_id_alloc, stable_id);
        return switch (field_type) {
            .string, .cvv, .expiry => {
                const string_field = Vapor.arena(.persist).create([]const u8) catch unreachable;
                string_field.* = if (default_value) |default| default.string else "";
                const value = FieldValue{ .string = string_field };
                field_values.put(stable_id_alloc, value) catch unreachable;
                focus_states.?.put(stable_id_alloc, false) catch unreachable;
                return value;
            },
            .credit_card => {
                const string_field = Vapor.arena(.persist).create([]const u8) catch unreachable;
                var formatted: []const u8 = "";
                if (default_value) |default| {
                    formatted = default.string;
                    var buf: [32]u8 = undefined;
                    formatted = std.fmt.allocPrint(Vapor.arena(.frame), "{s}", .{formatCreditCard(default.string, buf[0..])}) catch unreachable;
                }
                string_field.* = formatted;
                const value = FieldValue{ .credit_card = string_field };
                field_values.put(stable_id_alloc, value) catch unreachable;
                focus_states.?.put(stable_id_alloc, false) catch unreachable;
                return value;
            },
            .password => {
                const string_field = Vapor.arena(.persist).create([]const u8) catch unreachable;
                string_field.* = if (default_value) |default| default.string else "";
                const value = FieldValue{ .password = string_field };
                field_values.put(stable_id_alloc, value) catch unreachable;
                focus_states.?.put(stable_id_alloc, false) catch unreachable;
                return value;
            },
            .email => {
                const string_field = Vapor.arena(.persist).create([]const u8) catch unreachable;
                string_field.* = if (default_value) |default| default.string else "";
                const value = FieldValue{ .email = string_field };
                field_values.put(stable_id_alloc, value) catch unreachable;
                focus_states.?.put(stable_id_alloc, false) catch unreachable;
                return value;
            },
            .number => {
                const int_field = Vapor.arena(.persist).create(i32) catch unreachable;
                int_field.* = if (default_value) |default| default.number else 0;
                const value = FieldValue{ .number = int_field };
                field_values.put(stable_id_alloc, value) catch unreachable;
                focus_states.?.put(stable_id_alloc, false) catch unreachable;
                return value;
            },
            .float => {
                const float_field = Vapor.arena(.persist).create(f32) catch unreachable;
                float_field.* = if (default_value) |default| default.float else 0;
                const value = FieldValue{ .float = float_field };
                field_values.put(stable_id_alloc, value) catch unreachable;
                focus_states.?.put(stable_id_alloc, false) catch unreachable;
                return value;
            },
            .telephone => {
                const telephone_field = Vapor.arena(.persist).create([]const u8) catch unreachable;
                telephone_field.* = if (default_value) |default| default.string else "";
                const value = FieldValue{ .telephone = telephone_field };
                field_values.put(stable_id_alloc, value) catch unreachable;
                focus_states.?.put(stable_id_alloc, false) catch unreachable;
                return value;
            },
        };
    };
}

fn renderLabel(
    label: []const u8,
    label_left: f32,
    trans: f32,
    scale: f32,
    z_index: f32,
    text_color: Vapor.Types.Color,
    background: Vapor.Types.Background,
) Vapor.BuilderClose(.pure) {
    return Label(label)
        .background(background)
        .pos(.{ .left = .px(label_left), .type = .absolute, .top = if (trans == -50) .percent(50) else .percent(0) })
        .padding(.horizontal(2))
        // .height(.percent(100))
        .transition(.{
            .properties = &.{ .transform, .left, .top },
            .duration = 100,
            .timing = .easeInOut,
        })
        .font(14, 300, text_color)
        .inlineStyle("transform: translateY({d}%) scale({d}); z-index: {d}; text-align: center;", .{ -50, scale, z_index })
        .fontFamily(default_font_family);
}

const Callback = struct {
    value: FieldValue,
    on_change: ?*const fn (evt: *Vapor.Event) void = null,
    on_enter: ?*const fn (evt: *Vapor.Event) void = null,
};

pub fn render(field: Field) void {
    const container = Container();
    const stable_id = container.getUUID();
    var value: FieldValue = undefined;
    if (field.value) |v| {
        insertValue(stable_id, v);
        value = v;
    } else {
        value = createValue(stable_id, field.type, field.default_value);
    }
    var field_type = field.type;
    if (field.value) |v| {
        field_type = getFieldTypeFromValue(v);
    }

    // 1. Check focus state
    const is_focused = if (focus_states) |fs| fs.get(stable_id) orelse blk: {
        std.log.info("stable_id {s} doesnt exist", .{stable_id});
        break :blk false;
    } else blk: {
        break :blk false;
    };

    const background = field.background;
    // 2. Animation / Style variables
    // const trans: f32 = if (is_focused or field.trans_label or checkLength(value) or field.placeholder != null) -50 else 50;
    const trans: f32 = if (is_focused or field.trans_label or checkLength(value) or field.placeholder != null) -150 else -50;
    const scale: f32 = if (is_focused or field.trans_label or checkLength(value) or field.placeholder != null) 0.9 else 1;
    // Adjust label left position if there is a left icon so it doesn't clash
    const label_left: f32 = if (is_focused or field.trans_label) 12 + 12 else 12;

    const z_index: f32 = if (is_focused) 10 else 0;
    const text_color: Vapor.Types.Color = if (is_focused) .palette(.tint) else .transparentizeHex(.palette(.text_color), 0.5);

    // 3. Calculate Input Padding based on icons
    // We reserve ~40px of space if an icon is present

    container
        .height(.px(36))
        .spacing(8)
        .pos(.relative)
        .border(.round(if (is_focused) .palette(.tint) else .palette(.border_color_light), .all(12)))
        .background(background)
        .shadow(.{
            .color = if (is_focused) .transparentizeHex(.palette(.tint), 0.2) else .transparent,
            .spread = 3,
        })
        .children({
        // Vapor.Static.HooksCtx(.destroy, destroy, .{stable_id})({
        const field_id = Vapor.fmtln("{s}_{s}", .{ @tagName(field_type), stable_id });
        var label_component: ?Vapor.BuilderClose(.pure) = null;
        if (field.label) |label| {
            label_component = renderLabel(label, label_left, trans, scale, z_index, text_color, background);
            label_component.?.fieldName(field_id).end();
        }

        const text_field: Vapor.TextFieldBuilder(.pure) = ErasedField(field, field_id);

        // --- 4. RENDER INPUT FIELD ---
        switch (field_type) {
            .string => {
                text_field
                    // OVERRIDE Padding here to account for icons
                    .pos(.absolute)
                    .onEventCtx(.focus, handleFocus, stable_id)
                    .onEventCtx(.blur, handleBlur, stable_id)
                    .onEventCtx(.input, stringCallback, Callback{ .value = value, .on_change = field.on_change })
                    .onEventCtx(.keydown, stringEnterCallback, Callback{ .value = value, .on_enter = field.on_enter })
                    .border(.none)
                    .width(.percent(100))
                    .val(value.string)
                    .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                    .end();
            },
            .telephone => {
                text_field
                    // OVERRIDE Padding here to account for icons
                    .pos(.absolute)
                    .onEventCtx(.focus, handleFocus, stable_id)
                    .onEventCtx(.blur, handleBlur, stable_id)
                    .border(.none)
                    .width(.percent(100))
                    .onEventCtx(.input, telephoneCallback, Callback{ .value = value, .on_change = field.on_change })
                    .val(value.telephone)
                    .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                    .end();
            },
            .credit_card => {
                text_field
                    // OVERRIDE Padding here to account for icons
                    .pos(.absolute)
                    .onEventCtx(.focus, handleFocus, stable_id)
                    .onEventCtx(.blur, handleBlur, stable_id)
                    .border(.none)
                    .width(.percent(100))
                    .onEventCtx(.input, creditCardCallback, Callback{ .value = value, .on_change = field.on_change })
                    .val(value.credit_card)
                    .config(.{ .max = 19 })
                    .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                    .end();
            },
            .email => {
                text_field
                    // OVERRIDE Padding here to account for icons
                    .pos(.absolute)
                    .onEventCtx(.focus, handleFocus, stable_id)
                    .onEventCtx(.blur, handleBlur, stable_id)
                    .width(.percent(100))
                    .onEventCtx(.input, emailCallback, Callback{ .value = value, .on_change = field.on_change })
                    .border(.none)
                    .val(value.email)
                    .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                    .end();
            },
            .password => {
                text_field
                    // OVERRIDE Padding here to account for icons
                    .pos(.absolute)
                    .onEventCtx(.focus, handleFocus, stable_id)
                    .onEventCtx(.blur, handleBlur, stable_id)
                    .width(.percent(100))
                    .onEventCtx(.input, passwordCallback, Callback{ .value = value, .on_change = field.on_change })
                    .border(.none)
                    .val(value.password)
                    .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                    .end();
            },
            .number => {
                text_field
                    // OVERRIDE Padding here to account for icons
                    .pos(.absolute)
                    .onEventCtx(.focus, handleFocus, stable_id)
                    .onEventCtx(.blur, handleBlur, stable_id)
                    .border(.none)
                    .width(.percent(100))
                    .onEventCtx(.input, numberCallback, Callback{ .value = value, .on_change = field.on_change })
                    .border(.none)
                    .config(field.config)
                    .placeholder(if (field.placeholder) |placeholder| placeholder.number else 0)
                    .val(value.number)
                    .end();
            },
            .float => {
                text_field
                    // OVERRIDE Padding here to account for icons
                    .pos(.absolute)
                    .onEventCtx(.focus, handleFocus, stable_id)
                    .onEventCtx(.blur, handleBlur, stable_id)
                    .border(.none)
                    .width(.percent(100))
                    .onEventCtx(.input, floatCallback, Callback{ .value = value, .on_change = field.on_change })
                    .border(.none)
                    .config(field.config)
                    .placeholder(if (field.placeholder) |placeholder| placeholder.float else 0)
                    .val(value.float)
                    .end();
            },
            else => {},
        }
        // });
    });
}

pub fn create(field: Field) *Field {
    const container = Container();
    const stable_id = container.getUUID();
    const alloc_field = fields.get(stable_id) orelse blk: {
        const new_field = Vapor.arena(.persist).create(Field) catch unreachable;
        new_field.* = field;
        fields.put(stable_id, new_field) catch unreachable;
        break :blk new_field;
    };
    alloc_field._container = container;
    return alloc_field;
}

pub fn Component(field: *Field, component: *const fn (*Field) Vapor.Builder(.pure)) void {
    const container = field._container orelse return;
    const stable_id = container.getUUID();
    var value: FieldValue = undefined;
    if (field.value) |v| {
        insertValue(stable_id, v);
        value = v;
    } else {
        value = createValue(stable_id, field.type, field.default_value);
    }
    var field_type = field.type;
    if (field.value) |v| {
        field_type = getFieldTypeFromValue(v);
    }

    // 1. Check focus state
    const is_focused = if (focus_states) |fs| fs.get(stable_id) orelse blk: {
        std.log.info("stable_id {s} doesnt exist", .{stable_id});
        break :blk false;
    } else blk: {
        break :blk false;
    };

    const background = field.background;
    // 2. Animation / Style variables
    const trans: f32 = if (is_focused or field.trans_label or checkLength(value) or field.placeholder != null) -150 else -50;
    const scale: f32 = if (is_focused or field.trans_label or checkLength(value) or field.placeholder != null) 0.9 else 1;
    // Adjust label left position if there is a left icon so it doesn't clash
    const label_left: f32 = if (is_focused or field.trans_label) 12 + 12 else 12;

    const z_index: f32 = if (is_focused) 10 else 0;
    const text_color: Vapor.Types.Color = if (is_focused) .palette(.tint) else .transparentizeHex(.palette(.text_color), 0.5);

    field.is_focused = is_focused;

    // 3. Calculate Input Padding based on icons
    // We reserve ~40px of space if an icon is present
    container
        .layout(.left_center)
        .width(.percent(100))
        .children({
        component(field).children({
            const field_id = Vapor.fmtln("{s}_{s}", .{ @tagName(field_type), stable_id });
            var label_component: ?Vapor.BuilderClose(.pure) = null;
            if (field.label) |label| {
                label_component = renderLabel(label, label_left, trans, scale, z_index, text_color, background);
                label_component.?.fieldName(field_id).end();
            }

            const text_field: Vapor.TextFieldBuilder(.pure) = ErasedField(field.*, field_id);

            // --- 4. RENDER INPUT FIELD ---
            switch (field_type) {
                .string => {
                    text_field
                        // OVERRIDE Padding here to account for icons
                        .pos(.absolute)
                        .onEventCtx(.focus, handleFocus, stable_id)
                        .onEventCtx(.blur, handleBlur, stable_id)
                        .onEventCtx(.input, stringCallback, Callback{ .value = value, .on_change = field.on_change })
                        .onEventCtx(.keydown, stringEnterCallback, Callback{ .value = value, .on_enter = field.on_enter })
                        .border(.none)
                        .width(.percent(100))
                        .val(value.string)
                        .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                        .end();
                },
                .telephone => {
                    text_field
                        // OVERRIDE Padding here to account for icons
                        .pos(.absolute)
                        .onEventCtx(.focus, handleFocus, stable_id)
                        .onEventCtx(.blur, handleBlur, stable_id)
                        .border(.none)
                        .width(.percent(100))
                        .onEventCtx(.input, telephoneCallback, Callback{ .value = value, .on_change = field.on_change })
                        .val(value.telephone)
                        .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                        .end();
                },
                .credit_card => {
                    text_field
                        // OVERRIDE Padding here to account for icons
                        .pos(.absolute)
                        .onEventCtx(.focus, handleFocus, stable_id)
                        .onEventCtx(.blur, handleBlur, stable_id)
                        .border(.none)
                        .width(.percent(100))
                        .onEventCtx(.input, creditCardCallback, Callback{ .value = value, .on_change = field.on_change })
                        .val(value.credit_card)
                        .config(.{ .max = 19 })
                        .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                        .end();
                },
                .email => {
                    text_field
                        // OVERRIDE Padding here to account for icons
                        .pos(.absolute)
                        .onEventCtx(.focus, handleFocus, stable_id)
                        .onEventCtx(.blur, handleBlur, stable_id)
                        .width(.percent(100))
                        .onEventCtx(.input, emailCallback, Callback{ .value = value, .on_change = field.on_change })
                        .border(.none)
                        .val(value.email)
                        .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                        .end();
                },
                .password => {
                    text_field
                        // OVERRIDE Padding here to account for icons
                        .pos(.absolute)
                        .onEventCtx(.focus, handleFocus, stable_id)
                        .onEventCtx(.blur, handleBlur, stable_id)
                        .width(.percent(100))
                        .onEventCtx(.input, passwordCallback, Callback{ .value = value, .on_change = field.on_change })
                        .border(.none)
                        .val(value.password)
                        .placeholder(if (field.placeholder) |placeholder| placeholder.string else "")
                        .end();
                },
                .number => {
                    text_field
                        // OVERRIDE Padding here to account for icons
                        .pos(.absolute)
                        .onEventCtx(.focus, handleFocus, stable_id)
                        .onEventCtx(.blur, handleBlur, stable_id)
                        .border(.none)
                        .width(.percent(100))
                        .onEventCtx(.input, numberCallback, Callback{ .value = value, .on_change = field.on_change })
                        .border(.none)
                        .config(field.config)
                        .placeholder(if (field.placeholder) |placeholder| placeholder.number else 0)
                        .val(value.number)
                        .end();
                },
                .float => {
                    text_field
                        // OVERRIDE Padding here to account for icons
                        .pos(.absolute)
                        .onEventCtx(.focus, handleFocus, stable_id)
                        .onEventCtx(.blur, handleBlur, stable_id)
                        .border(.none)
                        .width(.percent(100))
                        .onEventCtx(.input, floatCallback, Callback{ .value = value, .on_change = field.on_change })
                        .border(.none)
                        .config(field.config)
                        .placeholder(if (field.placeholder) |placeholder| placeholder.float else 0)
                        .val(value.float)
                        .end();
                },
                else => {},
            }
        });
    });
}
