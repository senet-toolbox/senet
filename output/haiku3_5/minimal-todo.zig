const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.ButtonCtx;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;

// Todo item structure
const TodoItem = struct {
    text: []const u8,
    completed: bool = false,
};

// Global state
var todos: Vapor.Array(TodoItem) = undefined;
var input: []const u8 = "";

// Initialize the application
pub fn init() void {
    // Create persistent array for todos
    todos = Vapor.array(TodoItem, .persist);
    
    // Set up the page
    Vapor.Page(.{ .src = @src() }, render, null);
}

// Add a new todo
fn addTodo() void {
    // Check if input is not empty
    if (input.len > 0) {
        // Copy input to persistent memory
        const copy = Vapor.arena(.persist).dupe(u8, input) catch return;
        
        // Append new todo item
        todos.append(.{ .text = copy }) catch return;
        
        // Clear input field
        input = "";
    }
}

// Delete a todo by index
fn deleteTodo(index: usize) void {
    if (index < todos.items.len) {
        // Free the memory of the todo text
        Vapor.arena(.persist).free(todos.items[index].text);
        
        // Remove the todo item
        _ = todos.swapRemove(index);
    }
}

// Toggle todo completion
fn toggleTodo(index: usize) void {
    if (index < todos.items.len) {
        todos.items[index].completed = !todos.items[index].completed;
    }
}

// Render function
fn render() void {
    Box().layout(.center).padding(.all(20)).spacing(16).children({
        // Title
        Text("Todo List").font(24, 700, .hex("#333333")).end();
        
        // Input and Add Button Row
        Box().layout(.row).spacing(10).children({
            TextField(.string)
                .bind(&input)
                .placeholder("Enter a new todo")
                .style(&.{
                    .padding(.horizontal(10))
                })
                .end();
            
            Button(addTodo)
                .style(&.{
                    .background(.hex("#4CAF50"))
                    .color(.hex("#ffffff"))
                })
                .children({
                    Text("Add").end();
                });
        });
        
        // Todo List
        Stack().spacing(10).children({
            for (todos.items, 0..) |todo, i| {
                Box().layout(.row).spacing(10).children({
                    // Checkbox to toggle completion
                    Button(toggleTodo, .{i})
                        .style(&.{
                            .background(if (todo.completed) .hex("#4CAF50") else .hex("#ffffff"))
                            .border(.round(.hex("#cccccc"), .all(2)))
                        })
                        .children({
                            Text(if (todo.completed) "✓" else " ").end();
                        });
                    
                    // Todo Text (with strikethrough if completed)
                    Text(todo.text)
                        .style(&.{
                            .textDecoration(if (todo.completed) .lineThrough else .none)
                            .color(if (todo.completed) .hex("#888888") else .hex("#000000"))
                        })
                        .end();
                    
                    // Delete Button
                    Button(deleteTodo, .{i})
                        .style(&.{
                            .background(.hex("#FF4136"))
                            .color(.hex("#ffffff"))
                        })
                        .children({
                            Text("X").end();
                        });
                });
            }
        });
    });
}
