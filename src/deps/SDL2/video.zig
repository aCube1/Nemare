const utils = @import("../../utils.zig");
const render = @import("render.zig");
const c = utils.c;
const displayError = utils.displayError;
const Rect = render.Rect;
const Color = render.Color;

// Window and renderer management
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
    var window_ptr = c.SDL_CreateWindow(
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
        return displayError(error.SdlError, "Unable to create Window!");

    return Window{ .ptr = window_ptr };
}

pub const RendererFlags = struct {
    software: bool = false,
    presentvsync: bool = false,
    targettexture: bool = false,

    pub fn as_u32(self: RendererFlags) u32 {
        return @intCast(u32,
            (if (self.software) c.SDL_RENDERER_SOFTWARE else c.SDL_RENDERER_ACCELERATED) |
            (if (self.presentvsync) c.SDL_RENDERER_PRESENTVSYNC else 0) |
            (if (self.targettexture) c.SDL_RENDERER_TARGETTEXTURE else 0)
        );
    }
};

pub const Renderer = struct {
    ptr: *c.SDL_Renderer,

    pub fn destroy(self: Renderer) void {
        c.SDL_DestroyRenderer(self.ptr);
    }

    pub fn clear(self: Renderer) !void {
        if (c.SDL_RenderClear(self.ptr) < 0)
            return displayError(error.SdlError, "Unable to clear the renderer!");
    }

    pub fn present(self: Renderer) void {
        c.SDL_RenderPresent(self.ptr);
    }

    pub fn drawRect(self: Renderer, rect: Rect) !void {
        if (c.SDL_RenderDrawRect(
            self.ptr,
            rect.getConstPtr(),
        ) < 0)
            return displayError(error.SdlError, "Unable to Draw Rect!");
    }

    pub fn setDrawColor(self: Renderer, color: Color) !void {
        if (c.SDL_SetRenderDrawColor(
            self.ptr,
            color.r,
            color.g,
            color.b,
            color.a,
        ) < 0)
            return displayError(error.SdlError, "Unable to set Render Color");
    }
};

pub fn createRenderer(
    window: Window,
    index: c_int,
    flags: RendererFlags,
) !Renderer {
    var renderer_ptr = c.SDL_CreateRenderer(
        window.ptr,
        index,
        flags.as_u32(),
    ) orelse
        return displayError(error.SdlError, "Unable to create Window Renderer!");

    return Renderer{ .ptr = renderer_ptr };
}
