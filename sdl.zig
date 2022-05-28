const std = @import("std");
const print = std.debug.print;
const c = @cImport({
    @cInclude("SDL.h");
});

const log = std.log.scoped(.sdl2);

pub fn displayError(errorMsg: []const u8) Error {
    if (c.SDL_GetError()) |err| {
        if(errorMsg) log.debug("{s}", .{errorMsg});
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
        return displayError("Failed to init SDL!");
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
            return displayError("Unable to create window!"),
    };
}

// Surfaces management
pub const Surface = struct {
    ptr: *c.SDL_Surface,

    pub fn destroy(self: Surface) void {
        c.SDL_FreeSurface(self.ptr);
    }
};

pub fn loadBMP(path: [:0]const u8) !Surface {
    return Surface{
        .ptr = c.SDL_LoadBMP(path)
        orelse
            return displayError("Unable to load image!"),
    };
}

pub fn getWindowSurface(window: *Window) !Surface {
    return Surface{.ptr = c.SDL_GetWindowSurface(window.*.ptr)};
}

pub fn blitSurface(srcSurface: *Surface, srcRect: ?*Rect, dstSurface: *Surface, dstRect: ?*Rect) !Error {
    const srcRect_ptr = if (srcRect) |_srcRect| _srcRect.getSdlPtr() else null;
    const dstRect_ptr = if (dstRect) |_dstRect| _dstRect.getSdlPtr() else null;
    if(c.SDL_BlitSurface(srcSurface.*.ptr, srcRect_ptr, dstSurface.*.ptr, dstRect_ptr) < 0) return displayError("");
}

pub fn updateWindowSurface(window: *Window) !Error {
    if(c.SDL_UpdateWindowSurface(window.*.ptr) < 0) return displayError("Unable to update window");
}

pub const Vector2D = extern struct {
    x: c_int,
    y: c_int,
};

pub const Rect = extern struct {
    pos: Vector2D,
    width: c_int,
    height: c_int,

    fn getSdlPtr(self: *Rect) *c.SDL_Rect {
        return @ptrCast(*c.SDL_Rect, self);
    }
    fn getConstSdlPtr(self: Rect) *const c.SDL_Rect {
        return @ptrCast(*const c.SDL_Rect, &self);
    }
};



// TODO: Not necessary, will be removed later
pub fn delay(ms: u32) void {
    c.SDL_Delay(ms);
}
