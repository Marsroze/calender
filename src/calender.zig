const std = @import("std");
const expect = std.testing.expect;

// Enum to store weekdays
const Day = enum(u4) {
    sun = 0,
    mon = 1,
    tue = 2,
    wed = 3,
    thu = 4,
    fri = 5,
    sat = 6,

    // Determines the space padding in the display function
    pub fn value(self: @This()) u4 {
        return @enumToInt(self);
    }
};

// enum test
test "value check" {
    try expect(Day.sun.value() == 0);
    try expect(Day.mon.value() == 1);
    try expect(Day.tue.value() == 2);
    try expect(Day.wed.value() == 3);
    try expect(Day.thu.value() == 4);
    try expect(Day.fri.value() == 5);
    try expect(Day.sat.value() == 6);
}

// Calender struct for related functionality
pub const Calender = struct {
    month: u4,
    year: u16,

    // Constructor for creating new struct
    pub fn init(month: u4, year: u16) @This() {
        return @This(){
            .month = month,
            .year = year,
        };
    }

    // Zeller's Algorithm
    fn getZeller(self: @This()) u8 {
        const d: i32 = 1;
        var m: i32 = self.month;
        var y: i32 = self.year;

        if (m <= 2) {
            m += 12;
        }

        if (self.month <= 2) {
            y -= 1;
        }
        // zig fmt: off
        const z: i32 = @mod((d + @divFloor((13 * (m + 1)), 5) + y 
            + @divFloor(y, 4) - @divFloor(y, 100) 
            + @divFloor(y, 400)), 7);
        // zig fmt: on
        return @intCast(u8, z);
    }

    // Returns the weekday from corresponding zeller number
    fn weekday(self: @This()) Day {
        return switch (self.getZeller()) {
            0 => Day.sat,
            1 => Day.sun,
            2 => Day.mon,
            3 => Day.tue,
            4 => Day.wed,
            5 => Day.thu,
            6 => Day.fri,
            else => unreachable,
        };
    }

    // Generate month names
    fn monthname(self: @This()) []const u8 {
        return switch (self.month) {
            1 => "January",
            2 => "February",
            3 => "March",
            4 => "April",
            5 => "May",
            6 => "June",
            7 => "July",
            8 => "August",
            9 => "September",
            10 => "October",
            11 => "November",
            12 => "December",
            else => unreachable,
        };
    }

    // No of days of the month
    fn tdays(self: @This()) u8 {
        return switch (self.month) {
            1 => 31,
            2 => if (@rem(self.year, 4) == 0) 29 else 28,
            3 => 31,
            4 => 30,
            5 => 31,
            6 => 30,
            7 => 31,
            8 => 31,
            9 => 30,
            10 => 31,
            11 => 30,
            12 => 31,
            else => unreachable,
        };
    }

    // Prints the calender for a specific month
    pub inline fn display(self: @This()) !void {
        const stdout = std.io.getStdOut();
        var buf = std.io.bufferedWriter(stdout.writer());
        var buffer = buf.writer();
        try buffer.print("+{s:-<35}+\n|{s: ^35}|", .{ "-", " " });
        try buffer.print("\n|\x1b[32m{s: ^35}\x1b[0m|\n", .{self.monthname()});
        try buffer.print("|{s: <35}|\n| \x1b[31mSUN  MON  TUE  WED  THU  FRI  SAT\x1b[0m |\n", .{" "});
        var i: usize = 0;
        const val = self.weekday().value();
        var wkday: usize = 0;
        while (i < val) : (i += 1) {
            wkday += 1;
            if (wkday == 1) {
                try buffer.print("|{s: <4}", .{" "});
            } else {
                try buffer.print("{s: <5}", .{" "});
            }
        }
        var day: usize = 1;
        while (day <= self.tdays()) : (day += 1) {
            if (wkday == 0) {
                try buffer.print("|{d:4}", .{day});
            } else {
                try buffer.print("{d:5}", .{day});
            }
            wkday += 1;
            if (wkday > 6) {
                try buffer.print(" |\n", .{});
                wkday = 0;
            }
        }
        while (wkday < 7) : (wkday += 1) {
            if (wkday == 0) {
                try buffer.print("|{s:4}", .{" "});
            } else {
                try buffer.print("{s:5}", .{" "});
            }
        }
        try buffer.print(" |\n|{s: <35}|\n+{s:-<35}+\n", .{ " ", "-" });
        try buf.flush();
    }

    // Prints the whole calender year
    pub fn wholeyear(self: *@This()) !void {
        self.month = 1;
        const stdout = std.io.getStdOut();
        var buf = std.io.bufferedWriter(stdout.writer());
        var buffer = buf.writer();
        try buffer.print("\x1b[34;1m\n*{s:-<35}*\x1b[0m\n", .{"-"});
        try buffer.print("\x1b[34;1m|\x1b[0m\x1b[31;1m{d: ^35}\x1b[0m\x1b[34;1m|\x1b[0m", .{self.year});
        try buffer.print("\x1b[34;1m\n*{s:-<35}*\x1b[0m\n", .{"-"});
        try buf.flush();
        while (self.month <= 12) : (self.month += 1) {
            try self.display();
        }
    }
};

test "check zeller" {
    var calender = Calender.init(1, 2023);
    try expect(calender.getZeller() == 1);
    calender = Calender.init(2, 2023);
    try expect(calender.getZeller() == 4);
    calender = Calender.init(8, 2023);
    try expect(calender.getZeller() == 3);
    calender = Calender.init(4, 2023);
    try expect(calender.getZeller() == 0);
    calender = Calender.init(5, 2023);
    try expect(calender.getZeller() == 2);
    calender = Calender.init(6, 2023);
    try expect(calender.getZeller() == 5);
    calender = Calender.init(9, 2023);
    try expect(calender.getZeller() == 6);
}

test "check weekday" {
    var calender = Calender.init(2, 2000);
    try expect(calender.weekday() == Day.tue);
    calender = Calender.init(2, 2001);
    try expect(calender.weekday() == Day.thu);
    calender = Calender.init(2, 2002);
    try expect(calender.weekday() == Day.fri);
    calender = Calender.init(2, 2003);
    try expect(calender.weekday() == Day.sat);
    calender = Calender.init(2, 2004);
    try expect(calender.weekday() == Day.sun);
    calender = Calender.init(2, 2005);
    try expect(calender.weekday() == Day.tue);
    calender = Calender.init(2, 2006);
    try expect(calender.weekday() == Day.wed);
    calender = Calender.init(10, 2007);
    try expect(calender.weekday() == Day.mon);
}

test "check days for feb" {
    var calender = Calender.init(2, 2020);
    try expect(calender.tdays() == 29);
    calender = Calender.init(2, 2021);
    try expect(calender.tdays() == 28);
}

test "month name" {
    var calender = Calender.init(1, 2000);
    try std.testing.expectEqualStrings("January", calender.monthname());
    calender = Calender.init(2, 1999);
    try std.testing.expectEqualStrings("February", calender.monthname());
    calender = Calender.init(3, 1998);
    try std.testing.expectEqualStrings("March", calender.monthname());
    calender = Calender.init(4, 1997);
    try std.testing.expectEqualStrings("April", calender.monthname());
    calender = Calender.init(5, 1996);
    try std.testing.expectEqualStrings("May", calender.monthname());
    calender = Calender.init(6, 1995);
    try std.testing.expectEqualStrings("June", calender.monthname());
    calender = Calender.init(7, 1994);
    try std.testing.expectEqualStrings("July", calender.monthname());
    calender = Calender.init(8, 1993);
    try std.testing.expectEqualStrings("August", calender.monthname());
    calender = Calender.init(9, 1992);
    try std.testing.expectEqualStrings("September", calender.monthname());
    calender = Calender.init(10, 1991);
    try std.testing.expectEqualStrings("October", calender.monthname());
    calender = Calender.init(11, 1990);
    try std.testing.expectEqualStrings("November", calender.monthname());
    calender = Calender.init(12, 1899);
    try std.testing.expectEqualStrings("December", calender.monthname());
}
