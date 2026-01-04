// IndexedDB WASM Bindings for Zig - Fixed Version

const TransactionMode = enum(i32) {
    readonly = 0,
    readwrite = 1,
};

const OpenResult = enum(i32) {
    success = 0,
    upgrade_needed = 1,
    err = -1,
};

// ============ EXTERNAL FUNCTION DECLARATIONS ============

// Database Operations
extern "env" fn indexDbOpenWasm(name_ptr: [*]const u8, name_len: usize, version: i32) i32;
extern "env" fn indexDbOpenWithUpgradeWasm(name_ptr: [*]const u8, name_len: usize, version: i32) i32;
extern "env" fn indexDbCloseWasm() i32;
extern "env" fn indexDbDeleteDatabaseWasm(name_ptr: [*]const u8, name_len: usize) i32;
extern "env" fn indexDbIsUpgradingWasm() i32;

// Object Store Operations (only during upgrade)
extern "env" fn indexDbCreateObjectStoreWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    key_path_ptr: [*]const u8,
    key_path_len: usize,
    auto_increment: i32,
) i32;
extern "env" fn indexDbQueueCreateObjectStoreWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    key_path_ptr: [*]const u8,
    key_path_len: usize,
    auto_increment: i32,
) i32;
extern "env" fn indexDbDeleteObjectStoreWasm(store_name_ptr: [*]const u8, store_name_len: usize) i32;

// Index Operations (only during upgrade)
extern "env" fn indexDbCreateIndexWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    index_name_ptr: [*]const u8,
    index_name_len: usize,
    key_path_ptr: [*]const u8,
    key_path_len: usize,
    unique: i32,
    multi_entry: i32,
) i32;
extern "env" fn indexDbQueueCreateIndexWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    index_name_ptr: [*]const u8,
    index_name_len: usize,
    key_path_ptr: [*]const u8,
    key_path_len: usize,
    unique: i32,
    multi_entry: i32,
) i32;
extern "env" fn indexDbDeleteIndexWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    index_name_ptr: [*]const u8,
    index_name_len: usize,
) i32;

// Transaction Operations
extern "env" fn indexDbBeginTransactionWasm(store_names_ptr: [*]const u8, store_names_len: usize, mode: i32) i32;
extern "env" fn indexDbCommitTransactionWasm() i32;
extern "env" fn indexDbAbortTransactionWasm() i32;

// CRUD Operations
extern "env" fn indexDbPutWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    key_ptr: [*]const u8,
    key_len: usize,
    value_ptr: [*]const u8,
    value_len: usize,
) i32;
extern "env" fn indexDbAddWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    value_ptr: [*]const u8,
    value_len: usize,
) i32;
extern "env" fn indexDbGetWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    key_ptr: [*]const u8,
    key_len: usize,
    result_id_ptr: *u32,
) i32;
extern "env" fn indexDbGetResultWasm(result_id: u32, buffer_ptr: [*]u8, buffer_len: usize) i32;
extern "env" fn indexDbGetResultSizeWasm(result_id: u32) i32;
extern "env" fn indexDbGetAllWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    result_id_ptr: *u32,
) i32;
extern "env" fn indexDbDeleteWasm(
    store_name_ptr: [*]const u8,
    store_name_len: usize,
    key_ptr: [*]const u8,
    key_len: usize,
) i32;
extern "env" fn indexDbClearWasm(store_name_ptr: [*]const u8, store_name_len: usize) i32;
extern "env" fn indexDbCountWasm(store_name_ptr: [*]const u8, store_name_len: usize, count_ptr: *u32) i32;

// Utility Operations
extern "env" fn indexDbFreeResultWasm(result_id: u32) i32;
extern "env" fn indexDbObjectStoreExistsWasm(store_name_ptr: [*]const u8, store_name_len: usize) i32;
extern "env" fn indexDbGetObjectStoreNamesWasm(buffer_ptr: [*]u8, buffer_len: usize) i32;
extern "env" fn indexDbGetVersionWasm() i32;

// ============ WRAPPER FUNCTIONS ============

/// Open database with automatic schema setup using queued operations
/// Queue your createObjectStore calls BEFORE calling this
pub fn open(name: []const u8, version: i32) bool {
    return indexDbOpenWasm(name.ptr, name.len, version) == 0;
}

/// Open database and check if upgrade is needed
/// Returns: .success (no upgrade), .upgrade_needed (call schema ops then close/reopen), .error
pub fn openWithUpgrade(name: []const u8, version: i32) OpenResult {
    const result = indexDbOpenWithUpgradeWasm(name.ptr, name.len, version);
    return @enumFromInt(result);
}

pub fn close() bool {
    return indexDbCloseWasm() == 0;
}

pub fn deleteDatabase(name: []const u8) bool {
    return indexDbDeleteDatabaseWasm(name.ptr, name.len) == 0;
}

pub fn isUpgrading() bool {
    return indexDbIsUpgradingWasm() == 1;
}

/// Create object store - ONLY call during upgrade (when isUpgrading() returns true)
pub fn createObjectStore(store_name: []const u8, key_path: ?[]const u8, auto_increment: bool) bool {
    const kp_ptr = if (key_path) |kp| kp.ptr else @as([*]const u8, undefined);
    const kp_len = if (key_path) |kp| kp.len else 0;

    return indexDbCreateObjectStoreWasm(
        store_name.ptr,
        store_name.len,
        kp_ptr,
        kp_len,
        if (auto_increment) 1 else 0,
    ) == 0;
}

/// Queue object store creation - call BEFORE open() to set up schema
pub fn queueCreateObjectStore(store_name: []const u8, key_path: ?[]const u8, auto_increment: bool) bool {
    const kp_ptr = if (key_path) |kp| kp.ptr else @as([*]const u8, undefined);
    const kp_len = if (key_path) |kp| kp.len else 0;

    return indexDbQueueCreateObjectStoreWasm(
        store_name.ptr,
        store_name.len,
        kp_ptr,
        kp_len,
        if (auto_increment) 1 else 0,
    ) == 0;
}

pub fn deleteObjectStore(store_name: []const u8) bool {
    return indexDbDeleteObjectStoreWasm(store_name.ptr, store_name.len) == 0;
}

/// Create index - ONLY call during upgrade
pub fn createIndex(
    store_name: []const u8,
    index_name: []const u8,
    key_path: []const u8,
    unique: bool,
    multi_entry: bool,
) bool {
    return indexDbCreateIndexWasm(
        store_name.ptr,
        store_name.len,
        index_name.ptr,
        index_name.len,
        key_path.ptr,
        key_path.len,
        if (unique) 1 else 0,
        if (multi_entry) 1 else 0,
    ) == 0;
}

/// Queue index creation - call BEFORE open()
pub fn queueCreateIndex(
    store_name: []const u8,
    index_name: []const u8,
    key_path: []const u8,
    unique: bool,
    multi_entry: bool,
) bool {
    return indexDbQueueCreateIndexWasm(
        store_name.ptr,
        store_name.len,
        index_name.ptr,
        index_name.len,
        key_path.ptr,
        key_path.len,
        if (unique) 1 else 0,
        if (multi_entry) 1 else 0,
    ) == 0;
}

pub fn beginTransaction(store_names: []const u8, mode: TransactionMode) bool {
    return indexDbBeginTransactionWasm(store_names.ptr, store_names.len, @intFromEnum(mode)) == 0;
}

pub fn commitTransaction() bool {
    return indexDbCommitTransactionWasm() == 0;
}

pub fn abortTransaction() bool {
    return indexDbAbortTransactionWasm() == 0;
}

pub fn put(store_name: []const u8, key: ?[]const u8, value: []const u8) bool {
    const k_ptr = if (key) |k| k.ptr else @as([*]const u8, undefined);
    const k_len = if (key) |k| k.len else 0;

    return indexDbPutWasm(
        store_name.ptr,
        store_name.len,
        k_ptr,
        k_len,
        value.ptr,
        value.len,
    ) == 0;
}

pub fn add(store_name: []const u8, value: []const u8) bool {
    return indexDbAddWasm(store_name.ptr, store_name.len, value.ptr, value.len) == 0;
}

pub fn get(store_name: []const u8, key: []const u8, buffer: []u8) ?[]u8 {
    var result_id: u32 = 0;
    if (indexDbGetWasm(store_name.ptr, store_name.len, key.ptr, key.len, &result_id) != 0) {
        return null;
    }

    const len = indexDbGetResultWasm(result_id, buffer.ptr, buffer.len);
    if (len < 0) {
        _ = indexDbFreeResultWasm(result_id);
        return null;
    }

    return buffer[0..@intCast(len)];
}

pub fn getResultSize(result_id: u32) ?usize {
    const size = indexDbGetResultSizeWasm(result_id);
    return if (size >= 0) @intCast(size) else null;
}

pub fn getAll(store_name: []const u8, buffer: []u8) ?[]u8 {
    var result_id: u32 = 0;
    if (indexDbGetAllWasm(store_name.ptr, store_name.len, &result_id) != 0) {
        return null;
    }

    const len = indexDbGetResultWasm(result_id, buffer.ptr, buffer.len);
    _ = indexDbFreeResultWasm(result_id);

    if (len < 0) return null;
    return buffer[0..@intCast(len)];
}

pub fn delete(store_name: []const u8, key: []const u8) bool {
    return indexDbDeleteWasm(store_name.ptr, store_name.len, key.ptr, key.len) == 0;
}

pub fn clear(store_name: []const u8) bool {
    return indexDbClearWasm(store_name.ptr, store_name.len) == 0;
}

pub fn count(store_name: []const u8) ?u32 {
    var result: u32 = 0;
    if (indexDbCountWasm(store_name.ptr, store_name.len, &result) == 0) {
        return result;
    }
    return null;
}

pub fn objectStoreExists(store_name: []const u8) bool {
    return indexDbObjectStoreExistsWasm(store_name.ptr, store_name.len) == 1;
}

pub fn getVersion() ?i32 {
    const version = indexDbGetVersionWasm();
    return if (version >= 0) version else null;
}

// ============ USAGE EXAMPLES ============

/// Example 1: Using queued schema operations (recommended)
pub fn exampleWithQueue() void {
    // Queue schema operations BEFORE opening
    _ = queueCreateObjectStore("users", "id", true);
    _ = queueCreateObjectStore("posts", "id", true);

    // Open will execute queued operations during upgrade if needed
    if (!open("myapp", 1)) {
        return;
    }

    // Now use the database
    const user_json = "{\"id\": 1, \"name\": \"Alice\"}";
    _ = put("users", null, user_json);

    _ = close();
}

/// Example 2: Using upgrade callback pattern
pub fn exampleWithUpgradeCheck() void {
    const result = openWithUpgrade("myapp", 2);

    switch (result) {
        .upgrade_needed => {
            // We're in upgrade mode - create stores now
            _ = createObjectStore("users", "id", true);
            _ = createObjectStore("settings", "key", false);
            _ = createIndex("users", "email_idx", "email", true, false);
            // Database will finish opening after this
        },
        .success => {
            // Database opened, no upgrade needed
        },
        .err => {
            return;
        },
    }

    // Use the database...
    var buffer: [4096]u8 = undefined;
    if (get("users", "1", &buffer)) |data| {
        _ = data;
    }

    _ = close();
}

/// Example 3: Check if store exists before operations
pub fn exampleSafeOperations() void {
    if (!open("myapp", 1)) return;

    if (objectStoreExists("users")) {
        _ = put("users", null, "{\"id\": 1, \"name\": \"Bob\"}");
    }

    _ = close();
}

