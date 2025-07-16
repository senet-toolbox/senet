const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Kit = Fabric.Kit;

const Product = struct {
    id: []const u8,
    name: []const u8,
    url: []const u8,
    image: []const u8,
    price: u32,
    cart_quantity: u32,
};

var is_loading: Signal(bool) = undefined;
var cart_count: u32 = 0;
pub fn init() void {
    is_loading.init(false);
}

fn handleAddToCart(product: Product) void {
    is_loading.toggle();
    const json = std.json.stringify(product, .{ .whitespace = .{}, .escape_unicode = false });
    // No function coloring in Fabric
    Kit.fetch("/app/addtocart", addToCart, .{ .method = .POST, .body = json });
}

fn addToCart(resp: Kit.Response) void {
    if (resp.code != 200) {
        return;
    }
    cart_count += 1;
    is_loading.toggle();
}

pub fn render(product: Product) void {
    Static.Box(.{
        .padding = .all(4),
        .shadow = .{},
        .hover = .{
            .shadow = .{
                .spread = 10,
            },
        },
    })({
        Static.Image(product.image, .{
            .width = .px(200),
            .height = .px(200),
            .margin = .{ .bottom = 8 },
            .padding = .all(4),
            .border_radius = .all(8),
        });
        Static.Link(.{ .url = Fabric.fmtln("/{s}/{s}", .{ product.url, product.id }), .aria_label = product.name }, .{})({
            Static.Text(product.name, .{});
        });

        Static.Box(.{
            .child_alignment = .x_between_center,
        })({
            Static.Text(product.price, .{});
            if (cart_count > 0) {
                Pure.AllocText("In Cart {}", .{cart_count}, .{});
            }
        });

        Static.Button(.{ .onPress = handleAddToCart }, .{})({
            Static.Text(if (is_loading) "Adding..." else "Add to Cart", .{});
        });
    });
}
