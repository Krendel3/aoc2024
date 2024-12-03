const std = @import("std");
const p = std.debug.print;
var allocator : std.mem.Allocator = undefined;
pub fn main() !void{
    var gpa =std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile("src/3day/input.txt", .{});
    defer file.close();
    const string = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
    defer allocator.free(string);
    var iter = std.mem.splitSequence(u8, string, "mul(");
    var first = true;
    var counter : i64 = 0;
    p("{d}",.{while (iter.next()) |v|{
        if(first){first = false; continue;}
        const mul = getMul(v);
        counter += mul;
    }else counter});
}
var next_enabled = true;
const listT = std.ArrayList(usize);

const do = "do()";
const dont = "don't()";
pub fn getMul(v : []const u8) i64{
    var comma_index : usize = v.len;
    const index = for (0..v.len) |i|{
        if (v[i] == ","[0]) comma_index = i;
        if (v[i] == ")"[0]) break i;
    } else v.len;
    
    const num1 = std.fmt.parseInt(i64, v[0..comma_index], 10) catch 0;
    const num2 = if(comma_index < v.len)std.fmt.parseInt(i64, v[comma_index + 1..index], 10) catch 0 else 0;
    
    defer next_enabled = enb:{
        var state = next_enabled;
        const start = if(num1 == 0 or num2 == 0) 0 else index + 1;
        break :enb 
        if (start >= v.len -| (dont.len - 1)) state else
        for (start..v.len -| (do.len - 1)) |i|{
            if (!(i + dont.len > v.len) and std.mem.eql(u8, v[i..i + dont.len], dont)) {state = false;}
            else if (std.mem.eql(u8, v[i..i + do.len], do)) state = true;
        } else state;
    };
    return if (!next_enabled or index == v.len) 0 else num1 * num2;
}