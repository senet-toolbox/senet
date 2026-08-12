## App: QueryForge

## Description: A multi-tab SQL editor with syntax-highlighted editing, query history, schema browser, and tabular results in a three-panel layout.

---

### 1. Context Files

- **vapor-core** — always included

---

### 2. Theme Direction

- Mode: hybrid — dark editor pane, light chrome (top bar, sidebar, results area)
- Vibe: clean modern developer tool, dense but airy, professional
- Accent: blue family for active tabs, Submit button, selected sidebar entries, focus states
- Monospace font: IBM Plex Mono (or similar) for all code, SQL text, table data, line numbers
- Sans-serif: system sans for UI labels, buttons, timestamps, sidebar metadata
- Needs: SQL syntax highlight colors — keywords (blue), strings (green/teal), numbers (amber/orange), types (purple), comments (muted italic), operators (default), functions (cyan)
- Needs: status colors — green (success/row count), red (error), yellow-orange (warning)
- Needs: editor gutter — slightly darker than editor background, muted line number color
- Needs: tab states — active (blue accent underline or fill), inactive (muted), hover
- Needs: alternating or subtle row styling for results table
- Needs: history entry selected state (blue-tinted highlight)

---

### 3. Data Types

```
enum SidebarView { queries, history, schemas }

enum ResultTab { results, chart, explain }

struct QueryTab:
  - id: u32
  - name: []const u8          // e.g. "select all users", "create table posts"
  - query_text: []const u8
  - result: ?*const QueryResult
  - has_error: bool
  - error_message: []const u8

struct QueryResult:
  - columns: []const ColumnDef
  - rows: []const [5][]const u8
  - row_count: u32
  - execution_time_ms: u32

struct ColumnDef:
  - name: []const u8           // e.g. "id", "name", "email"
  - col_type: []const u8       // e.g. "int", "string", "datetime"

struct HistoryEntry:
  - id: u32
  - query_text: []const u8
  - timestamp: []const u8      // e.g. "20:37:23"
  - success: bool
  - row_count: u32             // relevant when success = true
  - error_message: []const u8  // relevant when success = false

struct SchemaColumn:
  - name: []const u8
  - col_type: []const u8       // INT, VARCHAR, TEXT, TIMESTAMP, BOOLEAN, UUID, SERIAL
  - nullable: bool

struct SchemaTable:
  - name: []const u8
  - columns: []const SchemaColumn
  - expanded: bool
```

**Sample query tabs (3):**

1. id=1, name="select all users" — has 20-row result, no error
2. id=2, name="create table posts" — no result, has_error=true, error_message="relation 'posts' already exists"
3. id=3, name="query #3" — empty query text, no result, no error

**Sample result rows (20 rows):**
Columns: id (int), name (string), email (string), power (int), created_at (datetime)

| id                                                       | name     | email                 | power   | created_at          |
| -------------------------------------------------------- | -------- | --------------------- | ------- | ------------------- |
| 1                                                        | Vic Rokx | vic@rokx.io           | 9001    | 2024-01-15 09:11:02 |
| 2                                                        | Goku     | goku@capsule.corp     | 9000000 | 2024-01-16 14:22:44 |
| 3                                                        | Vegeta   | vegeta@saiyan.io      | 8500000 | 2024-01-17 08:05:33 |
| 4                                                        | Piccolo  | piccolo@namek.net     | 4200000 | 2024-01-18 11:44:21 |
| 5                                                        | Gohan    | gohan@orange.star.edu | 7000000 | 2024-01-19 16:30:00 |
| 6                                                        | Krillin  | krillin@kame.house.io | 750000  | 2024-01-20 07:15:55 |
| 7                                                        | Alicia   | alicia@example.com    | 92      | 2024-01-21 12:01:09 |
| 8                                                        | Trunks   | trunks@capsule.corp   | 6800000 | 2024-01-22 18:44:30 |
| 9                                                        | Bulma    | bulma@capsule.corp    | 85      | 2024-01-23 09:52:17 |
| 10                                                       | Yamcha   | yamcha@desert.net     | 400000  | 2024-01-24 10:10:10 |
| 11–20: additional users with similar realistic structure |

**Sample history (6 entries, newest first):**

1. id=6, "SELECT \* FROM users LIMIT 20", "20:37:23", success=true, row_count=20
2. id=5, "CREATE TABLE posts (id SERIAL PRIMARY KEY, ...)", "20:31:04", success=false, error_message="relation 'posts' already exists"
3. id=4, "SELECT u.name, COUNT(p.id) FROM users u JOIN posts p ...", "20:28:55", success=true, row_count=18
4. id=3, "INSERT INTO sessions (user_id, token) VALUES (...)", "20:15:30", success=true, row_count=1
5. id=2, "ALTER TABLE comments ADD COLUMN upvotes INT DEFAULT 0", "19:58:11", success=true, row_count=106
6. id=1, "SELECT \* FROM sessions WHERE expired = true", "19:44:02", success=false, error_message="insufficient data left in message"

**Sample schema tables (4):**

- users: id SERIAL PK, name VARCHAR(100) NOT NULL, email VARCHAR(255) UNIQUE, power INT DEFAULT 0, created_at TIMESTAMP DEFAULT NOW()
- posts: id SERIAL PK, user_id INT REFERENCES users(id), title VARCHAR(255) NOT NULL, body TEXT, published_at TIMESTAMP
- comments: id SERIAL PK, post_id INT REFERENCES posts(id), author_id INT REFERENCES users(id), body TEXT NOT NULL, upvotes INT DEFAULT 0
- sessions: id UUID PK, user_id INT REFERENCES users(id), token VARCHAR(512), expires_at TIMESTAMP

---

### 4. State

```
main.zig (or TopBar.zig — closely coupled):
  var tabs: Vapor.Array(QueryTab)     // initialized with 3 sample tabs
  var active_tab_id: u32 = 1
  var next_tab_id: u32 = 4
  var sidebar_view: SidebarView = .history

Editor.zig (or inline in main):
  var editor_text: []const u8 = ""    // synced with active tab's query_text

Results.zig (or inline in main):
  var result_tab: ResultTab = .results
  var selected_rows: [20]bool          // all false initially
  var select_all: bool = false

Sidebar.zig (or inline in main):
  var history: Vapor.Array(HistoryEntry)     // initialized with 6 sample entries
  var selected_history_id: u32 = 6           // most recent selected by default
  var schema_tables: [4]SchemaTable          // with expanded=false initially
```

---

### 5. File Structure

Single-file app (`main.zig`) — all state is tightly coupled across panels.

⚠️ RULE: Don't generate files that already exist

PRE-EXISTING FILES:

```
main.zig
Theme.zig
config.zig
```

**Sections within `main.zig`:**

1. Imports and theme constants
2. Data type and enum definitions
3. Sample data (tabs, history, schema, result rows)
4. State variables
5. Helper functions (`activeTab()`, `truncateQuery()`, `formatRowCount()`)
6. SQL syntax highlighter (tokenizer + colored span emitter)
7. Handler functions
8. Component renderers (tab button, sidebar toggle, history card, schema node, result row)
9. Panel renderers (`renderTopBar`, `renderSidebar`, `renderEditor`, `renderResults`)
10. Main `render()` function — three-panel layout composition
11. `init()` function

---

### 6. Navigation

No page routing — single-page app at `"/"`.

Three navigation mechanisms:

1. **Query tabs** (top bar): dynamic per-tab state, switch via `active_tab_id`
2. **Sidebar view toggle**: three buttons switch `sidebar_view` between `.queries`, `.history`, `.schemas`
3. **Result sub-tabs**: three buttons switch `result_tab` between `.results`, `.chart`, `.explain`

---

### 7. Pages / Views

**view: Top Bar**

- shows: horizontal tab strip of open query tabs; each tab shows truncated name, active tab visually distinct
- shows: close (×) button on each tab
- shows: (+) button at the end of the tab list to create a new tab
- shows: three sidebar toggle buttons below tabs — [queries] [history] [schemas] — active one visually distinct
- controls: click tab → `switchTab`; click × → `closeTab`; click + → `newTab`; click sidebar button → `setSidebarView`

**view: Sidebar — History**

- shows (when `sidebar_view == .history`): scrollable list of history entries, newest first
- each entry shows: status indicator dot (green = success + row count like "18 rows", red = error + "Error"), truncated SQL query (2–3 lines), timestamp string, red error message below if `success == false`
- selected entry (`selected_history_id`) is visually highlighted with blue tint
- each entry shows: three action buttons — Load, Save, Delete
- controls: Load → `loadHistory`; Save → `saveHistory`; Delete → `deleteHistory`

**view: Sidebar — Schemas**

- shows (when `sidebar_view == .schemas`): tree of database tables
- each table row shows: table name; clicking expands/collapses it → `toggleSchemaTable`
- expanded table shows: list of its columns with name, type, nullable indicator

**view: Sidebar — Queries**

- shows (when `sidebar_view == .queries`): list of currently open query tabs with name and first line of query text
- shows: empty state "No saved queries yet" if tabs is empty (fallback)

**view: Editor**

- shows: line number gutter on the left, syntax-highlighted SQL on the right
- editing mechanism: invisible `TextArea` overlaid precisely over the highlighted display layer; display layer has `.whiteSpace(.pre)` to preserve indentation
- SQL syntax highlighting colors: keywords (blue), strings (green), numbers (amber), types (purple), comments (muted italic), operators (neutral), function names (cyan)
- shows: Copy button in top-right corner of the editor pane
- state sync: `editor_text` ↔ active tab's `query_text` (frame alloc for display, persist alloc when committed)
- implementation note: line numbers are computed dynamically from newline count in `editor_text`

**view: Results**

- shows (when `result_tab == .results` and active tab has result): data table with typed column headers ("id int", "name string", etc.), scrollable rows, footer showing row count and execution time
- shows (when `result_tab == .results` and active tab `has_error`): centered error message in red error styling
- shows (when `result_tab == .results` and no result yet): centered placeholder "Run a query to see results"
- shows (when `result_tab == .chart`): placeholder text "Chart visualization coming soon"
- shows (when `result_tab == .explain`): placeholder text "Query explain plan coming soon"
- controls: sub-tab buttons [Results] [Chart] [Explain] → `setResultTab`
- controls: Submit ⌘+Enter button → `submitQuery`; Check Memory button → `checkMemory`
- table features: per-row checkboxes → `toggleRow`; select-all header checkbox → `toggleSelectAll`

---

### 8. Interactions

```
handler: switchTab
  file: main.zig
  trigger: clicking a query tab in the top bar
  mutates: active_tab_id, resets result_tab to .results, resets selected_rows to all false, resets select_all to false, syncs editor_text from new active tab's query_text

handler: closeTab
  file: main.zig
  trigger: × button on a tab
  mutates: removes tab from tabs array; if closing active tab, switches to adjacent tab (prefer right, fall back left); always ensures at least 1 tab remains (create empty if last)

handler: newTab
  file: main.zig
  trigger: + button in top bar
  mutates: appends new empty QueryTab with id=next_tab_id, name="query #N", increments next_tab_id; calls switchTab to the new tab

handler: setSidebarView
  file: main.zig
  trigger: sidebar toggle buttons [queries] [history] [schemas]
  mutates: sidebar_view

handler: setResultTab
  file: main.zig
  trigger: result sub-tab buttons [Results] [Chart] [Explain]
  mutates: result_tab

handler: onEditorChange
  file: main.zig
  trigger: TextArea onChange event
  mutates: editor_text (frame alloc for live display); active tab's query_text (persist alloc to survive tab switch)

handler: submitQuery
  file: main.zig
  trigger: Submit button click (and keyboard shortcut Ctrl+Enter / ⌘+Enter if supported)
  logic: if query contains SELECT keyword → simulate success, populate active tab's result with sample data and row_count, set has_error=false; else → simulate error, set has_error=true with relevant error_message
  mutates: active tab's result, has_error, error_message, name (derive from query text if possible); appends new HistoryEntry to history (persist alloc); resets selected_rows and select_all
  side_effects: Toast success ("N rows returned in Xms") or Toast error ("Query failed: <message>")

handler: copyQuery
  file: main.zig
  trigger: Copy button in editor pane
  side_effects: writes editor_text to clipboard, shows Toast confirmation ("Query copied to clipboard")

handler: loadHistory
  file: main.zig
  trigger: Load button on a history entry
  mutates: active tab's query_text, editor_text (synced), selected_history_id = entry.id
  side_effects: Toast info ("Query loaded from history")

handler: saveHistory
  file: main.zig
  trigger: Save button on a history entry
  mutates: (placeholder / no-op for now)
  side_effects: Toast info ("Save coming soon")

handler: deleteHistory
  file: main.zig
  trigger: Delete button on a history entry
  mutates: removes entry from history array; if deleted entry was selected_history_id, updates selected_history_id to adjacent entry or 0

handler: toggleSchemaTable
  file: main.zig
  trigger: clicking a table row in the schemas sidebar
  mutates: that SchemaTable's expanded field toggled

handler: toggleRow
  file: main.zig
  trigger: row checkbox in results table
  mutates: selected_rows[index] toggled; recalculates select_all (true only if all rows selected)

handler: toggleSelectAll
  file: main.zig
  trigger: header checkbox in results table
  mutates: select_all toggled; sets all selected_rows[i] to match select_all

handler: checkMemory
  file: main.zig
  trigger: Check Memory button in results area
  side_effects: Toast info with placeholder memory stats (e.g. "Heap: 1.2MB used / 8MB limit")
```

---

### 9. Layout Composition

```
┌─────────────────────────────────────────────────────┐
│ Top Bar                                              │  fixed height ~72px
│  [tab: select all users ×] [tab: create table… ×]  │
│  [tab: query #3 ×] [+]                              │
│  [queries] [history] [schemas]                       │
├────────────────┬────────────────────────────────────┤
│                │ Editor                              │
│ Sidebar        │  gutter | highlighted SQL code     │  resizable: drag handle
│ 320px fixed    │  (TextArea overlay, .pre)          │  default ~300px height
│ full height    ├── drag handle ─────────────────────┤
│ scrolls        │ Results                             │
│ vertically     │  [Results][Chart][Explain]          │
│                │  [Check Memory] [Submit ⌘+Enter]   │
│                │  table / error / empty state        │  remaining height, scrolls
└────────────────┴────────────────────────────────────┘
Toast overlay — fixed top-right corner
```

- **Top bar**: fixed height, full width, does not scroll
- **Sidebar**: fixed width 320px, full remaining height below top bar, scrolls vertically independently
- **Main area**: remaining width, split vertically between Editor and Results
- **Editor pane**: resizable height via a draggable horizontal divider; default ~300px; has its own internal scroll for long queries
- **Drag handle**: thin horizontal bar between Editor and Results; dragging adjusts editor height state
- **Results pane**: remaining height after editor + drag handle; scrolls vertically for long result sets
- **Toast**: overlaid fixed top-right, does not affect layout flow

---

### Validation Checklist

- ✅ Every handler in views (section 8) is defined in interactions (section 9)
- ✅ Every state var (section 4) is used by at least one view or handler
- ✅ Every struct field referenced in views exists in data types (section 3)
- ✅ No page routing — single view; nav enum not needed
- ✅ File ownership is clear: all state and handlers live in `main.zig`
- ✅ `saveHistory` and Ctrl+Enter are called out as placeholder/conditional — Code Agent knows to treat them gracefully
