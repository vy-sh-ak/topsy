const std = @import("std");
const conf = @import("config.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("topsy", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    // custom dependencies start here
    const glfw = conf.setGLFW(b);
    const cimgui = conf.setCimgui(b);
    const cimplot = conf.setCimplot(b);
    //websockets
    const websocket = b.dependency("websocket", .{
        .target = target,
        .optimize = optimize,
    });
    //raylib
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const exe = b.addExecutable(.{
        .name = "topsy",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            // root module.
            .imports = &.{
                .{ .name = "topsy", .module = mod },
            },
        }),
    });
    exe.root_module.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);
    exe.root_module.addImport("websocket", websocket.module("websocket"));
    //setting custom configs here
    exe.root_module.linkLibrary(glfw);
    exe.root_module.linkLibrary(cimgui);
    exe.root_module.linkLibrary(cimplot);
    exe.root_module.linkSystemLibrary("opengl32", .{});
    exe.root_module.linkSystemLibrary("gdi32", .{});
    exe.root_module.linkSystemLibrary("user32", .{});
    exe.root_module.linkSystemLibrary("shell32", .{});

    exe.root_module.addIncludePath(b.path("libs/glfw/include"));
    exe.root_module.addIncludePath(b.path("libs/cimgui"));
    exe.root_module.addIncludePath(b.path("libs/cimgui/imgui"));
    exe.root_module.addIncludePath(b.path("libs/cimgui/imgui/backends"));
    exe.root_module.addIncludePath(b.path("libs/cimplot"));
    exe.root_module.addIncludePath(b.path("libs/cimplot/implot"));

    conf.setConfig(b.allocator, exe, "config.json");

    // dependency management and build steps start here
    b.installArtifact(exe);
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    // A run step that will run the test executable.
    const run_mod_tests = b.addRunArtifact(mod_tests);

    // Creates an executable that will run `test` blocks from the executable's
    // root module. Note that test executables only test one module at a time,
    // hence why we have to create two separate ones.
    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    // A run step that will run the second test executable.
    const run_exe_tests = b.addRunArtifact(exe_tests);

    // A top level step for running all tests. dependOn can be called multiple
    // times and since the two run steps do not depend on one another, this will
    // make the two of them run in parallel.
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);

    // Just like flags, top level steps are also listed in the `--help` menu.
    //
    // The Zig build system is entirely implemented in userland, which means
    // that it cannot hook into private compiler APIs. All compilation work
    // orchestrated by the build system will result in other Zig compiler
    // subcommands being invoked with the right flags defined. You can observe
    // these invocations when one fails (or you pass a flag to increase
    // verbosity) to validate assumptions and diagnose problems.
    //
    // Lastly, the Zig build system is relatively simple and self-contained,
    // and reading its source code will allow you to master it.
}
