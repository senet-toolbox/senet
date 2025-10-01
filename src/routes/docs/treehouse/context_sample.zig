pub fn get(ctx: *Context) !void {
    const key = ctx.http_payload;
    const response = db.default_cache.get(key) catch |err| {
        ctx.ERROR(404, "VALUE NOT FOUND");
        return err;
    };
    ctx.STRING(response) catch |err| {
        ctx.ERROR(404, "SERVER ERROR");
        return err;
    };
}
