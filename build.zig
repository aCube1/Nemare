const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const nemare = b.addExecutable("nemare", "src/main.zig");
    nemare.setTarget(target);
    nemare.setBuildMode(mode);
    nemare.linkLibC();
    switch (target.getOsTag()) {
        .linux => nemare.linkSystemLibrary("SDL2"),
        .windows => {
                        // Change this according to where your SDL2 source files are located.
                        const SDL2_PATH = "C:/vclib/SDL2-2.0.22/";
                        nemare.addIncludeDir(SDL2_PATH ++ "include");
                        nemare.addLibPath(SDL2_PATH ++ "lib/x64");
                        nemare.linkSystemLibrary("SDL2");
        },
        else => std.debug.panic("Cannot identify current OS", .{}),
    }
    nemare.install();

    const nemare_cmd = nemare.run();
    nemare_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        nemare_cmd.addArgs(args);
    }

    const nemare_step = b.step("run-nemare", "Run Nemare");
    nemare_step.dependOn(&nemare_cmd.step);
}
