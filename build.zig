const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const nemare = b.addExecutable("nemare", "src/main.zig");
    nemare.setTarget(target);
    nemare.setBuildMode(mode);
    nemare.linkLibC();
    linkCLibraries(nemare, target.getOsTag());
    nemare.install();

    const nemare_cmd = nemare.run();
    nemare_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        nemare_cmd.addArgs(args);
    }

    const nemare_step = b.step("run-nemare", "Run Nemare");
    nemare_step.dependOn(&nemare_cmd.step);
}

pub fn linkCLibraries(
    exe: *std.build.LibExeObjStep,
    os_tag: std.Target.Os.Tag,
) void {
    const c_flags = [_][]const u8{
        "-std=c99",
        "-O2",
    };

    // Link stb_image
    exe.addCSourceFile("src/deps/stb/image.c", &c_flags);

    // Link SDL
    switch (os_tag) {
        .linux => exe.linkSystemLibrary("SDL2"),
        .windows => {
            // Change this according to where your SDL2 source files are located.
            const SDL2_PATH = "C:/vclib/SDL2-2.0.22/";
            exe.addIncludeDir(SDL2_PATH ++ "include");
            exe.addLibPath(SDL2_PATH ++ "lib/x64");
            exe.linkSystemLibrary("SDL2");
        },
        else => std.debug.panic("Unable to identify current OS", .{}),
    }
}
