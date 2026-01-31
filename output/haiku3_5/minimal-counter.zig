const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.ButtonCtx;
const Stack = Vapor.Stack;
const Center = Vapor.Center;

// State OUTSIDE render functions
var count: i32 = 0;

pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}

// Increment handler
fn increment() void {
    count += 1;
}

// Decrement handler
fn decrement() void {
    count -= 1;
}

fn render() void {
    Center()
        .layout(.center)
        .spacing(16)
        .padding(.all(20))
        .children({
            // Display the current count
            Text(@tagName(count))
                .font(24, 600, .hex("#333333"))
                .end();

            // Stack for buttons
            Stack(.horizontal)
                .spacing(16)
                .children({
                    // Decrement button
                    Button(decrement)
                        .background(.hex("#ff6b6b"))
                        .children({
                            Text("-")
                                .font(20, 600, .hex("#ffffff"))
                                .end();
                        });

                    // Increment button  
                    Button(increment)
                        .background(.hex("#4ecdc4"))
                        .children({
                            Text("+")
                                .font(20, 600, .hex("#ffffff"))
                                .end();
                        });
                });
        });
}
