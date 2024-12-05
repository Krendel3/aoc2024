
const std = @import("std"); 
const int = i32;
const list = std.ArrayList(int);
const rulesType = std.AutoHashMap(int, *list);
var rules : rulesType = undefined;
pub fn main() !void{
    //11307 high
    std.debug.print("{d} \n",.{try calculateSum("src/5day/input.txt")});
}
fn calculateSum(path : [] const u8) !int{
    var gpa =std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const string = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
    defer allocator.free(string);
    
    var iter = std.mem.splitSequence(u8,string,"\n");
    rules = rulesType.init(allocator);
    defer rules.deinit();
    while(iter.next())|line|{
        if(line.len == 1 and line[0]==13) break;
        var values_iter = std.mem.splitSequence(u8, line, "|");
        const key = try std.fmt.parseInt(int,values_iter.next().?, 10);
        const val = try std.fmt.parseInt(int,std.mem.trimRight(u8, values_iter.next().?, &([_]u8{13})), 10);
        if (rules.get(key))|set|{
            try set.*.append(val);
        }else{
            const space = try arena.allocator().alloc(list, 1);
            space[0] = list.init(arena.allocator());
            try rules.put(key,@constCast(&space[0]));
            try rules.get(key).?.*.append(val);
        }
    }
    var count : int = 0;
    return while(iter.next())|line|{
        count += try middle(std.mem.trimRight(u8, line, &([_]u8{13})),arena.allocator());
    } else count;
}
fn middle(line : []const u8,allocator : std.mem.Allocator) !int{
    var nums = list.init(allocator);
    defer nums.deinit();
    var iter = std.mem.splitScalar(u8, line, ","[0]);
    while (iter.next())|val|{
        try nums.append(try std.fmt.parseInt(int, val, 10));
    }
    var ptr : usize = 1;
    var incorrect = false;
    return if(while (ptr < nums.items.len){
        if (for (0..ptr) |index|{
            if (rules.get(nums.items[ptr]))|vals|{
                if (contains(vals,nums.items[index])){
                    const container = nums.items[ptr];
                    nums.items[ptr] = nums.items[index];
                    nums.items[index] = container;
                    break false;
                }
            }
        }else true) {ptr += 1;}
        else {ptr=1;incorrect = true;}
    }else incorrect) nums.items[nums.items.len / 2] else 0;
}
fn contains(l : *list, i : int) bool{
    for(0..l.items.len)|index|{
        if(l.items[index] == i)return true;
    }return false;
}
