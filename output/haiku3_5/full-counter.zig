const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const Stack = Vapor.Stack;
const Center = Vapor.Center;

// State declared OUTSIDE render function
var count: i32 = 0;

// Increment handler
fn increment() void {
    count += 1;
}

// Decrement handler
fn decrement() void {
    count -= 1;
}

// Counter style
const counter_style = Vapor.Style{
    .layout = .center,
    .padding = .all(24),
    .visual = .{
        .background = .hex("#f7fafc"),
        .border = .round(.hex("#e2e8f0"), .all(12)),
        .shadow = .card(.hex("#00000011")),
    },
};

const button_style = Vapor.Style{
    .padding = .tblr(10, 10, 16, 16),
    .margin = .horizontal(8),
    .visual = .{
        .background = .hex("#4299e1"),
        .text_color = .white,
        .font_weight = 600,
        .border = .round(.transparent, .all(8)),
    },
    .interactive = .hover_scale(),
};

// Render function
pub fn render() void {
    Center().height(.percent(100)).children({
        Box().style(&counter_style)({
            // Title
            Text("Simple Counter")
                .font(24, 700, .hex("#2d3748"))
                .margin(.b(20))
                .end();

            // Counter display
            Text(count)
                .font(48, 700, .hex("#4299e1"))
                .margin(.vertical(20))
                .end();

            // Button row
            Box().layout(.center).children({
                // Decrement button
                Button(decrement).style(&button_style)({
                    Text("-").end();
                });

                // Increment button
                Button(increment).style(&button_style)({
                    Text("+").end();
                });
            });
        });
    });
}

// Initialization
pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}
