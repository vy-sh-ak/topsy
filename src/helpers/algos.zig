pub fn binarySearch(comptime T: type, arr: []const T, l: i32, r: i32, x: T) i32 {
    var left = l;
    var right = r;
    while (left <= right) {
        const mid = left + @divTrunc((right - left), 2);
        const mid_idx: usize = @intCast(mid);
        if (arr[mid_idx] == x) return mid;
        if (arr[mid_idx] > x) {
            right = mid - 1;
        } else {
            left = mid + 1;
        }
    }
    return -1;
}