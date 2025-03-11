pub const any = *anyopaque;

/// Type level function that returns a closure
/// containing data `T`, argument `A` and return type `R`
pub fn Closure(comptime T: type, comptime A: type, comptime R: type) type {
    const Self = @This();
    return struct { clo: *T, fun: *const fn (self: *Self, a: A) R };
}
