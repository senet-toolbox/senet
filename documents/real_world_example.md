# Assembler — Vapor Component Examples & Cookbook

> **Purpose:** This document provides real-world, production-grade component examples for the Assembler AI to reference when generating Vapor/Zig UI code. Every pattern below is extracted from a working dashboard application with sidebar navigation, routing, SQL editor, data tables, charts, modals, forms, and more.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Application Initialization & Routing](#application-initialization--routing)
3. [Sidebar Navigation](#sidebar-navigation)
4. [Page Layout (Sidebar + Content)](#page-layout-sidebar--content)
5. [Dashboard Overview Page](#dashboard-overview-page)
6. [Data Table with Search & Pagination](#data-table-with-search--pagination)
7. [Detail Sheet (Slide-Over Panel)](#detail-sheet-slide-over-panel)
8. [SQL Editor with Syntax Highlighting](#sql-editor-with-syntax-highlighting)
9. [Charts & Data Visualization](#charts--data-visualization)
10. [Forms & Input Fields](#forms--input-fields)
11. [Confirmation Dialogs](#confirmation-dialogs)
12. [Toast Notifications](#toast-notifications)
13. [Dropdowns & Popovers](#dropdowns--popovers)
14. [Theme System](#theme-system)
15. [HTTP Data Fetching](#http-data-fetching)
16. [Animations](#animations)
17. [Reusable Component Patterns](#reusable-component-patterns)
18. [Common Gotchas & Best Practices](#common-gotchas--best-practices)

---

## 1. Project Structure {#project-structure}

A typical Vapor dashboard project is organized with one file per component/page:

```
src/
├── main.zig                    # App init, route registration
├── theme.zig                   # Theme constants, toggleTheme
├── pages/
│   ├── Dashboard.zig           # Main layout (sidebar + content router)
│   ├── Overview.zig            # Dashboard overview with charts/stats
│   ├── tables/
│   │   └── Page.zig            # Data table page with search & detail sheet
│   └── acorn/
│       ├── SqlEditorPage.zig   # SQL editor page
│       ├── sql_autocomplete.zig # Autocomplete engine
│       ├── SchemaPanel.zig     # Database schema sidebar
│       └── QueryStore.zig      # Saved queries state
└── components/
    └── Opaque.zig              # Shared component re-exports
```

**Key principle:** One component per file. State at file scope. Cross-file sharing via `@import`.

---

## 2. Application Initialization & Routing {#application-initialization--routing}

```zig
// main.zig
const std = @import("std");
const Vapor = @import("vapor");
const Dashboard = @import("pages/Dashboard.zig");
const Overview = @import("pages/Overview.zig");
const TablePage = @import("pages/tables/Page.zig");

export fn init() void {
    Vapor.init(.{});

    // Register routes
    Dashboard.init();       // /dashboard — main layout
    Overview.init();        // /overview — overview page
    TablePage.init();       // /tables — data table page

    // Register layout (wraps all /dashboard/* routes)
    Vapor.registerLayout("/dashboard", dashboardLayout, .{}) catch unreachable;
}

fn dashboardLayout(page: Vapor.PageFn) void {
    Dashboard.renderNavigation();   // Sidebar
    page();                         // Active route content
}
```

**Page registration with init pattern:**

```zig
// pages/Overview.zig
pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);

    // Initialize page-specific state
    chart = Chart.init(Vapor.arena(.persist), .{ .height = 200, .width = 500 });
    chart.build() catch unreachable;
}

fn render() void {
    // Page content here
}
```

---

## 3. Sidebar Navigation {#sidebar-navigation}

### Navigation Item Enum

Define navigation items as an enum with associated metadata:

```zig
const NavItem = enum {
    overview,
    tables,
    sql_editor,
    errors,
    settings,

    pub fn label(self: NavItem) []const u8 {
        return switch (self) {
            .overview => "Overview",
            .tables => "Tables",
            .sql_editor => "SQL Editor",
            .errors => "Errors",
            .settings => "Settings",
        };
    }

    pub fn icon(self: NavItem) *const Vapor.IconTokens {
        return switch (self) {
            .overview => .house,
            .tables => .table,
            .sql_editor => .terminal,
            .errors => .exclamation_triangle,
            .settings => .gear,
        };
    }

    pub fn route(self: NavItem) []const u8 {
        return switch (self) {
            .overview => "/dashboard",
            .tables => "/dashboard/tables",
            .sql_editor => "/dashboard/sql",
            .errors => "/dashboard/errors",
            .settings => "/dashboard/settings",
        };
    }
};
```

### Sidebar State

```zig
var selected_nav: NavItem = .overview;
var sidebar_expanded: bool = false;

const SIDEBAR_COLLAPSED: f32 = 60;
const SIDEBAR_EXPANDED: f32 = 240;
const ICON_AREA_WIDTH: f32 = 40;
```

### Sidebar Event Handlers

```zig
fn selectNav(item: NavItem) void {
    Vapor.Kit.navigate(item.route());
    selected_nav = item;
}

fn onSidebarHover(_: *Vapor.Event) void {
    sidebar_expanded = true;
}

fn onSidebarLeave(_: *Vapor.Event) void {
    sidebar_expanded = false;
}
```

### Collapsed Sidebar (Icon-Only)

```zig
fn renderCollapsedSidebar() void {
    // Logo
    Box()
        .width(.percent(100))
        .layout(.center)
        .height(.px(48))
        .children({
        Vapor.Graphic(.{ .src = "/assets/logo.svg" })
            .fill(.palette(.text_color))
            .size(.px(24))
            .end();
    });

    // Nav items — icon only
    Stack()
        .width(.percent(100))
        .spacing(4)
        .children({
        for (std.enums.values(NavItem)) |nav_item| {
            const is_active = selected_nav == nav_item;

            ButtonCtx(selectNav, .{nav_item})
                .width(.px(ICON_AREA_WIDTH))
                .height(.px(40))
                .layout(.center)
                .pointer()
                .background(if (is_active) .palette(.tint) else .transparent)
                .hover(.{ .background = if (is_active) .palette(.tint) else .palette(.highlight_color) })
                .duration(150)
                .children({
                Icon(nav_item.icon())
                    .font(16, 300, if (is_active) .white else .palette(.text_secondary))
                    .end();
            });
        }
    });
}
```

### Expanded Sidebar (Icon + Label)

```zig
fn renderExpandedSidebar() void {
    // Logo + Title
    Box()
        .layout(.left_center)
        .spacing(12)
        .padding(.xy(12, 0))
        .height(.px(48))
        .children({
        Vapor.Graphic(.{ .src = "/assets/logo.svg" })
            .fill(.palette(.text_color))
            .size(.px(24))
            .end();
        Text("My Project")
            .animationEnter("opaque-fade-in")
            .font(20, 700, .palette(.text_color))
            .end();
    });

    // Nav items — icon + label
    Stack()
        .width(.percent(100))
        .spacing(4)
        .children({
        for (std.enums.values(NavItem)) |nav_item| {
            const is_active = selected_nav == nav_item;

            ButtonCtx(selectNav, .{nav_item})
                .width(.percent(100))
                .height(.px(40))
                .layout(.left_center)
                .spacing(12)
                .padding(.xy(12, 0))
                .pointer()
                .duration(150)
                .background(if (is_active) .palette(.tint) else .transparent)
                .hover(.{
                    .background = if (is_active) .palette(.tint) else .palette(.highlight_color),
                })
                .children({
                Box()
                    .width(.px(ICON_AREA_WIDTH))
                    .height(.px(40))
                    .layout(.center)
                    .children({
                    Icon(nav_item.icon())
                        .font(14, 300, if (is_active) .white else .palette(.text_secondary))
                        .end();
                });
                Text(nav_item.label())
                    .animationEnter("opaque-fade-in")
                    .font(14, 400, if (is_active) .white else .palette(.text_color))
                    .end();
            });
        }
    });
}
```

### Full Sidebar Component

```zig
pub fn renderNavigation() void {
    const sidebar_width: Vapor.Types.Sizing = if (sidebar_expanded) .px(SIDEBAR_EXPANDED) else .px(SIDEBAR_COLLAPSED);

    Box()
        .pos(.tl(.percent(0), .percent(0), .fixed))
        .zIndex(100)
        .width(sidebar_width)
        .height(.percent(100))
        .background(.palette(.background))
        .border(.right(1, .palette(.border_color_light)))
        .transition(.{
            .properties = &.{ .width, .opacity, .padding },
            .duration = 100,
            .timing = .easeInOut,
        })
        .onHover(onSidebarHover)
        .onLeave(onSidebarLeave)
        .children({
        Stack()
            .width(.percent(100))
            .height(.percent(100))
            .padding(.all(10))
            .spacing(4)
            .children({
            if (sidebar_expanded) {
                renderExpandedSidebar();
            } else {
                renderCollapsedSidebar();
            }
        });
    });
}
```

---

## 4. Page Layout (Sidebar + Content) {#page-layout-sidebar--content}

The main render function combines the sidebar with a content area that switches based on the active nav item:

```zig
fn render() void {
    Box()
        .width(.percent(100))
        .height(.percent(100))
        .children({

        // Sidebar (fixed, rendered separately via layout)
        renderNavigation();

        // Main content area — offset by sidebar width
        Box()
            .ml(if (sidebar_expanded) SIDEBAR_EXPANDED else SIDEBAR_COLLAPSED)
            .width(.expand)
            .height(.percent(100))
            .scroll(.scroll_y())
            .children({

            // Route-based content switching
            switch (selected_nav) {
                .overview => renderDashboardView(),
                .tables => TablePage.render(),
                .sql_editor => SqlEditor.render(),
                .errors => renderErrorsView(),
                .settings => renderSettingsView(),
            }
        });
    });

    // Overlays (rendered on top, outside main layout)
    detail_sheet.render();
}
```

---

## 5. Dashboard Overview Page {#dashboard-overview-page}

### Summary Card Component

```zig
const SummaryKind = enum {
    total_users,
    active_sessions,
    error_rate,
    revenue,

    pub fn label(self: SummaryKind) []const u8 {
        return switch (self) {
            .total_users => "Total Users",
            .active_sessions => "Active Sessions",
            .error_rate => "Error Rate",
            .revenue => "Revenue",
        };
    }

    pub fn value(self: SummaryKind) usize {
        return switch (self) {
            .total_users => 12847,
            .active_sessions => 342,
            .error_rate => 2,
            .revenue => 48500,
        };
    }
};

fn SummaryCard(kind: SummaryKind) void {
    Stack()
        .width(.expand)
        .border(.simple(.palette(.border_color_light)))
        .padding(.all(16))
        .spacing(8)
        .children({
        Text(kind.label())
            .font(14, 300, .palette(.text_secondary))
            .end();
        TextFmt("{d}", .{kind.value()})
            .font(28, 600, .palette(.text_color))
            .end();
    });
}
```

### Overview Layout

```zig
fn renderOverview() void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .spacing(24)
        .padding(.all(24))
        .layer(.dot(0.5, 12, .transparentize(.palette(.border_color), 0.3)))
        .children({

        // Summary cards row
        Box()
            .width(.percent(100))
            .spacing(16)
            .children({
            SummaryCard(.total_users);
            SummaryCard(.active_sessions);
            SummaryCard(.error_rate);
            SummaryCard(.revenue);
        });

        // Charts row
        Box()
            .width(.percent(100))
            .spacing(16)
            .children({
            // Revenue chart
            Stack()
                .width(.percent(50))
                .padding(.all(16))
                .border(.round(.palette(.border_color_light), .all(12)))
                .spacing(8)
                .children({
                Text("Revenue (30d)")
                    .font(16, 600, .palette(.text_color))
                    .end();
                revenue_chart.render();
            });

            // Requests chart
            Stack()
                .width(.percent(50))
                .padding(.all(16))
                .border(.round(.palette(.border_color_light), .all(12)))
                .spacing(8)
                .children({
                Text("Requests (24h)")
                    .font(16, 600, .palette(.text_color))
                    .end();
                requests_chart.render();
            });
        });
    });
}
```

---

## 6. Data Table with Search & Pagination {#data-table-with-search--pagination}

### State

```zig
var table: DynamicTable(columns, .{}) = undefined;
var search_query: []const u8 = "";
var selected_column: usize = 0;
var rows: Vapor.Array(DynamicRow) = undefined;
var new_columns: Vapor.Array(DataColumn) = undefined;
```

### Initialization

```zig
pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);

    const allocator = Vapor.arena(.persist);
    new_columns = Vapor.array(DataColumn, .persist);
    rows = Vapor.array(DynamicRow, .persist);

    table.init(&.{});
    table.per_page = 16;
    table.on_row_click = onRowClick;
    table.click_on_row = true;
}
```

### Search Handler

```zig
fn onSearch(evt: *Vapor.Event) void {
    table.onSearch(evt.text(), selected_column);
}
```

### Table Page Render

```zig
pub fn render() void {
    Stack()
        .width(.percent(100))
        .padding(.all(28))
        .spacing(8)
        .children({

        // Search bar
        Box()
            .width(.percent(50))
            .layout(.left_center)
            .spacing(8)
            .children({
            TextField(.string)
                .bind(&search_query)
                .placeholder("Search...")
                .onChange(onSearch)
                .width(.percent(100))
                .height(.px(32))
                .padding(.xy(12, 0))
                .border(.round(.palette(.border_color_light), .all(4)))
                .end();
        });

        // Error state or data table
        if (err_response) |err| {
            Stack()
                .spacing(8)
                .width(.percent(30))
                .border(.simple(.palette(.text_color)))
                .padding(.all(8))
                .children({
                TextFmt("{s} {s}", .{ err.code, err.severity })
                    .font(16, 300, .palette(.text_color))
                    .end();
                Text(err.message)
                    .font(14, 300, .palette(.text_color))
                    .end();
            });
        } else {
            table.render();
        }
    });

    // Lifecycle hook — fetch data on mount
    Vapor.Static.HooksCtx(.mounted, mount, .{})({});
    sheet.render();
}

fn mount() void {
    fetchData();
}
```

---

## 7. Detail Sheet (Slide-Over Panel) {#detail-sheet-slide-over-panel}

### Sheet State & Setup

```zig
const Sheet = Opaque.Sheet;

var sheet: Sheet = .{
    .content = showRowDetails,
    .on_close = onSheetClose,
};

var current_row: *DynamicRow = undefined;
```

### Opening the Sheet

```zig
fn onRowClick(row: *DynamicRow) void {
    current_row = row;
    pending_action = .none;
    action_feedback = null;
    sheet.open();
}

fn onSheetClose(_: *Sheet) void {
    pending_action = .none;
    action_feedback = null;
}
```

### Sheet Content Renderer

```zig
fn showRowDetails(_: *Sheet) void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(16))
        .spacing(12)
        .children({

        // Header with email + copy button
        if (current_row.get("email")) |value| {
            switch (value) {
                .string => |v| {
                    Box()
                        .width(.percent(100))
                        .layout(.x_between_center)
                        .padding(.xy(12, 8))
                        .border(.simple(.palette(.border_color_light)))
                        .radius(.all(4))
                        .children({
                        Text(v.?).font(18, 300, .palette(.text_color)).end();
                        ButtonCtx(copyToClipboard, .{v.?})
                            .size(.square_px(32))
                            .layout(.center)
                            .pointer()
                            .children({
                            Icon(.copy).font(14, 300, .palette(.text_color)).end();
                        });
                    });
                },
                else => {},
            }
        }

        // Detail fields
        for (new_columns.items) |col| {
            if (current_row.get(col.name)) |value| {
                Box()
                    .width(.percent(100))
                    .border(.bottom(1, .palette(.border_color_light)))
                    .padding(.xy(8, 12))
                    .spacing(8)
                    .children({
                    Text(col.name).font(14, 300, .palette(.text_color)).end();
                    renderValue(value);
                });
            }
        }

        // Action buttons (Delete / Ban)
        renderActionSection();
    });
}
```

---

## 8. SQL Editor with Syntax Highlighting {#sql-editor-with-syntax-highlighting}

### Editor State

```zig
var text: []const u8 = "SELECT * FROM users LIMIT 10;";
var text_area: Vapor.Binded = .{};
var autocomplete: SQLAutoComplete = undefined;
var new_cursor_pos: ?usize = null;
```

### Editor Initialization

```zig
pub fn init() void {
    Vapor.Page(.{ .route = "/dashboard/sql" }, render, null);
    autocomplete = SQLAutoComplete.init(Vapor.arena(.persist));
}
```

### Keyboard Handling

```zig
fn handleKeyDown(evt: *Vapor.Event) void {
    const key = evt.key();

    // Cmd+Enter — execute query
    if (std.mem.eql(u8, key, "Enter") and evt.metaKey()) {
        evt.preventDefault();
        executeQuery();
        return;
    }

    // Cmd+/ — toggle comment
    if (std.mem.eql(u8, key, "/") and evt.metaKey()) {
        evt.preventDefault();
        toggleSQLComment(evt);
        return;
    }

    // Tab — autocomplete or indent
    if (std.mem.eql(u8, key, "Tab")) {
        evt.preventDefault();
        if (autocomplete.visible) {
            acceptAutocompleteSuggestion();
        } else {
            handleTab(evt.shiftKey());
        }
        return;
    }

    // Escape — dismiss autocomplete
    if (std.mem.eql(u8, key, "Escape")) {
        autocomplete.hide();
        return;
    }

    // Arrow keys — navigate autocomplete
    if (autocomplete.visible) {
        if (std.mem.eql(u8, key, "ArrowUp")) {
            evt.preventDefault();
            autocomplete.moveUp();
            return;
        }
        if (std.mem.eql(u8, key, "ArrowDown")) {
            evt.preventDefault();
            autocomplete.moveDown();
            return;
        }
    }
}
```

### Editor Render

```zig
fn render() void {
    Box()
        .width(.percent(100))
        .height(.percent(100))
        .pos(.relative)
        .children({

        // TextArea (transparent, captures input)
        TextArea()
            .ref(&text_area)
            .bind(&text)
            .onChange(onTextChange)
            .onEvent(.keydown, handleKeyDown)
            .width(.percent(100))
            .height(.percent(100))
            .fontFamily("JetBrains Mono, monospace")
            .fontSize(14)
            .padding(.all(16))
            .background(.transparent)
            .end();

        // Syntax-highlighted overlay (visual only, no interaction)
        Box()
            .pos(.tl(.px(0), .px(0), .absolute))
            .width(.percent(100))
            .height(.percent(100))
            .padding(.all(16))
            .inlineStyle("pointer-events: none;", .{})
            .children({
            renderHighlightedTokens();
        });

        // Autocomplete dropdown
        autocomplete.render();
    });
}
```

---

## 9. Charts & Data Visualization {#charts--data-visualization}

### Chart Initialization

```zig
var revenue_chart: Chart = undefined;

const revenue_points = [_]Chart.Point{
    .{ .x = 1, .y = 10 },
    .{ .x = 2, .y = 24 },
    .{ .x = 3, .y = 18 },
    // ...
};

pub fn init() void {
    revenue_chart = Chart.init(Vapor.arena(.persist), .{
        .height = 200,
        .width = 500,
    });
    revenue_chart.addSeries(.line, "Revenue", &revenue_points, .{
        .color = .palette(.text_color),
    }) catch unreachable;
    revenue_chart.xAxis(.{ .label = "Month", .tick_count = 12 });
    revenue_chart.yAxis(.{ .label = "", .tick_count = 6 });
    revenue_chart.build() catch unreachable;
}
```

### Chart Panel (Reusable Wrapper)

```zig
fn ChartPanel(title: []const u8, subtitle: []const u8, chart: *Chart) void {
    Stack()
        .width(.percent(50))
        .padding(.all(16))
        .border(.simple(.palette(.border_color_light)))
        .borderStyle(.dashed)
        .spacing(8)
        .children({
        Text(title).font(20, 600, .palette(.text_color)).end();
        Text(subtitle).font(14, 300, .palette(.text_color)).end();
        chart.render();
    });
}
```

### Stacked Bar Chart

```zig
const get_color = Vapor.Types.Color.hex("#222160");
const post_color = Vapor.Types.Color.hex("#3344FF");

const http_data = [_]Chart.Point{
    Chart.Point{ .x = 1, .stack = &.{
        .{ .value = 52, .color = get_color },
        .{ .value = 11, .color = post_color },
    }},
    Chart.Point{ .x = 2, .stack = &.{
        .{ .value = 48, .color = get_color },
        .{ .value = 13, .color = post_color },
    }},
};
```

---

## 10. Forms & Input Fields {#forms--input-fields}

### Basic Text Field

```zig
var email: []const u8 = "";

TextField(.email)
    .bind(&email)
    .placeholder("Email address")
    .width(.percent(100))
    .height(.px(36))
    .padding(.xy(12, 0))
    .border(.round(.palette(.border_color_light), .all(4)))
    .end();
```

### Search Field with Handler

```zig
var search_query: []const u8 = "";

fn onSearch(evt: *Vapor.Event) void {
    const query = evt.text();
    // filter data based on query
}

TextField(.string)
    .bind(&search_query)
    .placeholder("Search...")
    .onChange(onSearch)
    .onEvent(.keydown, handleSearchKeyDown)
    .width(.percent(100))
    .end();
```

### Submit on Enter

```zig
fn handleSearchKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        executeSearch();
    }
}
```

### Settings Form with Toggle Switch

```zig
fn renderSettingsView() void {
    Stack()
        .width(.px(600))
        .padding(.all(24))
        .spacing(20)
        .children({

        Text("Settings")
            .font(18, 600, .palette(.text_color))
            .end();

        // Display Name field
        Stack().spacing(4).children({
            Label("Display Name").end();
            TextField(.string)
                .bind(&display_name)
                .width(.percent(100))
                .height(.px(36))
                .border(.round(.palette(.border_color_light), .all(4)))
                .end();
        });

        // Email field
        Stack().spacing(4).children({
            Label("Email Address").end();
            TextField(.email)
                .bind(&email_value)
                .width(.percent(100))
                .height(.px(36))
                .border(.round(.palette(.border_color_light), .all(4)))
                .end();
        });

        // Toggle row
        Box()
            .layout(.x_between_center)
            .children({
            Text("Dark Mode")
                .font(14, 400, .palette(.text_color))
                .end();
            Switch.render("dark-mode", toggleTheme, .{});
        });
    });
}
```

---

## 11. Confirmation Dialogs {#confirmation-dialogs}

### State Machine Pattern

```zig
const ConfirmAction = enum { none, delete, ban };
var pending_action: ConfirmAction = .none;

fn onDeleteClicked() void {
    pending_action = .delete;
}

fn onCancelAction() void {
    pending_action = .none;
}

fn onConfirmDelete() void {
    // Execute deletion
    pending_action = .none;
}
```

### Reusable Confirm Dialog

```zig
fn renderConfirmDialog(
    title: []const u8,
    message: []const u8,
    on_confirm: anytype,
) void {
    Stack()
        .width(.percent(100))
        .spacing(12)
        .padding(.all(16))
        .border(.sharp(.all(1), .palette(.border_color_light)))
        .radius(.all(6))
        .background(.palette(.background))
        .children({

        Text(title).font(16, 600, .palette(.text_color)).end();
        Text(message).font(14, 300, .palette(.text_color)).end();

        Box()
            .width(.percent(100))
            .spacing(8)
            .layout(.left_center)
            .mt(4)
            .children({

            // Confirm button
            ButtonCtx(on_confirm, .{})
                .height(.px(34))
                .padding(.xy(16, 0))
                .layout(.center)
                .background(.hex("#DC2626"))
                .radius(.all(4))
                .pointer()
                .children({
                Text("Confirm").font(14, 500, .white).end();
            });

            // Cancel button
            ButtonCtx(onCancelAction, .{})
                .height(.px(34))
                .padding(.xy(16, 0))
                .layout(.center)
                .border(.sharp(.all(1), .palette(.border_color_light)))
                .background(.transparent)
                .radius(.all(4))
                .pointer()
                .children({
                Text("Cancel").font(14, 500, .palette(.text_color)).end();
            });
        });
    });
}
```

### Usage with State Switch

```zig
fn renderActionSection() void {
    switch (pending_action) {
        .none => {
            // Show action buttons
            Box().spacing(8).children({
                ButtonCtx(onDeleteClicked, .{}).children({
                    Icon(.trash).end();
                    Text("Delete").end();
                });
                ButtonCtx(onBanClicked, .{}).children({
                    Text("Ban User").end();
                });
            });
        },
        .delete => {
            renderConfirmDialog("Delete User", "This cannot be undone.", onConfirmDelete);
        },
        .ban => {
            renderConfirmDialog("Ban User", "User will be moved to banned list.", onConfirmBan);
        },
    }
}
```

---

## 12. Toast Notifications {#toast-notifications}

```zig
const Toast = Opaque.Toast;

// Success
Toast.success(.{ .title = "Saved", .description = "Changes saved successfully" });

// Warning
Toast.warning(.{ .title = "Deleted", .description = "This action cannot be undone" });

// Info
Toast.info(.{ .title = "Exporting", .description = "Your report will be ready shortly" });

// Error
Toast.err(.{ .title = "Failed", .description = "Could not connect to server" });
```

---

## 13. Dropdowns & Popovers {#dropdowns--popovers}

### Basic Dropdown (Manual)

```zig
var show_dropdown: bool = false;

fn toggleDropdown() void {
    show_dropdown = !show_dropdown;
}

fn render() void {
    Box().pos(.relative).children({
        Button(toggleDropdown).children({
            Text("Select Option").end();
            Icon(.chevron_down).end();
        });

        if (show_dropdown) {
            Stack()
                .pos(.tl(.px(0), .percent(100), .absolute))
                .zIndex(100)
                .width(.px(200))
                .background(.palette(.background))
                .border(.round(.palette(.border_color_light), .all(8)))
                .shadow(.card(.transparentize(.black, 0.1)))
                .children({
                for (options) |option| {
                    ButtonCtx(selectOption, .{option})
                        .width(.percent(100))
                        .padding(.xy(12, 8))
                        .hover(.{ .background = .palette(.highlight_color) })
                        .pointer()
                        .children({
                        Text(option.label).font(14, 400, .palette(.text_color)).end();
                    });
                }
            });
        }
    });
}
```

### PopOver Component

```zig
const PopOver = Opaque.PopOver;

PopOver.create(.{ .position = .bottom_right, .on_trigger = onFilterTrigger })
    .Trigger(FilterButton, .{})
    .Component(FilterContent, .{})
    .end();
```

---

## 14. Theme System {#theme-system}

### Theme Constants

```zig
pub const Theme = struct {
    pub const bg_base = Vapor.Types.Background.palette(.background);
    pub const bg_card = Vapor.Types.Background.palette(.background);
    pub const bg_hover = Vapor.Types.Background.hex("#3f3f46");

    pub const text = Vapor.Types.Color.palette(.text_color);
    pub const text_secondary = Vapor.Types.Color.hex("#a1a1aa");
    pub const text_muted = Vapor.Types.Color.hex("#71717a");

    pub const border = Vapor.Types.Color.hex("#27272a");
    pub const border_light = Vapor.Types.Color.hex("#3f3f46");

    pub const accent = Vapor.Types.Color.hex("#6366f1");
    pub const success = Vapor.Types.Color.hex("#10b981");
    pub const warning = Vapor.Types.Color.hex("#F5590B");
    pub const err = Vapor.Types.Color.hex("#ef4444");
};
```

### Usage in Components

```zig
Text("Error Count")
    .font(14, 600, Theme.err)
    .end();

Box()
    .background(Theme.bg_card)
    .border(.round(Theme.border_light, .all(8)))
    .children({ ... });
```

### Color Coding by Type

```zig
fn typeColor(data_type: []const u8) Vapor.Types.Color {
    const eql = std.mem.eql;
    if (eql(u8, data_type, "integer") or eql(u8, data_type, "bigint")) return .hex("#E20CB0");
    if (eql(u8, data_type, "text")) return .hex("#91B44E");
    if (eql(u8, data_type, "boolean")) return .palette(.tint);
    if (eql(u8, data_type, "json") or eql(u8, data_type, "jsonb")) return .hex("#F45128");
    if (std.ascii.startsWithIgnoreCase(data_type, "timestamp")) return .hex("#23DFB3");
    return .palette(.text_color);
}
```

---

## 15. HTTP Data Fetching {#http-data-fetching}

### GET Request

```zig
fn fetchSchemas() void {
    Vapor.Kit.Fetch.fetch("http://localhost:8080/sql_schemas", .{
        .method = .GET,
        .use_credentials = true,
    }).handle(handleResponse);
}

fn handleResponse(response: Vapor.Kit.Response) void {
    switch (response) {
        .Ok => |resp| handleSuccess(resp),
        .Err => |resp| std.log.err("Fetch failed: {s}", .{resp.message}),
    }
}

fn handleSuccess(resp: Vapor.Kit.OkResponse) void {
    const allocator = Vapor.arena(.persist);
    // Parse resp.body (JSON string)
    var result = Deserializer.QueryResult.fromJson(allocator, resp.body) catch return;
    defer result.deinit(allocator);

    // Process rows...
    for (result.rows) |row| {
        // populate state
    }
}
```

### POST Request (SQL Execution)

```zig
var requesting: bool = false;

fn executeQuery() void {
    requesting = true;
    err_response = null;

    Vapor.Kit.Fetch.fetch("http://localhost:8080/sql_raw", .{
        .method = .POST,
        .use_credentials = true,
        .body = text,
    }).handle(handleQueryResponse);
}

fn handleQueryResponse(response: Vapor.Kit.Response) void {
    requesting = false;
    switch (response) {
        .Ok => |resp| parseAndDisplayResults(resp),
        .Err => |resp| {
            err_response = .{
                .code = "500",
                .severity = "ERROR",
                .message = resp.message,
            };
        },
    }
}
```

### Loading State Pattern

```zig
fn render() void {
    if (requesting) {
        Center().width(.percent(100)).height(.percent(100)).children({
            Vapor.Svg(.{ .svg = @embedFile("loader.svg"), .override = true })
                .size(.px(42))
                .end();
        });
    } else if (err_response) |err| {
        // Error display
        Stack().spacing(8).padding(.all(16)).children({
            TextFmt("{s}: {s}", .{ err.severity, err.message })
                .font(14, 400, .hex("#DC2626"))
                .end();
        });
    } else {
        // Data display
        table.render();
    }
}
```

---

## 16. Animations {#animations}

### Defining Animations

```zig
const Animation = Vapor.Animation;

const pulse_glow = Animation.init("pulse-glow")
    .prop(.opacity, 0.5, 1.0)
    .prop(.scale, 0.98, 1.0)
    .duration(2000)
    .easing(.easeInOut)
    .infinite();

const slide_up = Animation.init("slide-up")
    .prop(.translateY, 20, 0)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const fade_scale = Animation.init("fade-scale")
    .prop(.scale, 0.95, 1.0)
    .prop(.opacity, 0, 1)
    .duration(200)
    .easing(.easeOut);

pub fn init() void {
    pulse_glow.build();
    slide_up.build();
    fade_scale.build();
}
```

### Applying Animations

```zig
// Enter/exit animations
Box()
    .animationEnter("slide-up")
    .animationExit("fade-out")
    .children({ ... });

// Conditional animation
Text("Loading")
    .animation(if (is_loading) "pulse-glow" else null)
    .end();

// Hover animation
Button(action)
    .hover(.{ .animation = "pulse-glow" })
    .children({ ... });
```

---

## 17. Reusable Component Patterns {#reusable-component-patterns}

### Status Badge

```zig
const Status = enum {
    healthy, degraded, unhealthy,

    pub fn label(self: Status) []const u8 {
        return switch (self) {
            .healthy => "Healthy",
            .degraded => "Degraded",
            .unhealthy => "Unhealthy",
        };
    }

    pub fn color(self: Status) Vapor.Types.Color {
        return switch (self) {
            .healthy => .hex("#10b981"),
            .degraded => .hex("#f59e0b"),
            .unhealthy => .hex("#ef4444"),
        };
    }

    pub fn icon(self: Status) *const Vapor.IconTokens {
        return switch (self) {
            .healthy => .activity,
            .degraded => .exclamation_circle,
            .unhealthy => .exclamation_triangle,
        };
    }
};

fn StatusBadge(status: Status) void {
    Box()
        .layout(.left_center)
        .spacing(6)
        .padding(.xy(8, 4))
        .background(.transparentize(status.color(), 0.1))
        .radius(.all(4))
        .children({
        Spacer(6)
            .radius(.all(3))
            .background(.{ .color = status.color() })
            .end();
        Text(status.label())
            .font(12, 500, status.color())
            .end();
    });
}
```

### Action Button with Icon

```zig
fn ActionButton(label: []const u8, icon_token: *const Vapor.IconTokens, handler: anytype) void {
    ButtonCtx(handler, .{})
        .height(.px(36))
        .padding(.xy(16, 0))
        .layout(.center)
        .pointer()
        .border(.sharp(.all(1), .palette(.border_color_light)))
        .hover(.{
            .background = .palette(.tint),
            .text_color = .palette(.background),
        })
        .children({
        Box().spacing(6).layout(.left_center).children({
            Icon(icon_token).font(14, 300, null).end();
            Text(label).font(14, 300, null).fontFamily("IBM Plex Mono, monospace").end();
        });
    });
}

// Usage
ActionButton("Refresh", .arrow_repeat, refreshData);
ActionButton("Export", .download, handleExport);
```

### Top Bar with Title + Actions

```zig
fn TopBar(title: []const u8) void {
    Box()
        .width(.percent(100))
        .layout(.x_between_center)
        .padding(.xy(16, 8))
        .height(.px(48))
        .border(.bottom(1, .palette(.border_color_light)))
        .children({

        // Left: title
        Text(title)
            .font(20, 200, .palette(.text_color))
            .end();

        // Right: actions
        Box()
            .spacing(8)
            .children({
            ActionButton("Refresh", .arrow_repeat, refreshData);
            ButtonCtx(toggleViewMode, .{})
                .height(.px(36))
                .padding(.xy(16, 0))
                .background(.palette(.tint))
                .layout(.center)
                .pointer()
                .hover(.{ .background = .hex("#222160") })
                .children({
                Text("Switch View")
                    .font(14, 300, .palette(.background))
                    .end();
            });
        });
    });
}
```

### Gradient Fade Overlay

```zig
// Place as sibling after a scrollable container
Box()
    .pos(.bl(.px(0), .px(0), .absolute))
    .width(.percent(100))
    .height(.px(72))
    .layer(.gradient(.linear, .to_bottom, &.{ .transparent, .palette(.background) }))
    .inlineStyle("pointer-events: none;", .{})
    .children({});
```

### Progress Bar

```zig
fn ProgressBar(percentage: u32) void {
    Box()
        .width(.px(80))
        .height(.px(6))
        .background(.palette(.highlight_color))
        .radius(.all(99))
        .children({
        Box()
            .width(.percent(percentage))
            .height(.percent(100))
            .background(.{ .color = .palette(.tint) })
            .radius(.all(99))
            .children({});
    });
}
```

---

## 18. Common Gotchas & Best Practices {#common-gotchas--best-practices}

### ✅ DO

- **Use `ButtonCtx` for handlers with arguments:** `ButtonCtx(handler, .{item_id})`
- **Use `Button` for no-arg handlers:** `Button(handler)`
- **Use `.persist` arena for state that survives navigation**
- **Use `.frame` arena for formatted display strings** (`Vapor.fmtln`)
- **Use `Vapor.Static.HooksCtx(.mounted, fn, .{})({})` for mount hooks**
- **Use `@import` for cross-file state sharing**
- **Use `.items(.{})` for simple child lists** (no `.end()` needed)
- **Use `.children({})` for complex child blocks** with logic (`.end()` needed)
- **Use `defer result.deinit(allocator)` for parsed responses**
- **Use `Vapor.cycle()` when updating state outside user events**
- **Use `.transition(.{ .properties, .duration, .timing })` for smooth animations on sidebar/menus**

### ❌ DON'T

- **Don't use `Button(handler, .{args})`** — this doesn't exist. Use `ButtonCtx`.
- **Don't forget `.end()` on leaf elements** inside `.children({})` blocks
- **Don't mix arena lifetimes** — never store `.frame` data in `.persist` arrays
- **Don't use `useState` / `useEffect`** patterns — just mutate Zig variables
- **Don't prop-drill** — use `@import("OtherFile.zig").variable` instead
- **Don't forget to call `.build()` on animations** in `init()`
- **Don't put mount logic in `render()`** — use `HooksCtx(.mounted, fn, .{})`
- **Don't use raw hex colors everywhere** — define a `Theme` struct with named constants
- **Don't create giant monolithic files** — one component per file
- **Don't forget `Vapor.onEnd(callback)` when setting cursor position** after text mutations
