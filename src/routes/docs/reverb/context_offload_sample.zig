var loom_engine = tether.Server.loom;
var atomic_pool = undefined;
fn init() void {
    loom_engine.scheduler.initPool(.{
        .allocator = allocator,
    });
    atomic_pool = loom_engine.scheduler.atm_pool;
}

pub fn getWithOffload(ctx: *Context) !void {
    const key = ctx.http_payload;
    // We create a buffer, and then copy the key into it.
    var buf: [512]u8 = undefined;
    const copied_key = @memcpy(&buf, key);

    // We generate a job, and then dispatch it.
    const job = atomic_pool.generateJob(logKey, .{copied_key});
    //This will dispatch a job and the thread pool will handle it.
    atomic_pool.dispatchJob(job);

    const response = db.default_cache.get(key) catch |err| {
        ctx.ERROR(404, "VALUE NOT FOUND");
        return err;
    };
    ctx.STRING(response) catch |err| {
        ctx.ERROR(404, "SERVER ERROR");
        return err;
    };
}
