const std = @import("std");
const Canopy = @import("canopy");

const User = struct {
    name: []const u8,
};

// Get a user by ID
fn getUser(ctx: *Context) !void {
    const id = try ctx.param("id");
    const user = try Canopy.db.get(User, id);
    try ctx.JSON(user);
}

// Create a new user
fn createUser(ctx: *Context) !void {
    var user: User = undefined;
    try ctx.bind(User, &user);
    try Canopy.db.insert(user);
    try ctx.STRING("User created!");
}

// Middleware
fn logger(next: Next, ctx: *Context) !void {
    const start = std.time.milliTimestamp();
    defer std.debug.print("Request took {d}ms\n", .{std.time.milliTimestamp() - start});

    try next(ctx);
}

pub fn main() !void {
    // Initialize the server
    // ...

    Canopy.db.connect() catch |err| {
        std.debug.print("Failed to connect to database: {s}\n", .{err});
        return;
    };

    try server.get("/:id", getUser, &.{logger});
    try server.post("/", createUser, &.{logger});
}
