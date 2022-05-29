const utils = @import("../../utils.zig");
const c = utils.c;
const displayError = utils.displayError;

pub const Point = extern struct {
    x: c_int,
    y: c_int,
};

pub const Rect = extern struct {
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,

    pub fn getPtr(self: Rect) *c.SDL_Rect {
        return @ptrCast(*c.SDL_Rect, &self);
    }

    pub fn getConstPtr(self: Rect) *const c.SDL_Rect {
        return @ptrCast(*const c.SDL_Rect, &self);
    }
};

pub const Color = extern struct {
    pub const black = rgb(0x00, 0x00, 0x00);
    pub const white = rgb(0xff, 0xff, 0xff);
    pub const red = rgb(0xff, 0x00, 0x00);
    pub const green = rgb(0x00, 0xff, 0x00);
    pub const blue = rgb(0x00, 0x00, 0xff);
    pub const magenta = rgb(0xff, 0x00, 0xff);
    pub const cyan = rgb(0x00, 0xff, 0xff);
    pub const yellow = rgb(0xff, 0xff, 0x00);

    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn rgb(r: u8, g: u8, b: u8) Color {
        return Color{ .r = r, .g = g, .b = b, .a = 255 };
    }

    pub fn rgba(r: u8, g: u8, b: u8, a: u8) Color {
        return Color{ .r = r, .g = g, .b = b, .a = a };
    }
};

