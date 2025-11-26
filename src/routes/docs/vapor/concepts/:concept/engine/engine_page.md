{#project-structure}

# Project Structure

Project structure in Vapor, is really up to you, by default Vapor, uses the routes directory to hold all the routes.
Vapor, as you know, renders to IOS, and Web, more are to come. By default, Vapor will render to Web. You can pull the IOS compilation tool via
metal. Then render to IOS.

![Diagram](/assets/project_structure.svg)

By default, Vapor generates a vapor.wasm file, and otherwise, a vapor.exe file, which is the entry point for the IOS application call.

The web directory holds the wasm bridge files, for connecting JS to vapor.wasm.
The src directory hold `main` and `routes`, and anything else you want to use or create.
The ios directory holds the ios bridge files, for connecting zig to native IOS objc code.

