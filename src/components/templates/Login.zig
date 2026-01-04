const std = @import("std");
const Vapor = @import("vapor");
const Text = Vapor.Text;
const Box = Vapor.Box;
const Center = Vapor.Center;
const Stack = Vapor.Stack;
const Opaque = @import("../Opaque.zig");
const Tabs = Opaque.Tabs;
const Field = Opaque.Field;
const Button = Opaque.Button;
const glitch = Opaque.glitch;
const KeyStone = Vapor.KeyStone;
const TrainTicket = @import("TrainTicket.zig");
const utils = Vapor.utils;
const Compiler = @import("../../main.zig");
const Vaporize = @import("vaporize");
const Validation = @import("vaporize").Validation;
const ValidationError = @import("vaporize").ValidationError;
const Select = @import("../Select.zig").Select;

var hovered: ?*const Vapor.IconTokens = null;

pub const Details = struct {
    username: []const u8 = "",
    email: []const u8 = "",
    password: []const u8 = "",
};

var details: Details = .{};

const key =
    \\<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-key-icon lucide-key"><path d="m15.5 7.5 2.3 2.3a1 1 0 0 0 1.4 0l2.1-2.1a1 1 0 0 0 0-1.4L19 4"/><path d="m21 2-9.6 9.6"/><circle cx="7.5" cy="15.5" r="5.5"/></svg>
;

fn submit() void {
    if (KeyStone.isAuthenticated()) {
        Vapor.print("Already logged in", .{});
    } else {
        Vapor.print("Logging in", .{});
    }
}

fn createAccount() void {
    const payload = utils.stringify(details, .frame) catch unreachable;
    Vapor.Kit.fetch("http://localhost:8080/user", createdAccount, .{
        .method = .POST,
        .credentials = "include",
        .body = payload,
        .body_type = .json,
    });
}

fn createdAccount(resp: Vapor.Kit.Response) void {
    if (resp.isOk()) {
        Vapor.println("Account created {s}", .{resp.ok.body});
    }
}

fn validateSession(resp: Vapor.Kit.Response) void {
    if (resp.isOk()) {
        Vapor.println("Session validated {s}", .{resp.ok.body});
    }
}

fn googleLogin() void {
    KeyStone.signInWithOauth(.google);
}

fn Card() Vapor.Builder(.pure) {
    return Stack()
        .background(.transparentizeHex(.palette(.background), 0.5))
        .border(.round(.palette(.border_color_light), .all(12)))
        .width(.percent(100))
        .padding(.all(16))
        .layout(.top_left)
        .spacing(16);
}

fn onHover(icon: *const Vapor.IconTokens, _: *Vapor.Event) void {
    hovered = icon;
}

fn onLeave(_: *Vapor.Event) void {
    hovered = null;
}

fn AuthBtn(func: anytype, icon: *const Vapor.IconTokens) void {
    Button(func, .{})
        .size(.hw_px(36, 36))
        .layout(.center)
        .background(.transparentizeHex(.black, 0.8))
        .border(.round(.black, .all(8)))
        .pointer()
        .hover(.{
            .background = .yellow,
            .text_color = .black,
        })
        .onEventCtx(.pointerenter, onHover, icon)
        .onLeave(onLeave)
        .children({
        const active = hovered != null and std.mem.eql(u8, hovered.?.web.?, icon.web.?);
        Vapor.Icon(icon)
            .font(18, 700, if (active) .black else .palette(.alternate_text_color))
            .end();
    });
}

const Country = enum {
    US,
    CA,
    UK,
};

const PaymentMethod = enum {
    card,
    paypal,
};

const CheckoutForm = struct {
    // Account
    account: struct {
        email: []const u8 = "",
        password: []const u8 = "",
        confirm_password: []const u8 = "",
        contact: struct {
            phone: []const u8 = "",
        } = .{},
    } = .{},

    payment: struct {
        method: []const u8 = "",
        expiry: []const u8 = "",
        cvv: []const u8 = "",
        billing_address: []const u8 = "",
        card_number: []const u8 = "",
    } = .{},

    shipping_details: struct {
        shipping_same_as_billing: Vaporize.Condition(CheckoutForm) = .{
            .callback = sameAsBilling,
            .target_field = "shipping",
        },
    } = .{},

    shipping: struct {
        address: []const u8 = "",
        country: []const u8 = "",
        state: []const u8 = "",
        city: []const u8 = "",
        postal_code: []const u8 = "",
    } = .{},

    pub const __validations = .{
        .email = Validation{ .field_type = .email },
        .password = Validation{ .field_type = .password },
        .confirm_password = Validation{ .field_type = .password, .target_field = "password", .match = true },
        .phone = Validation{ .field_type = .telephone, .depends_on = "country" },
        .card_number = Validation{ .field_type = .credit_card },
        .expiry = Validation{ .field_type = .expiry, .placeholder = "MM/YY" },
    };

    pub const __components = .{
        .method = PaymentMethodComponent,
        .cvv = CvvComponent,
        .country = CountryComponent,
    };
};

const Currency = enum {
    usd,
    eur,
};

const LoginForm = struct {
    email: []const u8 = "",
    password: []const u8 = "",
    age: u8 = 0,
    credit_card: []const u8 = "",
    currency: Currency = .usd,
    pub const __validations = .{
        .email = Validation{ .field_type = .email },
        .password = Validation{ .field_type = .password },
        .age = Validation{ .field_type = .int },
    };

    pub const __components = .{
        .credit_card = CreditCardComponent,
        .currency = CurrencyComponent,
    };
};

fn CreditCardComponent(form: *CheckoutForm, err: ?ValidationError) void {
    Box()
        .width(.percent(100))
        .direction(.column)
        .spacing(8)
        .children({
        Field.render(.{ .type = .string, .label = "Credit Card", .value = .{ .credit_card = &form.payment.card_number } });
        Box()
            .height(.px(16))
            .width(.percent(100)).children({
            if (err) |e| {
                Text(e.message)
                    .inlineStyle("min-width: 0;", .{})
                    .font(12, null, .red)
                    .height(.px(16))
                    .width(.percent(100))
                    .ellipsis(.dot)
                    .end();
            }
        });
    });
}

fn CvvComponent(form: *CheckoutForm, _: ?ValidationError) void {
    Box().width(.percent(30)).children({
        Field.render(.{
            .type = .cvv,
            .label = "CVV",
            .value = .{ .string = &form.payment.cvv },
            .field_name = "cvv",
            .placeholder = .{ .string = "123" },
        });
    });
}

var select: Select(Currency) = undefined;
fn CurrencyComponent(_: *LoginForm) void {
    select.render();
}

var payment_method: Select(PaymentMethod) = undefined;
fn PaymentMethodComponent(_: *CheckoutForm, _: ?ValidationError) void {
    payment_method.render();
}

var country: Select(Country) = undefined;
fn CountryComponent(_: *CheckoutForm, _: ?ValidationError) void {
    country.render();
}

fn sameAsBilling(form: *CheckoutForm) void {
    Vapor.print("sameAsBilling {any}", .{form.shipping_details.shipping_same_as_billing.value});
}

const FormCheckout = Compiler.vaporize.Form(CheckoutForm);
var login_form: FormCheckout = undefined;
var login_form2: FormCheckout = undefined;

pub fn init() void {
    // compile the struct into a UI form
    login_form.compile() catch unreachable;
    // login_form.inner_form.on_submit = onSubmit;

    login_form2.compile() catch unreachable;
    // login_form2.inner_form.on_submit = onSubmit;

    select = .fromItems(&.{
        .{ .value = Currency.usd, .label = "USD" },
        .{ .value = Currency.eur, .label = "EUR" },
    });

    select.trigger = "Currency";

    payment_method = .fromItems(&.{
        .{ .value = PaymentMethod.card, .label = "Card" },
        .{ .value = PaymentMethod.paypal, .label = "PayPal" },
    });

    payment_method.trigger = "Payment Method";

    country = .fromItems(&.{
        .{ .value = Country.US, .label = "United States" },
        .{ .value = Country.CA, .label = "Canada" },
        .{ .value = Country.UK, .label = "United Kingdom" },
    });
    country.trigger = "Country";
}

fn onSubmit(form: CheckoutForm) void {
    Vapor.print("Submitted {s}", .{form.payment.card_number});
}

fn LoginComponent() void {
    login_form.render();
}

fn onChange(evt: *Vapor.Event) void {
    evt.preventDefault();
    Vapor.print("onChange {s}", .{evt.text()});
}

var username: []const u8 = "";
pub fn render() void {
    Box()
        .layout(.top_center)
        .size(.full)
        .spacing(128)
        .children({
        Box()
            .width(.percent(40))
            .height(.percent(40))
            .direction(.column)
            .layout(.top_left)
            .spacing(32)
            .children({
            LoginComponent();
            // Stack().width(.percent(100)).spacing(16).layout(.left_center).children({
            //     Text("Login").font(16, 700, .palette(.text_color)).end();
            //     login_form2.render();
            // });
            //     const active_index = Tabs.NavBar("login_tabs", &.{ "Login", "Create Account" });
            //     switch (active_index) {
            //         0 => {
            //             Card().children({
            //                 Stack()
            //                     .width(.percent(100))
            //                     .spacing(8)
            //                     .children({
            //                     Text("Acorn Login")
            //                         .font(16, 700, .palette(.text_color))
            //                         .end();
            //                     Text("Login into your Acorn account.")
            //                         .font(14, 300, .palette(.text_color))
            //                         .end();
            //                 });
            //
            //                 Box()
            //                     .width(.percent(100))
            //                     .spacing(16)
            //                     .layout(.left_center)
            //                     .children({
            //                     AuthBtn(googleLogin, .google);
            //                     AuthBtn(googleLogin, .github);
            //                     AuthBtn(googleLogin, .apple);
            //                 });
            //                 Stack()
            //                     .width(.percent(100))
            //                     .spacing(16)
            //                     .children({
            //                     Field.render(.{
            //                         .label = "Username",
            //                         .value = .{ .string = &details.username },
            //                         .on_change = onChange,
            //                         .type = .string,
            //                         .id = "username",
            //                     });
            //                     Field.render(.{
            //                         .label = "Email",
            //                         .value = .{ .email = &details.email },
            //                         .type = .email,
            //                         .id = "email",
            //                     });
            //                     Field.render(.{
            //                         .label = "Password",
            //                         .value = .{ .password = &details.password },
            //                         .type = .password,
            //                         .id = "password",
            //                     });
            //                 });
            //                 Box()
            //                     .layout(.right_center)
            //                     .width(.percent(100))
            //                     .children({
            //                     Button(submit, .{})
            //                         .animation(&glitch)
            //                         .background(.transparentizeHex(.black, 0.8))
            //                         .border(.round(.black, .all(8)))
            //                         .padding(.all(6))
            //                         .pointer()
            //                         .children({
            //                         Text("Login")
            //                             .font(16, 300, .palette(.alternate_text_color))
            //                             .fontFamily("IBM Plex Sans,monospace")
            //                             .end();
            //                         Vapor.Svg(.{ .svg = key })
            //                             .stroke(.palette(.alternate_text_color))
            //                             .fill(.palette(.text_color))
            //                             .end();
            //                     });
            //                 });
            //             });
            //         },
            //         1 => {
            //             Card().children({
            //                 Stack()
            //                     .width(.percent(100))
            //                     .spacing(8)
            //                     .children({
            //                     Text("Login")
            //                         .font(16, 700, .palette(.text_color))
            //                         .end();
            //                     Text("Login into your Acorn account.")
            //                         .font(14, 300, .palette(.text_color))
            //                         .end();
            //                 });
            //                 Stack()
            //                     .width(.percent(100))
            //                     .spacing(16)
            //                     .children({
            //                     Field.render(.{ .label = "Username", .value = .{ .string = &details.username }, .type = .string });
            //                     Field.render(.{ .label = "Email", .value = .{ .email = &details.email }, .type = .email });
            //                     Field.render(.{ .label = "Password", .value = .{ .password = &details.password }, .type = .password });
            //                 });
            //                 Box()
            //                     .layout(.right_center)
            //                     .width(.percent(100))
            //                     .children({
            //                     Button(createAccount, .{})
            //                         .animation(&glitch)
            //                         .background(.transparentizeHex(.black, 0.8))
            //                         .border(.round(.black, .all(8)))
            //                         .padding(.all(6))
            //                         .pointer()
            //                         .children({
            //                         Text("Create Account")
            //                             .font(16, 300, .palette(.alternate_text_color))
            //                             .fontFamily("IBM Plex Sans,monospace")
            //                             .end();
            //                         Vapor.Icon(.person_rolodex)
            //                             .font(16, 700, .palette(.alternate_text_color))
            //                             .end();
            //                     });
            //                 });
            //             });
            //         },
            //         else => {},
            //     }
        });
        // TrainTicket.render(&details);
    });
}
