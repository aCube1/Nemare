const std = @import("std");
const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const nemare = b.addExecutable("nemare", "src/main.zig");
    nemare.setTarget(target);
    nemare.setBuildMode(mode);
    nemare.linkLibC();
    switch (target.getOsTag()) {
        .linux => nemare.linkSystemLibrary("SDL2"),
        else => std.log.err("Cannot identify current OS", .{}),
    }
    nemare.install();

    const nemare_cmd = nemare.run();
    nemare_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        nemare_cmd.addArgs(args);
    }

    const nemare_step = b.step("run", "Run Nemare");
    nemare_step.dependOn(&nemare_cmd.step);
}
