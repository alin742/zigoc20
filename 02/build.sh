#!/bin/sh


zig build-exe main.zig --name main.exe && rm ./main.exe.o && ./main.exe