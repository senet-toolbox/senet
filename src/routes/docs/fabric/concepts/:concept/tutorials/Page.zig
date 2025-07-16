const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Page = Fabric.Page;
const Custom = @import("../../../../../../components/Custom.zig");
const Kit = Fabric.Kit;
const CodeEditor = @import("../CodeEditor.zig");

var scaffold_code_editor: CodeEditor = undefined;
var register_code_editor: CodeEditor = undefined;
var grid_code_editor: CodeEditor = undefined;
var wire_code_editor: CodeEditor = undefined;
var assetso_code_editor: CodeEditor = undefined;
var assetsx_code_editor: CodeEditor = undefined;
var extend_code_editor: CodeEditor = undefined;
var update_code_editor: CodeEditor = undefined;
var checkwin_code_editor: CodeEditor = undefined;
var selectbox_code_editor: CodeEditor = undefined;
var winner_code_editor: CodeEditor = undefined;
var full_code_editor: CodeEditor = undefined;
pub fn init() void {
    scaffold_code_editor.init(&Fabric.lib.allocator_global, @embedFile("scaffold.zig"));
    register_code_editor.init(&Fabric.lib.allocator_global, @embedFile("register.zig"));
    grid_code_editor.init(&Fabric.lib.allocator_global, @embedFile("grid.zig"));
    wire_code_editor.init(&Fabric.lib.allocator_global, @embedFile("wire.zig"));
    assetso_code_editor.init(&Fabric.lib.allocator_global, @embedFile("assetsO.zig"));
    assetsx_code_editor.init(&Fabric.lib.allocator_global, @embedFile("assetsX.zig"));
    extend_code_editor.init(&Fabric.lib.allocator_global, @embedFile("extend.zig"));
    update_code_editor.init(&Fabric.lib.allocator_global, @embedFile("update.zig"));
    checkwin_code_editor.init(&Fabric.lib.allocator_global, @embedFile("checkwin.zig"));
    selectbox_code_editor.init(&Fabric.lib.allocator_global, @embedFile("selectbox.zig"));
    winner_code_editor.init(&Fabric.lib.allocator_global, @embedFile("winner.zig"));
    full_code_editor.init(&Fabric.lib.allocator_global, @embedFile("full.zig"));
}

var copied: bool = false;
var copied_text: []const u8 = "";
fn copy(text: []const u8) void {
    Fabric.Clipboard.copy(text);
    copied = true;
    copied_text = text;
    Fabric.cycle();
    Fabric.registerCtxTimeout(500, toggleIcon, .{});
}

fn toggleIcon() void {
    copied = false;
    copied_text = "";
    Fabric.cycle();
}

fn code_snippet_single(text: []const u8) void {
    Static.Box(.{
        .height = .percent(100),
        .background = .hex("#282a36"),
        .border_radius = .all(8),
        .padding = .all(8),
        .width = .percent(100),
        .direction = .column,
        .position = .{ .type = .relative },
    })({
        Static.CtxButton(copy, .{text}, .{
            .width = .px(22),
            .height = .px(22),
            .border_radius = .all(4),
            .display = .Center,
            .cursor = .pointer,
            .transition = .{ .duration = 300 },
            .hover = .{ .background = .hex("#2D303E") },
            .position = .{ .type = .absolute, .right = .px(8), .top = .px(8) },
        })({
            if (copied and std.mem.eql(u8, text, copied_text)) {
                Pure.Icon("bi bi-check", .{
                    .font_size = 16,
                    .text_color = .hex("#cccccc"),
                    .transition = .{ .duration = 300 },
                    .hover = .{ .text_color = .hex("#ffffff") },
                });
            } else {
                Pure.Icon("bi bi-clipboard", .{
                    .font_size = 16,
                    .text_color = .hex("#cccccc"),
                    .transition = .{ .duration = 300 },
                    .hover = .{ .text_color = .hex("#ffffff") },
                });
            }
        });
        Custom.HtmlText(text, .{
            .font_size = 16,
            .text_color = .hex("#ffffff"),
        });
    });
}

fn code_snippet(text: []const u8) void {
    Static.Box(.{
        .height = .percent(100),
        .background = .hex("#282a36"),
        .border_radius = .all(8),
        .padding = .all(8),
        .width = .percent(100),
        .direction = .column,
    })({
        Static.FlexBox(.{
            .child_alignment = .end_center,
            .width = .percent(100),
            .padding = .horizontal(12),
        })({
            Static.CtxButton(copy, .{text}, .{
                .width = .px(22),
                .height = .px(22),
                .border_radius = .all(4),
                .display = .Center,
                .cursor = .pointer,
                .transition = .{ .duration = 300 },
                .hover = .{ .background = .hex("#2D303E") },
            })({
                Pure.Icon("bi bi-clipboard", .{
                    .font_size = 16,
                    .text_color = .hex("#cccccc"),
                    .transition = .{ .duration = 300 },
                    .hover = .{ .text_color = .hex("#ffffff") },
                });
            });
        });
        Static.Text(text, .{
            .font_size = 16,
            .text_color = .hex("#ffffff"),
        });
    });
}

pub fn render() void {
    // Page Header
    Static.FlexBox(.{
        .child_gap = 16,
        .direction = .column,
        .margin = .{ .bottom = 32 },
        .width = .percent(100),
    })({
        Static.Text("Building the “Tic-Tac-Toe” Demo Route", .{
            .font_size = 32,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("This section walks you through adding a fully-working Tic-Tac-Toe game as a new page in your Fabric application. We’ll start by wiring up the route, then progressively add game logic and styling in later chapters.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
            .margin = .{ .bottom = 16 },
        });

        // Section 1.1
        Static.Text("1.1 Create the Route Folder", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Using the fabric cli, run...", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        code_snippet_single(
            \\metal fabric create tictac
        );
        code_snippet_single(
            \\cd tictac
        );
        code_snippet_single(
            \\metal fabric run
        );
        Static.Text("Create the tictac route", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        code_snippet_single("mkdir src/routes/tictac");
        code_snippet_single("cd src/routes/tictac");
        Static.Text("Fabric’s router maps URL segments to matching folders under `src/routes`. Creating the `tictac` directory means that visiting `/tictac` in the browser will load whatever components you register from this folder.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });

        // Section 1.2
        Static.Text("1.2 Scaffold `Page.zig`", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Inside `src/routes/tictac/`, add `Page.zig` with the minimal boilerplate:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        code_snippet_single("metal fabric gen page");
        scaffold_code_editor.render(0);

        // Section 1.3
        Static.Text("1.3 Register the Page in `main.zig`", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Update the imports and add one line inside `instantiate()`:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });

        register_code_editor.render(0);
        Static.Text("No other code changes are required—`fabric.renderCycle` already chooses the correct page implementation based on the route string you pass in from JavaScript. At this stage the page simply displays a centred title; we will flesh out the 3×3 grid and game state in upcoming sections.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });

        // Section 1.4
        Static.Text("1.4 Smoke-test the Route", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Column(.{ .child_gap = 8, .width = .percent(100) })({
            Static.Text("1. Navigate to `http://localhost:5173/tictac` in the browser.", .{ .font_size = 18, .text_color = .hex("#2a2a2a") });
            Static.Text("2. You should see the centred “Tic-Tac-Toe!” header.", .{ .font_size = 18, .text_color = .hex("#2a2a2a") });
        });
        Static.Text("If you get a blank screen, confirm:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Static.Column(.{ .child_gap = 8, .width = .percent(100) })({
            Static.Text("1. The folder is named exactly tictac (case‑sensitive).", .{ .font_size = 18, .text_color = .hex("#2a2a2a") });
            Static.Text("2. TicTacToe.init() is indeed called before the first renderUI.", .{ .font_size = 18, .text_color = .hex("#2a2a2a") });
        });

        // Section 10
        Static.Text("2. Creating a Reusable `Grid` Component", .{
            .font_size = 32,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 32, .bottom = 8 },
        });
        Static.Text("With the route skeleton in place, the next step is to render a 3x3 board. We’ll encapsulate board-drawing in a separate component so it can be tested or swapped out easily later.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
            .margin = .{ .bottom = 16 },
        });
        Static.Text("2.1 Add the `components` Directory", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Make sure your in the root directory.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        code_snippet_single("mkdir src/components");
        code_snippet_single("cd src/components");

        Static.Text("2.2 Implement `Grid.zig`", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        code_snippet_single("metal fabric gen component -o Grid");
        grid_code_editor.render(0);
        Static.Text("What this does:", .{ .font_size = 18, .font_weight = 700, .margin = .{ .top = 8 } });

        Static.List(.{})({
            Static.ListItem(.{})({
                Static.Text("Lays out nine equal‑sized flex children, producing the Tic‑Tac‑Toe grid.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("Where the click handler is added.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
        });
        Static.Text("Why percentage sizes? Using `33 %` width/height guarantees the grid remains square and responsive regardless of the container size.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
            .margin = .{ .top = 8 },
        });
        Static.Text("2.3 Wire the Component into the Tic-Tac-Toe Page", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Update `src/routes/tictac/Page.zig` so that it imports and renders the new component:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        wire_code_editor.render(0);
        Static.Text("Re-build and refresh `/tictac` — you should now see a 3x3 grid with cell indices.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });

        // Section 11
        Static.Text("3. Embedding X / O SVG Assets & Click Handling", .{
            .font_size = 32,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 32, .bottom = 8 },
        });
        Static.Text("Unlike a text-based “X” or “O”, SVG graphics scale crisply at any resolution and can be styled via CSS. Fabric can embed static asset files at compile-time using Zig’s `@embedFile` builtin, eliminating network requests for icons.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        Static.Text("3.1 Add the SVG files", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Create an `assets` folder at project root (or any path you like) and drop two files:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        Static.List(.{})({
            Static.ListItem(.{})({
                Static.Text("assets/X.svg", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            assetso_code_editor.render(0);

            Static.ListItem(.{})({
                Static.Text("assets/O.svg", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            assetsx_code_editor.render(0);
        });
        Static.Text("3.2 Extend `Grid.zig`", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Replace the placeholder-number implementation with click-aware logic and embedded icons:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        extend_code_editor.render(0);
        Static.Text("Key points", .{ .font_size = 18, .font_weight = 700, .margin = .{ .top = 8 } });
        Static.Table(.{
            .width = .percent(100),
            .border_radius = .all(8),
            .padding = .all(8),
            .margin = .{ .bottom = 16 },
        })({
            Static.TableRow(.{
                .width = .percent(100),
            })({
                Static.TableCell(.{
                    .width = .percent(15),
                    .border_thickness = .{ .bottom = 1, .right = 1, .top = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("Concept", .{
                        .font_size = 18,
                        .text_color = .hex("#4a4a4a"),
                        .display = .Center,
                    });
                });
                Static.TableCell(.{
                    .width = .percent(15),
                    .border_thickness = .{ .bottom = 1, .right = 1, .top = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("Where it appears", .{
                        .font_size = 18,
                        .text_color = .hex("#4a4a4a"),
                        .display = .Center,
                    });
                });
                Static.TableCell(.{
                    .width = .percent(70),
                    .border_thickness = .{ .bottom = 1, .top = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("Why it matters", .{
                        .display = .Center,
                        .font_size = 18,
                        .text_color = .hex("#4a4a4a"),
                    });
                });
            });
            Static.TableRow(.{
                .width = .percent(100),
            })({
                Static.TableCell(.{
                    .width = .percent(15),
                    .border_thickness = .{ .bottom = 1, .right = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("@embedFile", .{
                        .display = .Center,
                    });
                });
                Static.TableCell(.{
                    .width = .percent(15),
                    .border_thickness = .{ .bottom = 1, .right = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("drawX()/drawO()", .{
                        .display = .Center,
                    });
                });
                Static.TableCell(.{
                    .width = .percent(70),
                    .border_thickness = .{ .bottom = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("Embeds raw SVG markup in the Wasm binary; zero runtime fetches.", .{
                        .display = .Center,
                    });
                });
            });
            Static.TableRow(.{
                .width = .percent(100),
            })({
                Static.TableCell(.{
                    .width = .percent(15),
                    .border_thickness = .{ .bottom = 1, .right = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("Static.Svg", .{
                        .display = .Center,
                    });
                });
                Static.TableCell(.{
                    .width = .percent(15),
                    .border_thickness = .{ .bottom = 1, .right = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("same", .{
                        .display = .Center,
                    });
                });
                Static.TableCell(.{
                    .width = .percent(70),
                    .border_thickness = .{ .bottom = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("Lets Fabric treat the markup like any other DOM node, inheriting flex‑box centring and size constraints.", .{
                        .display = .Center,
                    });
                });
            });
            Static.TableRow(.{
                .width = .percent(100),
            })({
                Static.TableCell(.{
                    .width = .percent(15),
                    .border_thickness = .{ .bottom = 1, .right = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("Turn state", .{
                        .display = .Center,
                    });
                });
                Static.TableCell(.{
                    .width = .percent(15),
                    .border_thickness = .{ .bottom = 1, .right = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("current_player", .{
                        .display = .Center,
                    });
                });
                Static.TableCell(.{
                    .width = .percent(70),
                    .border_thickness = .{ .bottom = 1 },
                    .border_color = .hex("#000000"),
                })({
                    Static.Text("Ensures clicks alternate X→O→X…", .{
                        .display = .Center,
                    });
                });
            });
        });
        Static.Text("3.3 Smoke-test Interaction", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });

        Static.List(.{})({
            Static.ListItem(.{})({
                Static.Text("Click squares; should log Selecting a box!", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("Clicking an already‑taken square does nothing.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
        });

        Static.Text("If icons are missing, verify the asset path in `@embedFile` and that Zig’s build file includes the `assets` folder in `build.zig`.", .{
            .font_size = 18,
        });

        // Section 12
        Static.Text("4. Using Fabric.cycle() to re-render the board", .{
            .font_size = 32,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 32, .bottom = 8 },
        });
        Static.Text("Before we wire in win-detection, we need a clean way to tell Fabric “re-evaluate the entire board component now” whenever a move is made. Instead of sprinkling many small `Signal`s throughout the grid, we can leverage a single cycle fucntion call that explicitly invalidates the component tree.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        Static.Text("4.1 Why use a Fabric.cycle?", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });

        Static.List(.{})({
            Static.ListItem(.{})({
                Static.Text("Simplicity - One line (`Fabric.cycle()`) after any mutation guarantees a fresh render pass.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });

            Static.ListItem(.{})({
                Static.Text("Explicit intent - Makes it crystal‑clear where state changes occur.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });

            // insert code here
            Static.ListItem(.{})({
                Static.Text("Zero payload - A `Signal(void)` carries some heap allocated memory; while Fabric.cycle() is purely a _recompute_ trigger.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
        });
        Static.Text("4.2 Updated `Grid.zig` with `Fabric.cycle()`", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        update_code_editor.render(0);
        Static.Text("4.3 Quick test", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });

        Static.List(.{})({
            Static.ListItem(.{})({
                Static.Text("Re‑build and reload `/tictac` — you should now see a 3‑×‑3 grid with cell indices.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("Play a few moves—each click should instantly reflect the new X/O.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
            Static.ListItem(.{})({
                Static.Text("No console warnings about unused `Signal` or double initialisation.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
        });

        // Section 13
        Static.Text("5. Win Detection & Game Reset", .{
            .font_size = 32,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 32, .bottom = 8 },
        });
        Static.Text("The grid now re-renders on every move. Next we need a routine that inspects the board after each click and returns the winner—if any.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        Static.Text("5.1 `checkWin()` implementation", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        checkwin_code_editor.render(0);
        Static.Text("5.2 Integrate with `selectBox`", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Add a global to track the outcome:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        code_snippet_single("var winner: ?Player = null;");
        Static.Text("Then update the click handler:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        selectbox_code_editor.render(0);

        Static.Text("5.3 Display the winner & reset button", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Append this overlay inside `render()` after the grid loops:", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        winner_code_editor.render(0);
        full_code_editor.render(0);
        Static.Text("5.4 Quick test checklist", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.List(.{})({
            Static.ListItem(.{})({
                Static.Text("Complete any row/col/diagonal: the result should be a winner", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });

            Static.ListItem(.{})({
                Static.Text("Click **Play Again** — the board resets; X always starts first.", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });

            Static.ListItem(.{})({
                Static.Text("Play until all 9 squares filled with no winner (optional)", .{
                    .font_size = 18,
                    .text_color = .hex("#4a4a4a"),
                });
            });
        });
        // Section 14
        Static.Text("6. Alternative: Using an Array Signal for Fine-Grained State", .{
            .font_size = 32,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 32, .bottom = 8 },
        });
        Static.Text("Some teams prefer an explicit data-signal over a global force signal. The idea is to wrap the entire `[9]GridBox` array in a `Signal`, mutate only the relevant element, and let Fabric automatically re-diff dependent views. This adds a bit of boilerplate but makes the reactive dataflow crystal-clear.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
        Static.Text("6.1 Full Source (array-signal version)", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        // insert code here
        Static.Text("6.2 Comparing the Two Approaches", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        // insert code here
        Static.Text("6.3 Takeaway", .{
            .font_size = 24,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
            .margin = .{ .top = 16, .bottom = 8 },
        });
        Static.Text("Both techniques are valid. Pick force-signal for speed of implementation or when state mutations are rare. Choose array-signal (or multiple finer signals) when you want maintainability and precise reactive scopes.", .{
            .font_size = 18,
            .text_color = .hex("#666666"),
        });
    });
}
