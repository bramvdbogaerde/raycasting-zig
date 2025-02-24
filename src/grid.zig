const std = @import("std");
const allocator = std.heap.page_allocator;
const window = @import("window.zig");

/// Walls in the example grid
pub const example = [_]u8{ 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1 };

/// Logcal grid
pub const Grid = struct {
    /// An array denoting the walls in the level
    walls: []const u8,
    /// The width and height of the size (in pixels)
    cell_size: u32,
    /// The number of columns in the grid
    ncols: usize,
    /// The number of rows in the grid
    nrows: usize,
    /// Construct a grid from the given array,
    /// note that you need to free the backing array yourself
    /// if heap allocated.
    pub fn from_array(wall_array: []const u8, size: u32, ncols: usize, nrows: usize) ?*Grid {
        const grid = allocator.create(Grid) catch return null;
        grid.walls = wall_array;
        grid.cell_size = size;
        grid.ncols = ncols;
        grid.nrows = nrows;
        return grid;
    }

    pub fn get_column_row(self: *Grid, column: usize, row: usize) u8 {
        return self.walls[row * self.ncols + column];
    }

    /// Render the grid visually to the given window
    pub fn render(self: *Grid, win: *window.Window) void {
        // Draw the horizontal lines of the grid
        for (0..self.nrows) |r| {
            win.draw_hline(0, r * self.cell_size, win.width);
        }

        // Draw all the vertical lines
        for (0..self.ncols) |c| {
            win.draw_vline(c * self.cell_size, 0, win.height);
        }

        // Fill the cells that have walls
        for (0..self.ncols) |c| {
            for (0..self.nrows) |r| {
                if (self.get_column_row(c, r) > 0) {
                    win.draw_rect(c * self.cell_size, r * self.cell_size, self.cell_size, self.cell_size);
                }
            }
        }
    }
};
