const std = @import("std");
const log = std.log;
pub const c = @cImport({
    @cInclude("SDL.h");
});

pub fn displayError(err_type: Error, errorMsg: ?[]const u8) Error {
    if (errorMsg) |msg|
        log.debug("{s}\n", .{msg});

    switch (err_type) {
        error.SdlError =>
            if (c.SDL_GetError()) |err|
                log.debug("SDL2 Error: {s}\n", .{std.mem.span(err)}),
    }

    return err_type;
}

pub const Error = error{
    SdlError
};

