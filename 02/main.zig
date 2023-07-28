const std = @import("std");
const common = @import("common.zig");
const mem = std.mem;
const os = std.os;
const io = std.io;
const stdout = io.getStdOut().writer();
const fs = std.fs;
const fmt = std.fmt;
const DEBUG = false;

const BUFF_SZ = 256;
// const INPUT_FILE = "sample.txt";
// const LINE_CAP = 5;
const INPUT_FILE = "input.txt";
const LINE_CAP = 1024;

pub fn xor(c1: bool, c2: bool) bool {
    return (c1 or c2) and !(c1 and c2);
}

const Policy = struct {
    min: usize,
    max: usize,
    char: u8,

    pub fn init(min: usize, max: usize, char: u8) Policy {
        return Policy{ .min = min, .max = max, .char = char };
    }

    pub fn format(policy: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) std.os.WriteError!void {
        return writer.print("{d}-{d} {c}", .{ policy.min, policy.max, policy.char });
    }

    pub fn checkPassword(policy: @This(), pass: *[BUFF_SZ]u8) !bool {
        var n_occurance: usize = 0;
        for (pass) |pc| {
            if (policy.char == pc) n_occurance += 1;
        }
        if (n_occurance > policy.max or n_occurance < policy.min) {
            if (DEBUG) try stdout.print("\x1b[1;31mERROR:\x1b[0m password: {s}, violates policy: {any}\n", .{ pass, policy });
            return false;
        } else return true;
    }

    pub fn checkPasswordUpdated(policy: @This(), pass: *[BUFF_SZ]u8) !bool {
        var index_1: usize = policy.min - 1;
        var index_2: usize = policy.max - 1;
        var char_1: bool = policy.char == pass[index_1];
        var char_2: bool = policy.char == pass[index_2];
        var cond: bool = xor(char_1, char_2);
        if (DEBUG and !cond) try stdout.print("\x1b[1;31mERROR:\x1b[0m char @pos {d} ({c}) nor char @pos {d} ({c}) match specified policy char {c}\n", .{ index_1, pass[index_1], index_2, pass[index_2], policy.char });
        return cond;
    }
};

pub fn readPasswords(filename: []const u8, policies: *[LINE_CAP]Policy, pass: *[LINE_CAP][BUFF_SZ]u8) !usize {
    var f: fs.File = try fs.cwd().openFile(filename, .{});
    defer f.close();
    var reader = f.reader();
    var buff: [BUFF_SZ]u8 = undefined;
    var n_pass: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buff, '\n')) |line| {
        var tokens = mem.split(u8, line, ":");
        var policy_tokens = mem.split(u8, tokens.first(), " ");
        var policy_range_tokens = mem.split(u8, policy_tokens.first(), "-");
        var policy_min = try fmt.parseInt(usize, policy_range_tokens.first(), 10);
        var policy_max = try fmt.parseInt(usize, policy_range_tokens.next().?, 10);
        var policy_char = policy_tokens.next().?[0];
        var policy = Policy.init(policy_min, policy_max, policy_char);
        var password = mem.trimLeft(u8, tokens.next().?, " ");
        policies[n_pass] = policy;
        mem.copy(u8, &pass[n_pass], password);
        n_pass += 1;
    }
    return n_pass;
}

pub fn part1() !void {
    var policies: [LINE_CAP]Policy = undefined;
    var pass: [LINE_CAP][BUFF_SZ]u8 = undefined;
    var n_pass = try readPasswords(INPUT_FILE, &policies, &pass);
    var n_valid: usize = 0;
    for (common.range(n_pass)) |_, i| {
        var policy = policies[i];
        var password = pass[i];
        var valid_pass: bool = try policy.checkPassword(&password);
        if (!valid_pass) continue;
        n_valid += 1;
    }
    try stdout.print("\x1b[1;33mpart1:\x1b[0m {d}\n", .{n_valid});
}

pub fn part2() !void {
    var policies: [LINE_CAP]Policy = undefined;
    var pass: [LINE_CAP][BUFF_SZ]u8 = undefined;
    var n_pass = try readPasswords(INPUT_FILE, &policies, &pass);
    var n_valid: usize = 0;
    for (common.range(n_pass)) |_, i| {
        var policy = policies[i];
        var password = pass[i];
        var valid_pass: bool = try policy.checkPasswordUpdated(&password);
        if (!valid_pass) continue;
        n_valid += 1;
    }
    try stdout.print("\x1b[1;33mpart2:\x1b[0m {d}\n", .{n_valid});
}

pub fn main() !void {
    try part1();
    try part2();
}
