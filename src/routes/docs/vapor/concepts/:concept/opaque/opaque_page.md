{#ui-components}

## UI Components

Vapor includes a comprehensive component library for building production applications.

@ui_showcase_image

### Available Components

| Component     | Description                                             |
| ------------- | ------------------------------------------------------- |
| **DataTable** | Sortable, filterable, paginated tables with JSON export |
| **Chart**     | Bar, line, and combo charts                             |
| **Calendar**  | Date picker with month/year navigation                  |
| **Select**    | Searchable dropdowns with type-safe options             |
| **Tabs**      | Tabbed content navigation                               |
| **Dialog**    | Modal dialogs with animations                           |
| **Drawer**    | Slide-in panels                                         |
| **Toast**     | Stackable notifications                                 |
| **Command**   | Command palette (⌘K) with search                        |
| **Form**      | Auto-generated forms from structs                       |
| **Upload**    | File upload with drag-and-drop                          |
| **Slider**    | Range input controls                                    |

### Usage

Components are available via the Opaque UI library:

%metal add opaque-ui

```zig
const Opaque = @import("opaque");
const Select = Opaque.Select;
const DataTable = Opaque.DataTable;
const Calendar = Opaque.Calendar;
```

For full documentation, see [Opaque UI Docs](https://opaque.vapor.dev).

{#form-generation}

### Form Generation

Define a struct, get a complete form with validation:

```zig
const CheckoutForm = struct {
    account: struct {
        email: []const u8 = "",
        password: []const u8 = "",
    } = .{},

    pub const __validations = .{
        .email = Validation{ .field_type = .email },
        .password = Validation{ .field_type = .password },
    };
};

var form = Vaporize.Form(CheckoutForm){};
form.compile();
```

@checkout_form_image

Nested structs become form sections. Validation errors display inline. Custom components can override any field via `__components`.

---

## Quick Observations

### Strengths of the UI

| Aspect | Assessment |
|--------|------------|
| Visual consistency | Excellent - cohesive design language |
| Spacing/typography | Professional - proper hierarchy |
| Interactive states | Visible hover/focus states |
| Error handling | Clear inline validation |
| Accessibility | Appears to have proper labels |
| Dark mode ready | The chart suggests dark theme support |

### The Form Generation is the Killer Feature

Image 3 shows the exact struct from your code rendered as a real form:

```zig
Account
├── Email | Password (side-by-side)
├── Confirm password
└── Contact
    └── Phone

Payment
├── Payment Method (custom Select)
├── Expiry | CVV (side-by-side)
└── Billing address | Card number

Shipping details
└── Shipping same as billing [toggle]

[Submit]
````
