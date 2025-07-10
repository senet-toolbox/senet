if (winner) |winning_player| {
    switch (winning_player) {
        .x => {
            Static.Text("Player X Won!", .{
                .font_size = 24,
                .font_weight = 900,
                .text_color = .hex("#744DFF"),
                .margin = .{ .top = 32 },
            });
        },
        .o => {
            Static.Text("Player O Won!", .{
                .font_size = 24,
                .font_weight = 900,
                .text_color = .hex("#744DFF"),
                .margin = .{ .top = 32 },
            });
        },
    }
}
