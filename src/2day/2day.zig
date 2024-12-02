const std = @import("std");
const int = i64;
const p = std.debug.print;
var allocator : std.mem.Allocator = undefined;
pub fn main() !void{
    var gpa =std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    allocator = gpa.allocator();

    
    var file = try std.fs.cwd().openFile("src/2day/input2.txt", .{});
    defer file.close();

    const text = try file.readToEndAlloc(allocator,std.math.maxInt(int));
    defer allocator.free(text);
    var iter = std.mem.splitSequence(u8, text, "\n");
    var count : int = 0;
    p("{d} \n",.{while (iter.next()) |val|{
        if (val.len == 0) break count;
        if (try isSafe(val)) {count += 1;}
        
    }else count});
    

}
pub fn isSafe(val : [] const u8) !bool{
    

    var list = std.ArrayList(int).init(allocator);
    defer list.deinit();
    var iter =std.mem.splitScalar(u8, val, " "[0]);
    while (iter.next()) |num|{
        try list.append(std.fmt.parseInt(int, num, 10) catch try std.fmt.parseInt(int, num[0..num.len-1], 10));
    }
    const length = list.items.len;
    return for (0..length) |ignored|{
        var last : int = -1;
        var last_grow = true;
        var first_grow_comp = true;
        const valid = for (0..length) |i|{
            if (i == ignored) continue;
            defer last = list.items[i];
            if (last == -1) continue;
            const offset : int = list.items[i] - last;
            if (@abs(offset) < 1 or @abs(offset) > 3 or (last_grow != (offset > 0) and !first_grow_comp)) break false;
            last_grow = offset > 0; first_grow_comp = false;
        } else true;
        if (valid) break true;
    } else false;
}
// pub fn isSafe(iter : *std.mem.SplitIterator(u8,.scalar)) !bool{
//     var last : int = -1;
    
//     var last_grow = true;
//     var first_grow_comp = true;
//     return while (iter.next()) |num|{
        
//         const number = std.fmt.parseInt(int, num, 10) catch continue;
//         defer last = number;
//         if (last == -1) continue;
//         const offset : int = number - last;
//         if (@abs(offset) < 1 or @abs(offset) > 3 or (last_grow != (offset > 0) and !first_grow_comp)) break false;
//         last_grow = offset > 0; first_grow_comp = false;
//     }else true;
// }