const LoginForm = struct {
    email: []const u8 = "",
    password: []const u8 = "",
    const __validations = .{
        .email = Validation{ .field_type = .email },
        .password = Validation{ .field_type = .password },
    };
};

var vaporizer: Vaporizer = .{};
var login_form: vaporizer.Form(LoginForm) = .{};

pub fn init() void {
    // compile the struct into a UI form
    login_form.compile();
}

fn LoginComponent() void {
    login_form.render();
}
