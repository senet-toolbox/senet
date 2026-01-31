const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;

// State variables
var email: []const u8 = "";
var password: []const u8 = "";
var errorMessage: []const u8 = "";

pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn isValidEmail(text: []const u8) bool {
    return text.len > 0 and std.mem.indexOf(u8, text, "@") != null;
}

fn handleSubmit() void {
    // Reset error message
    errorMessage = "";

    // Validate email
    if (!isValidEmail(email)) {
        errorMessage = Vapor.arena(.persist).dupe(u8, "Please enter a valid email") catch return;
        return;
    }

    // If validation passes, you would typically handle login here
    // For this example, we'll just clear the error
    errorMessage = "";
}

fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        handleSubmit();
    }
}

fn render() void {
    Center().children({
        Box()
            .layout(.column)
            .spacing(16)
            .padding(.all(20))
            .background(.hex("#ffffff"))
            .border(.round(.hex("#e2e8f0"), .all(8)))
            .children({
                // Email input
                Text("Email").end();
                TextField(.string)
                    .bind(&email)
                    .placeholder("Enter your email")
                    .onEvent(.keydown, handleKeyDown)
                    .end();

                // Password input
                Text("Password").end();
                TextField(.password)
                    .bind(&password)
                    .placeholder("Enter your password")
                    .onEvent(.keydown, handleKeyDown)
                    .end();

                // Submit button
                Button(handleSubmit)
                    .children({
                        Text("Submit").end();
                    })
                    .end();

                // Error message (conditionally rendered)
                if (errorMessage.len > 0) {
                    Text(errorMessage)
                        .style(&.{
                            .color(.hex("#ff0000")),
                            .font(14, 400)
                        })
                        .end();
                }
            })
            .end();
    });
}
