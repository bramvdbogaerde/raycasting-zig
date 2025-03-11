const std = @import("std");
const allocator = std.heap.page_allocator;

/// `PlayerPosition` represents a player's position, including
/// its x and y position and the angle it is looking at.
pub const PlayerPosition = struct {
    /// The x position of the player
    x: u64,
    /// The y position of the player
    y: u64,
    /// The current angle of the player
    angle: f64,

    /// Copy the data of this structure to the other structure
    pub fn copy_to(self: *@This(), other: *@This()) void {
        other.x = self.x;
        other.y = self.y;
        other.angle = self.angle;
    }
    /// Rotate the position in a anti-clockwise fashion
    pub fn rotate(self: *@This(), angle: f64) void {
        self.angle += angle;
    }

    /// Create the initial player position (stack allocated)
    pub fn initial() PlayerPosition {
        return .{ .x = 0, .y = 0, .angle = 0 };
    }
};

/// The current state of the game
pub const GameState = struct {
    /// The current position of the player
    player_position: PlayerPosition,
    /// The previous position of the player
    previous_position: PlayerPosition,
    /// Save the previous player's position
    pub fn save_previous(self: *@This()) void {
        self.player_position.copy_to(self.player_position);
    }
    // Increate the current angle of the player in an
    // anti-clockwise manner.
    pub fn rotate(self: *@This(), angle: f64) void {
        self.player_position.rotate(angle);
    }
    /// Rotate the current player's position in anti-clockwise fashion
    pub fn rotate_cw(self: *@This(), angle: f64) void {
        self.player_position.rotate(-angle);
    }
    /// Create a heap allocated initial state
    pub fn initial() !*GameState {
        var st: *GameState = try allocator.create(GameState);
        st.player_position = PlayerPosition.initial();
        st.previous_position = PlayerPosition.initial();
        return st;
    }
};
