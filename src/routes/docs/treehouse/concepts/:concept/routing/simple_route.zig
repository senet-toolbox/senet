fn ping(ctx: *Context) !void {
    try ctx.STRING("Pong");
}

const User = struct {
    name: []const u8,
    age: u32,
};

fn postUsers(ctx: *Context) !void {
    var users: []User = undefined;
    ctx.glue([]User, &users) catch |err| {
        try ctx.STRING("Could not glue to user slice");
        return err;
    };
    db.default_cache.lpushmanyStructs("users", users) catch |err| {
        try ctx.STRING("Could not push users slice to treehouse");
        return err;
    };
}
