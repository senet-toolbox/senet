const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;

// ============================================
// STATE (outside render!)
// ============================================
var email: []const u8 = "";
var password: []const u8 = "";
var error_msg: ?[]const u8 = null;

// ============================================
// STYLES
// ============================================
const container_style = Vapor.Style{
    .size = .{ .width = .px(350) },
    .padding = .all(24),
    .visual = .{
        .background = .white,
        .border = .round(.hex("#e2e8f0"), .all(12)),
        .shadow = .card(.hex("#00000011")),
    },
};

const input_style = Vapor.Style{
    .padding = .all(12),
    .margin = .b(16),
    .visual = .{
        .border = .round(.hex("#e2e8f0"), .all(8)),
    },
};

const error_style = Vapor.Style{
    .margin = .b(16),
    .visual = .{
        .text_color = .hex("#e53e3e"),
        .font_size = 14,
    },
};

const submit_btn_style = Vapor.Style{
    .padding = .all(12),
    .visual = .{
        .background = .hex("#4299e1"),
        .text_color = .white,
        .border = .round(.transparent, .all(8)),
    },
    .interactive = .hover_scale(),
};

// ============================================
// ACTIONS
// ============================================
fn validateAndSubmit() void {
    // Reset previous error
    error_msg = null;

    // Validate email
    if (email.len == 0) {
        error_msg = "Email is required";
        return;
    }
    
    if (std.mem.indexOf(u8, email, "@") == null) {
        error_msg = "Invalid email address";
        return;
    }

    // If we get here, validation passed
    // In a real app, you'd do authentication here
    std.debug.print("Login attempt: {s}\n", .{email});
    
    // Clear sensitive data after submission
    email = "";
    password = "";
}

fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        validateAndSubmit();
    }
}

// ============================================
// INITIALIZATION
// ============================================
pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}

// ============================================
// RENDER
// ============================================
fn render() void {
    Center().height(.percent(100)).background(.hex("#edf2f7")).children({
        Box().style(&container_style)({
            // Title
            Text("Login")
                .font(24, 700, .hex("#2d3748"))
                .margin(.b(20))
                .end();

            // Error Message (if any)
            if (error_msg) |err| {
                Text(err).style(&error_style).end();
            }

            // Email Input
            TextField(.string)
                .bind(&email)
                .placeholder("Email")
                .style(&input_style)
                .onEvent(.keydown, handleKeyDown)
                .end();

            // Password Input
            TextField(.password)
                .bind(&password)
                .placeholder("Password")
                .style(&input_style)
                .onEvent(.keydown, handleKeyDown)
                .end();

            // Submit Button
            Button(validateAndSubmit)
                .style(&submit_btn_style)
                .width(.percent(100))
                .children({
                    Text("Log In").end();
                });
        });
    });
}
