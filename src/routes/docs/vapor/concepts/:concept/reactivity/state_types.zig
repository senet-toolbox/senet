const Vapor = @import("fabric");
const Pure = Vapor.Pure;
const Static = Vapor.Static;
const TextField = Static.TextField;

var text_field: Vapor.Binded = .{
    .text = "Inital Text",
};

pub fn render() void {
    TextField(.string)
        .bind(&text_field)
        .plain();

    Static.Text(text_field.text).plain(); // This will never update
    Pure.Text(text_field.text).plain(); // This will update
}
