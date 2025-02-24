const std = @import("std");
const sdl = @cImport(@cInclude("SDL2/SDL.h"));
const window = @import("window.zig");
const grid = @import("grid.zig");
const gamestate = @import("gamestate.zig");

fn handle_tick(_: *window.TickHandler, _: *window.Window, _: u64) void {}
fn handle_key(_: *window.KeyHandler, _: *window.Window, _: u64) void {}

pub fn main() !void {
    // Setup the game window
    const game_window = window.Window.create(400, 500).?;
    // Setup the game state
    const game_grid = grid.Grid.from_array(&grid.example, 100, 4, 5).?;
    var game_state = gamestate.GameState{ .player_x = 25, .player_y = 25, .prev_player_x = 25, .prev_player_y = 25 };
    // Setup the input handling logic, and animation ticks
    var tick_handler = window.TickHandler{ .handler = handle_tick, .state = &game_state };
    var key_handler = window.KeyHandler{ .handler = handle_key, .state = &game_state };

    game_window.set_on_tick(&tick_handler);
    game_window.set_on_key(&key_handler);

    // Render the first version of the grid
    game_grid.render(game_window);
    // Send it to the GPU!
    game_window.commit();

    try game_window.main_loop();
    game_window.deinit();
}
