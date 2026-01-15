// Kanban board - styled to match Dashboard theme
const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const Icon = Vapor.Icon;
const TextFmt = Vapor.TextFmt;
const TextField = Vapor.TextField;
const Animation = Vapor.Animation;
const Opaque = @import("../../components/Opaque.zig");
const Button = Opaque.Button;
const Alert = Opaque.Alert;

// Import UI Components (matching Dashboard imports)
const SelectStruct = @import("../../components/Select.zig");
const ToastStruct = @import("../../components/Toast.zig");
const SheetStruct = @import("../../components/Sheet.zig");
const FieldStruct = @import("../../components/Field.zig");
const TooltipStruct = @import("../../components/Tooltip.zig");
const SwitchStruct = @import("../../components/Switch.zig");
const GroupStruct = @import("../../components/Group.zig");

// ============================================================================
// TYPE ALIASES
// ============================================================================

pub const Select = SelectStruct.Select;
pub const Toast = ToastStruct;
pub const Sheet = SheetStruct;
pub const Field = FieldStruct;
pub const Tooltip = TooltipStruct;
pub const Switch = SwitchStruct;
pub const Group = GroupStruct;

// ============================================================================
// DATA TYPES
// ============================================================================

pub const TaskPriority = enum {
    low,
    medium,
    high,
    urgent,

    pub fn color(self: TaskPriority) Vapor.Types.Color {
        return switch (self) {
            .low => .hex("#10b981"),
            .medium => .hex("#f59e0b"),
            .high => .hex("#f97316"),
            .urgent => .palette(.danger),
        };
    }

    pub fn label(self: TaskPriority) []const u8 {
        return switch (self) {
            .low => "Low",
            .medium => "Medium",
            .high => "High",
            .urgent => "Urgent",
        };
    }

    pub fn icon(self: TaskPriority) *const Vapor.IconTokens {
        return switch (self) {
            .low => .flag,
            .medium => .flag_fill,
            .high => .exclamation_circle,
            .urgent => .exclamation_triangle_fill,
        };
    }
};

pub const TaskStatus = enum {
    backlog,
    todo,
    in_progress,
    review,
    done,

    pub fn label(self: TaskStatus) []const u8 {
        return switch (self) {
            .backlog => "Backlog",
            .todo => "To Do",
            .in_progress => "In Progress",
            .review => "Review",
            .done => "Done",
        };
    }

    pub fn color(self: TaskStatus) Vapor.Types.Color {
        return switch (self) {
            .backlog => .hex("#6b7280"),
            .todo => .hex("#3b82f6"),
            .in_progress => .hex("#8b5cf6"),
            .review => .hex("#f59e0b"),
            .done => .hex("#10b981"),
        };
    }

    pub fn icon(self: TaskStatus) *const Vapor.IconTokens {
        return switch (self) {
            .backlog => .inbox,
            .todo => .circle,
            .in_progress => .play_circle,
            .review => .eye,
            .done => .check_circle_fill,
        };
    }
};

pub const Task = struct {
    id: usize,
    title: []const u8,
    description: []const u8,
    status: TaskStatus,
    priority: TaskPriority,
    assignee: ?[]const u8,
    tags: []const []const u8,
    due_date: ?[]const u8,
    created_at: []const u8,
};

// ============================================================================
// STATE
// ============================================================================

var tasks: Vapor.Array(Task) = undefined;
var next_task_id: usize = 100;
var show_add_modal: bool = false;
var editing_task: ?*Task = null;
var dragging_task: ?*Task = null;
var hover_column: ?TaskStatus = null;
var search_query: []const u8 = "";
var filter_priority: ?TaskPriority = null;
var show_completed: bool = true;
var selected_task: ?*const Task = null;

// New task form state
var new_task_title: []const u8 = "";
var new_task_description: []const u8 = "";
var new_task_priority: TaskPriority = .medium;
var new_task_status: TaskStatus = .todo;

// Component instances
var detail_sheet: Sheet = undefined;
var priority_filter: Select(TaskPriority) = undefined;
var status_select: Select(TaskStatus) = undefined;
var alert: Alert = undefined;

// Select options
var priority_options = [_]Select(TaskPriority).Item{
    .{ .value = .low, .label = "Low" },
    .{ .value = .medium, .label = "Medium" },
    .{ .value = .high, .label = "High" },
    .{ .value = .urgent, .label = "Urgent" },
};

var status_options = [_]Select(TaskStatus).Item{
    .{ .value = .backlog, .label = "Backlog" },
    .{ .value = .todo, .label = "To Do" },
    .{ .value = .in_progress, .label = "In Progress" },
    .{ .value = .review, .label = "Review" },
    .{ .value = .done, .label = "Done" },
};

// ============================================================================
// THEME (Matching Dashboard Theme)
// ============================================================================

const Theme = struct {
    const bg_base = Vapor.Types.Background.palette(.background);
    const bg_card = Vapor.Types.Background.palette(.background);
    const bg_elevated = Vapor.Types.Background.palette(.background);
    const bg_hover = Vapor.Types.Background.hex("#3f3f46");
    const border = Vapor.Types.Color.hex("#27272a");
    const border_light = Vapor.Types.Color.hex("#3f3f46");
    const text = Vapor.Types.Color.palette(.text_color);
    const text_secondary = Vapor.Types.Color.hex("#a1a1aa");
    const text_muted = Vapor.Types.Color.hex("#71717a");
    const accent = Vapor.Types.Color.hex("#6366f1");
    const accent_hover = Vapor.Types.Color.hex("#818cf8");
    const success = Vapor.Types.Color.hex("#10b981");
    const warning = Vapor.Types.Color.hex("#F5590B");
    const err = Vapor.Types.Color.palette(.danger);
    const gradient_start = Vapor.Types.Color.hex("#6366f1");
    const gradient_end = Vapor.Types.Color.hex("#8b5cf6");
};

// ============================================================================
// ANIMATIONS (Matching Dashboard Animation Style)
// ============================================================================

const pulse_glow = Animation.init("kanban-pulse-glow")
    .prop(.opacity, 1, 0.5)
    .duration(2000)
    .dir(.alternate)
    .infinite();

const slide_up = Animation.init("kanban-slide-up")
    .prop(.translateY, 20, 0)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

const fade_scale = Animation.init("kanban-fade-scale")
    .prop(.scale, 0.95, 1)
    .prop(.opacity, 0, 1)
    .duration(200)
    .easing(.easeOut)
    .fill(.forwards);

const card_enter = Animation.init("kanban-card-enter")
    .prop(.translateY, 10, 0)
    .prop(.opacity, 0, 1)
    .duration(200)
    .easing(.easeOut)
    .fill(.forwards);

const modal_enter = Animation.init("kanban-modal-enter")
    .prop(.scale, 0.95, 1)
    .prop(.opacity, 0, 1)
    .duration(200)
    .easing(.easeOutBack)
    .fill(.forwards);

// ============================================================================
// SAMPLE DATA
// ============================================================================

fn initSampleData() void {
    tasks.appendSlice(&.{
        .{ .id = 1, .title = "Design system setup", .description = "Create color tokens, typography scale, and spacing system", .status = .done, .priority = .high, .assignee = "Sarah", .tags = &.{ "design", "foundation" }, .due_date = "Jan 10", .created_at = "Jan 5" },
        .{ .id = 2, .title = "User authentication flow", .description = "Implement login, signup, and password reset", .status = .in_progress, .priority = .urgent, .assignee = "Mike", .tags = &.{ "backend", "security" }, .due_date = "Jan 15", .created_at = "Jan 8" },
        .{ .id = 3, .title = "Dashboard wireframes", .description = "Create low-fidelity wireframes for main dashboard", .status = .review, .priority = .medium, .assignee = "Sarah", .tags = &.{"design"}, .due_date = "Jan 12", .created_at = "Jan 6" },
        .{ .id = 4, .title = "API documentation", .description = "Document all REST endpoints with examples", .status = .todo, .priority = .low, .assignee = "Alex", .tags = &.{ "docs", "api" }, .due_date = "Jan 20", .created_at = "Jan 9" },
        .{ .id = 5, .title = "Database schema review", .description = "Review and optimize current database schema", .status = .backlog, .priority = .medium, .assignee = null, .tags = &.{ "backend", "database" }, .due_date = null, .created_at = "Jan 10" },
        .{ .id = 6, .title = "Mobile responsive layout", .description = "Ensure all pages work on mobile devices", .status = .todo, .priority = .high, .assignee = "Sarah", .tags = &.{ "frontend", "mobile" }, .due_date = "Jan 18", .created_at = "Jan 7" },
        .{ .id = 7, .title = "Unit test coverage", .description = "Increase test coverage to 80%", .status = .in_progress, .priority = .medium, .assignee = "Mike", .tags = &.{ "testing", "quality" }, .due_date = "Jan 25", .created_at = "Jan 11" },
        .{ .id = 8, .title = "Performance audit", .description = "Run Lighthouse and optimize critical metrics", .status = .backlog, .priority = .low, .assignee = null, .tags = &.{"performance"}, .due_date = null, .created_at = "Jan 12" },
        .{ .id = 9, .title = "Notification system", .description = "Build real-time notification infrastructure", .status = .todo, .priority = .high, .assignee = "Alex", .tags = &.{ "backend", "realtime" }, .due_date = "Jan 22", .created_at = "Jan 10" },
        .{ .id = 10, .title = "Settings page", .description = "User preferences and account settings UI", .status = .review, .priority = .medium, .assignee = "Sarah", .tags = &.{ "frontend", "ui" }, .due_date = "Jan 14", .created_at = "Jan 8" },
    }) catch |err| Vapor.printErr("Failed to init tasks: {any}", .{err});
}

// ============================================================================
// EVENT HANDLERS
// ============================================================================

fn openAddModal() void {
    new_task_title = "";
    new_task_description = "";
    new_task_priority = .medium;
    new_task_status = .todo;
    alert.open();
}

fn closeAddModal() void {
    alert.close();
    editing_task = null;
}

fn addTask() void {
    if (new_task_title.len == 0) return;

    const task = Task{
        .id = next_task_id,
        .title = Vapor.arena(.persist).dupe(u8, new_task_title) catch return,
        .description = Vapor.arena(.persist).dupe(u8, new_task_description) catch return,
        .status = new_task_status,
        .priority = new_task_priority,
        .assignee = null,
        .tags = &.{},
        .due_date = null,
        .created_at = "Today",
    };

    tasks.append(task) catch return;
    next_task_id += 1;
    closeAddModal();
    Toast.success(.{ .title = "Task Created", .description = "New task has been added to the board" });
}

fn moveTask(task: *Task, new_status: TaskStatus) void {
    task.status = new_status;
}

fn deleteTask(task: *Task) void {
    for (tasks.items, 0..) |*t, i| {
        if (t.id == task.id) {
            _ = tasks.orderedRemove(i);
            break;
        }
    }
    Toast.warning(.{ .title = "Task Deleted", .description = "This action cannot be undone" });
}

fn handleViewTask(task: *Task) void {
    selected_task = task;
    detail_sheet.open();
}

fn closeDetailSheet() void {
    detail_sheet.close();
    selected_task = null;
}

fn toggleCompleted() void {
    show_completed = !show_completed;
    if (show_completed) {
        Toast.info(.{ .title = "Showing Completed", .description = "Done tasks are now visible" });
    } else {
        Toast.info(.{ .title = "Hiding Completed", .description = "Done tasks are now hidden" });
    }
}

fn clearFilter() void {
    filter_priority = null;
}

fn setFilterPriority(priority: TaskPriority) void {
    if (filter_priority == priority) {
        filter_priority = null;
    } else {
        filter_priority = priority;
    }
}

fn handleExport() void {
    Toast.info(.{ .title = "Exporting Data", .description = "Your board data will be ready shortly" });
}

fn handleRefresh() void {
    Toast.success(.{ .title = "Board Refreshed", .description = "All tasks are up to date" });
}

// ============================================================================
// INITIALIZATION
// ============================================================================

pub fn init() void {
    // Build animations
    pulse_glow.build();
    slide_up.build();
    fade_scale.build();
    card_enter.build();
    modal_enter.build();

    // Initialize component libraries
    SelectStruct.new();
    ToastStruct.new();
    SheetStruct.new();
    FieldStruct.new();
    TooltipStruct.new();
    SwitchStruct.new();
    GroupStruct.new();

    // Initialize data
    tasks = Vapor.array(Task, .persist);
    initSampleData();

    // Initialize selects
    priority_filter = .fromItems(&priority_options);
    priority_filter.trigger = "Priority";

    status_select = .fromItems(&status_options);
    status_select.trigger = "Status";

    // Initialize sheet
    detail_sheet = Sheet.init(.right);
    detail_sheet.content = renderDetailSheetContent;
    alert = .init(renderAddModal);
}

// ============================================================================
// COMPONENTS
// ============================================================================

fn renderNavigation() void {
    Stack()
        .width(.px(240))
        .height(.percent(100))
        .padding(.all(20))
        .spacing(24)
        .children({
        // Logo
        Box()
            .layout(.left_center)
            .spacing(12)
            .children({
            Box()
                .width(.px(40))
                .height(.px(40))
                .background(.black)
                .border(.round(.black, .all(8)))
                .layout(.center)
                .children({
                Icon(.kanban)
                    .font(20, 700, .white)
                    .end();
            });
            Stack()
                .spacing(0)
                .children({
                Text("Kanban")
                    .font(20, 700, Theme.text)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Text("Board")
                    .font(11, 500, Theme.text_muted)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });
        });

        // Navigation Items
        Stack()
            .width(.percent(100))
            .spacing(4)
            .children({
            Text("VIEWS")
                .font(10, 600, Theme.text_muted)
                .fontFamily("IBM Plex Mono,monospace")
                .margin(.b(8))
                .end();

            renderNavButton("Board", .kanban, true);
            renderNavButton("List", .list_ul, false);
            renderNavButton("Calendar", .calendar, false);
            renderNavButton("Timeline", .bar_chart_line, false);
        });

        // Stats Section
        Stack()
            .width(.percent(100))
            .spacing(4)
            .children({
            Text("STATISTICS")
                .font(10, 600, Theme.text_muted)
                .fontFamily("IBM Plex Mono,monospace")
                .margin(.b(8))
                .end();

            renderStatRow("Total Tasks", tasks.items.len);
            renderStatRow("In Progress", countByStatus(.in_progress));
            renderStatRow("Completed", countByStatus(.done));
        });

        // Spacer
        Box().height(.grow).children({});

        // User profile
        Box()
            .width(.percent(100))
            .padding(.all(8))
            .layout(.left_center)
            .spacing(12)
            .children({
            Stack()
                .spacing(0)
                .width(.grow)
                .children({
                Text("Vic Rokx")
                    .font(14, 500, Theme.text)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Text("Project Manager")
                    .font(12, 400, Theme.text_muted)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });
            Icon(.chevron_expand)
                .font(14, 400, Theme.text_muted)
                .end();
        });
    });
}

fn renderNavButton(comptime label: []const u8, comptime nav_icon: *const Vapor.IconTokens, is_active: bool) void {
    Box()
        .width(.percent(100))
        .padding(.xy(14, 4))
        .background(if (is_active) .transparentizeHex(.palette(.tint), 0.1) else .transparent)
        .border(.r(1, if (is_active) .palette(.tint) else .transparent))
        .layer(if (is_active) .dot(0.5, 6, .transparentizeHex(.palette(.tint), 0.3)) else null)
        .layout(.left_center)
        .spacing(12)
        .pointer()
        .duration(150)
        .hover(.{
            .background = if (is_active) .transparentizeHex(.palette(.tint), 0.1) else .palette(.highlight_color),
        })
        .children({
        Box()
            .width(.px(32))
            .height(.px(32))
            .layout(.center)
            .children({
            Icon(nav_icon)
                .font(16, 400, if (is_active) .palette(.tint) else Theme.text_secondary)
                .end();
        });
        Text(label)
            .font(14, if (is_active) @as(u32, 500) else @as(u32, 400), if (is_active) .palette(.tint) else Theme.text_secondary)
            .fontFamily("Montserrat")
            .end();
    });
}

fn renderStatRow(comptime label: []const u8, count: usize) void {
    Box()
        .width(.percent(100))
        .padding(.xy(14, 8))
        .layout(.x_between_center)
        .children({
        Text(label)
            .font(13, 400, Theme.text_secondary)
            .fontFamily("IBM Plex Mono,monospace")
            .end();
        TextFmt("{d}", .{count})
            .font(13, 600, Theme.text)
            .fontFamily("IBM Plex Mono,monospace")
            .end();
    });
}

fn renderHeader() void {
    Box()
        .width(.percent(100))
        .height(.px(72))
        .padding(.horizontal(28))
        .background(Theme.bg_base)
        .layout(.x_between_center)
        .children({
        // Left: Title
        Stack()
            .spacing(4)
            .layout(.left_center)
            // .width(.grow)
            .children({
            Text("Kanban Board")
                .font(24, 700, Theme.text)
                .fontFamily("IBM Plex Mono,monospace")
                .end();
        });

        // Right: Controls
        Box()
            .layout(.right_center)
            .spacing(12)
            .children({

            // Search
            Box()
                .width(.px(200))
                // .height(.px(40))
                // .padding(.horizontal(12))
                // .background(.palette(.highlight_color))
                // .border(.round(Theme.border, .all(8)))
                .layout(.left_center)
                .spacing(8)
                .children({
                Field.render(.{ .label = "Search...", .value = .{ .string = &search_query } });
                //     Icon(.search)
                //         .font(16, 400, Theme.text_muted)
                //         .end();
                //     TextField(.string)
                //         .bind(&search_query)
                //         .placeholder("Search tasks...")
                //         .background(.transparent)
                //         .font(14, 400, Theme.text)
                //         .fontFamily("IBM Plex Mono,monospace")
                //         .width(.grow)
                //         .end();
            });

            // Priority filter
            Box()
                .width(.px(140))
                .children({
                priority_filter.render();
            });

            // Toggle completed
            Button(toggleCompleted, .{})
                .padding(.xy(14, 9))
                .children({
                if (show_completed) {
                    Box()
                        .width(.px(8))
                        .height(.px(8))
                        .background(.palette(.tint))
                        .border(.round(.palette(.tint), .all(99)))
                        .animation("kanban-pulse-glow")
                        .children({});
                }
                Text(if (show_completed) "Hide Done" else "Show Done")
                    .font(13, 500, if (show_completed) .palette(.tint) else Theme.text_secondary)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });

            Button(handleExport, .{})
                .padding(.xy(14, 9))
                .children({
                Text("Export")
                    .font(13, 500, .palette(.text_color))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Icon(.download)
                    .font(14, 400, .palette(.text_color))
                    .end();
            });

            // Refresh button
            Button(handleRefresh, .{})
                .width(.px(40))
                .height(.px(40))
                .layout(.center)
                .pointer()
                .children({
                Icon(.arrow_clockwise)
                    .inheritHover(&.{.text_color})
                    .font(18, 700, .palette(.text_color))
                    .end();
            });

            // Add task button
            Button(openAddModal, .{})
                .padding(.xy(14, 9))
                .background(.palette(.tint))
                .children({
                Icon(.plus)
                    .font(14, 600, .palette(.background))
                    .end();
                Text("Add Task")
                    .font(13, 500, .palette(.background))
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });
        });
    });
}

fn countByStatus(status: TaskStatus) usize {
    var count: usize = 0;
    for (tasks.items) |task| {
        if (task.status == status) count += 1;
    }
    return count;
}

fn renderBoard() void {
    Box()
        .width(.percent(100))
        .height(.grow)
        .padding(.all(28))
        .layout(.top_left)
        .spacing(20)
        .scroll(.scroll_x())
        .children({
        // Render columns for each status
        for (std.enums.values(TaskStatus)) |status| {
            if (status == .done and !show_completed) continue;
            renderColumn(status);
        }
    });
}

fn renderColumn(status: TaskStatus) void {
    // const is_drop_target = hover_column == status and dragging_task != null;
    const task_count = countByStatus(status);

    Box()
        .width(.percent(20))
        .height(.percent(100))
        .direction(.column)
        // .background(if (is_drop_target) .transparentizeHex(status.color(), 0.1) else .palette(.highlight_color))
        // .border(.round(if (is_drop_target) status.color() else .palette(.border_color_light), .all(12)))
        .padding(.all(16))
        .spacing(12)
        .children({
        // Column header
        Box()
            .layout(.x_between_center)
            .padding(.b(8))
            .border(.bottom(.palette(.border_color_light)))
            .children({
            Box()
                .layout(.left_center)
                .spacing(10)
                .children({
                Icon(status.icon())
                    .font(16, 500, status.color())
                    .end();
                Text(status.label())
                    .font(14, 600, Theme.text)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Box()
                    .padding(.xy(8, 4))
                    // .background(.transparentizeHex(status.color(), 0.2))
                    // .border(.round(status.color(), .all(10)))
                    .children({
                    TextFmt("{d}", .{task_count})
                        .font(11, 600, status.color())
                        .end();
                });
            });

            Button(addTaskToColumn, .{status})
                .width(.px(28))
                .height(.px(28))
                .layout(.center)
                .background(.transparent)
                .border(.round(.palette(.border_color_light), .all(6)))
                .pointer()
                .hover(.{ .background = Theme.bg_hover })
                .children({
                Icon(.plus)
                    .font(14, 400, Theme.text_muted)
                    .end();
            });
        });

        // Tasks list
        Stack()
            .width(.percent(100))
            .height(.grow)
            .spacing(10)
            .scroll(.scroll_y())
            .children({
            for (tasks.items) |*task| {
                if (task.status != status) continue;
                if (!matchesFilter(task)) continue;
                renderTaskCard(task);
            }

            // Empty state
            if (task_count == 0) {
                Center()
                    .height(.px(100))
                    .children({
                    Stack()
                        .layout(.center)
                        .spacing(8)
                        .children({
                        Icon(.inbox)
                            .font(24, 400, Theme.text_muted)
                            .end();
                        Text("No tasks")
                            .font(13, 400, Theme.text_muted)
                            .fontFamily("IBM Plex Mono,monospace")
                            .end();
                    });
                });
            }
        });
    });
}

fn addTaskToColumn(status: TaskStatus) void {
    new_task_status = status;
    openAddModal();
}

fn matchesFilter(task: *const Task) bool {
    // Priority filter
    if (filter_priority) |priority| {
        if (task.priority != priority) return false;
    }

    // Search filter
    if (search_query.len > 0) {
        const title_lower = std.ascii.allocLowerString(Vapor.arena(.frame), task.title) catch return true;
        const query_lower = std.ascii.allocLowerString(Vapor.arena(.frame), search_query) catch return true;
        if (std.mem.indexOf(u8, title_lower, query_lower) == null) return false;
    }

    return true;
}

fn renderTaskCard(task: *Task) void {
    Box()
        .width(.percent(100))
        .padding(.all(14))
        .animationEnter("kanban-card-enter")
        // .background(Theme.bg_elevated)
        .border(.sharp(.all(1), .palette(.border_color_light)))
        .direction(.column)
        .spacing(10)
        .pointer()
        .hover(.{
            // .background = .palette(.highlight_color),
            // .border = .round(.palette(.tint), .all(10)),
        })
        .children({
        // Title and priority
        Box()
            .layout(.x_between_center)
            .children({
            Text(task.title)
                .ellipsis(.dot)
                .font(14, 500, Theme.text)
                .fontFamily("IBM Plex Mono,monospace")
                .width(.percent(70))
                .end();
            Box()
                .padding(.xy(6, 3))
                // .background(.transparentizeHex(task.priority.color(), 0.2))
                // .border(.round(task.priority.color(), .all(4)))
                .children({
                Text(task.priority.label())
                    .font(10, 600, task.priority.color())
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
            });
        });

        // Description
        if (task.description.len > 0) {
            Text(task.description)
                .font(12, 400, Theme.text_secondary)
                .fontFamily("IBM Plex Mono,monospace")
                .end();
        }

        // Tags
        if (task.tags.len > 0) {
            Box()
                .layout(.left_center)
                .spacing(6)
                .wrap(.wrap)
                .children({
                for (task.tags) |tag| {
                    Box()
                        .padding(.xy(8, 4))
                        .background(.palette(.highlight_color))
                        .border(.round(.palette(.border_color_light), .all(4)))
                        .children({
                        Text(tag)
                            .font(10, 500, Theme.text_muted)
                            .fontFamily("IBM Plex Mono,monospace")
                            .end();
                    });
                }
            });
        }

        // Footer: Assignee, due date, actions
        Box()
            .layout(.x_between_center)
            .margin(.t(4))
            .children({
            Box()
                .layout(.left_center)
                .spacing(12)
                .children({
                // Assignee
                if (task.assignee) |assignee| {
                    Box()
                        .layout(.left_center)
                        .spacing(6)
                        .children({
                        Box()
                            .width(.px(20))
                            .height(.px(20))
                            .background(.{ .color = Theme.accent })
                            .border(.round(Theme.accent, .all(10)))
                            .layout(.center)
                            .children({
                            Text(assignee[0..1])
                                .font(10, 600, .white)
                                .fontFamily("IBM Plex Mono,monospace")
                                .end();
                        });
                        Text(assignee)
                            .font(11, 400, Theme.text_secondary)
                            .fontFamily("IBM Plex Mono,monospace")
                            .end();
                    });
                }

                // Due date
                if (task.due_date) |due| {
                    Box()
                        .layout(.left_center)
                        .spacing(4)
                        .children({
                        Icon(.calendar)
                            .font(11, 400, Theme.text_muted)
                            .end();
                        Text(due)
                            .font(11, 400, Theme.text_muted)
                            .fontFamily("IBM Plex Mono,monospace")
                            .end();
                    });
                }
            });

            // Actions
            Box()
                .layout(.right_center)
                .spacing(4)
                .children({
                // View
                Button(handleViewTask, .{task})
                    .width(.px(24))
                    .height(.px(24))
                    .layout(.center)
                    .background(.transparent)
                    .pointer()
                    .hover(.{ .background = .palette(.highlight_color) })
                    .children({
                    Icon(.eye)
                        .font(12, 400, Theme.text_muted)
                        .end();
                });

                // Move left
                if (canMoveLeft(task.status)) {
                    Button(moveTaskLeft, .{task})
                        .width(.px(24))
                        .height(.px(24))
                        .layout(.center)
                        .background(.transparent)
                        .pointer()
                        .hover(.{ .background = .palette(.highlight_color) })
                        .children({
                        Icon(.chevron_left)
                            .font(12, 400, Theme.text_muted)
                            .end();
                    });
                }

                // Move right
                if (canMoveRight(task.status)) {
                    Button(moveTaskRight, .{task})
                        .width(.px(24))
                        .height(.px(24))
                        .layout(.center)
                        .background(.transparent)
                        .pointer()
                        .hover(.{ .background = .palette(.highlight_color) })
                        .children({
                        Icon(.chevron_right)
                            .font(12, 400, Theme.text_muted)
                            .end();
                    });
                }

                // Delete
                Button(deleteTask, .{task})
                    .width(.px(24))
                    .height(.px(24))
                    .layout(.center)
                    .background(.transparent)
                    .pointer()
                    .hover(.{ .background = .transparentizeHex(.palette(.danger), 0.2) })
                    .children({
                    Icon(.trash)
                        .font(12, 400, Theme.text_muted)
                        .end();
                });
            });
        });
    });
}

fn canMoveLeft(status: TaskStatus) bool {
    return status != .backlog;
}

fn canMoveRight(status: TaskStatus) bool {
    return status != .done;
}

fn moveTaskLeft(task: *Task) void {
    task.status = switch (task.status) {
        .backlog => .backlog,
        .todo => .backlog,
        .in_progress => .todo,
        .review => .in_progress,
        .done => .review,
    };
}

fn moveTaskRight(task: *Task) void {
    task.status = switch (task.status) {
        .backlog => .todo,
        .todo => .in_progress,
        .in_progress => .review,
        .review => .done,
        .done => .done,
    };
}

fn renderAddModal(_: *Alert) void {

    // Modal
    Box()
        .width(.px(480))
        .padding(.all(24))
        // .background(Theme.bg_card)
        // .border(.round(.palette(.border_color_light), .all(16)))
        .direction(.column)
        .spacing(20)
        // .shadow(.card(.black))
        .animationEnter("kanban-modal-enter")
        .children({
        // Header
        Box()
            .layout(.x_between_center)
            .children({
            Text("Add New Task")
                .font(20, 700, Theme.text)
                .fontFamily("IBM Plex Mono,monospace")
                .end();
            Button(closeAddModal, .{})
                .width(.px(36))
                .height(.px(36))
                .layout(.center)
                .pointer()
                .children({
                Icon(.x_lg)
                    .font(16, 400, Theme.text_secondary)
                    .end();
            });
        });

        // Form
        Stack()
            .spacing(16)
            .children({
            // Title
            Stack()
                .spacing(6)
                .children({
                Text("Title")
                    .font(13, 500, Theme.text_secondary)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Box()
                    .width(.percent(100))
                    .padding(.horizontal(14))
                    // .background(.palette(.highlight_color))
                    // .border(.round(.palette(.border_color_light), .all(8)))
                    .layout(.left_center)
                    .children({
                    Field.render(.{ .label = "Title", .value = .{ .string = &new_task_title } });
                });
            });

            // Description
            Stack()
                .spacing(6)
                .children({
                Text("Description")
                    .font(13, 500, Theme.text_secondary)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Box()
                    .width(.percent(100))
                    .height(.px(100))
                    .padding(.all(14))
                    // .background(.palette(.highlight_color))
                    // .border(.round(.palette(.border_color_light), .all(8)))
                    .children({
                    Vapor.TextArea()
                        .ariaLabel("Text Area")
                        .width(.percent(100))
                        .height(.percent(100))
                        .outline(.none)
                        .border(.solid(.tblr(1, 3, 1, 1), .palette(.border_color_light), .all(6)))
                        .padding(.all(8))
                        .font(16, 300, .palette(.text_color))
                        .fontFamily("IBM Plex Sans,monospace")
                        .resize(.none)
                        .end();
                });
            });

            // Priority selector
            Stack()
                .spacing(6)
                .children({
                Text("Priority")
                    .font(13, 500, Theme.text_secondary)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Box()
                    .layout(.left_center)
                    .spacing(8)
                    .children({
                    for (std.enums.values(TaskPriority)) |priority| {
                        const is_selected = new_task_priority == priority;
                        Button(selectPriority, .{priority})
                            .padding(.xy(12, 8))
                            .background(if (is_selected) .transparentizeHex(priority.color(), 0.2) else .palette(.highlight_color))
                            .border(.round(if (is_selected) priority.color() else .palette(.border_color_light), .all(6)))
                            .pointer()
                            .children({
                            Icon(priority.icon())
                                .font(12, 400, priority.color())
                                .end();
                            Text(priority.label())
                                .font(12, 500, if (is_selected) priority.color() else Theme.text_secondary)
                                .fontFamily("IBM Plex Mono,monospace")
                                .end();
                        });
                    }
                });
            });

            // Status selector
            Stack()
                .spacing(6)
                .children({
                Text("Status")
                    .font(13, 500, Theme.text_secondary)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Box()
                    .layout(.left_center)
                    .spacing(8)
                    .wrap(.wrap)
                    .children({
                    inline for (@typeInfo(TaskStatus).@"enum".fields) |field| {
                        const status = @as(TaskStatus, @enumFromInt(field.value));
                        const is_selected = new_task_status == status;
                        Button(selectStatus, .{status})
                            .padding(.xy(12, 8))
                            .background(if (is_selected) .transparentizeHex(status.color(), 0.2) else .palette(.highlight_color))
                            .border(.round(if (is_selected) status.color() else .palette(.border_color_light), .all(6)))
                            .pointer()
                            .children({
                            Text(status.label())
                                .font(12, 500, if (is_selected) status.color() else Theme.text_secondary)
                                .fontFamily("IBM Plex Mono,monospace")
                                .end();
                        });
                    }
                });
            });
        });

        // Actions
        Box()
            .layout(.right_center)
            .spacing(12)
            .margin(.t(8))
            .children({
            Button(closeAddModal, .{})
                .padding(.xy(20, 12))
                .children({
                Text("Cancel")
                    .font(14, 500, Theme.text_secondary)
                    .fontFamily("Montserrat")
                    .end();
            });
            Button(addTask, .{})
                .padding(.xy(20, 12))
                .background(.palette(.tint))
                .children({
                Icon(.plus)
                    .font(14, 600, .palette(.background))
                    .end();
                Text("Add Task")
                    .font(14, 600, .palette(.background))
                    .fontFamily("Montserrat")
                    .end();
            });
        });
    });
}

fn selectPriority(priority: TaskPriority) void {
    new_task_priority = priority;
}

fn selectStatus(status: TaskStatus) void {
    new_task_status = status;
}

fn renderDetailSheetContent(_: *Sheet) void {
    if (selected_task) |task| {
        Stack()
            .width(.percent(100))
            .height(.percent(100))
            .padding(.all(24))
            .spacing(24)
            .children({
            // Header
            Box()
                .layout(.x_between_center)
                .children({
                Text("Task Details")
                    .font(20, 700, Theme.text)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Button(closeDetailSheet, .{})
                    .width(.px(36))
                    .height(.px(36))
                    .layout(.center)
                    .pointer()
                    .children({
                    Icon(.x_lg)
                        .font(16, 400, Theme.text_secondary)
                        .end();
                });
            });

            // Title and Status
            Box()
                .width(.percent(100))
                .padding(.all(20))
                .direction(.column)
                .spacing(12)
                .layout(.center)
                .children({
                Text(task.title)
                    .font(24, 700, Theme.text)
                    .fontFamily("IBM Plex Mono,monospace")
                    .end();
                Box()
                    .layout(.center)
                    .spacing(8)
                    .children({
                    Box()
                        .padding(.xy(10, 6))
                        .background(.transparentizeHex(task.status.color(), 0.2))
                        .border(.round(task.status.color(), .all(6)))
                        .children({
                        Text(task.status.label())
                            .font(12, 600, task.status.color())
                            .fontFamily("IBM Plex Mono,monospace")
                            .end();
                    });
                    Box()
                        .padding(.xy(10, 6))
                        .background(.transparentizeHex(task.priority.color(), 0.2))
                        .border(.round(task.priority.color(), .all(6)))
                        .children({
                        Text(task.priority.label())
                            .font(12, 600, task.priority.color())
                            .fontFamily("IBM Plex Mono,monospace")
                            .end();
                    });
                });
            });

            // Description
            if (task.description.len > 0) {
                Stack()
                    .width(.percent(100))
                    .spacing(8)
                    .children({
                    Text("Description")
                        .font(12, 500, Theme.text_muted)
                        .fontFamily("IBM Plex Mono,monospace")
                        .end();
                    Text(task.description)
                        .font(14, 400, Theme.text_secondary)
                        .fontFamily("IBM Plex Mono,monospace")
                        .end();
                });
            }

            // Details
            Stack()
                .width(.percent(100))
                .spacing(16)
                .children({
                if (task.assignee) |assignee| {
                    renderDetailRow("Assignee", assignee);
                }
                if (task.due_date) |due| {
                    renderDetailRow("Due Date", due);
                }
                renderDetailRow("Created", task.created_at);
                renderDetailRowFmt("Task ID", "TASK-{d}", .{task.id});
            });

            // Tags
            if (task.tags.len > 0) {
                Stack()
                    .width(.percent(100))
                    .spacing(8)
                    .children({
                    Text("Tags")
                        .font(12, 500, Theme.text_muted)
                        .fontFamily("IBM Plex Mono,monospace")
                        .end();
                    Box()
                        .layout(.left_center)
                        .spacing(8)
                        .wrap(.wrap)
                        .children({
                        for (task.tags) |tag| {
                            Box()
                                .padding(.xy(10, 6))
                                .background(.palette(.highlight_color))
                                .border(.round(.palette(.border_color_light), .all(6)))
                                .children({
                                Text(tag)
                                    .font(12, 500, Theme.text_secondary)
                                    .fontFamily("IBM Plex Mono,monospace")
                                    .end();
                            });
                        }
                    });
                });
            }

            // Actions
            Box()
                .width(.percent(100))
                .layout(.left_center)
                .spacing(12)
                .children({
                Button(closeDetailSheet, .{})
                    .padding(.xy(12, 8))
                    .background(.{ .color = Theme.warning })
                    .border(.round(Theme.warning, .all(12)))
                    .pointer()
                    .layout(.center)
                    .spacing(8)
                    .children({
                    Icon(.pencil)
                        .font(16, 400, Theme.bg_base.color)
                        .end();
                    Text("Edit Task")
                        .font(14, 500, Theme.bg_base.color)
                        .fontFamily("Montserrat")
                        .end();
                });
                Button(closeDetailSheet, .{})
                    .padding(.xy(12, 8))
                    .background(Theme.bg_elevated)
                    .border(.round(.palette(.border_color_light), .all(12)))
                    .pointer()
                    .layout(.center)
                    .spacing(8)
                    .children({
                    Icon(.link)
                        .font(16, 400, Theme.text_secondary)
                        .end();
                    Text("Copy Link")
                        .font(14, 500, Theme.text_secondary)
                        .fontFamily("Montserrat")
                        .end();
                });
            });
        });
    }
}

fn renderDetailRow(label: []const u8, value: []const u8) void {
    Box()
        .width(.percent(100))
        .layout(.x_between_center)
        .padding(.vertical(12))
        .border(.bottom(.palette(.border_color_light)))
        .children({
        Text(label)
            .font(14, 400, Theme.text_muted)
            .fontFamily("Montserrat")
            .end();
        Text(value)
            .font(14, 500, Theme.text)
            .fontFamily("Montserrat")
            .end();
    });
}

fn renderDetailRowFmt(comptime label: []const u8, comptime fmt: []const u8, args: anytype) void {
    Box()
        .width(.percent(100))
        .layout(.x_between_center)
        .padding(.vertical(12))
        .border(.bottom(.palette(.border_color_light)))
        .children({
        Text(label)
            .font(14, 400, Theme.text_muted)
            .fontFamily("Montserrat")
            .end();
        TextFmt(fmt, args)
            .font(14, 500, Theme.text)
            .fontFamily("Montserrat")
            .end();
    });
}

// ============================================================================
// MAIN RENDER
// ============================================================================

pub fn render() void {
    Box()
        .width(.percent(100))
        .height(.percent(100))
        .background(Theme.bg_base)
        .layout(.top_left)
        .children({

        // Main content area
        Stack()
            .width(.percent(100))
            .height(.percent(100))
            .children({
            // Header
            renderHeader();

            // Board
            renderBoard();
        });

        // Overlays
        detail_sheet.render();
        Toast.renderStack();
        alert.render();
    });
}
