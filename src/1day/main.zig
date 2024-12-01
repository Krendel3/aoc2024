const std = @import("std");
//    const main = try (try std.fs.cwd().openFile(file_name, .{})).readToEndAlloc(allocator.*, std.math.maxInt(usize));
const prt = std.debug.print;
pub fn main() !void {
    var gpa =std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const file = try std.fs.cwd().openFile("src/input.txt", .{});
    defer file.close();
    
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buff : [1024]u8 = undefined;
    
    var first = std.ArrayList(u32).init(allocator);
    var second = std.ArrayList(u32).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buff, '\n'))|val|{
        
        const index = for (0..val.len)|l|{
            if(std.mem.eql(u8,val[l..l+1]," "))break l;
        }else val.len-1;
        bk1:{try first.append(std.fmt.parseUnsigned(u32, val[0..index], 10) catch break : bk1);}
        try second.append( std.fmt.parseUnsigned(u32, val[index + 3..val.len], 10) catch try std.fmt.parseUnsigned(u32, val[index + 3..], 10));
    }
    
    
    //comptime lessThanFn: fn(@TypeOf(context), lhs:T, rhs:T)bool
    const func = comptime struct{
        pub fn less(ctx : u1 , l : u32, r : u32) bool{
            _ =ctx;
            return l < r;
        }
    }.less;
    const first_list = try first.toOwnedSlice();
    const second_list = try second.toOwnedSlice();

    defer allocator.free(first_list);
    defer allocator.free(second_list);
    std.mem.sort(u32, first_list, @as(u1,1),comptime func);
    std.mem.sort(u32, second_list, @as(u1,1),comptime func);
    
    
    var score : u64 = 0;
    prt("{d}",.{for (first_list) |val|{
        const index  = std.sort.binarySearch(u32, second_list, val, 
        comptime struct{pub fn comp(a : u32, b : u32) std.math.Order{
            return std.math.order(a,b);
        }}.comp
        ) orelse first_list.len;
        if(index == first_list.len) continue;
        var count : u32 = 1;
        if (index > 0){for (0..index)|off|{
            if (second_list[index - off-1] == val) {count += 1;}
            else break;
        }}
        for (index + 1..second_list.len)|off|{
            if (second_list[off] == val) {count += 1;}
            else break;
        }
        
        score += val * count;
    } else score});
    

}

