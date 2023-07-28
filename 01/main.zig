const std = @import("std");
const os = std.os;
const io = std.io;
const stdout = io.getStdOut().writer();
const fs = std.fs;
const fmt = std.fmt;
// const INPUT_FILE = "sample.txt";
// const VALS_CAP = 100;
const INPUT_FILE = "input.txt";
const VALS_CAP = 256;
const BUFF_CAP = 256;
const DEBUG = false;
const YEAR = 2020;

pub fn readFile(filename: []const u8, vals: *[VALS_CAP]i32) !usize {
    var f: fs.File = try fs.cwd().openFile(filename, .{});
    defer f.close();
    var buff: [BUFF_CAP]u8 = undefined;
    var reader = f.reader();
    var vals_sz: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buff, '\n')) |line| {
        vals[vals_sz] = try fmt.parseInt(i32, line, 10);
        vals_sz += 1;
    }
    return vals_sz;
}

pub fn part1() !void {
    var vals: [VALS_CAP]i32 = undefined;
    var vals_sz: usize = try readFile(INPUT_FILE, &vals);
    var comb = [_]i32{ 0, 0 };
    var found: bool = false;
    for (vals[0..vals_sz]) |r| {
        if (r >= YEAR) continue;
        for (vals[0..vals_sz]) |c| {
            if (c + r == YEAR) {
                if (DEBUG) try stdout.print("-> ", .{});
                comb = [_]i32{ c, r };
                found = true;
            }
            if (DEBUG) try stdout.print("{d} + {d} = {d}\n", .{ r, c, c + r });
            if (found) break;
        }
        if (found) break;
    }
    try stdout.print("\x1b[1;32mpart1:\x1b[0m {d}\n", .{comb[0] * comb[1]});
}

pub fn part2() !void {
    var vals: [VALS_CAP]i32 = undefined;
    var vals_sz: usize = try readFile(INPUT_FILE, &vals);
    var comb = [_]i32{ 0, 0, 0 };
    var found: bool = false;
    // FUCKIT DUMB BRUTE FORCE
    for (vals[0..vals_sz]) |r| {
        if (r > YEAR) continue;
        for (vals[0..vals_sz]) |c| {
            if (c + r > YEAR) continue;
            for (vals[0..vals_sz]) |d| {
                // GRUG DO O(3) SEARCH
                if (c + r + d == YEAR) {
                    if (DEBUG) try stdout.print("-> ", .{});
                    comb = [_]i32{ c, r, d };
                    found = true;
                }
                if (DEBUG) try stdout.print("{d} + {d} + {d} = {d}\n", .{ r, c, d, c + r + d });
                if (found) break;
            }
            if (found) break;
        }
        if (found) break;
    }
    try stdout.print("\x1b[1;32mpart2:\x1b[0m {d}\n", .{comb[0] * comb[1] * comb[2]});
}

pub fn main() !void {
    try part1();
    try part2();
}
