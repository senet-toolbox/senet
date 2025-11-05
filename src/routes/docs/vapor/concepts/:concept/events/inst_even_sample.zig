const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Element = Fabric.Element;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Binded = Fabric.Binded;

var email_input_element: Element = Element{};

// Instance struct of Form;
const Form = @This();
name: []const u8,
email: []const u8,

fn onWrite(form: *Form, evt: *Fabric.Event) void {
    const email = evt.text();
    form.email = email;
}

fn mount(form: *Form) void {
    // here we attache a listener to the element itself
    email_input_element.addInstListener(.input, form, onWrite);
}

pub fn render(form: *Form) void {
    // Hooks calls to mount when all its children have been added to screen.
    Static.CtxHooks(.mounted, .{form}, .{})({
        Binded.Input(&email_input_element, .{
            .string = .{ .default = "Email" },
        }, Style{
            .outline = .none,
            .border_color = .hex("#000000"),
            .padding = .all(4),
        });
    });
}
