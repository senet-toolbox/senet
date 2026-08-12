fn selectRow(box: *GridRow) void {
    if (box.clicked or winner != null) return; // ignore if game over

    box.clicked = true;
    box.player  = current_player;

    if (checkWin()) |p| { // 🚧
        winner = p;
    } else {
        // Toggle turn only if no winner yet
        current_player = switch (current_player) { .x => .o, .o => .x };
    }

    Fabric.cycle(); 
}
