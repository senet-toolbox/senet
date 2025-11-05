const std = @import("std");
const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Style = Vapor.Style;
const Static = Vapor.Static;
const HtmlText = Custom.Chain.HtmlText;
const Box = Static.Box;
const Text = Static.Text;
const Link = Static.Link;
const Image = Static.Image;
const Svg = Static.Svg;
const Button = Static.Button;
const Center = Static.Center;
const List = Static.List;
const ListItem = Static.ListItem;
const Stack = Static.Stack;
const Heading = Static.Heading;

const Pure = Vapor.Pure;
const Page = Vapor.Page;
const CodeEditor = @import("../../../../../../components/CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");
const Vaporize = @import("vaporize");

var code_editor: CodeEditor = undefined;
var get_code_editor: CodeEditor = undefined;
var set_code_editor: CodeEditor = undefined;
var append_code_editor: CodeEditor = undefined;
var toggle_code_editor: CodeEditor = undefined;
var increment_code_editor: CodeEditor = undefined;
var decrement_code_editor: CodeEditor = undefined;
var dyanmic_code_editor: CodeEditor = undefined;

var vapor_code_editor: CodeEditor = undefined;
var react_code_editor: CodeEditor = undefined;
var svelte_code_editor: CodeEditor = undefined;
var vapor_style_code_editor: CodeEditor = undefined;
var pure_ui_code_example: CodeEditor = undefined;
var pure_ui_code_example_and_text: CodeEditor = undefined;
var reactive_ui: CodeEditor = undefined;
var signal_increment_sample: CodeEditor = undefined;
var effect_sample: CodeEditor = undefined;
var non_effect_sample: CodeEditor = undefined;
var import_example: CodeEditor = undefined;
var immediate_mode: CodeEditor = undefined;
var state_types: CodeEditor = undefined;

const items: []const []const u8 = &.{
    "set",
    "get",
    "toggle",
    "append",
    "getElement",
    "decrement",
    "increment",
    "compare",
    "force",
    "subscribe",
    "tether",
    "update",
    "derived",
    "effect",
    "startBatch",
    "endBatch",
};
// Initialization
var reactivity_page: *Vaporize.Node = undefined;
pub fn init() void {
    content.init();
    var parser = Vaporize.Parser.init(Vapor.lib.allocator_global, @embedFile("reactivity_page.md"));
    reactivity_page = parser.parse() catch unreachable;

    pure_ui_code_example.init(&Vapor.lib.allocator_global, @embedFile("pure_ui_sample.zig"));
    pure_ui_code_example_and_text.init(&Vapor.lib.allocator_global, @embedFile("pure_ui_sample_and_text.zig"));
    reactive_ui.init(&Vapor.lib.allocator_global, @embedFile("reactive_ui.zig"));
    signal_increment_sample.init(&Vapor.lib.allocator_global, @embedFile("signal_increment_sample.zig"));
    effect_sample.init(&Vapor.lib.allocator_global, @embedFile("effect_approach.zig"));
    non_effect_sample.init(&Vapor.lib.allocator_global, @embedFile("non_effect_approach.zig"));
    import_example.init(&Vapor.lib.allocator_global, @embedFile("import_example.zig"));
    immediate_mode.init(&Vapor.lib.allocator_global, @embedFile("immediate_mode.zig"));
    state_types.init(&Vapor.lib.allocator_global, @embedFile("state_types.zig"));
    // code_editor.init(&Vapor.lib.allocator_global, @embedFile("signal_sample.zig"));
    // get_code_editor.init(&Vapor.lib.allocator_global, @embedFile("signal_get_sample.zig"));
    // set_code_editor.init(&Vapor.lib.allocator_global, @embedFile("signal_set_sample.zig"));
    // append_code_editor.init(&Vapor.lib.allocator_global, @embedFile("signal_append_sample.zig"));
    // toggle_code_editor.init(&Vapor.lib.allocator_global, @embedFile("signal_toggle_sample.zig"));
    // increment_code_editor.init(&Vapor.lib.allocator_global, @embedFile("signal_increment_sample.zig"));
    // decrement_code_editor.init(&Vapor.lib.allocator_global, @embedFile("signal_decrement_sample.zig"));
    // vapor_code_editor.init(&Vapor.lib.allocator_global, @embedFile("vapor_sample.zig"));
    // react_code_editor.init(&Vapor.lib.allocator_global, @embedFile("react_sample.js"));
    // svelte_code_editor.init(&Vapor.lib.allocator_global, @embedFile("svelte_sample.svelte"));
    // vapor_style_code_editor.init(&Vapor.lib.allocator_global, @embedFile("vapor_style_sample.zig"));
    // dyanmic_code_editor.init(&Vapor.lib.allocator_global, @embedFile("dynamic_sample.zig"));
}

// Deinitialization

pub fn Txt(text: []const u8) void {
    Text(text).style(styles.body_text);
}

pub fn html(text: []const u8) void {
    HtmlText(text).style(styles.body_text);
}

const BoxCode = Box.margin(.tb(8, 24)).size(.hw(.fit, .percent(100)));

const Content = @import("../../../../../../components/Content.zig");
var content: Content.new(@embedFile("reactivity_page.md")) = .{};

fn component() void {
    Vaporize.traverse(reactivity_page, .{
        .code_color = .palette(.tint),
        .text_color = .palette(.text_color), // We changed this to Pure
        .heading_color = .palette(.text_color),
    }, void, null) catch unreachable;
}

// Render
pub fn render() void {
    content.content(component);
    // Page Header
    // Box.style(&.{
    //     .child_gap = 24,
    //     .direction = .column,
    //     .margin = .{ .bottom = 32 },
    //     .size = .w(.percent(100)),
    // })({
    //     Heading(0, "Reactivity").style(&.{
    //         .visual = .{ .text_color = .palette(.text_color), .font_weight = 500 },
    //         .padding = .t(12),
    //         .font_family = "IBM Plex Sans,sans-serif",
    //     });
    //     html(
    //         \\If you're new to application development, reactivity, is the concept of being able to update your application in real time, without having to refresh the page.
    //     );
    //     html(
    //         \\Many frameworks, such as React, Svelte, and Vue, have there own reactivity system, with their own pros and cons.
    //         \\All of these reactivity systems, are known as Signal based systems. When a value is changed, only the component that
    //         \\depends on that value will be updated.
    //     );
    //     Heading(3, "Signal Types").style(styles.heading);
    //     List.style(&.{
    //         .layout = .left_center,
    //         .direction = .column,
    //         .size = .w(.percent(100)),
    //         .child_gap = 8,
    //     })({
    //         ListItem.body()({
    //             html(
    //                 \\<strong>React</strong> has, <code style="color: rgb(var(--tint))">useState</code>,
    //                 \\<code style="color: rgb(var(--tint))">useEffect</code>, and <code style="color: rgb(var(--tint))">useRef</code>, to achieve this.
    //             );
    //         });
    //         ListItem.body()({
    //             html(
    //                 \\<strong>Svelte</strong> has Runes, <code style="color: rgb(var(--tint))">$state</code>,
    //                 \\<code style="color: rgb(var(--tint))">$effect</code>, or <code style="color: rgb(var(--tint))">$derived</code>.
    //             );
    //         });
    //         ListItem.body()({
    //             html(
    //                 \\<strong>Vue</strong> has, <code style="color: rgb(var(--tint))">useRef</code>,
    //                 \\<code style="color: rgb(var(--tint))">reactive</code>, and more.
    //             );
    //         });
    //     });
    //     html(
    //         \\The issue with all of these, is the requirement for both the UI and the functions to use the same reactivity variable. This means that
    //         \\Updating a value in a JS function, like <code style="color: rgb(var(--tint))">let x = 1; x+=1;</code>.
    //         \\Will not update the UI. This is because React, Svelte, Vue, and many other frameworks are transpiled.
    //     );
    //     html(
    //         \\For new developers, the <code style="color: rgb(var(--tint))">useState</code>, <code style="color: rgb(var(--tint))">useEffect</code>, symptom,
    //         \\has become an overwhelming and complex issue.
    //         \\Tracking down dependency chains, or having to use
    //         \\<code style="color: rgb(var(--tint))">useMemo</code>, to avoid cascading updates, has caused developers to become frustrated.
    //     );
    //
    //     html(
    //         \\Moreover, this means that the developer must now understand both the UI's functional nature, and the language's own nature. We must switch
    //         \\contexts, when working with these frameworks.
    //     );
    //
    //     Heading(2, "UI as reactivity").style(styles.heading);
    //     Text("Vapor, is a toolkit, this means that the developer can decide how they want there application's reactivity to work.")
    //         .font(18, null, .palette(.text_color)).close();
    //     List.direction(.column).spacing(8).body()({
    //         ListItem.body()({
    //             html("Immediate Mode");
    //         });
    //         ListItem.body()({
    //             html("Retained Mode");
    //         });
    //     });
    //
    //     html(
    //         \\Vapor, has taken the concept of reactivity, and <i>Inversed It!</i>
    //         \\Instead of defining a reactive variable like <code style="color: rgb(var(--tint))">let counter = $state(0);</code>
    //         \\ we define our UI as reactive.
    //     );
    //
    //     html(
    //         \\There are two types of state components in Vapor.
    //     );
    //
    //     List.direction(.column)
    //         .body()({
    //         ListItem.body()({
    //             html(
    //                 \\<strong>Static</strong> components, will never update!
    //             );
    //         });
    //         ListItem.body()({
    //             html(
    //                 \\<strong>Pure</strong> components, will only update if their styles or props change.
    //             );
    //         });
    //     });
    //
    //     state_types.render(0);
    //
    //     Heading(3, "Immediate Mode").style(styles.heading);
    //     Text(
    //         \\Immediate Mode is the default mode of Vapor. It is the simplest mode, and is the very performant, this site runs in immediate mode.
    //     ).style(styles.body_text);
    //
    //     Text(
    //         \\Immediate mode is extremely fast.
    //         \\In a worst case sceanrio, with a list of 10,000 nodes, no stable keys, in which the first node is order removed,
    //         \\the entire render
    //         \\cycle from removal to UI update takes 15ms on a 2021 M1 MacBook Pro.
    //     ).style(styles.body_text);
    //
    //     Text(
    //         \\Immediate mode requires no state management, if a variable changes the UI will change, only the elements that are affected will be updated.
    //     ).style(styles.body_text);
    //
    //     html(
    //         \\This means that if we define a <code style="color: rgb(var(--tint))">var counter: usize = 0;</code> and then we increment it
    //         \\<code style="color: rgb(var(--tint))">counter += 1;</code> then the Pure UI will update.
    //     );
    //
    //     BoxCode.body()({
    //         immediate_mode.render(0);
    //     });
    //
    //     // BoxCode.body()({
    //     //     reactive_ui.render(0);
    //     // });
    //
    //     Heading(3, "80% of content in an application is static").style(styles.mini_heading);
    //     html(
    //         \\While it may seem like overhead to have to define what is Static, or Pure, 80% of the time, you'll import the
    //         \\<code style="color: rgb(var(--tint))">Static</code> module.
    //         \\Grab out the Component types you need, and be done with it!
    //     );
    //     BoxCode.body()({
    //         import_example.render(0);
    //     });
    //
    //     Heading(3, "Retained Mode").style(styles.heading);
    //     html(
    //         \\There are two types of state management systems in Vapor,
    //     );
    //
    //     List.direction(.column)
    //         .body()({
    //         ListItem.body()({
    //             html(
    //                 \\<code style="color: rgb(var(--tint))">Signal(T)</code>
    //             );
    //         });
    //         ListItem.body()({
    //             html(
    //                 \\<code style="color: rgb(var(--tint))">cycle()</code>
    //             );
    //         });
    //     });
    //
    //     Heading(3, "Using cycle()").style(styles.mini_heading);
    //     BoxCode.body()({
    //         pure_ui_code_example.render(0);
    //     });
    //     html(
    //         \\This function tells Vapor, to update the UI, this is agnostic to the variables. It will update all the UI that has changed, not just
    //         \\the <code style="color: rgb(var(--tint))">counter</code> variable. For example the following will udpate both the
    //         \\<code style="color: rgb(var(--tint))">counter</code> and the <code style="color: rgb(var(--tint))">text</code>.
    //     );
    //     BoxCode.body()({
    //         pure_ui_code_example_and_text.render(0);
    //     });
    //     Heading(3, "Zig is meant to be Explicit!").style(styles.heading);
    //     html(
    //         \\Developers and Zig users alike, will most likely want to have explicit control over the UI, and not depend on the framework.
    //         \\Svelte, came to this realization, and implemented runes, which are explicit UI variables.
    //     );
    //     html("Vapor, has the same concept. When need be developers, can define their own UI variables through the <code style=\"color: rgb(var(--tint))\">Signal(T)</code> type.");
    //     Heading(3, "Signal(T)").style(styles.heading);
    //     html(
    //         \\<code style="color: rgb(var(--tint))">Signal(T)</code> is a type that is used to define UI variables.
    //         \\It is a wrapper around a <code style="color: rgb(var(--tint))">Vapor.cycle()</code>.
    //     );
    //     BoxCode.body()({
    //         signal_increment_sample.render(0);
    //     });
    //     html(
    //         \\<code style="color: rgb(var(--tint))">Signal(T)</code> has a number of methods, that can be used to change or update the state variable.
    //     );
    //     List.layout(.flex).direction(.column).childGap(8).body()({
    //         for (METHODS) |label| {
    //             ListItem.body()({
    //                 HtmlText(label).style(styles.body_text);
    //             });
    //         }
    //     });
    //     Heading(3, "Effects").style(styles.mini_heading);
    //     html(
    //         \\Vapor, has decided to completely remove the concept of useEffect, useMemo, and subscriptions, entirely.
    //         \\Instead, a functional approach should be used.
    //     );
    //     Heading(4, "With the concept of effects").style(styles.mini_heading);
    //     BoxCode.body()({
    //         effect_sample.render(0);
    //     });
    //     Heading(4, "Without the concept of effects").style(styles.mini_heading);
    //     BoxCode.body()({
    //         non_effect_sample.render(0);
    //     });
    //     html(
    //         \\While Vapor, takes a strong stance against the use of effects, subscriptions, and such, it does not mean you cannot build your own effect system.
    //         \\I did this originally, to determine if Vapor needed an effect system, however with the complexity and history of issues
    //         \\with effects, I removed it.
    //         \\If you truly want one, then you are going to have to build it yourself.
    //     );
    //     Heading(4, "Its just Zig").style(styles.mini_heading);
    //     html(
    //         \\Since Vapor is not transpiled, and is just Zig, this means the variables can be passed from file to file.
    //         \\Instead of defining <code style="color: rgb(var(--tint))">const [counter, setCounter] = useState(0)</code> variables,
    //         \\and then passing them down the tree, to use in a child component.
    //     );
    //     html(
    //         \\We can just import the variable where needed. <div><code style="color: rgb(var(--tint))">const Parent = @import("parent.zig");</code></div>
    //         \\<code style="color: rgb(var(--tint))">Parent.counter += 1;</code>
    //     );
    //     html(
    //         \\This also means that we can pass variables from parent to child, or child to parent.
    //         \\This shows the immense power of Zig, and keeping the framework away from transpilation!
    //     );
    // });
}

const METHODS = [_][]const u8{
    "<p><code style=\"color: rgb(var(--tint))\">get</code>()</p>",
    "<p><code style=\"color: rgb(var(--tint))\">set</code>()</p>",
    "<p><code style=\"color: rgb(var(--tint))\">increment</code>()</p>",
    "<p><code style=\"color: rgb(var(--tint))\">decrement</code>()</p>",
    "<p><code style=\"color: rgb(var(--tint))\">toggle</code>()</p>",
    "<p><code style=\"color: rgb(var(--tint))\">append</code>(value: T)</p>",
    "<p><code style=\"color: rgb(var(--tint))\">getElement</code>(index: usize)</p>",
    "<p><code style=\"color: rgb(var(--tint))\">compare</code>()</p>",
    "<p><code style=\"color: rgb(var(--tint))\">and more...</code></p>",
};

const styles = struct {
    pub const heading = &Vapor.Style{
        .visual = .{ .text_color = .palette(.text_color), .font_weight = 600 },
        .padding = .t(12),
        .font_family = "IBM Plex Sans,sans-serif",
    };
    pub const mini_heading = &Vapor.Style{
        .font_family = "IBM Plex Sans",
        .visual = .{ .text_color = .palette(.text_color), .font_weight = 600 },
        .margin = .t(12),
    };
    pub const body_text = &Vapor.Style{
        .visual = .font(16, null, null),
    };
};
