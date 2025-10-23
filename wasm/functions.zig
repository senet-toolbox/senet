// =====================================
// Event Handling
// =====================================

/// Registers a global event listener for a given event type and callback.
pub extern fn createEventListener(event_ptr: [*]const u8, event_type_len: usize, cb_id: u32) void;

/// Registers an event listener on a specific element.
pub extern fn createElementEventListener(element_ptr: [*]const u8, element_len: usize, event_ptr: [*]const u8, event_type_len: usize, cb_id: u32) void;

/// Registers an event listener on a specific element instance.
pub extern fn createElementEventInstListener(element_ptr: [*]const u8, element_len: usize, event_ptr: [*]const u8, event_type_len: usize, cb_id: u32) void;

/// Removes a previously registered event listener from an element.
pub extern fn removeElementEventListener(element_ptr: [*]const u8, element_len: usize, event_ptr: [*]const u8, event_type_len: usize, cb_id: u32) void;

/// Retrieves event data as a string or byte sequence.
pub extern fn getEventDataWasm(id: u32, ptr: [*]const u8, len: usize) [*:0]u8;

/// Gets input value associated with an event.
pub extern fn getEventDataInputWasm(id: u32) [*:0]u8;

/// Extracts a numeric property from event data.
pub extern fn getEventDataNumberWasm(id: u32, ptr: [*]const u8, len: usize) f32;

/// Prevents the default action for the specified event.
pub extern fn eventPreventDefault(id: u32) void;

// =====================================
// DOM Element Manipulation
// =====================================

/// Creates a new DOM element with an ID, type, and optional text.
pub extern fn createElement(id_ptr: [*]const u8, id_len: usize, elem_type: u8, btn_id: u32, text_ptr: [*]const u8, text_len: usize) void;

/// Adds a CSS class to the specified element.
pub extern fn addClass(id_ptr: [*]const u8, id_len: usize, class_id_ptr: [*]const u8, class_id_len: usize) void;

/// Removes a CSS class from the specified element.
pub extern fn removeClass(id_ptr: [*]const u8, id_len: usize, class_id_ptr: [*]const u8, class_id_len: usize) void;

/// Sets a numeric attribute on an element.
pub extern fn mutateDomElementWasm(id_ptr: [*]const u8, id_len: usize, attribute: [*]const u8, attribute_len: usize, value: u32) void;

/// Modifies a style attribute using a numeric value.
pub extern fn mutateDomElementStyleWasm(id_ptr: [*]const u8, id_len: usize, attribute: [*]const u8, attribute_len: usize, value: f32) void;

/// Modifies a style attribute using a string value.
pub extern fn mutateDomElementStyleStringWasm(id_ptr: [*]const u8, id_len: usize, attribute: [*]const u8, attribute_len: usize, value_ptr: [*]const u8, value_len: usize) void;

/// Defines a new CSS class dynamically.
pub extern fn createClass(class_ptr: [*]const u8, class_len: usize) void;

/// Highlights a DOM node visually (useful for debugging).
pub extern fn highlightTargetNode(ptr: [*]const u8, len: usize, type: u32) void;
pub extern fn highlightHoverTargetNode(ptr: [*]const u8, len: usize, type: u32) void;
pub extern fn clearHighlight() void;
pub extern fn clearHoverHighlight() void;

// =====================================
// Interactions
// =====================================

/// Focuses a DOM element (e.g., input).
pub extern fn elementFocusWasm(element_ptr: [*]const u8, element_len: usize) void;
pub extern fn elementFocusedWasm(element_ptr: [*]const u8, element_len: usize) bool;

/// Programmatically triggers a click on an element.
pub extern fn callClickWASM(id_ptr: [*]const u8, id_len: usize) void;

// =====================================
// Input Handling
// =====================================

/// Retrieves the current value of an input element.
pub extern fn getInputValueWasm(ptr: [*]const u8, len: usize) [*:0]u8;

/// Sets the value of an input element.
pub extern fn setInputValueWasm(ptr: [*]const u8, len: usize, text_ptr: [*]const u8, text_len: usize) void;

// =====================================
// Storage APIs - Local Storage
// =====================================

/// Stores a string value in local storage.
pub extern fn setLocalStorageStringWasm(ptr: [*]const u8, len: usize, value_ptr: [*]const u8, value_len: usize) void;

/// Retrieves a string value from local storage.
pub extern fn getLocalStorageStringWasm(ptr: [*]const u8, len: usize) [*:0]u8;

/// Removes a key from local storage.
pub extern fn removeLocalStorageWasm(ptr: [*]const u8, len: usize) void;

/// Clears all stored values in local storage.
pub extern fn clearLocalStorageWasm() void;

/// Stores a number in local storage.
pub extern fn setLocalStorageNumberWasm(ptr: [*]const u8, len: usize, value: u32) void;

/// Retrieves a signed integer from local storage.
pub extern fn getLocalStorageI32Wasm(ptr: [*]const u8, len: usize) i32;

/// Retrieves an unsigned integer from local storage.
pub extern fn getLocalStorageU32Wasm(ptr: [*]const u8, len: usize) u32;

/// Retrieves an unsigned integer (alias).
pub extern fn getLocalStorageUIntWasm(ptr: [*]const u8, len: usize) u32;

/// Retrieves a floating-point number (encoded) from local storage.
pub extern fn getLocalStorageF32Wasm(ptr: [*]const u8, len: usize) u32;

// =====================================
// Storage APIs - Cookies
// =====================================

/// Sets a cookie.
pub extern fn setCookieWasm(cookie_ptr: [*]const u8, cookie_len: usize) void;

/// Retrieves a cookie by name.
pub extern fn getCookieWasm(name_ptr: [*]const u8, name_len: usize) ?[*:0]u8;

/// Gets all cookies as a string.
pub extern fn getCookiesWasm() [*:0]u8;

// =====================================
// Async & Timers
// =====================================

// External JavaScript functions

/// Registers a JS timeout with callback.
pub extern "env" fn timeout(ms: u32, callbackId: u32) void;

/// Timeout with context preservation.
pub extern "env" fn timeoutCtx(ms: u32, callbackId: u32) void;

/// Registers a repeating interval.
pub extern "env" fn createInterval(name_ptr: [*]const u8, name_len: usize, delay: u32) void;

/// Creates a network hook with callback.
pub extern fn createHookWASM(urlPtr: [*]const u8, urlLen: usize, cb_id: u32) void;

// =====================================
// Window & Layout Info
// =====================================

/// Retrieves window metadata (e.g., dimensions).
pub extern fn getWindowInformationWasm() [*:0]u8;

/// Gets element’s bounding rectangle (x, y, width, height).
pub extern fn getBoundingClientRectWasm(ptr: [*]const u8, len: usize) [*]f32;

/// Gets element offsets relative to its parent.
pub extern fn getOffsetsWasm(ptr: [*]const u8, len: usize) [*]f32;

/// Retrieves numeric attributes (e.g., width, height).
pub extern fn getAttributeWasmNumber(ptr: [*]const u8, len: usize, attribute_ptr: [*]const u8, attribute_len: usize) u32;

// =====================================
// System Utilities
// =====================================

/// Toggles between light and dark themes.
pub extern fn toggleThemeWasm() void;

/// Copies text to the clipboard.
pub extern fn copyTextWasm(ptr: [*]const u8, len: usize) void;

/// Requests a UI re-render cycle.
pub extern fn requestRerenderWasm() void;

/// Tracks memory allocations (for debugging).
pub extern fn trackAllocWasm() void;

// =====================================
// Console & Debugging
// =====================================

/// Logs a message to the console.
pub extern fn consoleLogWasm(ptr: [*]const u8, len: usize) i32;

/// Logs a styled/colored message to the console.
pub extern fn consoleLogColoredWasm(ptr: [*]const u8, len: usize, style_ptr_1: [*]const u8, style_len_1: usize, style_ptr_2: [*]const u8, style_len_2: usize) i32;

pub extern fn createObserverWasm(ptr: [*]const u8, len: usize) void;
