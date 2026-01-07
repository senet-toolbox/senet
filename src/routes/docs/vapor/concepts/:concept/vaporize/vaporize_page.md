{#vaporize}

# Vaporize

#### Vaporize is a Component function that is unqiue to Vapor

Vaporize, or vaporization, is the process of converting Zig code, Markdown, or HTML files into native Vapor components.

Vaporize, works like a runtime compiler, when loaded in the browser, and a build time compiler when used in a Zig build.

The runtime version is best used for when you need dynamic UI, and the build time version is best used for when you need static UI.

Vaporize exposes the following set of functions:

- **Mardown(anytype)** - Returns a comptime Markdown Type, which can be used to generate UI
  - **compile(string)** - Takes a markdown string and compiles it into native Vapor components
  - **render()** - Renders the compiled markdown

- **Form(struct {...})** - Returns a comptime Form Type, which can be used to generate UI
  - **compile()** - Takes a form struct and compiles it into native Vapor components
  - **render()** - Renders the compiled form from a struct

#### For example, we can Vaporize a Markdown file:

```zig
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");


var vaporizer: Vaporize.Compiler = undefined;
var markdown: vaporizer.MarkDown(.{}) = .{};

// Mardkown file
const markdown_text =
    \\# Main Heading
    \\
    \\- Item 1
    \\  - Nested item 1
    \\  - Nested item 2
    \\- Item 2
    \\  - Nested item 3
    \\
    \\This is the second paragraph.
;

pub fn init() void {
    // Initialize the vaporize compiler
    vaporizer = Vaporize.init(Vapor.arena(.persist), .{}) catch |err| {
        Vapor.printErr("Failed to initialize vaporizer: {any}", .{err});
        return;
    };

    markdown.compile(markdown_text) catch |err| {
        Vapor.printErr("Failed to compile markdown: {any}", .{err});
        return;
    };
}

fn render() void {
    markdown.render() catch |err| {
        Vapor.printErr("Failed to render markdown: {any}", .{err});
        return;
    };
}
```

One major benefit as discussed in the Codex Engine section, is that since we compile our entire UI tree to a single WASM binary, vaporizing multiple files,
scales memory usage logarithmically, since the markdown files uses the same function calls for each `Text`, `Link`, `ListItem`, ect.

### One Vaporization Instance

We only need to init and create one instance of the Vaporize compiler, and then we can use it anywhere in our application.
For this website, we have a single instance intialized in the `init` function within the `instances.zig` file.

```zig
pub var vaporizer: Vaporize.Compiler = undefined;

pub fn init() void {
    Vapor.init(.{});
    vaporizer = Vaporize.init(Vapor.arena(.persist), style_config) catch ...;
}
```

Afterwards, we can just import the vaporizer and use it anywhere in our application, like so:

```zig
const Vapor = @import("vapor");
const Instances = @import("instances.zig");

var markdown: Instances.vaporizer.MarkDown(.{}) = .{};

// Mardkown file
const markdown_text =
    \\# Main Heading
    \\
    \\- Item 1
    \\  - Nested item 1
    \\  - Nested item 2
    \\- Item 2
    \\  - Nested item 3
    \\
    \\This is the second paragraph.
;

pub fn init() void {
   markdown.compile(markdown_text) catch |err| {
        Vapor.printErr("Failed to compile markdown: {any}", .{err});
        return;
    };
}

fn render() void {
    markdown.render();
}
```

#### However, you can also do this at runtime.

Vaporize is a runtime compiler, so we can fetch the markdown file, and then compile it at runtime. For example the TextArea below, is a live markdown editor,
that generates UI at runtime.

@text_area

@realtime_markdown

You could use this to create a live markdown editor, that exists in the browser, and then in your Zig code, add functionality and styling.

#### We can also do this with normal Zig code:

For example, we can Vaporize a struct, which has a `__valdiations` field that is used for validations, and defining element types.

Each field type maps to a element type, for example `i32` maps to number `TextField`, and `bool` maps to `Checkbox`.

- `[]const u8` maps to `TextField`
- `[]const []const u8` maps to `TextArea`
- `i32` maps to `TextField`
- `bool` maps to `Checkbox`
- `enum` maps to `Radio`

```zig
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");
const Validation = Vaporize.Validation;
const Compiler = Vaporize.Compiler;

const Form = struct {
    username: []const u8 = "",
    email: []const u8 = "",
    phonenumber: []const u8 = "",
    password: []const u8 = "",
    age: u6 = 0,
    pub var __validations = .{
        .username = Validation{ .min = 3, .max = 10, .err = "Username must be between 3 and 10 characters" },
        .email = Validation{ .field_type = .email },
        .phonenumber = Validation{ .field_type = .telephone },
        .password = Validation{ .field_type = .password },
        .age = Validation{
            .min_value = 18,
            .max_value = 120,
            .err = "Age must be between 18 and 120",
        },
    };
};

var vaporizer: Compiler = undefined;
var new_form: vaporize.Form(Form) = undefined;

pub fn init() void {
    // Initialize the vaporize compiler
    vaporizer = Vaporize.init(Vapor.arena(.persist), .{}) catch |err| {
        Vapor.printErr("Failed to initialize vaporizer: {any}", .{err});
        return;
    };
    new_form.compile() catch |err| {
        Vapor.printErr("Failed to compile form: {any}", .{err});
        return;
    };
}

fn render() void {
    new_form.render() catch |err| {
        Vapor.printErr("Failed to render form: {any}", .{err});
        return;
    };
}
```

@form

### Validations

With the `Form(...)` comptime function, we automatically get validations for free, if, if you want to style the different elements, or includes a custom
component, or validation. You can do so by adding a `__validations` field to your struct. Or the components anonymous struct.

One thing to note, is that the validations are anonymous struct, the order of the fields, and the field names, must coincide with the order of the struct fields.

You can also use the type definitions themselves, as a validation or boudnary, for example the age field is currently a u6 type, this means that the maximum value is 120.

Instead of having to check via an `if` statement, like so: `if (form.age > 120) {}`, we can simply use the type definition to ensure that the value is within the range.

You can also do the same with the string fields, like so: `[16]u8` instead of `[]const u8`, this means that the field can only contain 16 characters.

{#complex-form}

### Complex Form

Below is a sample of a complex checkout form, with validation and custom components. This is a real-world example of a checkout form.
It includes, conditionals, sections, custom components, validation, dropdowns, and auto formatting.

<!-- @complex_form -->

#### Code

```zig
const Vapor = @import("vapor");
const Vaporize = @import("vaporize");
const Validation = Vaporize.Validation;
const ValidationError = Vaporize.ValidationError;

const Box = Vapor.Box;
const Text = Vapor.Text;
const Compiler = @import("../main.zig");
const Select = @import("../components/Opaque.zig").Select;
const new = @import("../components/Select.zig").new;
const Field = @import("../components/Opaque.zig").Field;

const Currency = enum { usd, eur };

const Country = enum { US, CA, UK };

const PaymentMethod = enum { card, paypal };

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
        .cvv = Validation{ .field_type = .cvv, .placeholder = "123", .err = "CVV is required" },
        .address = Validation{ .field_type = .string, .required = true },
        .city = Validation{ .field_type = .string, .required = true },
        .state = Validation{ .field_type = .string, .required = true },
        .postal_code = Validation{ .field_type = .string, .required = true },
    };

    pub const __components = .{
        .method = PaymentMethodComponent,
        .country = CountryComponent,
    };
};
fn PaymentMethodComponent(_: *CheckoutForm, _: ?ValidationError) void {
    payment_method.render();
}

fn CountryComponent(_: *CheckoutForm, _: ?ValidationError) void {
    country.render();
}

fn sameAsBilling(form: *CheckoutForm) void {
    Vapor.print("sameAsBilling {any}", .{form.shipping_details.shipping_same_as_billing.value});
}

fn onSubmit(form: CheckoutForm) void {
    Vapor.print("Submitted {any}", .{form});
}

const FormCheckout = Compiler.vaporize.Form(CheckoutForm);
var login_form: FormCheckout = undefined;
var country: Select(Country) = undefined;
var payment_method: Select(PaymentMethod) = undefined;

pub fn init() void {
    Field.new();
    new();
    // compile the struct into a UI form
    login_form.compile() catch unreachable;
    login_form.inner_form.on_submit = onSubmit;

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

pub fn LoginComponent() void {
    login_form.render();
}
```
