const std = @import("std");
const os = std.os;
const io = std.io;
const stdout = io.getStdOut().writer();
const fs = std.fs;
const fmt = std.fmt;
const DEBUG = false;

pub fn part1() !void {}

pub fn part2() !void {}

pub fn main() !void {
    try stdout.print("Hello ZIG!\n", .{});
    // try part1();
    // try part2();
}
