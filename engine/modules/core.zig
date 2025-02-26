const root = @import("root");
pub usingnamespace @import("core/misc.zig");
pub usingnamespace @import("core/logging.zig");
pub usingnamespace @import("core/engineTime.zig");
pub usingnamespace @import("core/rtti.zig");
pub usingnamespace @import("core/jobs.zig");
pub const engine = @import("core/engine.zig");
pub const tracy = @import("core/lib/zig_tracy/tracy.zig");
pub const zm = @import("core/lib/zmath/zmath.zig");
pub usingnamespace @import("core/lib/p2/algorithm.zig");
const algorithm = @import("core/lib/p2/algorithm.zig");
pub usingnamespace @import("core/math.zig");
pub usingnamespace @import("core/string.zig");
pub usingnamespace @import("core/args.zig");

pub const scene = @import("core/scene.zig");
pub const SceneSystem = scene.SceneSystem;
pub const lua = @import("core/lua.zig");

pub const Engine = engine.Engine;

const Name = algorithm.Name;
pub const spng = @import("core/lib/zig-spng/spng.zig");

pub const assert = std.debug.assert;

const std = @import("std");
const tests = @import("core/tests.zig");
const logging = @import("core/logging.zig");
const vk = @import("vulkan");
const c = @This();

const logs = logging.engine_logs;
const log = logging.engine_log;

pub var gScene: *SceneSystem = undefined;

pub fn start_module(allocator: std.mem.Allocator) void {
    _ = algorithm.createNameRegistry(allocator) catch unreachable;
    gEngine = allocator.create(Engine) catch unreachable;
    gEngine.* = Engine.init(allocator) catch unreachable;

    gScene = gEngine.createObject(scene.SceneSystem, .{ .can_tick = true }) catch unreachable;

    try lua.test_lua();

    logging.setupLogging(gEngine) catch unreachable;

    logs("core module starting up... ");
    return;
}

pub fn run() void {}

pub fn shutdown_module(allocator: std.mem.Allocator) void {
    algorithm.destroyNameRegistry();
    logs("core module shutting down...");
    logging.forceFlush();
    gEngine.deinit();
    allocator.destroy(gEngine);
    return;
}

pub fn dispatchJob(capture: anytype) !void {
    try gEngine.jobManager.newJob(capture);
}

pub var gEngine: *Engine = undefined;

pub fn createObject(comptime T: type, params: engine.NeonObjectParams) !*T {
    return gEngine.createObject(T, params);
}

pub fn splitIntoLines(file_contents: []const u8) std.mem.SplitIterator(u8) {
    // find a \n and see if it has \r\n
    var index: u32 = 0;
    while (index < file_contents.len) : (index += 1) {
        if (file_contents[index] == '\n') {
            if (index > 0) {
                if (file_contents[index - 1] == '\r') {
                    return std.mem.split(u8, file_contents, "\r\n");
                } else {
                    return std.mem.split(u8, file_contents, "\n");
                }
            } else {
                return std.mem.split(u8, file_contents, "\n");
            }
        }
    }
    return std.mem.split(u8, file_contents, "\n");
}

// alignment of 1 should be used for text files
pub fn loadFileAlloc(filename: []const u8, comptime alignment: usize, allocator: std.mem.Allocator) ![]u8 {
    var file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    const filesize = (try file.stat()).size;
    var buffer: []u8 = try allocator.alignedAlloc(u8, alignment, filesize);
    try file.reader().readNoEof(buffer);
    return buffer;
}

const showDebug = false;

pub fn implement_func_for_tagged_union_nonull(
    self: anytype,
    comptime funcName: []const u8,
    comptime returnType: type,
    args: anytype,
) returnType {
    const Self = @TypeOf(self);
    inline for (@typeInfo(std.meta.Tag(Self)).Enum.fields) |field| {
        if (@as(std.meta.Tag(Self), @enumFromInt(field.value)) == self) {
            if (@hasDecl(@TypeOf(@field(self, field.name)), funcName)) {
                return @field(@field(self, field.name), funcName)(args);
            }
        }
    }

    unreachable;
}

pub fn writeToFile(data: []const u8, path: []const u8) !void {
    const file = try std.fs.cwd().createFile(
        path,
        .{
            .read = true,
        },
    );

    const bytes_written = try file.writeAll(data);
    _ = bytes_written;
    log("written: bytes to {s}", .{path});
}

pub fn dupeZ(comptime T: type, allocator: std.mem.Allocator, source: []const T) ![]T {
    var buff: []T = try allocator.alloc(T, source.len + 1);
    for (source, 0..source.len) |s, i| {
        buff[i] = s;
    }
    buff[source.len] = 0;
    return buff;
}

pub fn dupe(comptime T: type, allocator: std.mem.Allocator, source: []const T) ![]T {
    var buff: []T = try allocator.alloc(T, source.len);
    for (source, 0..) |s, i| {
        buff[i] = s;
    }
    return buff;
}

pub const NeonObjectTableName: []const u8 = "NeonObjectTable";
