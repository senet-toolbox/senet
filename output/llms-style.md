# Vapor Style Guide

A comprehensive design system reference for building consistent, beautiful UIs with the Vapor Framework.

---

## Table of Contents

1. [Design Tokens](#design-tokens)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing System](#spacing-system)
5. [Borders & Radius](#borders--radius)
6. [Shadows](#shadows)
7. [Layout Patterns](#layout-patterns)
8. [Component Styles](#component-styles)
9. [Interactive States](#interactive-states)
10. [Animations](#animations)
11. [Icons](#icons)
12. [Responsive Patterns](#responsive-patterns)

---

## Design Tokens

### Defining Theme Variables

Create reusable style variables at the top of your component files:

```zig
// Color tokens
var background: Vapor.Types.Background = .palette(.background);
var border_color: Vapor.Types.Color = .palette(.border_color_light);
var text_color: Vapor.Types.Color = .palette(.text_color);
var tint: Vapor.Types.Background = .palette(.tint);
var icon_color: Vapor.Types.Color = .palette(.icon_color);

// Border tokens
var border: Vapor.Types.BorderGrouped = .round(.palette(.border_color_light), .all(12));
var selected_border: Vapor.Types.BorderGrouped = .round(.palette(.tint), .all(12));

// Typography tokens
var font_family: []const u8 = "Montserrat";
var mono_font: []const u8 = "IBM Plex Mono,monospace";
```

### Theme Struct Pattern

For larger applications, create a centralized Theme struct:

```zig
const Theme = struct {
    // Backgrounds
    const bg_base = Vapor.Types.Background.palette(.background);
    const bg_elevated = Vapor.Types.Background.hex("#FFFFFF");
    const bg_muted = Vapor.Types.Background.transparentizeHex(.palette(.tint), 0.1);
    
    // Text colors
    const text_primary = Vapor.Types.Color.palette(.text_color);
    const text_secondary = Vapor.Types.Color.hex("#8C8C8C");
    const text_muted = Vapor.Types.Color.hex("#A2A2A2");
    const text_on_tint = Vapor.Types.Color.white;
    
    // Brand colors
    const accent = Vapor.Types.Color.palette(.tint);
    const accent_bg = Vapor.Types.Background.palette(.tint);
    const danger = Vapor.Types.Color.hex("#FF4000");
    const warning = Vapor.Types.Color.hex("#FFB700");
    const success = Vapor.Types.Color.hex("#16DF8F");
    const info = Vapor.Types.Color.hex("#007AFF");
    
    // Borders
    const border_default = Vapor.Types.Color.palette(.border_color_light);
    const border_focus = Vapor.Types.Color.palette(.tint);
};
```

---

## Color System

### Palette Tokens (Theme-Aware)

Use `.palette()` for colors that automatically adapt to light/dark themes:

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `.palette(.background)` | `#FFFFFF` | `#0F0F0F` | Page/card backgrounds |
| `.palette(.text_color)` | `#000000` | `#EAEAEA` | Primary text |
| `.palette(.tint)` | `#002bff` | `#F2FF00` | Brand accent, CTAs |
| `.palette(.border_color_light)` | `#e4e4e4` | `#1E1E1E` | Subtle borders |
| `.palette(.border_color)` | `#262626` | `#27272a` | Strong borders |
| `.palette(.icon_color)` | `#A2A2A2` | `#484848` | Icons, muted elements |
| `.palette(.highlight_color)` | `#F3F3F3` | `#27272a` | Hover backgrounds |
| `.palette(.danger)` | `#FF4E33` | `#FF4E33` | Error states |

### Color Modifiers

```zig
// Transparency
.transparentizeHex(.palette(.tint), 0.8)  // 80% transparent
.transparentize(.hex("#000000"), 0.5)     // 50% transparent

// Direct colors
.hex("#FF5733")
.rgba(255, 87, 51, 255)
.white
.black
.transparent
```

### Semantic Color Usage

```zig
// Success states
const success_bg = Vapor.Types.Background.transparentizeHex(.hex("#16DF8F"), 0.2);
const success_text = Vapor.Types.Color.hex("#16DF8F");

// Error states
const error_bg = Vapor.Types.Background.transparentizeHex(.hex("#FF4000"), 0.2);
const error_text = Vapor.Types.Color.hex("#FF4000");

// Warning states
const warning_bg = Vapor.Types.Background.transparentizeHex(.hex("#FFB700"), 0.2);
const warning_text = Vapor.Types.Color.hex("#FFB700");

// Info states
const info_bg = Vapor.Types.Background.transparentizeHex(.hex("#007AFF"), 0.2);
const info_text = Vapor.Types.Color.hex("#007AFF");
```

---

## Typography

### Font Families

| Family | Usage | Example |
|--------|-------|---------|
| `"Montserrat"` | Primary UI, body text, labels | Buttons, form labels, navigation |
| `"IBM Plex Sans,monospace"` | Technical UI, data tables | Table cells, stats |
| `"IBM Plex Mono,monospace"` | Code, monospace content | Code blocks, keyboard shortcuts |
| `"Geist Mono, monospace"` | Code editor, technical | Syntax highlighting |

### Font Scale

```zig
// Headings
.font(80, 900, .palette(.text_color))  // Hero/Display
.font(64, 700, .palette(.text_color))  // H1
.font(32, 700, .palette(.text_color))  // H2 / Subheading
.font(20, 500, .palette(.text_color))  // H3 / Mini heading
.font(18, 500, .palette(.text_color))  // H4

// Body text
.font(16, 400, .palette(.text_color))  // Body large
.font(14, 300, .palette(.text_color))  // Body default
.font(13, 400, .palette(.text_color))  // Body small

// UI elements
.font(12, 300, .hex("#8C8C8C"))        // Caption, helper text
.font(14, 600, .palette(.text_color))  // Button text, labels

// Monospace
.font(14, 300, .palette(.text_color)).fontFamily("IBM Plex Mono,monospace")
```

### Font Weight Reference

| Weight | Usage |
|--------|-------|
| `100` | Light, decorative |
| `300` | Body text, descriptions |
| `400` | Default body |
| `500` | Semi-bold, emphasis |
| `600` | Labels, button text |
| `700` | Headings, bold |
| `900` | Display, hero text |

### Text Styling Patterns

```zig
// Ellipsis for overflow
Text(long_text)
    .ellipsis(.dot)
    .end();

// Italic emphasis
Text("emphasis")
    .fontStyle(.italic)
    .end();

// Preserve whitespace
Text("code  content")
    .whiteSpace(.pre)
    .end();

// Hover text color change
Text("Interactive")
    .hoverText(.palette(.tint))
    .duration(100)
    .end();
```

---

## Spacing System

### Base Unit: 4px

All spacing should follow a 4px grid system:

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Tight spacing, icon gaps |
| `sm` | 8px | Default component internal spacing |
| `md` | 12px | Component spacing, list gaps |
| `lg` | 16px | Section spacing |
| `xl` | 24px | Card padding, major sections |
| `2xl` | 32px | Page sections |
| `3xl` | 48px | Hero sections |
| `4xl` | 64px | Major page divisions |

### Padding Patterns

```zig
// Uniform
.padding(.all(8))
.padding(.all(12))
.padding(.all(16))
.padding(.all(20))
.padding(.all(24))

// Horizontal/Vertical
.padding(.xy(16, 12))      // horizontal: 16, vertical: 12
.padding(.horizontal(12))
.padding(.vertical(8))

// Individual sides
.padding(.tblr(8, 8, 12, 12))  // top, bottom, left, right
.padding(.t(16))               // top only
.padding(.b(8))                // bottom only
.padding(.l(24))               // left only

// Common button padding
.padding(.tblr(8, 8, 10, 10))  // Slightly more horizontal
.padding(.xy(16, 10))          // Standard button
.padding(.all(4))              // Icon button
```

### Margin Patterns

```zig
.margin(.t(64))           // Top margin
.margin(.b(32))           // Bottom margin
.margin(.tb(64, 64))      // Top and bottom
.margin(.all(0))          // Reset margins
.margin(.horizontal(12))
```

### Spacing (Gap)

```zig
// Stack/Box spacing between children
.spacing(4)   // Tight
.spacing(8)   // Default
.spacing(12)  // Comfortable
.spacing(16)  // Relaxed
.spacing(24)  // Sections
.spacing(32)  // Major gaps
.spacing(64)  // Page sections
```

---

## Borders & Radius

### Border Radius Scale

| Size | Value | Usage |
|------|-------|-------|
| `xs` | `.all(4)` | Subtle rounding, tags |
| `sm` | `.all(6)` | Dropdowns, tooltips |
| `md` | `.all(8)` | Buttons, inputs |
| `lg` | `.all(12)` | Cards, modals |
| `xl` | `.all(16)` | Large cards |
| `2xl` | `.all(18)` | Hero cards |
| `pill` | `.all(99)` | Pills, avatars |

### Border Patterns

```zig
// Simple border (1px solid with radius)
.border(.simple(.palette(.border_color_light)))

// Rounded border with custom radius
.border(.round(.palette(.border_color_light), .all(12)))

// Solid border with thickness control
.border(.solid(.all(1), .palette(.border_color_light), .all(12)))

// Directional borders
.border(.bottom(1, .palette(.border_color_light)))
.border(.top(1, .hex("#E4E4E4")))
.border(.tb(.palette(.border_color_light)))  // Top and bottom

// Asymmetric thickness
.border(.solid(.tblr(1, 3, 1, 1), .palette(.border_color_light), .all(6)))

// Focus/Selected state border
.border(.round(.palette(.tint), .all(12)))

// No border
.border(.none)
```

### Common Border Compositions

```zig
// Card border
.border(.round(.palette(.border_color_light), .all(12)))

// Input default
.border(.round(.palette(.border_color_light), .all(12)))

// Input focus
.border(.round(.palette(.tint), .all(12)))

// Button outline
.border(.solid(.all(1), .palette(.border_color_light), .all(8)))

// Divider line
.border(.bottom(1, .palette(.border_color_light)))
```

---

## Shadows

### Shadow Presets

```zig
// Card shadow
.shadow(.card(.palette(.text_color)))

// Glow effect
.shadow(.glow(30, .transparentizeHex(.black, 0.1)))

// Custom shadow
.shadow(.{
    .top = 4,
    .spread = 2,
    .blur = 6,
    .color = .transparentizeHex(.black, 0.05),
})

// Focus ring shadow
.shadow(.{
    .color = .transparentizeHex(.palette(.tint), 0.2),
    .spread = 3,
})
```

### NewShadow (Advanced)

```zig
// Inset + Drop shadow combo (Button style)
.newShadow(Vapor.Types.NewShadow.init()
    .inset(0, -2, .transparentizeHex(.black, 0.2))
    .drop(0, 1, 3, .transparentizeHex(.black, 0.1)))

// Pressed state (reduced shadows)
.newShadow(Vapor.Types.NewShadow.init()
    .inset(0, -2, .transparentizeHex(.black, 0))
    .drop(0, 1, 3, .transparentizeHex(.black, 0)))

// Keyboard key style
.newShadow(Vapor.Types.NewShadow.init()
    .inset(0, -2, .transparentizeHex(.black, 0.3)))
```

---

## Layout Patterns

### Common Layouts

```zig
// Centered content
.layout(.center)

// Horizontal space-between with vertical center
.layout(.x_between_center)

// Horizontal evenly spaced
.layout(.x_even_center)

// Left-aligned, vertically centered
.layout(.left_center)

// Right-aligned, vertically centered
.layout(.right_center)

// Top-left aligned
.layout(.top_left)

// Bottom-center aligned
.layout(.bottom_center)
```

### Flex Direction

```zig
.direction(.column)         // Vertical stack
.direction(.row)            // Horizontal (default)
.direction(.column_reverse) // Reversed vertical
```

### Sizing Patterns

```zig
// Fixed sizes
.width(.px(240))
.height(.px(48))

// Percentage
.width(.percent(100))
.height(.percent(50))

// Flexible
.width(.grow)          // Take remaining space
.height(.fit)          // Fit to content
.size(.full)           // 100% width and height

// Elastic (min to max)
.height(.elastic(36, 256))  // Min 36px, max 256px

// Combined width/height
.hw(.percent(100), .percent(60))  // height, width
.hw_px(48, 48)                     // Fixed square
```

### Container Patterns

```zig
// Full-width centered container
Box()
    .width(.percent(100))
    .layout(.center)
    .children({...});

// Sidebar + Content layout
Box()
    .width(.percent(100))
    .layout(.x_between_center)
    .children({
        // Sidebar
        Box().width(.px(240)).children({...});
        // Content
        Box().width(.grow).children({...});
    });

// Card grid
Box()
    .width(.percent(100))
    .layout(.top_left)
    .wrap(.wrap)
    .spacing(24)
    .children({...});
```

---

## Component Styles

### Buttons

#### Primary Button
```zig
pub fn PrimaryButton(func: anytype, args: anytype) Vapor.ButtonBuilder(.pure) {
    return ButtonCtx(func, args)
        .layout(.center)
        .spacing(8)
        .padding(.xy(16, 10))
        .background(.palette(.tint))
        .border(.round(.transparent, .all(8)))
        .font(14, 600, .white)
        .cursor(.pointer)
        .duration(100)
        .hoverScale();
}
```

#### Secondary Button
```zig
pub fn SecondaryButton(func: anytype, args: anytype) Vapor.ButtonBuilder(.pure) {
    return ButtonCtx(func, args)
        .layout(.center)
        .spacing(8)
        .padding(.xy(16, 10))
        .background(.palette(.background))
        .border(.round(.palette(.border_color_light), .all(8)))
        .font(14, 500, .palette(.text_color))
        .cursor(.pointer)
        .duration(100)
        .hover(.{
            .border = .round(.palette(.tint), .all(8)),
            .text_color = .palette(.tint),
        });
}
```

#### Ghost Button
```zig
pub fn GhostButton(func: anytype, args: anytype) Vapor.ButtonBuilder(.pure) {
    return ButtonCtx(func, args)
        .layout(.center)
        .spacing(8)
        .padding(.all(8))
        .background(.transparent)
        .border(.round(.transparent, .all(8)))
        .font(14, 500, .palette(.text_color))
        .cursor(.pointer)
        .duration(100)
        .hover(.{
            .background = .transparentizeHex(.palette(.tint), 0.1),
        });
}
```

#### Icon Button
```zig
pub fn IconButton(func: anytype, args: anytype) Vapor.ButtonBuilder(.pure) {
    return ButtonCtx(func, args)
        .width(.px(32))
        .height(.px(32))
        .layout(.center)
        .background(.transparent)
        .border(.round(.transparent, .all(6)))
        .cursor(.pointer)
        .duration(100)
        .hover(.{
            .background = .transparentizeHex(.palette(.tint), 0.1),
        });
}
```

#### Elevated Button (with shadow)
```zig
pub fn ElevatedButton(func: anytype, args: anytype) Vapor.ButtonBuilder(.pure) {
    return ButtonCtx(func, args)
        .layout(.x_between_center)
        .spacing(8)
        .width(.fit)
        .height(.fit)
        .border(.round(.palette(.border_color_light), .all(12)))
        .background(.transparentizeHex(.hex("#F5F5F5"), 0.2))
        .duration(100)
        .padding(.tblr(8, 8, 10, 10))
        .newShadow(Vapor.Types.NewShadow.init()
            .inset(0, -2, .transparentizeHex(.black, 0.2))
            .drop(0, 1, 3, .transparentizeHex(.black, 0.1)))
        .hover(.{
            .transform = .scaleDecimal(1.01),
            .new_shadow = Vapor.Types.NewShadow.init()
                .inset(0, -2, .transparentizeHex(.black, 0))
                .drop(0, 1, 3, .transparentizeHex(.black, 0)),
        });
}
```

### Inputs

#### Text Field
```zig
TextField(.string)
    .width(.percent(100))
    .height(.px(44))
    .padding(.tblr(8, 8, 12, 12))
    .outline(.none)
    .border(.round(.palette(.border_color_light), .all(12)))
    .background(.palette(.background))
    .font(14, 300, .palette(.text_color))
    .fontFamily("Montserrat")
    .placeholder("Enter text...")
    .end();
```

#### Text Field with Focus State
```zig
// State management for focus
const is_focused = focus_states.get(field_id) orelse false;

TextField(.string)
    .border(.round(
        if (is_focused) .palette(.tint) else .palette(.border_color_light),
        .all(12)
    ))
    .shadow(.{
        .color = if (is_focused) 
            .transparentizeHex(.palette(.tint), 0.2) 
        else 
            .transparent,
        .spread = 3,
    })
    // ... other styles
    .end();
```

#### Text Area
```zig
TextArea()
    .width(.percent(100))
    .height(.elastic(36, 256))
    .padding(.all(8))
    .outline(.none)
    .border(.solid(.tblr(1, 3, 1, 1), .palette(.border_color_light), .all(6)))
    .font(16, 300, .palette(.text_color))
    .fontFamily("IBM Plex Sans,monospace")
    .resize(.none)
    .end();
```

### Cards

#### Basic Card
```zig
Box()
    .padding(.all(20))
    .background(.palette(.background))
    .border(.round(.palette(.border_color_light), .all(12)))
    .children({...});
```

#### Elevated Card
```zig
Box()
    .padding(.all(20))
    .background(.palette(.background))
    .border(.round(.palette(.border_color_light), .all(12)))
    .shadow(.{
        .top = 4,
        .spread = 2,
        .blur = 6,
        .color = .transparentizeHex(.black, 0.05),
    })
    .children({...});
```

#### Interactive Card
```zig
Box()
    .padding(.all(20))
    .background(.palette(.background))
    .border(.round(.palette(.border_color_light), .all(12)))
    .cursor(.pointer)
    .duration(100)
    .hover(.{
        .border = .round(.palette(.tint), .all(12)),
        .transform = .scaleDecimal(1.02),
    })
    .children({...});
```

### Badges/Tags

#### Status Badge
```zig
Box()
    .padding(.xy(8, 4))
    .background(.transparentizeHex(.palette(.tint), 0.2))
    .border(.round(.palette(.tint), .all(4)))
    .children({
        Text("Active")
            .font(12, 500, .palette(.tint))
            .end();
    });
```

#### Priority Badge (Kanban style)
```zig
fn PriorityBadge(priority: Priority) void {
    const color = switch (priority) {
        .high => Vapor.Types.Color.hex("#FF4000"),
        .medium => Vapor.Types.Color.hex("#FFB700"),
        .low => Vapor.Types.Color.hex("#16DF8F"),
    };
    
    Box()
        .padding(.xy(8, 4))
        .background(.transparentize(color, 0.2))
        .border(.round(color, .all(4)))
        .children({
            Text(@tagName(priority))
                .font(11, 600, color)
                .end();
        });
}
```

### Avatar

```zig
// Basic avatar
Image(.{ .src = user.avatar, .alt = user.name })
    .width(.px(40))
    .height(.px(40))
    .border(.round(.transparent, .all(99)))
    .end();

// Avatar with status indicator
Box()
    .pos(.relative)
    .children({
        Image(.{ .src = user.avatar, .alt = user.name })
            .width(.px(40))
            .height(.px(40))
            .border(.round(.transparent, .all(99)))
            .end();
        
        // Online indicator
        Box()
            .pos(.br(.px(0), .px(0), .absolute))
            .width(.px(12))
            .height(.px(12))
            .background(.hex("#16DF8F"))
            .border(.round(.palette(.background), .all(99)))
            .children({});
    });
```

### Checkbox

```zig
fn Checkbox(is_selected: bool, func: anytype, args: anytype) void {
    ButtonCtx(func, args)
        .width(.px(20))
        .height(.px(20))
        .cursor(.pointer)
        .duration(100)
        .hoverScale()
        .border(.solid(
            .all(1),
            if (is_selected) .transparentizeHex(.palette(.tint), 0.8) else .palette(.border_color_light),
            .all(6)
        ))
        .layout(.center)
        .children({
            if (is_selected) {
                Box()
                    .width(.px(14))
                    .height(.px(14))
                    .background(.transparentizeHex(.palette(.tint), 0.8))
                    .border(.round(.transparent, .all(4)))
                    .children({});
            }
        });
}
```

---

## Interactive States

### Hover Effects

```zig
// Scale on hover
.hoverScale()

// Custom scale
.hover(.{ .transform = .scaleDecimal(1.02) })

// Background change
.hover(.{ .background = .transparentizeHex(.palette(.tint), 0.1) })

// Border change
.hover(.{ .border = .round(.palette(.tint), .all(12)) })

// Text color change
.hover(.{ .text_color = .palette(.tint) })

// Multiple properties
.hover(.{
    .background = .transparentizeHex(.palette(.tint), 0.1),
    .border = .round(.palette(.tint), .all(12)),
    .transform = .scaleDecimal(1.02),
})

// Directional scale
.hover(.{ .transform = .direction_scale(.up, 4, 1.05) })
.hover(.{ .transform = .direction_scale(.right, 4, 1.05) })
```

### Focus States

```zig
// Focus ring with shadow
.shadow(.{
    .color = if (is_focused) 
        .transparentizeHex(.palette(.tint), 0.2) 
    else 
        .transparent,
    .spread = 3,
})

// Border color change on focus
.border(.round(
    if (is_focused) .palette(.tint) else .palette(.border_color_light),
    .all(12)
))
```

### Selected/Active States

```zig
// Tab active state
.background(if (is_active) 
    .transparentizeHex(.palette(.tint), 0.7) 
else 
    .transparent)
.border(.round(.palette(.tint), .all(4)))
.font(14, 300, if (is_active) .white else .palette(.text_color))

// List item selected
.background(if (is_selected) 
    .transparentizeHex(.palette(.tint), 0.05) 
else 
    .palette(.background))
.border(.round(
    if (is_selected) .palette(.tint) else .transparent,
    .all(6)
))
```

### Disabled State

```zig
// Disabled button pattern
.background(if (is_disabled) .palette(.disabled) else .palette(.tint))
.cursor(if (is_disabled) .not_allowed else .pointer)
.font(14, 500, if (is_disabled) .palette(.light_text) else .white)
```

### Transition/Duration

```zig
// Simple duration
.duration(100)   // 100ms transition
.duration(150)   // Standard
.duration(200)   // Relaxed
.duration(300)   // Slow

// Detailed transition control
.transition(.{
    .properties = &.{.height, .opacity, .transform},
    .duration = 150,
    .timing = .easeInOut,
})
```

---

## Animations

### Defining Animations

```zig
// Fade in with scale
const animateEnter = Vapor.Animation.init("component-enter")
    .prop(.opacity, 0, 1)
    .prop(.scale, 0.9, 1)
    .duration(100)
    .easing(.easeInOut);

// Fade out with scale
const animateExit = Vapor.Animation.init("component-exit")
    .prop(.opacity, 1, 0)
    .prop(.scaleY, 1, 0.9)
    .duration(100)
    .easing(.easeInOut);

// Slide up fade in
const slideUp = Animation.init("slide-up")
    .prop(.translateY, 20, 0)
    .prop(.opacity, 0, 1)
    .duration(300)
    .easing(.easeOut)
    .fill(.forwards);

// Spin animation
const spinner = Animation.init("spin")
    .easing(.easeInOut)
    .duration(100)
    .prop(.rotate, 0, 180);
```

### Building Animations

```zig
pub fn new() void {
    animateEnter.build();
    animateExit.build();
}
```

### Using Animations

```zig
Box()
    .animationEnter("component-enter")
    .animationExit("component-exit")
    .children({...});

// Conditional animation
Box()
    .animationEnter(if (!is_open) "component-enter" else null)
    .children({...});

// Animation on specific element
Text("Glitchy")
    .animation("text-glitch-chromatic")
    .end();
```

### Transform Origin

```zig
.transformOrigin(.top_center)
.transformOrigin(.center)
.transformOrigin(.bottom_left)
```

---

## Icons

### Icon Usage

```zig
// Basic icon
Icon(.check)
    .font(16, 300, .palette(.text_color))
    .end();

// Icon with specific color
Icon(.chevron_down)
    .font(14, 700, .palette(.icon_color))
    .end();

// Icon in button
ButtonCtx(handleClick, .{})
    .children({
        Icon(.plus)
            .font(18, 500, .white)
            .end();
        Text("Add Item")
            .font(14, 500, .white)
            .end();
    });
```

### Common Icon Patterns

| Action | Icon Token |
|--------|------------|
| Add/Create | `.plus`, `.plus_circle` |
| Delete | `.trash`, `.x_lg` |
| Edit | `.pencil`, `.pencil_square` |
| Search | `.search` |
| Close | `.x_lg` |
| Expand | `.chevron_down` |
| Collapse | `.chevron_up` |
| Navigate | `.chevron_left`, `.chevron_right` |
| Menu | `.three_dots`, `.three_dots_vertical` |
| Settings | `.gear` |
| User | `.account`, `.user_circle` |
| Success | `.check`, `.check_circle`, `.check2_all` |
| Error | `.exclamation_circle`, `.x_circle` |
| Warning | `.exclamation_triangle` |
| Info | `.info_circle` |
| Home | `.home`, `.house` |
| Notifications | `.bell` |
| Download | `.download`, `.cloud_download_fill` |
| Upload | `.upload` |
| Filter | `.funnel` |
| Sort | `.sort_alpha_down`, `.sort_alpha_up` |
| Send | `.send` |

### Icon Sizing Guide

| Size | Font Size | Usage |
|------|-----------|-------|
| XS | 12px | Inline indicators |
| SM | 14px | Button icons, nav |
| MD | 16px | Default |
| LG | 18px | Prominent actions |
| XL | 24px | Headers, empty states |
| 2XL | 32px | Hero icons |

---

## Responsive Patterns

### Device Detection

```zig
if (Vapor.isDesktop()) {
    // Desktop layout
}

if (Vapor.isMobile()) {
    // Mobile layout
}
```

### Responsive Sizing

```zig
// Different sizes per device
.width(.mobile_desktop(.percent(100), .percent(60)))
.height(.mobile_desktop(.fit, .percent(50)))
.hw(.mobile_desktop_percent(100, 70), .mobile_desktop_percent(100, 60))
```

### Responsive Layout

```zig
Box()
    .layout(if (Vapor.isMobile()) .top_center else .x_even_center)
    .direction(if (Vapor.isMobile()) .column else .row)
    .children({...});
```

### Responsive Spacing

```zig
.padding(if (Vapor.isMobile()) .all(12) else .all(24))
.spacing(if (Vapor.isMobile()) 16 else 32)
```

---

## Quick Reference

### Standard Component Sizing

| Component | Height | Padding |
|-----------|--------|---------|
| Button (sm) | 32px | `.xy(12, 6)` |
| Button (md) | 40px | `.xy(16, 10)` |
| Button (lg) | 48px | `.xy(20, 12)` |
| Input | 44px | `.tblr(8, 8, 12, 12)` |
| Select trigger | 44px | `.all(8)` |
| Table row | 48px | `.horizontal(8)` |
| Nav item | 36-44px | `.tblr(6, 6, 6, 24)` |
| Avatar (sm) | 32px | - |
| Avatar (md) | 40px | - |
| Avatar (lg) | 48px | - |
| Icon button | 32px | `.all(4)` |
| Badge | auto | `.xy(8, 4)` |
| Tab | 32px | `.tblr(4, 4, 8, 8)` |
| Toast | 52px | `.all(8)` |

### Standard Border Radius

| Component | Radius |
|-----------|--------|
| Button | `.all(8)` |
| Input | `.all(12)` |
| Card | `.all(12)` |
| Modal | `.all(16)` |
| Dropdown | `.all(6)` - `.all(12)` |
| Badge | `.all(4)` |
| Avatar | `.all(99)` (circle) |
| Tab | `.all(4)` |
| Toast | `.all(16)` |
| Tooltip | `.all(6)` |

### Z-Index Scale

| Layer | Z-Index | Usage |
|-------|---------|-------|
| Base | 0 | Normal content |
| Dropdown | 100 | Select menus |
| Sticky | 200 | Sticky headers |
| Fixed | 500 | Fixed nav |
| Modal backdrop | 998 | Modal overlay |
| Modal | 999 | Modal content |
| Toast | 9999 | Toast notifications |
| Tooltip | 10000 | Tooltips |

---

## Complete Component Examples

### Navigation Bar

```zig
Box()
    .width(.percent(100))
    .height(.px(64))
    .padding(.horizontal(24))
    .background(.palette(.background))
    .border(.bottom(1, .palette(.border_color_light)))
    .layout(.x_between_center)
    .children({
        // Logo
        Box().layout(.left_center).spacing(8).children({
            Icon(.home).font(24, 600, .palette(.tint)).end();
            Text("Brand").font(20, 700, .palette(.text_color)).end();
        });
        
        // Navigation items
        Box().layout(.center).spacing(24).children({
            for (nav_items) |item| {
                Link(.{ .url = item.url, .aria_label = item.label })
                    .font(14, 500, if (is_active(item)) 
                        .palette(.tint) 
                    else 
                        .palette(.text_color))
                    .hover(.{ .text_color = .palette(.tint) })
                    .duration(100)
                    .children({
                        Text(item.label).end();
                    });
            }
        });
        
        // Actions
        Box().layout(.right_center).spacing(12).children({
            IconButton(search, .{}).children({
                Icon(.search).font(18, 500, .palette(.icon_color)).end();
            });
            PrimaryButton(login, .{}).children({
                Text("Sign In").end();
            });
        });
    });
```

### Modal Dialog

```zig
// Backdrop
Box()
    .blur(1)
    .size(.full)
    .pos(.full(.fixed))
    .zIndex(998)
    .children({
        ButtonCtx(close, .{})
            .size(.full)
            .pos(.tl(.px(0), .px(0), .fixed))
            .end();
    });

// Modal content
Box()
    .pos(.tl(.percent(50), .percent(50), .fixed))
    .inlineStyle("transform: translate(-50%, -50%)", .{})
    .zIndex(999)
    .animationEnter("modal-enter")
    .animationExit("modal-exit")
    .width(.px(480))
    .background(.palette(.background))
    .border(.round(.palette(.border_color_light), .all(16)))
    .shadow(.glow(30, .transparentizeHex(.black, 0.1)))
    .children({
        // Header
        Box()
            .width(.percent(100))
            .padding(.all(20))
            .border(.bottom(1, .palette(.border_color_light)))
            .layout(.x_between_center)
            .children({
                Text("Modal Title").font(18, 600, .palette(.text_color)).end();
                IconButton(close, .{}).children({
                    Icon(.x_lg).font(18, 500, .palette(.icon_color)).end();
                });
            });
        
        // Body
        Box()
            .width(.percent(100))
            .padding(.all(20))
            .children({
                // Content here
            });
        
        // Footer
        Box()
            .width(.percent(100))
            .padding(.all(20))
            .border(.top(1, .palette(.border_color_light)))
            .layout(.right_center)
            .spacing(12)
            .children({
                SecondaryButton(close, .{}).children({
                    Text("Cancel").end();
                });
                PrimaryButton(confirm, .{}).children({
                    Text("Confirm").end();
                });
            });
    });
```

### Empty State

```zig
Box()
    .width(.percent(100))
    .padding(.vertical(48))
    .layout(.center)
    .children({
        Stack()
            .layout(.center)
            .spacing(16)
            .children({
                Icon(.inbox)
                    .font(48, 300, .palette(.icon_color))
                    .end();
                Text("No items found")
                    .font(18, 500, .palette(.text_color))
                    .end();
                Text("Try adjusting your search or filters")
                    .font(14, 400, .palette(.icon_color))
                    .end();
                PrimaryButton(createNew, .{}).children({
                    Icon(.plus).font(16, 500, .white).end();
                    Text("Add New Item").end();
                });
            });
    });
```

---

## Best Practices

### 1. Consistent Token Usage
Always use palette tokens instead of hardcoded colors for theme compatibility:
```zig
// ✓ Good
.background(.palette(.background))
.font(14, 300, .palette(.text_color))

// ✗ Avoid
.background(.hex("#FFFFFF"))
.font(14, 300, .hex("#000000"))
```

### 2. Component Composition
Create reusable styled component functions:
```zig
// ✓ Good - Reusable
pub fn Card() Vapor.Builder(.pure) {
    return Box()
        .padding(.all(20))
        .background(.palette(.background))
        .border(.round(.palette(.border_color_light), .all(12)));
}

// Use it
Card().children({...});
```

### 3. State-Based Styling
Use conditional expressions for interactive states:
```zig
.background(if (is_selected) 
    .transparentizeHex(.palette(.tint), 0.1) 
else 
    .transparent)
```

### 4. Semantic Naming
Use descriptive variable names for style tokens:
```zig
var selected_background = Vapor.Types.Background.transparentizeHex(.palette(.tint), 0.05);
var selected_border = Vapor.Types.BorderGrouped.round(.palette(.tint), .all(12));
```

### 5. Animation Performance
Keep animations short and use easing for polish:
```zig
.duration(100)  // Short for micro-interactions
.duration(200)  // Medium for state changes
.duration(300)  // Longer for page transitions
```
