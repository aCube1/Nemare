const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});

const log = std.log.scoped(.sdl2);

pub fn displayError() Error {
    if (c.SDL_GetError()) |err| {
        log.debug("SDL2 Error: {s}\n", .{std.mem.span(err)});
    }

    return Error.SdlError;
}

pub const Error = error{SdlError};

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
        return displayError();
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

// Window and display management
pub const Window = struct {
    ptr: *c.SDL_Window,

    pub fn destroy(self: Window) void {
        c.SDL_DestroyWindow(self.ptr);
    }
};

pub const WindowPosition = union(enum) {
    default: void,
    centered: void,
    absolute: c_int,
};

pub const WindowFlags = struct {
    fullscreen: bool = false,
    borderless: bool = false,
    resizable: bool = false,
    minimized: bool = false,
    maximized: bool = false,
    hidden: bool = false,
    // Insert more if needed

    pub fn as_u32(self: WindowFlags) u32 {
        return @intCast(u32,
            c.SDL_WINDOW_OPENGL |
            (if (self.fullscreen) c.SDL_WINDOW_FULLSCREEN else 0) |
            (if (self.borderless) c.SDL_WINDOW_BORDERLESS else 0) |
            (if (self.resizable) c.SDL_WINDOW_RESIZABLE else 0) |
            (if (self.minimized) c.SDL_WINDOW_MINIMIZED else 0) |
            (if (self.maximized) c.SDL_WINDOW_MAXIMIZED else 0) |
            (if (self.hidden) c.SDL_WINDOW_HIDDEN else c.SDL_WINDOW_SHOWN)
        );
    }
};

pub fn createWindow(
    title: [:0]const u8,
    x: WindowPosition,
    y: WindowPosition,
    width: c_int,
    height: c_int,
    flags: WindowFlags,
) !Window {
    return Window{
        .ptr = c.SDL_CreateWindow(
            title,
            switch (x) {
                .default => c.SDL_WINDOWPOS_UNDEFINED,
                .centered => c.SDL_WINDOWPOS_CENTERED,
                .absolute => |v| v,
            },
            switch (y) {
                .default => c.SDL_WINDOWPOS_UNDEFINED,
                .centered => c.SDL_WINDOWPOS_CENTERED,
                .absolute => |v| v,
            },
            width,
            height,
            flags.as_u32(),
        ) orelse
            return displayError(),
    };
}

// TODO: Not necessary, will be removed later
pub fn delay(ms: u32) void {
    c.SDL_Delay(ms);
}
