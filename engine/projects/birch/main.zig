const std = @import("std");
const nw = @import("root").neonwood;

const core = nw.core;
const graphics = nw.graphics;
const platform = nw.platform;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .stack_trace_frames = 20,
    }){};

    defer {
        const cleanupStatus = gpa.deinit();
        if (cleanupStatus == .leak) {
            std.debug.print("gpa cleanup leaked memory\n", .{});
        }
    }

    nw.graphics.setStartupSettings("maxObjectCount", 10);

    var allocator = gpa.allocator();

    core.start_module(allocator);
    defer core.shutdown_module(allocator);

    try platform.start_module(allocator, "Birch Renderer", null);
    defer platform.shutdown_module(allocator);

    nw.assets.start_module(allocator);
    defer nw.assets.shutdown_module(allocator);

    try core.gEngine.run();

    while (!core.gEngine.exitConfirmed) {
        //var x: *i32 = @ptrFromInt(0xfffffff0);
        var i: usize = 1;
        if (i > 0) {}
        platform.getInstance().pollEvents();
    }
}
