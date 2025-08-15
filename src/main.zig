const std= @include("std");
const glad= @include("glad");
const gl= @include("glfw");


pub fn main ()!void {
    std.debug.print("Hello zig!\n", .{});
}
