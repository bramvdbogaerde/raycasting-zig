pub const Direction = enum { Up, Down, Left, Right, Stationary };

pub const GameState = struct {
    /// The x current position of the player
    player_x: u32,
    /// The current y position of the player
    player_y: u32,
    ///  The previous x position of the player
    prev_player_x: u32,
    /// Previous y position of the player
    prev_player_y: u32,
    /// The current direction the player is heading
    direction: Direction = Direction.Stationary,
};
