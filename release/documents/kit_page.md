# Kit

Vapor Kit is a utilities module: fetching, navigation, parsing, and URL encoding/decoding.

{#fetch}

## Fetch

`fetch` takes a URL and an `HttpReq`, dispatches the request, and returns a `*Fetch` — a handle whose state and result the rest of your UI reads from. There's no separate "is it loading" boolean to keep in sync: the handle *is* the source of truth, and because a completed fetch is an [event into Vapor](reactivity.md#one-rule), the UI reconciles on its own when the response lands.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Kit = Vapor.Kit;
const Fetch = Vapor.Kit.Fetch;

pub export fn init() void {
    Vapor.init(.{});
    Kit.init(); // Kit must be initialized before any fetch

    Vapor.Page(.{ .route = "/" }, render, null);

    var f = Fetch.fetch("/documents/kit_page.md", .{ .method = .GET });
    f.handle(handleResponse, .{});
}

fn handleResponse(result: Kit.Fetch.Result) void {
    switch (result) {
        .ok => |data| {
            std.debug.print("Status: {d}\n", .{data.status});
            std.debug.print("Body: {s}\n", .{data.body});
        },
        .err => |err| {
            std.debug.print("Error: {s}\n", .{err.message});
        },
    }
}
```

Two things to get right up front:

- **`fetch` returns a pointer, `*Fetch`.** Store the pointer you get back; read `state()` and `response()` off it from render. How long that pointer stays valid depends on the request — see [Handle lifetime](#lifetime).
- **`handle` takes two arguments**: the callback and an args tuple. Pass `.{}` when the callback needs nothing extra; the tuple is how you hand it context without globals (see [Passing context](#passing-context)).

{#result}

### The Result

The callback receives a `Result`, a tagged union you must match on before touching any data. You can't reach the body without first acknowledging the error case — success and failure aren't representable at once.

```zig
pub const Result = union(enum) {
    ok: Response,
    err: ErrorResponse,
};
```

For the common cases there are helpers, so you don't always need a full `switch`:

```zig
if (result.isOk()) { ... }        // bool
const maybe_body = result.body();  // ?[]const u8, null on error
const maybe_resp = result.unwrap(); // ?Response, null on error
```

`Response` and `ErrorResponse` carry these fields:

| `Response` | Type | Notes |
|---|---|---|
| `status` | `u16` | HTTP status code |
| `body` | `[]const u8` | response body |
| `url` | `[]const u8` | final URL |
| `content_type` | `[]const u8` | |
| `content_length` | `usize` | |
| `elapsed_ms` | `u32` | round-trip time |
| `redirected` | `bool` | |
| `headers` | `?Headers` | **currently always `null`** — header parsing is not wired up yet |

| `ErrorResponse` | Type | Notes |
|---|---|---|
| `code` | `u16` | status code, where applicable |
| `message` | `[]const u8` | human-readable message |
| `body` | `[]const u8` | body, if any |
| `url` | `[]const u8` | |
| `elapsed_ms` | `u32` | |
| `kind` | `ErrorKind` | `.network`, `.timeout`, `.parse`, `.aborted`, `.http`, `.unknown` |

{#request-lifecycle}

### The request lifecycle

The callback model gives you a clean three-step flow. Because the `Fetch` handle is the single source of truth, the UI never tracks loading state separately — it reads `state()` and `response()` off the handle.

**1. Fire the request and keep the handle.**

```zig
const Vapor = @import("vapor");
const Kit = Vapor.Kit;
const Fetch = Vapor.Kit.Fetch;

var current_req: ?*Fetch = null;

fn getTodo() void {
    var f = Fetch.fetch("https://some-api.com/todos/1", .{ .method = .GET });
    f.handle(handleResponse, .{});
    current_req = f;
}
```

**2. Handle the response.** You don't assign state or trigger a re-render here — when this callback returns, Vapor reconciles for you (a completed `fetch` is an event in, same [events-in, UI-out rule](reactivity.md#one-rule) as a click). The handle already holds the last result; do whatever extra work you need.

```zig
fn handleResponse(result: Fetch.Result) void {
    switch (result) {
        .ok => |data| { _ = data; },
        .err => |err| { _ = err; },
    }
}
```

**3. Render from the handle.** Branch on `state()`, and read the actual fetched data back with `response()`. This is the half the loop depends on — `response()` returns the last `Result`, so you render what you fetched rather than a placeholder.

```zig
fn render() void {
    if (current_req) |f| {
        switch (f.state()) {
            .idle, .loading => {
                Vapor.Svg(.{ .svg = @embedFile("loader.svg"), .override = true })
                    .size(.px(36))
                    .end();
            },
            .ok => {
                if (f.response()) |result| {
                    if (result.body()) |b| {
                        Text(b).font(16, 400, .palette(.text_color)).end();
                    }
                }
            },
            .err => {
                if (f.response()) |result| switch (result) {
                    .err => |e| {
                        Text(e.message).font(14, 300, .palette(.text_color)).end();
                    },
                    else => {},
                };
            },
        }
    }
}
```

`state()` returns a `Kit.FetchState` (`.idle`, `.loading`, `.ok`, `.err`); `response()` returns `?Result` (the last result, or `null` before one arrives).

{#lifetime}

### Handle lifetime

How long a `*Fetch` stays valid depends on how the request is keyed. This is the one thing about fetch that isn't "just a pointer," so it's worth understanding.

- **GET / OPTIONS, or any method given an explicit `key`** are *registered*. They live in a persistent registry and are never recycled, so the pointer is valid for the life of the app. Stash it in a store, read it from render forever — it stays correct. This is the common case, and it's why the lifecycle example above can hold `current_req` indefinitely.

- **Keyless mutations** (`POST`/`PUT`/`PATCH`/`DELETE`) are *pooled*. They're meant to be read soon after firing — spinner, then result, then done. The pointer stays valid until its pool slot is recycled, which only happens once many other mutations have been fired. A stale read isn't a crash; it would just surface a different request's state.

**The rule:** if you need to hold a request long-term and read it from render across many events, give it a `key`. A keyed request is registered, so its pointer is as stable as a GET. Keyless mutations are transient by design — fire, read, move on.

{#dedup}

### Deduplication and keys

A request is identified by `(url, method)`, plus an optional `key`. Calling `fetch` again with the same identity returns the **same** `*Fetch` and shares its state and last result — you don't get a second independent request.

The default behavior is chosen per method, because the cost of getting it wrong is asymmetric — a redundant read is cheap, but a silently-dropped write is a real bug:

- **GET / OPTIONS** coalesce by `(url, method)`. Firing the same GET from two places shares one handle and one state — that's the point.
- **Mutations** (`POST`/`PUT`/`PATCH`/`DELETE`) are **independent per call** by default. A write is a discrete action, not shared state, so two rapid creates don't collide and clobber each other.

The `key` overrides both. It *is* the request's identity: give two calls the same key and they coalesce; give a read a unique key and it becomes distinct.

```zig
// Double-submit protection: repeated taps coalesce onto one in-flight request.
var f = Fetch.fetch("/todos", .{
    .method = .POST,
    .body = "{\"title\":\"Walk the dog\"}",
    .body_type = .json,
    .key = "create-todo",
});
f.handle(handleResponse, .{});
```

For the common double-click case you often don't even need a key: `handle()` sets `.loading` synchronously, so a button that disables on `.loading` closes the window before a second request can fire. Reach for `key` when you want request-level coalescing (programmatic retries, multiple components triggering the same save) or a stable long-lived handle.

{#passing-context}

### Passing context to the callback

The framework prepends the `Result` onto your args tuple: whatever you pass after the callback arrives *after* the result. So `handle(myFn, .{ &state, "extra" })` calls `myFn(result, &state, "extra")`. This lets a callback act on specific state without a global.

```zig
const Item = struct { id: u32, loaded: bool = false };
var item = Item{ .id = 1 };

fn getItem() void {
    var f = Fetch.fetch("https://some-api.com/items/1", .{ .method = .GET });
    f.handle(onItem, .{ &item }); // onItem receives (result, &item)
}

fn onItem(result: Fetch.Result, target: *Item) void {
    if (result.isOk()) target.loaded = true;
}
```

{#cancel-release}

### Canceling and releasing

`cancel()` drops the in-flight request and returns the handle to `.idle`; any pending callback is discarded rather than fired.

```zig
if (current_req) |f| f.cancel();
```

`release()` is an optional eager reclaim for a *pooled* mutation handle, for when you know the UI is done with the result. It's a no-op for registered (GET/keyed) requests, and never required — pooled slots are also reclaimed automatically when the pool is under pressure. Use it only as an optimization.

{#post}

### POST and other methods, with a body

`HttpReq` covers all standard methods and request options. For a body, set `body` and the matching `body_type`:

```zig
fn createTodo() void {
    var f = Fetch.fetch("https://some-api.com/todos", .{
        .method = .POST,
        .body = "{\"title\":\"Walk the dog\",\"done\":false}",
        .body_type = .json,
    });
    f.handle(handleResponse, .{});
    current_req = f;
}
```

The full `HttpReq` shape:

| Field | Type | Default | |
|---|---|---|---|
| `method` | `Methods` | — | `GET`, `POST`, `PATCH`, `DELETE`, `PUT`, `OPTIONS` |
| `body` | `?[]const u8` | `null` | |
| `body_type` | `BodyType` | `.string` | `.string` or `.json` |
| `key` | `?[]const u8` | `null` | dedup identity / stable-handle opt-in (see above) |
| `headers` | `?Headers` | `null` | |
| `extra_headers` | `[]const HttpHeader` | `&.{}` | |
| `mode` | `?[]const u8` | `null` | passthrough to the underlying fetch |
| `redirect` | `?[]const u8` | `null` | passthrough |
| `referrer_policy` | `?[]const u8` | `null` | passthrough |
| `integrity` | `?[]const u8` | `null` | passthrough |
| `use_credentials` | `bool` | `false` | |
| `credentials` | `?[]const u8` | `null` | |

{#debugging}

### Debugging and mocking

Two fields on the handle control debugging: `debug` for logging, and `mock` for simulating conditions. **Set both before calling `handle()`** — `handle` reads them when it dispatches, so setting them afterward has no effect.

`mock` is a single tagged union, so you can't combine contradictory states:

```zig
pub const Mock = union(enum) {
    none,                          // default — real request
    infinite_loading,              // stays in .loading forever
    error_response: ErrorResponse, // force an error
    ok_response: Response,         // force a success
};
```

**Force an error.** Note `debug` and `mock` are set *before* `handle`:

```zig
var current_fetch: ?*Fetch = null;

fn getTodo() void {
    var f = Fetch.fetch("https://some-api.com/todos/1", .{ .method = .GET });
    f.debug = true;
    f.mock = .{ .error_response = .{
        .code = 404,
        .message = "Error Not Found",
        .body = "",
        .url = "https://some-api.com/todos/1",
        .elapsed_ms = 1000,
        .kind = .network,
    } };
    f.handle(handleResponse, .{});
    current_fetch = f;
}
```

With this set, `state()` is `.err` and the `.err` branch always renders.

**Force an infinite loading state**, useful for checking spinners:

```zig
fn getTodo() void {
    var f = Fetch.fetch("https://some-api.com/todos/1", .{ .method = .GET });
    f.mock = .infinite_loading;
    f.handle(handleResponse, .{});
    current_fetch = f;
}
```

The handle stays in `.loading`, so the `.loading` branch always renders.

**Force a successful response**, to build UI before the endpoint exists:

```zig
fn getTodo() void {
    var f = Fetch.fetch("https://some-api.com/todos/1", .{ .method = .GET });
    f.mock = .{ .ok_response = .{
        .status = 200,
        .body = "{\"id\":1,\"title\":\"Mocked todo\"}",
        .headers = null,
        .url = "https://some-api.com/todos/1",
        .content_type = "application/json",
        .content_length = 0,
        .elapsed_ms = 50,
        .redirected = false,
    } };
    f.handle(handleResponse, .{});
    current_fetch = f;
}
```

Mocked responses are delivered synchronously: the callback fires immediately during `handle`, and `state()` / `response()` reflect the mock right away.
