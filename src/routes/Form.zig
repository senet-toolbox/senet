const LoginForm = struct {
    email: []const u8,
    password: []const u8,
    confirm_password: []const u8,
    const __validations = .{
        .email = Validation{ .field_type = .email },
        .password = Validation{ .field_type = .password },
        .confirm_password = Validation{ .field_type = .password, .match = true, .target_field = "password" },
    };
};

var login_form: Form(LoginForm) = undefined;

pub fn init() void {
    // compile the struct into a UI form
    login_form.compile();
}

fn LoginComponent() void {
    // render the form
    login_form.render();
}
