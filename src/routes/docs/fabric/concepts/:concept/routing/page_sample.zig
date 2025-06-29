const Fabric = @import("fabric");
const Style = Fabric.Style;
const Page = Fabric.Page;

// Page Initialization
pub fn init() void {
    Page(@src(), render, deinit, Style{
        .background = .hex("#ffffff"),
    });
}

// Page Deinitialization
pub fn deinit() void {}

// Render Root of the Page
pub fn render() void {
    // This is the Root of the page
}
