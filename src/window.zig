const std = @import("std");
const sdl = @cImport(@cInclude("SDL2/SDL.h"));
const allocator = std.heap.page_allocator;

pub const Window = struct {
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
    /// Create a new window instance using the default allocator
    /// and initialize SDL
    pub fn create(w: u32, h: u32) ?*Window {
        // initialize SDL
        if (sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) != 0) {
            std.debug.print("Could not initialize SDL, reason {s}!", .{sdl.SDL_GetError()});
            return null;
        }

        // Create a window and obtain its surface
        const win = allocator.create(Window) catch return null;
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

    /// Set a pixel at a particular location
    pub fn set_pixel(self: *Window, x: usize, y: usize, r: u8, g: u8, b: u8) void {
        const idx = x + (y * self.width);
        self.sdl_pixels[idx] = sdl.SDL_MapRGBA(self.sdl_surface.format, r, g, b, 255);
    }

    /// Render the pixels to screen (send frame buffer to the GPU)
    pub fn commit(self: *Window) void {
        _ = sdl.SDL_UpdateWindowSurface(self.sdl_window);
    }

    /// Run the main loop of the application
    pub fn main_loop(_: *Window) !void {
        var evt: sdl.SDL_Event = undefined;
        var quit: bool = false;
        while (!quit) {
            while (sdl.SDL_PollEvent(&evt) != 0) {
                switch (evt.type) {
                    sdl.SDL_QUIT => quit = true,
                    else => continue,
                }
            }
        }
    }

    /// Free's up the resources from SDL
    pub fn deinit(self: *Window) void {
        _ = sdl.SDL_DestroyWindowSurface(self.sdl_window);
        _ = sdl.SDL_DestroyWindow(self.sdl_window);
        _ = allocator.destroy(self);
    }
};
