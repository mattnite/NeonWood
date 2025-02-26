const std = @import("std");

const spng = @import("lib/zig-spng/build.zig");
const lua = @import("lib/lua/build.zig");
const zigTracy = @import("lib/zig_tracy/build_tracy.zig");

pub fn addLib(b: *std.Build, exe: *std.build.LibExeObjStep, comptime packagePath: []const u8, cflags: []const []const u8, enableTracy: bool) void {
    _ = cflags;
    exe.addIncludePath(.{ .path = packagePath ++ "/lib" });
    spng.addLib(b, exe, packagePath ++ "/lib/zig-spng");
    lua.addLib(b, exe, packagePath ++ "/lib/lua");

    if (enableTracy) {
        zigTracy.link(b, exe, packagePath ++ "/lib/zig_tracy/tracy-0.7.8/");
    } else {
        zigTracy.link(b, exe, null);
    }
}
