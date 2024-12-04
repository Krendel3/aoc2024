const std = @import("std");
const v2 = @Vector(2,i32);
const uv2 = @Vector(2,usize);

var size : uv2 = undefined;
var grid : std.ArrayList([]const u8) = undefined;
pub fn main() !void{
    var gpa =std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("src/4day/input.txt", .{});
    defer file.close();

    const string = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
    defer allocator.free(string);

    var iter = std.mem.tokenizeSequence(u8, string,  "\n");
    
    size = .{iter.peek().?.len - 1,0};
    grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();

    while (iter.next()) |val|{
        const str = std.mem.trimRight(u8, val, ([_]u8{13})[0..1]);
        // std.debug.print("{s}, {d}\n",.{str, str.len});
        try grid.append(str);
    }
    size[1] = grid.items.len;
    
    var count : usize = 0;
    
    
    std.debug.print("{d}",.{for (1..size[1]-1) |i|{
        for (1..size[0]-1) |j|{
            count += checkPos(vec(j,i));
        }
    }else count});
}
fn checkPos(pos : v2) usize{
    if (getGridItem(pos) != "A"[0]) return 0;
    return if (checkCross(pos,.{1,1}) and checkCross(pos,.{-1,1})) 1 else 0;

}
fn checkCross(pos : v2, dir : v2) bool{
    return
    (getGridItem(pos + dir) == "M"[0] 
    and 
    getGridItem(pos - dir) == "S"[0])
    or
    (getGridItem(pos + dir) == "S"[0] 
    and 
    getGridItem(pos - dir) == "M"[0]);
}
fn getGridItem(pos : v2) u8{
    return grid.items[@as(usize,@intCast(pos[1]))][@as(usize,@intCast(pos[0]))]; 
}

fn vec(x : usize,y : usize) v2{
    return .{@as(i32,@intCast(x)),@as(i32,@intCast(y))};
}

