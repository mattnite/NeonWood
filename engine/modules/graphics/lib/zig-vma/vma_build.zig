const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;
const Module = std.build.Module;
const vma_config = @import("vma_config.zig");
const version: std.SemanticVersion = @import("builtin").zig_version;

// @src() is only allowed inside of a function, so we need this wrapper
fn srcFile() []const u8 {
    return @src().file;
}
const sep = std.fs.path.sep_str;

const zig_vma_path = std.fs.path.dirname(srcFile()).?;
const zig_vma_file = zig_vma_path ++ sep ++ "vma.zig";

pub fn pkg(b: *Builder, vk_root_file: []const u8) *Module {
    const allocator = b.allocator;
    _ = allocator;
    return b.createModule(.{
        .source_file = .{ .path = zig_vma_file },
        .dependencies = &[_]std.Build.ModuleDependency{
            .{
                .name = "vk",
                .module = b.createModule(
                    .{ .source_file = .{ .path = vk_root_file } },
                ),
            },
        },
    });
}

pub fn pkg2(b: *Builder, vk_package: anytype) *Module {
    const allocator = b.allocator;
    _ = allocator;
    return b.createModule(.{
        .source_file = .{ .path = zig_vma_file },
        .dependencies = &[_]std.Build.ModuleDependency{
            .{
                .name = "vk",
                .module = vk_package,
            },
        },
    });
}

fn getConfigArgs(comptime config: vma_config.Config) []const []const u8 {
    comptime {
        @setEvalBranchQuota(100000);
        var args: []const []const u8 = &[_][]const u8{
            std.fmt.comptimePrint("-DVMA_VULKAN_VERSION={}", .{config.vulkanVersion}),
            std.fmt.comptimePrint("-DVMA_DEDICATED_ALLOCATION={}", .{@intFromBool(config.dedicatedAllocation)}),
            std.fmt.comptimePrint("-DVMA_BIND_MEMORY2={}", .{@intFromBool(config.bindMemory2)}),
            std.fmt.comptimePrint("-DVMA_MEMORY_BUDGET={}", .{@intFromBool(config.memoryBudget)}),
            std.fmt.comptimePrint("-DVMA_STATIC_VULKAN_FUNCTIONS={}", .{@intFromBool(config.staticVulkanFunctions)}),
            std.fmt.comptimePrint("-DVMA_STATS_STRING_ENABLED={}", .{@intFromBool(config.statsStringEnabled)}),
        };
        if (config.debugInitializeAllocations) |value| {
            args = args ++ &[_][]const u8{std.fmt.comptimePrint(
                "-DVMA_DEBUG_INITIALIZE_ALLOCATIONS={}",
                .{@intFromBool(value)},
            )};
        }
        if (config.debugMargin) |value| {
            args = args ++ &[_][]const u8{std.fmt.comptimePrint(
                "-DVMA_DEBUG_MARGIN={}",
                .{value},
            )};
        }
        if (config.debugDetectCorruption) |value| {
            args = args ++ &[_][]const u8{std.fmt.comptimePrint(
                "-DVMA_DEBUG_DETECT_CORRUPTION={}",
                .{@intFromBool(value)},
            )};
        }
        if (config.recordingEnabled) |value| {
            args = args ++ &[_][]const u8{std.fmt.comptimePrint(
                "-DVMA_RECORDING_ENABLED={}",
                .{@intFromBool(value)},
            )};
        }
        if (config.debugMinBufferImageGranularity) |value| {
            args = args ++ &[_][]const u8{std.fmt.comptimePrint(
                "-DVMA_DEBUG_MIN_BUFFER_IMAGE_GRANULARITY={}",
                .{value},
            )};
        }
        if (config.debugGlobalMutex) |value| {
            args = args ++ &[_][]const u8{std.fmt.comptimePrint(
                "-DVMA_DEBUG_GLOBAL_MUTEX={}",
                .{@intFromBool(value)},
            )};
        }
        if (config.useStlContainers) |value| {
            args = args ++ &[_][]const u8{std.fmt.comptimePrint(
                "-DVMA_USE_STL_CONTAINERS={}",
                .{@intFromBool(value)},
            )};
        }
        if (config.useStlSharedMutex) |value| {
            args = args ++ &[_][]const u8{std.fmt.comptimePrint(
                "-DVMA_USE_STL_SHARED_MUTEX={}",
                .{@intFromBool(value)},
            )};
        }

        return args;
    }
}

pub fn link(object: *LibExeObjStep, vk_package: anytype, mode: std.builtin.Mode, target: std.zig.CrossTarget, builder: *Builder) void {
    var package = pkg2(builder, vk_package);
    linkWithoutModule(object, mode, target);
    object.addModule("vma", package);
}

pub fn linkWithoutModule(object: *LibExeObjStep, mode: std.builtin.Mode, target: std.zig.CrossTarget) void {
    const commonArgs = &[_][]const u8{ "-std=c++14", "-DVMA_IMPLEMENTATION" };
    const releaseArgs = &[_][]const u8{} ++ commonArgs ++ comptime getConfigArgs(vma_config.releaseConfig);
    const debugArgs = &[_][]const u8{} ++ commonArgs ++ comptime getConfigArgs(vma_config.debugConfig);
    const args = if (mode == .Debug) debugArgs else releaseArgs;

    object.addCSourceFile(.{ .file = .{ .path = zig_vma_path ++ sep ++ "vk_mem_alloc.cpp" }, .flags = args });
    object.linkLibC();
    if (target.getAbi() != .msvc) {
        // MSVC can't link libc++, it causes duplicate symbol errors.
        // But it's needed for other targets.
        object.linkLibCpp();
    }
}
