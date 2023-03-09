const std = @import("std");
const clap = @import("clap");
const Calender = @import("calender.zig").Calender;

pub fn main() !void {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-m, --month <usize>    An option parameter, which takes in month as a value.
        \\-y, --year  <usize>    An option parameter, which takes in year as a value.
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();
    if (res.args.help) {
        return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    }
    if (res.args.year) |y| {
        if (res.args.month) |m| {
            var cal = Calender.init(@intCast(u4, m), @intCast(u16, y));
            cal.display() catch |err| {
                std.debug.print("Failed to print the calender for the month!", .{});
                return err;
            };
        } else {
            var cal = Calender.init(0, @intCast(u16, y));
            cal.wholeyear() catch |err| {
                std.debug.print("Failed to print the calender for the year!", .{});
                return err;
            };
        }
    } else {
        return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    }
}

test {
    std.testing.refAllDeclsRecursive(@import("calender.zig"));
}
