{#vapor-accessibility-reference}

# Vapor Accessibility Reference

#### Complete guide to building accessible UIs with Vapor's built-in a11y API.

---

{#overview}

## Overview

Vapor provides a chainable accessibility API on every component through the `ComponentBuilder`. These methods map directly to WAI-ARIA attributes, enabling screen reader support, keyboard navigation, and semantic markup without leaving the builder chain.

---

{#aria-labels}

## ARIA Labels

Use `.ariaLabel()` to provide an accessible name for elements that don't have visible text, or where the visible text is insufficient.

```zig
// Icon-only button needs a label for screen readers
Button(closeModal)
    .ariaLabel("Close dialog")
    .children({
        Icon(.close).end();
    });

// Image with descriptive label
Image(.{ .src = "/logo.png", .alt = "Company Logo" })
    .ariaLabel("Acme Corp homepage logo")
    .end();

// Search field
TextField(.string)
    .bind(&query)
    .ariaLabel("Search articles")
    .placeholder("Search...")
    .end();
```

---

{#roles}

## Semantic Roles

Use `.role()` to override or specify the ARIA role of an element. This tells assistive technology what kind of widget or structure the element represents.

```zig
const Accessibility = Vapor.Accessibility;

// Navigation landmark
Box()
    .role(.navigation)
    .ariaLabel("Main navigation")
    .children({
        Link(.{ .url = "/" }).children({ Text("Home").end(); });
        Link(.{ .url = "/about" }).children({ Text("About").end(); });
    });

// Tab list pattern
Box()
    .role(.tablist)
    .ariaLabel("Settings tabs")
    .direction(.row)
    .children({
        for (tabs, 0..) |tab, i| {
            ButtonCtx(selectTab, .{i})
                .role(.tab)
                .ariaSelected(i == active_tab)
                .children({
                    Text(tab.label).end();
                });
        }
    });

// Tab panel
Box()
    .role(.tabpanel)
    .ariaLabel(tabs[active_tab].label)
    .children({
        // Panel content
    });
```

### Available Roles

Roles are defined in `Accessibility.Role` and include standard WAI-ARIA roles:

| Role            | Use Case                                    |
| --------------- | ------------------------------------------- |
| `.navigation`   | Navigation landmarks                        |
| `.tablist`      | Container for tab elements                  |
| `.tab`          | Individual tab trigger                      |
| `.tabpanel`     | Content panel associated with a tab         |
| `.dialog`       | Modal dialogs                               |
| `.alert`        | Important, time-sensitive messages          |
| `.button`       | Non-button elements acting as buttons       |
| `.listbox`      | List selection widgets                      |
| `.option`       | Options within a listbox                    |
| `.menu`         | Menu widgets                                |
| `.menuitem`     | Items within a menu                         |
| `.region`       | Generic landmark                            |
| `.complementary`| Supporting content                          |

---

{#expanded-and-selected}

## Expanded & Selected States

### ariaExpanded

Indicates whether a collapsible section or dropdown is open or closed.

```zig
var dropdown_open: bool = false;

fn toggleDropdown() void {
    dropdown_open = !dropdown_open;
}

fn render() void {
    // Dropdown trigger
    Button(toggleDropdown)
        .ariaExpanded(dropdown_open)
        .ariaControls("dropdown-menu")
        .children({
            Text("Options").end();
            Icon(.chevron_down).end();
        });

    // Dropdown content
    if (dropdown_open) {
        Stack()
            .id("dropdown-menu")
            .role(.menu)
            .children({
                for (options) |option| {
                    ButtonCtx(selectOption, .{option})
                        .role(.menuitem)
                        .children({
                            Text(option.label).end();
                        });
                }
            });
    }
}
```

### ariaSelected

Marks an item as selected within a group (tabs, list items, options).

```zig
for (items, 0..) |item, i| {
    ButtonCtx(selectItem, .{i})
        .ariaSelected(i == selected_index)
        .background(if (i == selected_index) .palette(.tint) else .transparent)
        .children({
            Text(item.name).end();
        });
}
```

---

{#aria-controls}

## ariaControls

Links a controlling element to the element it controls, by ID. Screen readers use this to announce the relationship.

```zig
// Accordion pattern
Button(toggleSection)
    .ariaExpanded(section_open)
    .ariaControls("section-content")
    .children({
        Text("Section Title").end();
    });

Box()
    .id("section-content")
    .hidden(!section_open)
    .children({
        Text("Section body content goes here.").end();
    });
```

---

{#active-descendant}

## ariaActiveDescendant

Used for composite widgets (listboxes, menus, grids) where focus stays on the container but a child is visually highlighted. The value should be the UUID/ID of the currently active child.

```zig
var active_option_id: ?[]const u8 = null;

fn render() void {
    Box()
        .role(.listbox)
        .ariaLabel("Color picker")
        .ariaActiveDescendant(active_option_id)
        .tabIndex(0)
        .onEvent(.keydown, handleArrowKeys)
        .children({
            for (colors) |color| {
                Box()
                    .id(color.id)
                    .role(.option)
                    .ariaSelected(std.mem.eql(u8, color.id, active_option_id orelse ""))
                    .children({
                        Text(color.name).end();
                    });
            }
        });
}
```

---

{#aria-hidden}

## ariaHidden

Hides an element from the accessibility tree while keeping it visually present. Use for decorative elements or redundant content.

```zig
// Decorative icon next to text — screen reader only needs the text
Box().direction(.row).spacing(8).children({
    Icon(.star)
        .ariaHidden(true)
        .end();
    Text("Favorites").end();
});

// Decorative separator
Box()
    .ariaHidden(true)
    .height(.px(1))
    .background(.palette(.border_color))
    .end();
```

---

{#tab-index}

## tabIndex

Controls keyboard focus order. Use `0` to make a non-interactive element focusable, `-1` to remove it from tab order (but allow programmatic focus).

```zig
// Make a div focusable
Box()
    .tabIndex(0)
    .role(.button)
    .ariaLabel("Custom interactive area")
    .onEvent(.keydown, handleKeyPress)
    .children({
        Text("Click or press Enter").end();
    });

// Remove from tab order (focusable programmatically only)
Box()
    .tabIndex(-1)
    .ref(&hidden_panel)
    .children({
        Text("Panel content").end();
    });
```

---

{#combined-a11y-struct}

## Full Accessibility Struct

For complex cases, you can pass an `Accessibility` struct directly using `.a11y()`:

```zig
Box()
    .a11y(.{
        .role = .dialog,
        .label = "Confirm deletion",
        .expanded = true,
        .controls = "dialog-body",
        .tab_index = 0,
    })
    .children({
        // Dialog content
    });
```

### Accessibility Fields

| Field               | Type              | Description                              |
| ------------------- | ----------------- | ---------------------------------------- |
| `.role`             | `Accessibility.Role` | WAI-ARIA role                         |
| `.label`            | `[]const u8`      | Accessible name (`aria-label`)           |
| `.expanded`         | `bool`            | Expanded state (`aria-expanded`)         |
| `.selected`         | `bool`            | Selected state (`aria-selected`)         |
| `.controls`         | `[]const u8`      | ID of controlled element                 |
| `.active_descendant`| `?[]const u8`     | ID of active child in composite widget   |
| `.hidden`           | `bool`            | Hidden from accessibility tree           |
| `.tab_index`        | `i16`             | Tab order index                          |

---

{#accessibility-patterns}

## Common Accessible Patterns

### Accessible Modal Dialog

```zig
if (show_modal) {
    // Backdrop — hidden from screen readers
    Box()
        .pos(.full(.fixed))
        .zIndex(999)
        .background(.transparentize(.black, 0.5))
        .ariaHidden(true)
        .children({
            Button(closeModal).size(.full).end();
        });

    // Dialog
    Center()
        .pos(.full(.fixed))
        .zIndex(1000)
        .children({
            Box()
                .role(.dialog)
                .ariaLabel("Confirm action")
                .tabIndex(-1)
                .ref(&modal_ref)
                .width(.px(400))
                .padding(.all(24))
                .background(.palette(.background))
                .border(.round(.palette(.border_color), .all(12)))
                .children({
                    Text("Are you sure?").font(18, 700, null).end();
                    Text("This action cannot be undone.").end();
                    Box().direction(.row).spacing(12).layout(.right_center).children({
                        Button(closeModal).ariaLabel("Cancel").children({
                            Text("Cancel").end();
                        });
                        Button(confirmAction).ariaLabel("Confirm deletion").children({
                            Text("Delete").end();
                        });
                    });
                });
        });
}
```

### Accessible Navigation

```zig
fn Navbar() void {
    Box()
        .role(.navigation)
        .ariaLabel("Main navigation")
        .direction(.row)
        .layout(.x_between_center)
        .padding(.horizontal(24))
        .children({
            Link(.{ .url = "/" })
                .ariaLabel("Home")
                .children({
                    Icon(.home).end();
                });

            for (nav_items) |item| {
                Link(.{ .url = item.url, .aria_label = item.label })
                    .children({
                        Text(item.label).end();
                    });
            }
        });
}
```

### Skip Navigation Link

```zig
fn render() void {
    // Visually hidden but accessible via keyboard
    Link(.{ .url = "#main-content", .aria_label = "Skip to main content" })
        .pos(.{ .type = .absolute, .top = .px(-9999) })
        .children({
            Text("Skip to content").end();
        });

    Navbar();

    Box()
        .id("main-content")
        .tabIndex(-1)
        .children({
            // Main page content
        });
}
```
