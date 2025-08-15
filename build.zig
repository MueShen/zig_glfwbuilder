const std = @import("std");

pub fn build(b: *std.Build) void {
    const target= b.standardTargetOptions(.{});
    const optimize=b.standardOptimizeOption(.{});

    const glfw_module= b.createModule(.{
        .target=target,
        .optimize=optimize,
        .link_libc=true
    });
    const glfw = b.addLibrary(.{
        .name= "glfw",
        .root_module = glfw_module
    });

    const glad_module= b.createModule(.{
        .target=target,
        .optimize=optimize,
        .link_libc=true
    });
    const glad=b.addLibrary(.{
        .name="glad",
        .root_module= glad_module
    });

    glad_module.addCSourceFiles(.{.files= &[_][]const u8{
        "ext/glad/glad.c"
    }});
    

    glfw_module.addCSourceFiles(.{.files = &[_][]const u8{
        "ext/glfw/src/context.c",
        "ext/glfw/src/egl_context.c",
        "ext/glfw/src/glx_context.c",
        "ext/glfw/src/init.c",
        "ext/glfw/src/input.c",
        "ext/glfw/src/linux_joystick.c",
        "ext/glfw/src/monitor.c",
        "ext/glfw/src/nsgl_context.m",
        "ext/glfw/src/null_init.c",
        "ext/glfw/src/null_joystick.c",
        "ext/glfw/src/null_monitor.c",
        "ext/glfw/src/null_window.c",
        "ext/glfw/src/osmesa_context.c",
        "ext/glfw/src/platform.c",
        "ext/glfw/src/posix_module.c",
        "ext/glfw/src/posix_poll.c",
        "ext/glfw/src/posix_thread.c",
        "ext/glfw/src/posix_time.c",
        "ext/glfw/src/vulkan.c",
        "ext/glfw/src/wgl_context.c",
        "ext/glfw/src/win32_init.c",
        "ext/glfw/src/win32_joystick.c",
        "ext/glfw/src/win32_module.c",
        "ext/glfw/src/win32_monitor.c",
        "ext/glfw/src/win32_thread.c",
        "ext/glfw/src/win32_time.c",
        "ext/glfw/src/win32_window.c",
        "ext/glfw/src/window.c",
        "ext/glfw/src/wl_init.c",
        "ext/glfw/src/wl_monitor.c",
        "ext/glfw/src/wl_window.c",
        "ext/glfw/src/x11_init.c",
        "ext/glfw/src/x11_monitor.c",
        "ext/glfw/src/x11_window.c",
        "ext/glfw/src/xkb_unicode.c"
    }, .flags= &[_][]const u8{ "-D_GLFW_X11", "-Wall", "-Wextra"}});

    const exe=b.addExecutable(.{
        .name="HelloWindow",
        .root_module= b.createModule(.{
            .root_source_file=b.path("src/main.zig"),
            .target=target,
            .optimize=optimize,
        }),

    });
    exe.addIncludePath(b.path("ext/glad/"));
    exe.addIncludePath(b.path("ext/glad/glad/"));
    exe.addIncludePath(b.path("ext/glfw/include/GLFW"));


    exe.linkLibrary(glad);
    exe.linkLibrary(glfw);
    exe.linkLibC();
    b.installArtifact(exe);
}

