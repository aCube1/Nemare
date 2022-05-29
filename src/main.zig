const std = @import("std");
const SDL = @import("deps/SDL2/sdl.zig");

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
        600,
        .{},
    );
    defer window.destroy();

    var renderer = try SDL.createRenderer(window, -1, .{ .presentvsync = true });
    defer renderer.destroy();

    try renderer.clear();
        try renderer.setDrawColor(SDL.Color.white);
        try renderer.drawRect(.{
            .x = 0, .y = 0,
            .width = 64, .height = 64,
        });
    renderer.present();

    SDL.delay(2000);
}
