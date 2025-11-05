pub extern fn createChartWasm(
    id_ptr: [*]const u8,
    id_len: usize,
    config_ptr: [*]const u8,
    config_len: usize,
) void;
