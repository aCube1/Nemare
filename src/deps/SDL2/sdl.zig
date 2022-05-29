const std = @import("std");
const utils = @import("../../utils.zig");
const c = utils.c;
const displayError = utils.displayError;

usingnamespace @import("video.zig");
usingnamespace @import("render.zig");

// Initialization, shutdown and error handling
pub const InitFlags = struct {
    pub const everything = InitFlags{
        .video = true,
        .audio = true,
        .timer = true,
        .events = true,
    };
    video: bool = false,
    audio: bool = false,
    timer: bool = false,
    events: bool = false,
    // Insert more if needed

    pub fn as_u32(self: InitFlags) u32 {
        return @as(u32,
            (if (self.video) c.SDL_INIT_VIDEO else 0) |
            (if (self.audio) c.SDL_INIT_AUDIO else 0) |
            (if (self.timer) c.SDL_INIT_TIMER else 0) |
            (if (self.events) c.SDL_INIT_EVENTS else 0)
        );
    }
};

pub fn init(flags: InitFlags) !void {
    if (c.SDL_Init(flags.as_u32()) < 0)
        return displayError(error.SdlError, "Failed to init SDL2!");
}

pub fn quit() void {
    c.SDL_Quit();
}

pub fn getError() ?[]const u8 {
    return if (c.SDL_GetError()) |err|
        std.mem.span(err)
    else
        null;
}

// TODO: Not necessary, will be removed later
pub fn delay(ms: u32) void {
    c.SDL_Delay(ms);
}
