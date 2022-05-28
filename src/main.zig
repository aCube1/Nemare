const std = @import("std");
const SDL = @import("deps/sdl2.zig");

pub fn main() !void {
    try SDL.init(.{
        .video = true,
        .events = true,
    });
    defer SDL.quit();

    var window = try SDL.createWindow(
        "Nemare",
        .{ .default = {} },
        .{ .default = {} },
        800,
        400,
        .{},
    );
    defer window.destroy();

    // TODO: Only test purpose
    SDL.delay(2000);
}
