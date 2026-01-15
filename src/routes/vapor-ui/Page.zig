const Vapor = @import("vapor");
const Opaque = @import("../../components/Opaque.zig");
const Templates = @import("../../components/templates/Dashboard.zig");
const KanbanBoard = @import("../../components/templates/KanbanBoard.zig");
const Tabs = Opaque.Tabs;
const Text = Vapor.Text;
const Box = Vapor.Box;
const Center = Vapor.Center;
const Stack = Vapor.Stack;
const Login = @import("../../components/templates/Login.zig");
const KeyStone = Vapor.KeyStone;
const Payment = @import("../../components/templates/Payment.zig");
const Stripe = @import("../../components/templates/Stripe.zig");
const ChartPage = @import("../../routes/ui/chart/ChartPage.zig");
const ButtonPage = @import("../../routes/ui/button/ButtonPage.zig");
const CommandPalettePage = @import("../../routes/ui/commandpalette/CommandPalettePage.zig");
const ComboBoxPage = @import("../../routes/ui/combobox/ComboboxPage.zig");
const AccordionPage = @import("../../routes/ui/accordion/AccordionPage.zig");
const SelectPage = @import("../../routes/ui/select/SelectPage.zig");
const Footer = @import("Footer.zig");
const VaporUINav = @import("VaporUINav.zig");
const TablePage = @import("../../routes/ui/table/TablePage.zig");
const DialogPage = @import("../../routes/ui/dialog/DialogPage.zig");
const AlertPage = @import("../../routes/ui/alert/AlertPage.zig");
const DatePickerPage = @import("../../routes/ui/datepicker/DatePickerPage.zig");
const DrawerPage = @import("../../routes/ui/drawer/DrawerPage.zig");
const ToastPage = @import("../../routes/ui/toasts/ToastPage.zig");
const TextFieldPage = @import("../../routes/ui/textfield/TextFieldPage.zig");

var login: Login = .{
    .login_title = "Login into Acorn",
    .login_subtitle = "Login into your Acorn account.",
    .create_account_title = "Create Acorn Account",
    .create_account_subtitle = "Create an Acorn account to login",
};

var stripe: Stripe = .{
    .title = "Payment",
    .subtitle = "Payment to your account",
};

pub fn init() void {
    VaporUINav.init();
    Vapor.lib.registerLayout("/ui", layout, .{}) catch unreachable;
    KanbanBoard.init();
    // Templates.init();
    // Payment.init();
    // stripe.init();
    // KeyStone.init(.{
    //     .google = .{ .client_id = "857934785938457..." },
    //     .github = .{ .client_id = "495370952740521..." },
    //     .apple = .{ .client_id = "1434343434343..." },
    // });
    // ChartPage.init();
    // ComboBoxPage.init();
    // SelectPage.init();
    // AccordionPage.init();
    // AlertPage.init();
    // DatePickerPage.init();
    // DrawerPage.init();
    // DialogPage.init();
    // TablePage.init();
    // ButtonPage.init();
    // CommandPalettePage.init();
    TextFieldPage.init();
    // ToastPage.init();
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn layout(page: *const fn () void) void {
    VaporUINav.render();
    page();
    Box()
        .width(.percent(100))
        .layout(.top_center)
        .padding(.b(32))
        .children({
        Box()
            .width(.percent(50))
            .children({
            Footer.render();
        });
    });
}

pub fn render() void {
    Vapor.Stack()
        .width(.percent(100))
        .layout(.top_center)
        .children({
        Vapor.Stack()
            .layout(.center)
            .height(.px(512))
            .width(.percent(100))
            .children({
            Text("vapor-ui ⇒").style(&.{
                .visual = .font(12, 500, .hex("#6f6f6f")),
                .font_family = "IBM Plex Mono,monospace",
            });
            Text("vapor-ui")
                .font(72, 700, .palette(.text_color))
                .end();
            Text("Vapor UI is a collection of well crafted UI components for Vapor. It comes with default animations, and a rich set of components.")
                .font(16, 300, .palette(.text_color))
                .end();
            Text("Vapor allows you to build complex UIs, and Animations, with no dependencies.")
                .font(14, 300, .palette(.text_color))
                .fontFamily("Montserrat")
                .end();
        });
        Stack()
            .spacing(24)
            .width(.percent(90))
            .children({
            const index = Tabs.NavBar("vapor-ui", &.{ "Components", "Templates", "Authentication", "Payments", "Stripe" });
            switch (index) {
                0 => {
                    // Opaque.View();
                    KanbanBoard.render();
                },
                1 => {
                    // KanbanBoard.render();
                    // Templates.render();
                },
                2 => {
                    Box()
                        .width(.percent(100))
                        .layout(.center)
                        .children({
                        Box()
                            .direction(.column)
                            .width(.percent(50))
                            .children({
                            login.render();
                        });
                    });
                },
                3 => {
                    Payment.render();
                },
                4 => {
                    Box()
                        .width(.percent(100))
                        .layout(.center)
                        .children({
                        Box()
                            .direction(.column)
                            .width(.percent(50))
                            .children({
                            stripe.render();
                        });
                    });
                },

                else => {},
            }
        });
    });
}
