const std = @import("std");
const sdl = @cImport(@cInclude("SDL2/SDL.h"));
const window = @import("window.zig");

pub fn main() !void {
    const game_window = window.Window.create(500, 500).?;

    for (50..100) |i| {
        for (50..100) |j| {
            game_window.set_pixel(i, j, 255, 255, 255);
        }
    }
    game_window.commit();

    try game_window.main_loop();
    game_window.deinit();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
