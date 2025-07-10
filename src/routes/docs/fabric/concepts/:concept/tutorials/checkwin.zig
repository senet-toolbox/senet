// All 8 possible winning line combinations (rows, columns, diagonals)
const win_patterns = [8][3]usize{
    .{ 0, 1, 2 }, // top row
    .{ 3, 4, 5 }, // middle row
    .{ 6, 7, 8 }, // bottom row
    .{ 0, 3, 6 }, // left column
    .{ 1, 4, 7 }, // middle column
    .{ 2, 5, 8 }, // right column
    .{ 0, 4, 8 }, // main diagonal
    .{ 2, 4, 6 }, // anti‑diagonal
};

/// Returns the winning player, or `null` if no one has yet won.
fn checkWin() ?Player {
    for (win_patterns) |pattern| {
        const a = &grid_boxes[pattern[0]];
        const b = &grid_boxes[pattern[1]];
        const c = &grid_boxes[pattern[2]];

        if (a.clicked and b.clicked and c.clicked and a.player == b.player and a.player == c.player) {
            return a.player;
        }
    }
    return null;
}
