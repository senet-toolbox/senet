const std = @import("std");
const Vapor = @import("vapor");
const RootPage = @import("routes/Page.zig");
const Navbar = @import("components/Navbar.zig");
const DocsNavbar = @import("components/DocNavbar.zig");
const VaporUILayout = @import("routes/vapor-ui/VaporUINav.zig");
// const AcornNavbar = @import("components/AcornNavbar.zig");
const VaporDocs = @import("routes/docs/vapor/Page.zig");
const VaporDocsConcepts = @import("routes/docs/vapor/concepts/:concept/Page.zig");
const MetalDocs = @import("routes/docs/metal/Page.zig");
const Huh = @import("routes/huh/Page.zig");
const Install = @import("routes/install/Page.zig");
const Theme = @import("theme");
const TestPage = @import("routes/TestPage.zig");
const Vaporize = @import("vaporize");
const LegoCity = @import("routes/lego-city/Page.zig");
const JsonEditor = @import("routes/JsonEditor.zig");
const FilePage = @import("routes/FilePage.zig");
const Stack = Vapor.Stack;
const SyncEngine = @import("sync/SyncEngine.zig");
const DatePicker = @import("components/DatePicker.zig");
const Opaque = @import("components/Opaque.zig");
const Table = Opaque.Table;
const Column = Opaque.Column;
const Action = Opaque.Action;
const Sheet = Opaque.Sheet;
const Select = Opaque.Select;
const Accordion = Opaque.Accordion;
const Alert = Opaque.Alert;
const Toast = Opaque.Toast;
const Chart = Opaque.Chart;
const ButtonCtx = Vapor.CtxButton;
const Field = Opaque.Field;
const Tooltip = Opaque.Tooltip;
const ComboBox = Opaque.ComboBox;
const OButton = Opaque.Button;
const ComboBoxDialog = Opaque.ComboBoxDialog;
const CommandPalette = Opaque.CommandPalette;
const Switch = Opaque.Switch;
const Login = @import("components/templates/Login.zig");
const Payment = @import("components/templates/Payment.zig");
const Profile = @import("components/templates/Profile.zig");
const Dashboard = @import("components/templates/Dashboard.zig");
const VaporUI = @import("routes/vapor-ui/Page.zig");
// const Payment = @import("components/templates/Payments.zig");
const KeyStone = Vapor.KeyStone;
const Bench = @import("routes/Bench.zig");
const OverlayManager = @import("components/OverlayManager.zig");
const AcornDashboard = @import("routes/acorn/Dashboard.zig");
// const Content = @import("components/Content.zig");
// const Draggable = Vapor.Draggable;
//
const Static = Vapor.Static;
const Center = Vapor.Center;
const Box = Vapor.Box;
const Button = Vapor.Button;
const TextFmt = Vapor.TextFmt;
const Text = Vapor.Text;
const TextField = Vapor.TextField;
const Label = Vapor.Label;
// const TextField = Vapor.TextField;
//
fn registerLayouts() !void {
    initLayouts();
    try Vapor.lib.registerLayout("/", layout, .{});
    try Vapor.lib.registerLayout("/docs", layoutDocs, .{ .reset = true });
}

//
// fn hook(ctx: Vapor.lib.HookContext) void {
//     // DocsNavbar.reinitObserver();
// }
//
// fn hookAfter(ctx: Vapor.lib.HookContext) void {
//     // Content.initBoxes();
//     Vapor.print("After Hook called {s}", .{ctx.to_path});
// }
fn initLayouts() void {
    Navbar.init();
    DocsNavbar.init();
}

pub fn layout(page: *const fn () void) void {
    page();
    Navbar.render();
}

pub fn layoutDocs(page: *const fn () void) void {
    page();
    DocsNavbar.render();
}
//
// fn layoutAcorn(page: *const fn () void) void {
//     AcornNavbar.render();
//     page();
// }
//
// fn ErrorPage() void {
//     Center().size(.full).direction(.column).spacing(32).children({
//         Text("Page Not Found").font(72, 700, .palette(.text_color)).end();
//         Center().spacing(32).width(.percent(100)).children({
//             Button(.{ .on_press = Vapor.Kit.back })
//                 .duration(100)
//                 .hoverScale()
//                 .cursor(.pointer)
//                 .hw(.px(45), .px(160))
//                 .border(.sharp(.all(1), .palette(.text_color)))
//                 .children({
//                 Text("Go back").fontFamily("Montserrat").font(18, null, null).end();
//             });
//         });
//     });
// }
//

fn ToastButton(func: anytype, options: Toast.Options, text: []const u8) void {
    ButtonCtx(func, .{options})
        .duration(100)
        .hoverScale()
        .cursor(.pointer)
        .hw(.px(45), .px(160))
        .border(.sharp(.all(1), .palette(.text_color)))
        .children({
        Text(text).fontFamily("Montserrat").font(18, null, null).end();
    });
}

var counter: usize = 0;

fn increment() void {
    counter += 1;
}

var _text: []const u8 = "";
fn ToastTrial() void {
    Box().size(.full).direction(.column)
        .layout(.top_center)
        .padding(.all(16))
        .spacing(32).children({
        // chart.render();
        Box()
            .border(.round(.palette(.border_color_light), .all(4)))
            .width(.percent(80))
            // .height(.percent(30))
            .children({
            table.render();
        });
        Stack()
            .width(.percent(30))
            .children({
            OButton(comboboxDialogOpen, .{}).children({
                Text("open")
                    .font(14, 300, .palette(.text_color))
                    .fontFamily("Montserrat")
                    .end();
            });
            // command_palette.render();
            // Field.render(.{ .label = "Email", .value = .{ .string = &_text } });

            // Switch.render("test-switch");
        });
    });

    sheet.render();
    // combobox_dialog.render();

    // alert.render();
}
// var items = [_]Accordion.AccordionItem{
//     .{
//         .title = "Product Information",
//         .description =
//         \\Our flagship product combines cutting-edge technology with sleek design.
//         \\Built with premium materials, it offers unparalleled performance and reliability.
//         ,
//         .trigger = AccordionTrigger,
//         .content = AccordionContent,
//     },
//     .{ .title = "Title", .description = "Description", .trigger = AccordionTrigger, .content = AccordionContent },
// };
// var accordion: Accordion = undefined;
//
// fn AccordionTrigger(item: *Accordion.AccordionItem) void {
//     Text(item.title)
//     .fontFamily("Montserrat")
//     .font(16, 300, .palette(.text_color)).end();
// }
//
// fn AccordionContent(item: *Accordion.AccordionItem) void {
//     Text(item.description).font(16, 300, .palette(.text_color)).end();
// }

fn regenerate() void {
    if (counter % 2 == 0) {
        const costs = [_]Chart.Point{
            .{ .x = 1, .y = 80 },
            .{ .x = 2, .y = 20 },
            .{ .x = 3, .y = 25 },
            .{ .x = 4, .y = 40 },
            .{ .x = 5, .y = 55 },
            .{ .x = 6, .y = 25 },
        };

        const sales = [_]Chart.Point{
            .{ .x = 1, .y = 40 },
            .{ .x = 2, .y = 95 },
            .{ .x = 3, .y = 10 },
            .{ .x = 4, .y = 40 },
            .{ .x = 5, .y = 65 },
            .{ .x = 6, .y = 75 },
        };

        chart.updateSeries(&.{
            Chart.SeriesData{ .name = "Sales", .data = &sales },
            Chart.SeriesData{ .name = "Costs", .data = &costs },
        });
    } else {
        const sales = [_]Chart.Point{
            .{ .x = 1, .y = 30 },
            .{ .x = 2, .y = 50 },
            .{ .x = 3, .y = 45 },
            .{ .x = 4, .y = 80 },
            .{ .x = 5, .y = 65 },
            .{ .x = 6, .y = 95 },
        };

        const costs = [_]Chart.Point{
            .{ .x = 1, .y = 20 },
            .{ .x = 2, .y = 35 },
            .{ .x = 3, .y = 30 },
            .{ .x = 4, .y = 50 },
            .{ .x = 5, .y = 45 },
            .{ .x = 6, .y = 55 },
        };

        chart.updateSeries(&.{
            Chart.SeriesData{ .name = "Sales", .data = &sales },
            Chart.SeriesData{ .name = "Costs", .data = &costs },
        });
    }
    counter += 1;
}

fn content(_: *Alert) void {
    Box()
        .width(.percent(100))
        .spacing(16)
        .direction(.column)
        .children({
        Text("Are you sure?")
            .font(22, 700, .palette(.text_color))
            .fontFamily("Montserrat")
            .end();
        Text("This action cannot be undone. This will permanently delete your account and remove your data from our servers.")
            .font(14, 300, .palette(.text_color))
            .fontFamily("Montserrat")
            .end();
        Box()
            .width(.percent(100))
            .spacing(16)
            .layout(.right_center)
            .children({
            ButtonCtx(Alert.close, .{&alert})
                .cursor(.pointer)
                .hw(.px(42), .px(100))
                .background(.palette(.text_color))
                .border(.round(.palette(.text_color), .all(6)))
                .hoverScale()
                .children({
                Text("Cancel").fontFamily("Montserrat").font(14, null, .white).end();
            });
            ButtonCtx(Alert.close, .{&alert})
                .cursor(.pointer)
                .hw(.px(42), .px(100))
                .border(.round(.palette(.text_color), .all(6)))
                .hoverScale()
                .children({
                Text("Close").fontFamily("Montserrat").font(14, null, .black).end();
            });
        });
    });
}
//
var alert: Alert = undefined;
var sheet: Sheet = undefined;
var date_picker: DatePicker = undefined;

var svg: ?[]const u8 = null;
var chart: Chart = undefined;

const Status = enum {
    pending,
    success,
    err,
};

const Data = struct {
    id: usize,
    status: Status,
    email: []const u8,
    amount: i32,
};

var data = [_]Data{
    .{ .id = 0, .status = .pending, .email = "john@doe.com", .amount = 100 },
    .{ .id = 1, .status = .success, .email = "jane@doe.com", .amount = 200 },
    .{ .id = 2, .status = .err, .email = "john@doe.com", .amount = 300 },
    .{ .id = 3, .status = .pending, .email = "mary@doe.com", .amount = 400 },
    .{ .id = 4, .status = .success, .email = "vic@doe.com", .amount = 500 },
    .{ .id = 5, .status = .err, .email = "alicia@doe.com", .amount = 600 },
    .{ .id = 6, .status = .pending, .email = "nick@doe.com", .amount = 700 },
    .{ .id = 7, .status = .success, .email = "paxton@doe.com", .amount = 800 },
    .{ .id = 8, .status = .err, .email = "jaden@doe.com", .amount = 900 },
    .{ .id = 9, .status = .pending, .email = "sara@doe.com", .amount = 1000 },
    .{ .id = 10, .status = .success, .email = "marina@doe.com", .amount = 1100 },
    .{ .id = 11, .status = .err, .email = "gil@doe.com", .amount = 1200 },
    .{ .id = 12, .status = .pending, .email = "clara@doe.com", .amount = 1300 },
    .{ .id = 13, .status = .pending, .email = "mads@doe.com", .amount = 1400 },
    .{ .id = 14, .status = .success, .email = "jake@doe.com", .amount = 1500 },
    .{ .id = 15, .status = .err, .email = "james@doe.com", .amount = 1600 },
    .{ .id = 16, .status = .pending, .email = "jake@doe.com", .amount = 1700 },
    .{ .id = 17, .status = .success, .email = "james@doe.com", .amount = 1800 },
    .{ .id = 18, .status = .err, .email = "james@doe.com", .amount = 1900 },
    .{ .id = 19, .status = .pending, .email = "jake@doe.com", .amount = 2000 },
    .{ .id = 20, .status = .success, .email = "james@doe.com", .amount = 2100 },
    .{ .id = 21, .status = .err, .email = "james@doe.com", .amount = 2200 },
    .{ .id = 22, .status = .pending, .email = "jake@doe.com", .amount = 2300 },
    .{ .id = 23, .status = .success, .email = "james@doe.com", .amount = 2400 },
    .{ .id = 24, .status = .err, .email = "james@doe.com", .amount = 2500 },
    .{ .id = 25, .status = .pending, .email = "jake@doe.com", .amount = 2600 },
    .{ .id = 26, .status = .success, .email = "james@doe.com", .amount = 2700 },
    .{ .id = 27, .status = .err, .email = "james@doe.com", .amount = 2800 },
    .{ .id = 28, .status = .pending, .email = "jake@doe.com", .amount = 2900 },
    .{ .id = 29, .status = .success, .email = "james@doe.com", .amount = 3000 },
    .{ .id = 30, .status = .err, .email = "james@doe.com", .amount = 3100 },
    .{ .id = 31, .status = .pending, .email = "jake@doe.com", .amount = 3200 },
    .{ .id = 32, .status = .success, .email = "james@doe.com", .amount = 3300 },
    .{ .id = 33, .status = .err, .email = "james@doe.com", .amount = 3400 },
    .{ .id = 34, .status = .pending, .email = "jake@doe.com", .amount = 3500 },
    .{ .id = 35, .status = .success, .email = "james@doe.com", .amount = 3600 },
    .{ .id = 36, .status = .err, .email = "james@doe.com", .amount = 3700 },
    .{ .id = 37, .status = .pending, .email = "jake@doe.com", .amount = 3800 },
    .{ .id = 38, .status = .success, .email = "james@doe.com", .amount = 3900 },
    .{ .id = 39, .status = .err, .email = "james@doe.com", .amount = 4000 },
    .{ .id = 40, .status = .pending, .email = "jake@doe.com", .amount = 4100 },
    .{ .id = 41, .status = .success, .email = "james@doe.com", .amount = 4200 },
    .{ .id = 42, .status = .err, .email = "james@doe.com", .amount = 4300 },
    .{ .id = 42, .status = .err, .email = "james@doe.com", .amount = 4300 },
    .{ .id = 44, .status = .pending, .email = "jake@doe.com", .amount = 4500 },
    .{ .id = 45, .status = .success, .email = "james@doe.com", .amount = 4600 },
    .{ .id = 46, .status = .err, .email = "james@doe.com", .amount = 4700 },
    .{ .id = 47, .status = .pending, .email = "jake@doe.com", .amount = 4800 },
    .{ .id = 48, .status = .success, .email = "james@doe.com", .amount = 4900 },
    .{ .id = 49, .status = .err, .email = "james@doe.com", .amount = 5000 },
    .{ .id = 50, .status = .pending, .email = "jake@doe.com", .amount = 5100 },
    .{ .id = 51, .status = .success, .email = "james@doe.com", .amount = 5200 },
    .{ .id = 52, .status = .err, .email = "james@doe.com", .amount = 5300 },
    .{ .id = 53, .status = .pending, .email = "jake@doe.com", .amount = 5400 },
    .{ .id = 54, .status = .success, .email = "james@doe.com", .amount = 5500 },
    .{ .id = 55, .status = .err, .email = "james@doe.com", .amount = 5600 },
    .{ .id = 56, .status = .pending, .email = "jake@doe.com", .amount = 5700 },
    .{ .id = 57, .status = .success, .email = "james@doe.com", .amount = 5800 },
    .{ .id = 58, .status = .err, .email = "james@doe.com", .amount = 5900 },
    .{ .id = 59, .status = .pending, .email = "jake@doe.com", .amount = 6000 },
    .{ .id = 60, .status = .success, .email = "james@doe.com", .amount = 6100 },
    .{ .id = 61, .status = .err, .email = "james@doe.com", .amount = 6200 },
    .{ .id = 62, .status = .pending, .email = "jake@doe.com", .amount = 6300 },
    .{ .id = 63, .status = .success, .email = "james@doe.com", .amount = 6400 },
    .{ .id = 64, .status = .err, .email = "james@doe.com", .amount = 6500 },
    .{ .id = 65, .status = .pending, .email = "jake@doe.com", .amount = 6600 },
    .{ .id = 66, .status = .success, .email = "james@doe.com", .amount = 6700 },
    .{ .id = 67, .status = .err, .email = "james@doe.com", .amount = 6800 },
    .{ .id = 68, .status = .pending, .email = "jake@doe.com", .amount = 6900 }, // <-- add this
    .{ .id = 69, .status = .success, .email = "james@doe.com", .amount = 7000 },
    .{ .id = 70, .status = .err, .email = "james@doe.com", .amount = 7100 },
    .{ .id = 71, .status = .pending, .email = "jake@doe.com", .amount = 7200 },
    .{ .id = 72, .status = .success, .email = "james@doe.com", .amount = 7300 },
    .{ .id = 73, .status = .err, .email = "james@doe.com", .amount = 7400 },
    .{ .id = 74, .status = .pending, .email = "jake@doe.com", .amount = 7500 },
    .{ .id = 75, .status = .success, .email = "james@doe.com", .amount = 7600 },
    .{ .id = 76, .status = .err, .email = "james@doe.com", .amount = 7700 },
    .{ .id = 77, .status = .pending, .email = "jake@doe.com", .amount = 7800 },
    .{ .id = 78, .status = .success, .email = "james@doe.com", .amount = 7900 },
    .{ .id = 79, .status = .err, .email = "james@doe.com", .amount = 8000 },
    .{ .id = 80, .status = .pending, .email = "jake@doe.com", .amount = 8100 },
    .{ .id = 81, .status = .success, .email = "james@doe.com", .amount = 8200 },
    .{ .id = 82, .status = .err, .email = "james@doe.com", .amount = 8300 },
    .{ .id = 83, .status = .pending, .email = "jake@doe.com", .amount = 8400 },
    .{ .id = 84, .status = .success, .email = "james@doe.com", .amount = 8500 },
    .{ .id = 85, .status = .err, .email = "james@doe.com", .amount = 8600 },
    .{ .id = 86, .status = .pending, .email = "jake@doe.com", .amount = 8700 },
    .{ .id = 87, .status = .success, .email = "james@doe.com", .amount = 8800 },
    .{ .id = 88, .status = .err, .email = "james@doe.com", .amount = 8900 },
    .{ .id = 89, .status = .pending, .email = "jake@doe.com", .amount = 9000 },
    .{ .id = 90, .status = .success, .email = "james@doe.com", .amount = 9100 },
    .{ .id = 91, .status = .err, .email = "james@doe.com", .amount = 9200 },
};

const columns = [_]Column(Data){
    Column(Data){ .title = "Status", .width = 100, .key = "status", .filter = true },
    Column(Data){ .title = "Email", .width = 100, .sort = .asc, .key = "email", .search = true },
    Column(Data){ .title = "Amount", .width = 100, .key = "amount" },
};

const MyTable = Table(Data, &columns, .{
    .actions = &[_]Action(Data){
        .{ .label = "Delete", .on_action = handleDelete, .icon = .trash },
        .{ .label = "Edit", .on_action = handleEdit, .icon = .pencil },
    },
});
var table: MyTable = undefined;

fn onSelect(item: *Data) void {
    Vapor.print("You selected {s}", .{item.email});
}

fn onFilter(item: *Data) void {
    Vapor.print("You filtered {s}", .{item.email});
}

fn handleDelete(item: *Data) void {
    Vapor.print("You deleted {s}", .{item.email});
}

var current_row: *Data = undefined;
fn handleEdit(item: *Data) void {
    current_row = item;
    Vapor.print("You edited {s}", .{item.email});
    status_select.default(Select(Status).Item{ .value = item.status, .label = @tagName(item.status) });
    sheet.open();
}

var focused: []const u8 = "";
fn onFocus(label: []const u8, _: *Vapor.Event) void {
    Vapor.print("Focused", .{});
    if (std.mem.eql(u8, focused, label)) {
        focused = "";
        return;
    }
    focused = label;
}

fn save() void {
    sheet.close();
    table.refresh();
}

fn toLowerCase(str: []const u8) []const u8 {
    return std.ascii.allocLowerString(Vapor.arena(.frame), str) catch unreachable;
}

fn EditField(label: []const u8, field_type: Vapor.Types.InputTypes, value: anytype) void {
    Stack()
        .width(.percent(100))
        .spacing(8)
        .children({
        Label(label)
            .font(14, 300, null)
            .fontFamily("Montserrat")
            .end();
        TextField(field_type)
            .fieldName(toLowerCase(label))
            .font(14, 300, null)
            .border(.round(if (std.mem.eql(u8, label, focused)) .palette(.tint) else .palette(.border_color_light), .all(6)))
            .padding(.tblr(8, 8, 12, 12))
            .outline(.none)
            .background(.transparent)
            .fontFamily("Montserrat")
            .font(14, 300, .palette(.text_color))
            .bind(value)
            .shadow(.{
                .color = if (std.mem.eql(u8, label, focused)) .transparentizeHex(.palette(.tint), 0.1) else .transparent,
                .spread = 2,
            })
            .onEventCtx(.focus, onFocus, label)
            .onEventCtx(.blur, onFocus, label)
            .end();
    });
}

fn TooltipContent() void {
    Text("Tooltip").font(14, 300, .palette(.alternate_text_color)).end();
}

fn TooltipTrigger() void {
    Text("Hover me").end();
}

fn TooltipContent2() void {
    Text("Tooltip2").font(14, 300, .palette(.alternate_text_color)).end();
}

fn ctx_increment(local_counter: *usize) void {
    local_counter.* += 1;
}

fn comboboxDialogOpen() void {
    // combobox_dialog.open();
    sheet.toggle();
}

fn sample(_: *Sheet) void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .layout(.top_center)
        .spacing(8)
        .children({
        Stack()
            .layout(.center)
            .children({
            TextFmt("{d}", .{2650})
                .layout(.center)
                .font(72, 700, .palette(.text_color))
                .fontFamily("Montserrat")
                .end();
            Text("Github Stars")
                .layout(.center)
                .font(14, 300, .palette(.text_color))
                .fontFamily("Montserrat")
                .end();
        });
        Box()
            .children({
            chart.render();
        });
        OButton(comboboxDialogOpen, .{})
            .width(.px(800 / 3))
            .children({
            Text("Close")
                .font(14, 300, .palette(.text_color))
                .fontFamily("Montserrat")
                .end();
        });
    });
}

fn EditRow(_: *Sheet) void {
    Stack()
        .width(.percent(100))
        .height(.percent(100))
        .padding(.all(20))
        .layout(.y_between_center)
        .children({
        Stack()
            .width(.percent(100))
            .spacing(32)
            .children({
            status_select.render();
            combobox.render();
            Field.render(.{ .label = "Email", .value = .{ .string = &current_row.email } });
            Field.render(.{ .label = "Amount", .value = .{ .number = &current_row.amount } });
            Tooltip.render(.{ .name = "info", .title = "Info", .content = "This is a tooltip" });
            Tooltip.render(.{ .name = "info", .title = "Info", .content = "This is a tooltip" });
            Tooltip.render(.{ .name = "info2", .trigger = TooltipTrigger, .component = TooltipContent });
            OButton(ctx_increment, .{&counter}).children({
                Text("Increment")
                    .font(14, 300, .palette(.text_color))
                    .fontFamily("Montserrat")
                    .end();
            });
        });
        Button(.{ .on_press = save })
            .font(14, 300, .white)
            .border(.round(.palette(.border_color_light), .all(4)))
            .padding(.tblr(8, 8, 8, 8))
            .background(.palette(.background))
            .children({
            Text("Save")
                .font(16, 700, .palette(.text_color))
                .fontFamily("Montserrat")
                .end();
        });
    });
}

var status_select: Select(Status) = undefined;

var combobox: ComboBox(Status) = undefined;

const MenuItem = struct {
    label: []const u8,
    icon: ?*const Vapor.IconTokens = null,
    value: []const u8 = "",
};

var menu_items = [_]MenuItem{
    .{ .label = "Item 1", .value = "1" },
    .{ .label = "Item 2", .value = "2" },
    .{ .label = "Item 3", .value = "3" },
    .{ .label = "Item 4", .value = "4" },
    .{ .label = "Item 5", .value = "5" },
    .{ .label = "Item 6", .value = "6" },
    .{ .label = "Item 7", .value = "7" },
    .{ .label = "Item 8", .value = "8" },
    .{ .label = "Item 9", .value = "9" },
};

var combobox_dialog: ComboBoxDialog(MenuItem) = undefined;

var command_palette: CommandPalette = .{};

var status_options = [_]Select(Status).Item{
    .{ .value = Status.pending, .label = "Pending" },
    .{ .value = Status.success, .label = "Success" },
    .{ .value = Status.err, .label = "Error" },
};

var combobox_options = [_]ComboBox(Status).Item{
    .{ .value = Status.pending, .label = "Pending" },
    .{ .value = Status.success, .label = "Success" },
    .{ .value = Status.err, .label = "Error" },
    .{ .value = Status.pending, .label = "Pending" },
    .{ .value = Status.err, .label = "Error" },
    .{ .value = Status.success, .label = "Success" },
    .{ .value = Status.err, .label = "Error" },
};

var combobox_dialog_options = [_]ComboBoxDialog(Status).Item{
    .{ .value = Status.pending, .label = "Pending" },
    .{ .value = Status.success, .label = "Success" },
    .{ .value = Status.err, .label = "Error" },
    .{ .value = Status.pending, .label = "Pending" },
    .{ .value = Status.err, .label = "Error" },
    .{ .value = Status.success, .label = "Success" },
    .{ .value = Status.err, .label = "Error" },
};

fn onStatusSelect(item: *Select(Status).Item) void {
    current_row.status = item.value;
}

const GoogleResponse = struct {
    success: bool,
    token: []const u8,
    user: struct { name: []const u8, email: []const u8 },
};

fn onAuthChange(resp: Vapor.Kit.Response) void {
    if (resp.isOk()) {
        Vapor.printlnSrc("Logged response {s}", .{resp.ok.body}, @src());
        const parsed_value: std.json.Parsed(GoogleResponse) = std.json.parseFromSlice(GoogleResponse, Vapor.arena(.persist), resp.ok.body, .{}) catch |err| {
            Vapor.printSrcErr("Error could not parse response {any} {s}\n", .{ err, resp.ok.body }, @src());
            return;
        };
        const google_resp: GoogleResponse = parsed_value.value;
        Vapor.lib.store("google_session_token", google_resp.token);
    }
}

var login: Login = .{
    .login_title = "Login into Acorn",
    .login_subtitle = "Login into your Acorn account.",
    .create_account_title = "Create Acorn Account",
    .create_account_subtitle = "Create an Acorn account to login",
};

// var payment: Payment = .{
//     // .title = "Payment",
//     // .subtitle = "Payment to your account",
// };

fn PaymentPage() void {
    Box()
        .layout(.center)
        .size(.full)
        .spacing(128)
        .children({
        Box()
            .width(.percent(40))
            .height(.percent(40))
            .direction(.column)
            .layout(.top_left)
            .spacing(16)
            .children({
            // payment.render();
        });
    });
}

fn LoginPage() void {
    Box()
        .layout(.center)
        .size(.full)
        .spacing(128)
        .children({
        Box()
            .width(.percent(40))
            .height(.percent(40))
            .direction(.column)
            .layout(.top_left)
            .spacing(16)
            .children({
            login.render();
        });
    });
}

fn returnError() void {
    std.log.info("Hello from Zig!", .{});
    std.log.err("An error occurred: {d}", .{42});
    std.log.debug("Debug value: {s}", .{"test"});
    // unreachable;
}

fn initPages() void {
    // VaporUI.init();
    // KeyStone.init(.{ .google = .{ .client_id = "868061436260-4irmgvghqm8107i21iodr88r8uu10g5u.apps.googleusercontent.com" } });
    // KeyStone.onAuthChange(onAuthChange);

    // AcornDashboard.init();
    // Vapor.Page(.{ .route = "/" }, SyncEngine.CrudRender, null);
    // SyncEngine.init();

    // TestPage.init();
    // Bench.init();
    // JsonEditor.init();
    // FilePage.init();
    Vapor.Page(.{ .route = "/" }, RootPage.render, null);
    RootPage.init();
    VaporDocs.init();
    VaporDocsConcepts.init();
    // // LegoCity.init();
    // // Vapor.Page(.{ .route = "/lego-city" }, LegoCity.render, null);
    // // Vapor.Page(.{ .route = "/error" }, ErrorPage, null); // Weird bug where if you put any route before the "/" it loads that route instead of the root
    MetalDocs.init();
    Huh.init();
    Install.init();
    //
    // Vapor.Page(.{ .route = "/login" }, LoginPage, null);
    // // // payment.init();
    // Vapor.Page(.{ .route = "/payment" }, Payment.render, null);
    // Vapor.Page(.{ .route = "/auth" }, Profile.render, null);

    // Dashboard.init(); // Build animations
    // Vapor.Page(.{ .route = "/dashboard" }, Dashboard.render, null);
    // Vapor.Page(.{ .route = "/success" }, Payment.render, null);
    // Vapor.Page(.{ .route = "/vapor-ui" }, Opaque.View, null);
}
//
// export fn immediateMode() void {
//     Vapor.cycle();
// }
//
// var counter: u32 = 0;
// fn increment() void {
//     Vapor.print("Increment", .{});
//     // Vapor.registerCtxTimeout("test", 1000, Vapor.print, .{ "Hello", .{} });
//     // test_struct.inner_struct.count += 1;
// }
// // //
// fn CounterWithBuider() void {
//     // const Center, Text, Button, TextFmt = .{ Vapor.Center, Vapor.Text, Vapor.Button, Vapor.TextFmt };
//     // Center().size(.full).direction(.column).children({
//     //     Text("Vapor").font(16 * 10, 700, .palette(.text_color)).end();
//     //     Center().spacing(32).width(.percent(100)).children({
//     Button(.{ .on_press = increment })
//         .duration(100)
//         .hoverScale()
//         .cursor(.pointer)
//         .hw(.px(45), .px(160))
//         .border(.sharp(.all(1), .palette(.text_color)))
//         .children({
//         Text("Increment").fontFamily("Montserrat").font(18, null, null).end();
//     });
//     Text(counter)
//         .width(.px(48))
//         .font(32, 700, .palette(.text_color)).end();
//     // });
//     // });
// }
//
// fn CounterWithStyle() void {
//     Center().style(Styles.container)({
//         Text("Vapor").style(Styles.title);
//         Center().style(Styles.controls)({
//             Button(.{ .on_press = increment }).style(Styles.button)({
//                 Text("Increment").style(Styles.button_text);
//             });
//             TextFmt("{d}", .{counter}).style(Styles.counter);
//         });
//     });
// }
//
// const Styles = struct {
//     pub const container = &Vapor.Style{
//         .size = .full,
//         .direction = .column,
//     };
//     pub const title = &Vapor.Style{
//         .visual = .font(160, 700, .palette(.text_color)),
//     };
//     pub const controls = &Vapor.Style{
//         .size = .{ .width = .percent(100) },
//         .child_gap = 32,
//     };
//
//     pub const button = &Vapor.Style{
//         .size = .hw(.px(45), .px(160)),
//         .visual = .{ .border = .sharp(.all(1), .palette(.text_color)), .cursor = .pointer },
//         .transition = .{ .duration = 100 },
//         .interactive = .hover_scale(),
//     };
//     pub const button_text = &Vapor.Style{
//         .visual = .{ .font_size = 18 },
//         .font_family = "Montserrat",
//     };
//     pub const counter = &Vapor.Style{
//         .size = .{ .width = .px(48) },
//         .visual = .font(32, 700, .palette(.text_color)),
//     };
// };
// var text: []const u8 = "";
// fn logText(evt: *Vapor.Event) void {
//     Vapor.print("From Text: {s}", .{evt.text()});
// }
//
// fn CommonButton() Vapor.Builder {
//     return Button(.{ .on_press = increment })
//         .border(.sharp(.all(1), .black))
//         .padding(.tblr(4, 4, 8, 8));
// }
//
// var binded: Vapor.Binded = .{};
// var draggable_id: usize = 0;
// var intialX: f32 = 0;
// var intialY: f32 = 0;
// var x: f32 = 0;
// var y: f32 = 0;
// var currentX: f32 = 0;
// var currentY: f32 = 0;
// fn drag(evt: *Vapor.Event) void {
//     evt.preventDefault();
//     const deltaX = evt.clientX() - intialX;
//     const deltaY = evt.clientY() - intialY;
//     x = currentX + deltaX;
//     y = currentY + deltaY;
//
//     binded.translate3d(.{ .x = x, .y = y });
//     // Vapor.print("Box: {any} {any}", .{ x, y });
// }
//
// fn addDraggable(_: *Vapor.Event) void {
//     // Vapor.print("Box: addDraggable Client {any} {any}", .{ evt.clientX(), evt.clientY() });
//     // Vapor.print("Box: addDraggable Offset {any} {any}", .{ evt.offsetX(), evt.offsetY() });
//     // intialX = evt.clientX();
//     // intialY = evt.clientY();
//     // draggable_id = draggable.addListener(.mousemove, drag) orelse unreachable;
// }
//
// fn removeDraggable(_: *Vapor.Event) void {
//     Vapor.print("Box: removeDraggable", .{});
//     _ = draggable.removeListener(.mousemove, draggable_id);
// }
//
// var draggable: Draggable = .{
//     // .on_drag = onDrag,
// };
// // fn mount() void {
// //     _ = draggable(&binded);
// // }
//
// fn onDrag(self: *Draggable, evt: *Vapor.Event) void {
//     Vapor.print("Box: onDrag {any}", .{evt});
//     self.updatePosition(self.x, self.y);
// }
//
// var drop_area: Vapor.Binded = .{};
//
// fn mount() void {
//     Vapor.println("mount", .{});
//     counter = 10;
//     Vapor.cycle();
// }
//
// fn onDragOver(evt: *Vapor.Event) void {
//     Vapor.print("Drag: onDrop {any}", .{evt});
// }
//
// fn App() void {
//     vaporize.compileForm(Form) catch unreachable;
//
//     // Text("Hello").end();
//     // CounterWithBuider();
//
//     // Vaporize.init();
//     // Center().size(.full).children({
//     // Static.Hooks(.{ .mounted = mount })({
//     //     Box().size(.full).layout(.x_between_center).children({
//     //         Box().width(.percent(25)).height(.percent(100)).background(.blue).children({
//     //             Text("Drag Here").end();
//     //         });
//     //         Box()
//     //             .pos(.absolute)
//     //             .width(.px(100)).height(.px(100))
//     //             .background(.red)
//     //             .createDraggable(&draggable)
//     //             .end();
//     //         Box().ref(&drop_area).width(.percent(25)).height(.percent(100)).background(.green).children({
//     //             Text("Drop Here").end();
//     //         });
//     //     });
//     // });
//     // });
// }
// const Count = struct {
//     count: u32,
// };
//
// fn fetchCounter() void {
//     _ = Vapor.Kit.fetch("http://localhost:8080/ping", handleCounter, .{ .method = .GET });
//     // const resp = future.await();
//     // Vapor.print("Fetched {any}", .{resp});
// }
//
// fn handleCounter(resp: Vapor.Kit.Response) void {
//     switch (resp) {
//         .ok => |data| {
//             const parsed = Vapor.Kit.glue(Count, data.body) catch |err| {
//                 Vapor.printErr("Failed to parse response: {any}", .{err});
//                 return;
//             };
//             counter = parsed.count;
//         },
//         .err => |err| {
//             Vapor.printErr("Failed to fetch: {s}", .{err.message});
//             return;
//         },
//     }
// }

//
// const Form2 = struct {
//     height: u32 = 0,
//     weight: u32 = 0,
//     pub var __validations = .{
//         .weight = Vaporize.Validation{
//             .min_value = 18,
//             .max_value = 120,
//             .err = "Weight must be between 5 and 250",
//         },
//         .height = Vaporize.Validation{
//             .min_value = 18,
//             .max_value = 120,
//             .err = "Height must be between 100 and 210",
//         },
//     };
// };

// fn CommonButton() Vapor.Builder {
//     return Button(.{ .on_press = increment })
//         .border(.sharp(.all(1), .black))
//         .padding(.tblr(4, 4, 8, 8));
// }

const Form = struct {
    username: []const u8 = "",
    email: []const u8 = "",
    phonenumber: []const u8 = "",
    password: []const u8 = "",
    age: u32 = 0,

    pub var __validations = .{
        .username = Vaporize.Validation{ .min = 3, .max = 10, .err = "Username must be between 3 and 10 characters" },
        .email = Vaporize.Validation{ .field_type = .email },
        .phonenumber = Vaporize.Validation{ .field_type = .telephone },
        .password = Vaporize.Validation{ .field_type = .password },
        .age = Vaporize.Validation{
            .min_value = 18,
            .max_value = 120,
            .err = "Age must be between 18 and 120",
        },
    };
};

var new_form: vaporize.Form(Form) = undefined;
fn App() void {
    // Text("Hello").end();
    // CommonButton().background(.red).children({
    //     Text("Hello").end();
    // });
    //
    // CommonButton().background(.blue).padding(.all(10)).border(.dashed(.all(1), .black)).children({
    //     Text("Hello").end();
    // });
    //
    //
    Stack().direction(.column).layout(.top_center).size(.full).children({
        Stack().width(.percent(60)).layout(.center).padding(.all(16))
            .border(.sharp(.tblr(1, 0, 0, 1), .palette(.text_color)))
            .children({
            Stack()
                .width(.percent(100)).layout(.center).spacing(16)
                .border(.simple(.palette(.text_color)))
                .children({
                Text("SIGN UP").font(84, 900, .palette(.text_color))
                    .padding(.horizontal(12))
                    .border(.bottom(1, .palette(.text_color)))
                    .layout(.center)
                    .width(.percent(100))
                    .end();
                Stack()
                    .width(.percent(100)).layout(.center).spacing(16).padding(.all(20))
                    .children({
                    new_form.render();
                });
            });
        });
    });
}

// fn App2() void {
//     // vaporize.compile("Form") catch unreachable;
//     // vaporize.compile("Form") catch unreachable;
//     Box().width(.percent(30)).layout(.center).spacing(16).padding(.all(20)).children({
//         new_form2.render();
//     });
// }

const style_config = Vaporize.StyleConfig{
    .code_style = .{ .visual = .{
        .text_color = .palette(.tint),
        .background = .palette(.background),
        .border = .simple(.palette(.text_color)),
    } },
    .text_style = .{
        .visual = .{ .text_color = .palette(.text_color) },
    },
    .heading_style = .{ .visual = .{ .text_color = .palette(.text_color) } },
    .text_field_style = .{
        .size = .hw(.px(38), .percent(100)),
        .padding = .tblr(4, 4, 8, 8),
        .transition = .{ .duration = 100 },
        .visual = .{
            .outline = .none,
            .border = .simple(.palette(.text_color)),
            .background = .palette(.background),
            .font_size = 18,
        },
        .interactive = .{
            .hover = .{
                .border = .simple(.palette(.tint)),
            },
        },
        .font_family = "Montserrat",
    },
    .struct_style = .{
        .layout = .left_center,
        .direction = .column,
        .child_gap = 8,
        .size = .hw(.fit, .percent(100)),
    },
    .list_style = .{ .layout = .left_center, .direction = .column, .child_gap = 8 },
    .button_style = .{
        .layout = .center,
        .size = .hw(.px(52), .percent(50)),
        .visual = .{
            .border = .none,
            .background = .palette(.text_color),
            .cursor = .pointer,
            .font_size = 18,
            .text_color = .white,
        },
        .transition = .{ .duration = 100 },
        .interactive = .hoverScaleTextBackground(.white, .palette(.tint)),
        .child_gap = 8,
        .font_family = "Montserrat",
    },
    .submit_style = .{
        .layout = .center,
        .size = .w(.percent(100)),
        .margin = .{ .top = 32 },
        .visual = .{
            .border = .round(.transparentizeHex(.palette(.alternate_background), 0.5), .all(4)),
            .background = .transparentizeHex(.palette(.alternate_background), 0.9),
            .cursor = .pointer,
            .font_size = 16,
            .text_color = .white,
            .new_shadow = Vapor.Types.NewShadow.init()
                .inset(0, -2, .transparentizeHex(.palette(.alternate_background), 0.5))
                .drop(0, 1, 3, .transparentizeHex(.palette(.alternate_background), 0.1)),
        },
        .transition = .{ .duration = 100 },
        .interactive = .{
            .hover = .{
                .new_shadow = Vapor.Types.NewShadow.init()
                    .inset(0, -2, .transparentizeHex(.black, 0))
                    .drop(0, 1, 3, .transparentizeHex(.black, 0)),
            },
        },
        .padding = .tblr(4, 4, 8, 8),
        .child_gap = 8,
        .font_family = "IBM Plex Sans,monospace",
    },
    .table_header_style = Vapor.Types.Style{
        .size = .w(.percent(100)),
        .direction = .row,
        .layout = .left_center,
        .visual = .{
            .background = .palette(.tint),
            .border = .bottom(1, .palette(.border_color)),
            .text_color = .palette(.alternate_text_color),
        },
    },
    .table_row_style = Vapor.Types.Style{
        .size = .w(.percent(100)),
        .direction = .row,
        .layout = .left_center,
        .visual = .{
            .background = .transparent,
            .border = .bottom(1, .palette(.border_color)),
            .text_color = .palette(.text_color),
        },
    },
};
//
// var new_form2: vaporize.comptimeForm(Form2) = undefined;
pub var vaporize: Vaporize.Compiler = undefined;

const TodoItem = @import("haiku3-5.zig");
pub export fn init() void {
    // InitializeVapor
    Vapor.init(.{
        .mode = .atomic, // .atomic
        .page_node_count = 10_240,
    });

    // Initialize todo list
    // TodoItem.init();

    OverlayManager.init();
    Opaque.initAnimations();
    // Opaque.new();
    // Opaque.init();

    vaporize = Vaporize.init(Vapor.arena(.persist), .{}) catch unreachable; // this causes issues
    // initHooks();

    // Global style variables
    Vapor.setGlobalStyleVariables(.{ // Adds 11kb
        .themes = &.{
            Vapor.ThemeDefinition{ .name = "light", .theme = Theme.Light, .default = true },
            Vapor.ThemeDefinition{ .name = "dark", .theme = Theme.Dark },
        },
    });

    // Initialize your root component or app
    registerLayouts() catch |err| {
        Vapor.lib.printlnSrcErr("Failed to register layout {any}", .{err}, @src());
    };
    initPages();
    // Vapor.Page(.{ .route = "/fjlskfj" }, App2, null);
}

pub fn main() void {}

// // Import a JS function to handle the panic message
// extern fn jsPanic(ptr: [*]const u8, len: usize) noreturn;
//
// pub const panic = myPanic;
//
// fn myPanic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
//     // Pass the message to JS before crashing
//     jsPanic(msg.ptr, msg.len);
//     // Ensure the Wasm execution actually stops
//     @trap();
// }

pub const std_options = std.Options{
    .log_level = .debug,
    .logFn = Vapor.lib.log,
};

// pub const std_options = std.Options{
//     // Set the log level (optional, defaults to .info in safe modes)
//     .log_level = .debug,
//
//     // Override the log function
//     .logFn = log,
// };
//
// pub fn log(
//     comptime level: std.log.Level,
//     comptime scope: @Type(.enum_literal),
//     comptime format: []const u8,
//     args: anytype,
// ) void {
//     if (Vapor.lib.isWasi and Vapor.lib.build_options.enable_debug) {
//         const allocator = Vapor.arena(.persist);
//         const buf = std.fmt.allocPrint(allocator, format, args) catch return;
//         const buf_with_src = std.fmt.allocPrint(allocator, "[{any}] [{any}] {s}", .{ level, scope, buf[0..] }) catch return;
//         _ = Vapor.Wasm.consoleLogWasm(buf_with_src.ptr, buf_with_src.len);
//         Vapor.arena(.persist).free(buf_with_src);
//         Vapor.arena(.persist).free(buf);
//     } else if (!Vapor.lib.isWasi) {
//         std.debug.print(format, args);
//     }
//     // Implementation that calls a 'jsLog' extern function
//     // similar to the panic handler above.
// }
