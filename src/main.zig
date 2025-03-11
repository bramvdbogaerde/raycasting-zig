const std = @import("std");
const sdl = @cImport(@cInclude("SDL2/SDL.h"));
const window = @import("window.zig");
const grid = @import("grid.zig");
const gamestate = @import("gamestate.zig");

fn handle_key(_: *window.KeyHandler(gamestate.GameState), _: *window.Window(gamestate.GameState), _: u64) void {}

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
    game_window.commit();

    try game_window.main_loop();
    game_window.deinit();
}
