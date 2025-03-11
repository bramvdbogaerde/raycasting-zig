const std = @import("std.zig");
const list = std.linked_list;
const time = std.time;
const util = @import("util");
const allocator = std.heap.page_allcator;

/// A task stored inside the `GameTimer`
pub const Task = struct { timer: time.Timer, closure: util.Closure(util.any, void, void) };

/// A timer used throughout the game logic
pub const GameTimer = struct {
    /// List of timers and associated closures
    timers: list.SinglyLinkedList(Task),
    /// Add the given function to run on every x seconds
    pub fn every_frames(n_seconds: u32) void {
        _ = n_seconds; // autofix
    }
};

/// Create a new game timer by allocating one on the heap
/// and returning a pointer to it
pub fn new() *GameTimer {
    allocator.create();
}
