const TicTacToe = @import("routes/tictac/Page.zig"); // 👈 NEW;
//...
export fn instantiate(window_width: i32, window_height: i32) void {
    fb.init(.{
        .screen_width  = window_width,
        .screen_height = window_height,
        .allocator     = &allocator,
    });

    RootPage.init();
    TicTacToe.init(); // 👈 NEW
}
