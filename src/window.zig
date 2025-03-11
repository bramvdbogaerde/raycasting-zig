const std = @import("std");
const sdl = @cImport(@cInclude("SDL2/SDL.h"));
const allocator = std.heap.page_allocator;
const util = @import("util.zig");

/// Enumeration representing a "compass" direction
pub const Direction = enum { Up, Down, Left, Right };

/// Closure for handling key presses
pub fn KeyHandler(comptime S: type) type {
    return struct {
        const Self = @This();
        handler: *const fn (*Self, *Window(S), u64) void,
        state: *S,
    };
}

/// Graphical representation of the game where
/// `S` the logical state of the game.
pub fn Window(comptime S: type) type {
    return struct {
        /// The height of the window
        height: u32,
        /// The width of the window
        width: u32,
        /// Reference to the current SDL window
        sdl_window: *sdl.SDL_Window,
        /// Reference to the current SDL surface (and its pixels)
        sdl_surface: *sdl.SDL_Surface,
        /// Reference to the pixels on the SDL surface
        sdl_pixels: [*]u32,
        /// A function that gets called on every key press
        on_key_press: *KeyHandler(S),
        /// Create a new window instance using the default allocator
        /// and initialize SDL
        pub fn create(w: u32, h: u32) ?*@This() {
            // initialize SDL
            if (sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) != 0) {
                std.debug.print("Could not initialize SDL, reason {s}!", .{sdl.SDL_GetError()});
                return null;
            }

            // Create a window and obtain its surface
            const win = allocator.create(Window(S)) catch return null;
            win.height = h;
            win.width = w;
            win.sdl_window = sdl.SDL_CreateWindow("Game", 0, 0, @intCast(w), @intCast(h), 0).?;
            win.sdl_surface = sdl.SDL_GetWindowSurface(win.sdl_window);
            // Ensure that we have 4 bytes pr pixel (i.e., RGBA)
            std.debug.assert(win.sdl_surface.format.*.BytesPerPixel == 4);
            // store a reference to the pixel buffer of the surface
            win.sdl_pixels = @alignCast(@ptrCast(win.sdl_surface.pixels));
            return win;
        }

        /// Add a function for handling key presses
        pub fn set_on_key(self: *@This(), on_key_fn: *KeyHandler(S)) void {
            self.on_key_press = on_key_fn;
        }

        /// Set a pixel at a particular location
        pub fn set_pixel(self: *@This(), x: usize, y: usize, r: u8, g: u8, b: u8) void {
            const idx = x + (y * self.width);
            self.sdl_pixels[idx] = sdl.SDL_MapRGBA(self.sdl_surface.format, r, g, b, 255);
        }

        /// Draw a horizontal line starting at the given position
        /// and length
        pub fn draw_hline(self: *@This(), x: usize, y: usize, length: usize) void {
            for (x..x + length) |i| {
                self.set_pixel(i, y, 255, 255, 255);
            }
        }

        /// Draw a vertical line starting at the given position
        /// and length
        pub fn draw_vline(self: *@This(), x: usize, y: usize, length: usize) void {
            for (y..y + length) |i| {
                self.set_pixel(x, i, 255, 255, 255);
            }
        }

        pub fn draw_rect(self: *@This(), x: usize, y: usize, width: usize, height: usize) void {
            for (x..x + width) |cx| {
                for (y..y + height) |cy| {
                    self.set_pixel(cx, cy, 255, 255, 255);
                }
            }
        }

        /// Render the pixels to screen (send frame buffer to the GPU)
        pub fn commit(self: *@This()) void {
            _ = sdl.SDL_UpdateWindowSurface(self.sdl_window);
        }

        /// Run the main loop of the application
        pub fn main_loop(self: *@This()) !void {
            var evt: sdl.SDL_Event = undefined;
            var quit: bool = false;
            const timer = try std.time.Timer.start();
            _ = timer; // autofix

            while (!quit) {
                while (sdl.SDL_PollEvent(&evt) != 0) {
                    switch (evt.type) {
                        sdl.SDL_QUIT => quit = true,
                        sdl.SDL_KEYDOWN => self.on_key_press.handler(self.on_key_press, self, evt.key.keysym.scancode),
                        else => continue,
                    }
                }
                // self.on_tick.handler(self.on_tick, self, timer.lap());
            }
        }

        /// Free's up the resources from SDL
        pub fn deinit(self: *@This()) void {
            _ = sdl.SDL_DestroyWindowSurface(self.sdl_window);
            _ = sdl.SDL_DestroyWindow(self.sdl_window);
            _ = allocator.destroy(self);
        }
    };
}
