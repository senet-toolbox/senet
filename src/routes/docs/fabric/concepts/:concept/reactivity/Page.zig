const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
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

const Pure = Fabric.Pure;
const Page = Fabric.Page;
const CodeEditor = @import("../../../../../../components/CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

var code_editor: CodeEditor = undefined;
var get_code_editor: CodeEditor = undefined;
var set_code_editor: CodeEditor = undefined;
var append_code_editor: CodeEditor = undefined;
var toggle_code_editor: CodeEditor = undefined;
var increment_code_editor: CodeEditor = undefined;
var decrement_code_editor: CodeEditor = undefined;
var dyanmic_code_editor: CodeEditor = undefined;

var fabric_code_editor: CodeEditor = undefined;
var react_code_editor: CodeEditor = undefined;
var svelte_code_editor: CodeEditor = undefined;
var fabric_style_code_editor: CodeEditor = undefined;
var pure_ui_code_example: CodeEditor = undefined;
var pure_ui_code_example_and_text: CodeEditor = undefined;
var reactive_ui: CodeEditor = undefined;
var signal_increment_sample: CodeEditor = undefined;
var effect_sample: CodeEditor = undefined;
var non_effect_sample: CodeEditor = undefined;
var import_example: CodeEditor = undefined;

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
pub fn init() void {
    pure_ui_code_example.init(&Fabric.lib.allocator_global, @embedFile("pure_ui_sample.zig"));
    pure_ui_code_example_and_text.init(&Fabric.lib.allocator_global, @embedFile("pure_ui_sample_and_text.zig"));
    reactive_ui.init(&Fabric.lib.allocator_global, @embedFile("reactive_ui.zig"));
    signal_increment_sample.init(&Fabric.lib.allocator_global, @embedFile("signal_increment_sample.zig"));
    effect_sample.init(&Fabric.lib.allocator_global, @embedFile("effect_approach.zig"));
    non_effect_sample.init(&Fabric.lib.allocator_global, @embedFile("non_effect_approach.zig"));
    import_example.init(&Fabric.lib.allocator_global, @embedFile("import_example.zig"));
    // code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_sample.zig"));
    // get_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_get_sample.zig"));
    // set_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_set_sample.zig"));
    // append_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_append_sample.zig"));
    // toggle_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_toggle_sample.zig"));
    // increment_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_increment_sample.zig"));
    // decrement_code_editor.init(&Fabric.lib.allocator_global, @embedFile("signal_decrement_sample.zig"));
    // fabric_code_editor.init(&Fabric.lib.allocator_global, @embedFile("fabric_sample.zig"));
    // react_code_editor.init(&Fabric.lib.allocator_global, @embedFile("react_sample.js"));
    // svelte_code_editor.init(&Fabric.lib.allocator_global, @embedFile("svelte_sample.svelte"));
    // fabric_style_code_editor.init(&Fabric.lib.allocator_global, @embedFile("fabric_style_sample.zig"));
    // dyanmic_code_editor.init(&Fabric.lib.allocator_global, @embedFile("dynamic_sample.zig"));
}

// Deinitialization

pub fn Txt(text: []const u8) void {
    Text(text).style(styles.body_text);
}

pub fn html(text: []const u8) void {
    HtmlText(text).style(styles.body_text);
}

const BoxCode = Box.margin(.tb(8, 24)).size(.hw(.fit, .percent(100)));

// Render
pub fn render() void {
    // Page Header
    Box.style(&.{
        .child_gap = 24,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .size = .w(.percent(100)),
    })({
        Text("Reactivity").style(&.{
            .font_family = "IBM Plex Sans",
            .visual = .font(32, 700, .palette(.text_color)),
        });
        html(
            \\If you're new to application development, reactivity, is the concept of being able to update your application in real time, without having to refresh the page.
        );
        html(
            \\Many frameworks, such as React, Svelte, and Vue, have there own reactivity system, with their own pros and cons.
            \\All of these reactivity systems, are known as Signal based systems. When a value is changed, only the component that 
            \\depends on that value will be updated.
        );
        Text("Signal Types").style(styles.heading);
        List.direction(.column)
            .body()({
            ListItem.body()({
                html(
                    \\<strong>React</strong> has, <code style="color: rgb(var(--tint))">useState</code>, 
                    \\<code style="color: rgb(var(--tint))">useEffect</code>, and <code style="color: rgb(var(--tint))">useRef</code>, to achieve this.
                );
            });
            ListItem.body()({
                html(
                    \\<strong>Svelte</strong> has Runes, <code style="color: rgb(var(--tint))">$state</code>, 
                    \\<code style="color: rgb(var(--tint))">$effect</code>, or <code style="color: rgb(var(--tint))">$derived</code>.
                );
            });
            ListItem.body()({
                html(
                    \\<strong>Vue</strong> has, <code style="color: rgb(var(--tint))">useRef</code>, 
                    \\<code style="color: rgb(var(--tint))">reactive</code>, and more.
                );
            });
        });
        html(
            \\The issue with all of these, is the requirement for both the UI and the functions to use the same reactivity variable. This means that
            \\Updating a value in a JS function, like <code style="color: rgb(var(--tint))">let x = 1; x+=1;</code>. 
            \\Will not update the UI. This is because React, Svelte, Vue, and many other frameworks are transpiled.
        );
        html(
            \\For new developers, the <code style="color: rgb(var(--tint))">useState</code>, <code style="color: rgb(var(--tint))">useEffect</code>, symptom, 
            \\has become an overwhelming and complex issue.
            \\Tracking down dependency chains, or having to use
            \\<code style="color: rgb(var(--tint))">useMemo</code>, to avoid cascading updates, has caused developers to become frustrated.
        );

        html(
            \\Moreover, this means that the developer must now understand both the UI's functional nature, and the language's own nature. We must switch
            \\contexts, when working with these frameworks. 
        );

        Text("UI as reactivity").style(styles.heading);
        html(
            \\Fabric, has taken the concept of reactivity, and <i>Inversed It!</i> 
            \\Instead of defining a reactive variable like <code style="color: rgb(var(--tint))">var counter: usize = 0;</code> 
            \\ we define our UI as reactive.
        );
        HtmlText("<code style=\"color: rgb(var(--tint))\">Pure.TextFmt(...)</code>").style(&.{
            .layout = .center,
            .visual = .font(20, null, null),
        });

        Text("UI Types").style(styles.heading);
        List.direction(.column)
            .body()({
            ListItem.body()({
                html(
                    \\<strong>Static</strong> components, will never update!
                );
            });
            ListItem.body()({
                html(
                    \\<strong>Pure</strong> components, will only update if their styles or props change.
                );
            });
        });

        html(
            \\This means that if we define a <code style="color: rgb(var(--tint))">var counter: usize = 0;</code> and then we increment it 
            \\<code style="color: rgb(var(--tint))">counter += 1;</code> then the Pure UI will update.
        );

        BoxCode.body()({
            reactive_ui.render(0);
        });

        HtmlText("80% of content in an application is static").style(styles.mini_heading);
        html(
            \\While it may seem like overhead to have to define what is Static, or Pure, 80% of the time, you'll import the 
            \\<code style="color: rgb(var(--tint))">Static</code> module.
            \\Grab out the Component types you need, and be done with it!
        );
        BoxCode.body()({
            import_example.render(0);
        });

        HtmlText("Using Fabric.cycle()").style(styles.mini_heading);
        BoxCode.body()({
            pure_ui_code_example.render(0);
        });
        html(
            \\You have probably noticed the <code style="color: rgb(var(--tint))">Fabric.cycle()</code> function...
        );
        html(
            \\This function tells Fabric, to update the UI, this is agnostic to the variables. It will update all the UI that has changed, not just
            \\the <code style="color: rgb(var(--tint))">counter</code> variable. For example the following will udpate both the 
            \\<code style="color: rgb(var(--tint))">counter</code> and the <code style="color: rgb(var(--tint))">text</code>.
        );
        BoxCode.body()({
            pure_ui_code_example_and_text.render(0);
        });
        Text("Zig is meant to be Explicit!").style(styles.heading);
        html(
            \\Developers and Zig users alike, will most likely want to have explicit control over the UI, and not depend on the framework.
            \\Svelte, came to this realization, and implemented runes, which are explicit UI variables.
        );
        html("Fabric, has the same concept. When need be developers can define their own UI variables through the <code style=\"color: rgb(var(--tint))\">Signal</code> type.");
        Text("Signal").style(styles.heading);
        html(
            \\<code style="color: rgb(var(--tint))">Signal</code> is a type that is used to define UI variables. 
            \\It is a wrapper around a <code style="color: rgb(var(--tint))">Fabric.cycle()</code>.
        );
        BoxCode.body()({
            signal_increment_sample.render(0);
        });
        html(
            \\<code style="color: rgb(var(--tint))">Signal</code> has a number of methods, that can be used to change or update the state variable.
        );
        List.layout(.flex).direction(.column).childGap(8).body()({
            for (METHODS) |label| {
                ListItem.body()({
                    HtmlText(label).style(styles.body_text);
                });
            }
        });
        html(
            \\Fabric, has decided to completely remove the concept of useEffect, useMemo, and subscriptions, entirely. 
            \\Instead, a function approach should be used. 
        );
        Text("With the concept of effects").style(styles.mini_heading);
        BoxCode.body()({
            effect_sample.render(0);
        });
        Text("Without the concept of effects").style(styles.mini_heading);
        BoxCode.body()({
            non_effect_sample.render(0);
        });
        html(
            \\While Fabric, takes a strong stance against the use of effects, subscriptions, and such, it does not mean you cannot build your own effect system.
            \\I did this originally, to determine if Fabric needed a effect system, however with the complexity and histroy of issues with effects, I removed it.
            \\If you truly want one, then you are going to have to build it yourself.
        );
        Text("Its just Zig").style(styles.mini_heading);
        html(
            \\Since Fabric is not transpiled, and is just Zig, this means the variables can be passed from file to file. 
            \\Instead of defining <code style="color: rgb(var(--tint))">const [counter, setCounter] = useState(0)</code> variables, 
            \\and then passing them down the tree, to use in a child component. 
        );
        html(
            \\We can just import the variable where needed. <div><code style="color: rgb(var(--tint))">const Parent = @import("parent.zig");</code></div>
            \\<code style="color: rgb(var(--tint))">Parent.counter += 1;</code>
        );
        html(
            \\This also means that we can pass variables from parent to child, or child to parent. 
            \\This shows the immense power of Zig, and keeping the framework away from transpilation!
        );
    });
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
};

const styles = struct {
    pub const heading = &Fabric.Style{
        .font_family = "IBM Plex Sans",
        .visual = .font(24, 700, .palette(.text_color)),
    };
    pub const mini_heading = &Fabric.Style{
        .font_family = "IBM Plex Sans",
        .visual = .font(20, 700, .palette(.text_color)),
        .margin = .t(12),
    };
    pub const body_text = &Fabric.Style{
        .visual = .font(18, null, null),
    };
};
