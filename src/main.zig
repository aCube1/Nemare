const std = @import("std");
const c = @cImport({
    @cImport("SDL.h");
});

pub fn main() anyerror!void {
    std.log.debug("Hello Worlda!", .{});
}
