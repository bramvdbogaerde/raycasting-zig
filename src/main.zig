const std = @import("std");
const sdl = @cImport(@cInclude("SDL2/SDL.h"));
const window = @import("window.zig");
const grid = @import("grid.zig");
const gamestate = @import("gamestate.zig");

// For convenience
const GameState = gamestate.GameState;
const Window = window.Window(gamestate.GameState);

fn handle_key(self: *window.KeyHandler(GameState), win: *Window, sym: i32) void {
    switch (sym) {
        'j' => {
            self.state.rotate((std.math.pi / 180.0) * 10);
        },
        'k' => {
            self.state.rotate_cw((std.math.pi / 180.0) * 10);
        },
        else => {},
    }
    draw_position(self.state, win);
}

// Draw the current angle as a line in the main window
fn draw_position(st: *GameState, win: *Window) void {
    const y: usize = @intFromFloat(100 + @sin(st.player_position.angle) * 50);
    const x: usize = @intFromFloat(100 + @cos(st.player_position.angle) * 50);

    win.draw_line(100, 100, x, y);
}

pub fn main() !void {
    // Setup the game window
    const game_window = window.Window(gamestate.GameState).create(400, 500).?;
    // Setup the game state
    const game_grid = grid.Grid.from_array(&grid.example, 100, 4, 5).?;
    _ = game_grid; // autofix
    const game_state = try gamestate.GameState.initial();
    var key_handler = window.KeyHandler(gamestate.GameState){ .handler = handle_key, .state = game_state };

    game_window.set_on_key(&key_handler);

    // Render the first version of the grid
    // game_grid.render(game_window);
    // Send it to the GPU!
    // game_window.commit();

    try game_window.main_loop();
    game_window.deinit();
}
