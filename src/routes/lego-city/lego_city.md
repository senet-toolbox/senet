# Lego City

@lego_city_image

#### In this tutorial, we will build a simple Lego City.

#### By then end of this tutorial, you will:

1. Have an understanding of memory management, and how it's much simpler than one would think.

2. Know how to use comptime, and create UI components.

3. Know how to use the builder pattern, and how to generate UI components, based on a single base component.

4. And much more!

## Let's get started!

### Step 1: Create a new project

%metal create lego-city my-lego-city-tutorial

%cd my-lego-city-tutorial && metal run web

#### Each project is a self-contained Zig application, with a

- src/main.zig - The main entry point for your application
- src/routes/Page.zig - The root page for your application
- assets/ - Static assets for your application
- build.zig - The build script for your application
- wasm/functions.zig - The glue code for your application
- web/ - The web directory for your application
- template.html - The template for your application

The **src/routes/Page.zig** file, is the main page we will be building within.

Now taking a quick trip back in time, we all probably remember playing and building with Lego blocks, whether it was Star Wars, or Lego Cities, or Bionicles.

Each Lego set, has a different set of blocks, some rectagnular, some sqaure, and in today's world, even more complex shapes.

So to build a Lego City we are going to need a box of Lego blocks.

```zig
const LegoType = enum {
    sqaure,
    rectangle,
};

const LegoBlock = struct {
    type: LegoType = .rectangle,
};

const LegoBox = struct {
    blocks: []LegoBlock,
};
```

We define our `LegoBox` as a struct, with a field `blocks` which is an array of `LegoBlock`s.

Lego blocks are also a struct, with a field `type` which is an enum, with two options, `sqaure` and `rectangle`.

This gives us a simple way to define our various Lego blocks, and their shapes. We will add more blocks as we go.

### Step 2: Add blocks to the Lego Box

```zig
const LegoType = enum {
    sqaure,
    rectangle,
};

const LegoBlock = struct {
    type: LegoType = .rectangle,
};

const LegoBox = struct {
    pub const blocks: [32]LegoBlock = .{LegoBlock{}} ** 32; // 👈 We changed this to a comptime array
};
```

We changed the `LegoBox` struct to be a comptime array,
which means that we can define the number of blocks we want to use, and the compiler will generate the array for us.

This creates a static array of `LegoBlock`s, which we can then use to build our Lego City. There are other ways to do this, that we will cover later.

### Step 3: Building a Lego House

Each of the Lego Houses is made up of 16 Rectangular Lego blocks. We can use indexing to access the blocks in our Lego Box.

```zig
const LegoHouse = struct {
    lego_bricks: [16]LegoBlock,
};

fn buildHouse() LegoHouse {
    const lego_blocks = LegoBox.blocks[0..16];
    return LegoHouse{ .lego_bricks = lego_blocks };
}
```

There is a problem with this, since we keep using the same blocks, from the Lego Box, we will end up of with same houses over and over again.

This means, just like a contruction site, that handles all the logistics of building a house, we need to create a Construction struct,
which will handle the logistics of building a house.

```zig
const LegoType = enum {
    sqaure,
    rectangle,
};

const LegoBlock = struct {
    type: LegoType = .rectangle,
};

const LegoBox = struct {
    pub const blocks: [32]LegoBlock = .{LegoBlock{}} ** 32; // 👈 We changed this to a comptime array
};

const LegoHouse = struct {
    lego_bricks: []const LegoBlock,
};

fn buildHouse() LegoHouse {
    const lego_blocks = LegoBox.blocks[0..16];
    return LegoHouse{ .lego_bricks = lego_blocks };
}

/// Construction
const Construction = struct {
    free_blocks_index: usize = 0,

    fn buildHouse(self: *Construction) LegoHouse {
        const lego_blocks = LegoBox.blocks[self.free_blocks_index .. self.free_blocks_index + 16];
        self.free_blocks_index += 16;
        return LegoHouse{ .lego_bricks = lego_blocks };
    }
};

var construction = Construction{};
```

Now lets change our `buildHouse` function to use the construction struct.

```zig
/// Construction
const Construction = struct {
    free_blocks_index: usize = 0,

    fn buildHouse(self: *Construction) LegoHouse {
        const lego_blocks = LegoBox.blocks[self.free_blocks_index .. self.free_blocks_index + 16];
        self.free_blocks_index += 16;
        return LegoHouse{ .lego_bricks = lego_blocks };
    }
};

var construction = Construction{};
```

Now we can use the `buildHouse` function to build a house, and we will be using new bricks for each house built.

Lets finally run our application, and see what we have built so far.

```zig
/// ... rest of the code

var lego_houses: [2]LegoHouse = undefined;
pub fn init() void {
   lego_houses[0] = construction.buildHouse();
   lego_houses[1] = construction.buildHouse();
}

pub fn render() void {
    Center().size(.full).direction(.column).children({
        for (lego_houses) |house| {
            Text("Lego House").end();
        }
    });
}
```

One problem you may have noticed with the above, is if we try and create more than 2 houses, we will get a compile error.

Running the following code will result in a compile error:

```zig
var lego_houses: [2]LegoHouse = undefined;
pub fn init() void {
    markdown.compile(lego_page) catch unreachable;
    lego_houses[0] = construction.buildHouse();
    lego_houses[1] = construction.buildHouse();
    lego_houses[2] = construction.buildHouse();
}
```

This is because we are trying to index into an array of size 2, with index that's out of bounds.

We can fix this changing the array to a dynamic array, so we can create as many houses as we want.

```zig
var lego_houses: std.array_list.Managed(LegoHouse) = undefined;
pub fn init() void {
    lego_houses = std.array_list.Managed(LegoHouse).init(Vapor.arena(.persist));
}
```

In the above code, we changed our array to a managed heap array, which makes it possible to grow the array as needed.

Now we can create as many houses as we want, and they will be added to the array.

```zig
var lego_houses: std.array_list.Managed(LegoHouse) = undefined;
pub fn init() void {
    lego_houses = std.array_list.Managed(LegoHouse).init(Vapor.arena(.persist));
    lego_houses.append(construction.buildHouse()) catch unreachable;
    lego_houses.append(construction.buildHouse()) catch unreachable;
}

pub fn render() void {
    Center().size(.full).direction(.column).children({
        for (lego_houses.items) |house| { // 👈 We changed this to a dynamic array, and now need to access the items field
            Text("Lego House").end();
        }
    });
}
```

But... we still have a problem, even though we can create as many houses as we want, our `LegoBox` only has 32 blocks.
And since each house needs 16 blocks, we can only create 2 houses.

If we run the following code, by adding a third house, we will get a runtime error.

```zig
var lego_houses: std.array_list.Managed(LegoHouse) = undefined;
pub fn init() void {
    lego_houses = std.array_list.Managed(LegoHouse).init(Vapor.arena(.persist));
    lego_houses.append(construction.buildHouse()) catch unreachable;
    lego_houses.append(construction.buildHouse()) catch unreachable;
    lego_houses.append(construction.buildHouse()) catch unreachable; // 👈 This will result in a runtime error
}
```

The reason is that our `free_blocks_index` is incremented by 16 each time, and so when we try to create the third house, we will
exceed the bounds of our `LegoBox.blocks` array.

To fix this, first we should add better error handling, and then we can fix the issue of the array being too small.

```zig
/// Construction
const Construction = struct {
    free_blocks_index: usize = 0,

    fn buildHouse(self: *Construction) !LegoHouse {
        if (self.free_blocks_index + 16 > LegoBox.blocks.len) {
            Vapor.printErr("Failed to build house not enough blocks!", .{});
            return error.OutOfBounds;
        }
        const lego_blocks = LegoBox.blocks[self.free_blocks_index .. self.free_blocks_index + 16];
        self.free_blocks_index += 16;
        return LegoHouse{ .lego_bricks = lego_blocks };
    }
};

/// ... rest of the code

var lego_houses: std.array_list.Managed(LegoHouse) = undefined;

pub fn init() void {
    lego_houses = std.array_list.Managed(LegoHouse).init(Vapor.arena(.persist));

    const first_house = construction.buildHouse() catch return;
    lego_houses.append(first_house) catch unreachable;

    const second_house = construction.buildHouse() catch return;
    lego_houses.append(second_house) catch unreachable;

    const third_house = construction.buildHouse() catch return;
    lego_houses.append(third_house) catch unreachable;
}
```

Now our function works, and we see a nice error message, in the browser console. 🎉

Now if you are coming from a React or JS or non memory managed language, you probably are thinking, why is this so hard to just create a list of elements?

Well, in Zig it's not, I have been purposefully showing you errors, and memory problems, so that when you do get them, you know what to do.

In reality most of the time, you will use Vapor's automatic memory management to create lists, or arrays, or HashMaps, and so on. Or use heap memory,
which is far easier to use.

The point here is to give you a better understanding of how memory works in Zig.

Let's be clear, so far we have a dynamic array of LegoHouses, and an array of LegoBlocks, and then a Construction struct, which is used to build houses.

Let's change our LegoBox struct to now use a pool, so we can create as many houses as we want.

```zig
const LegoBox = struct {
    pub var blocks: std.heap.MemoryPool(LegoBlock) = std.heap.MemoryPool(LegoBlock).init(Vapor.arena(.persist));
};

const LegoHouse = struct {
    lego_bricks: [16]*const LegoBlock = undefined,
};

/// Construction
const Construction = struct {
    fn buildHouse(_: *Construction) !LegoHouse {
        var lego_bricks: [16]*const LegoBlock = undefined;
        for (0..16) |i| {
            const lego_block = try LegoBox.blocks.create();
            lego_block.* = .{};
            lego_bricks[i] = lego_block;
        }
        return LegoHouse{ .lego_bricks = lego_bricks };
    }
};

var construction = Construction{};
```

As you may have noticed, we changed our Construction struct, as well as our LegoHouse struct too.

Now LegoHouse stores an array of constant pointers to LegoBlock, which is what we want, we don't want to duplicate the LegoBlock struct.
We just want to store a pointer to the LegoBlock from the pool.

Within the `buildHouse` function, we create a new lego_bricks array, and then we loop adding the pointers from the pool to the array.

Then we finally return teh LegoHouse.

We can now create as many houses as we want, and they will be added to the array.

```zig

pub fn init() void {
    lego_houses = std.array_list.Managed(LegoHouse).init(Vapor.arena(.persist));

    for (0..100) |_| {
        const house = construction.buildHouse() catch return;
        lego_houses.append(house) catch unreachable;
    }
}
```

We can simplfy the entire system by using just an allocator from Vapor, and looping over the number of houses we want.

```zig
pub fn init() void {
    markdown.compile(lego_page) catch unreachable; // 👈 We changed this to a comptime array
    lego_houses = std.array_list.Managed(LegoHouse).init(Vapor.arena(.persist));

    for (0..100) |_| {
        lego_houses.append(LegoHouse{}) catch unreachable;
    }
}
```

While this is much simpler, remember, the goal is to build a Lego City, and se it's important that we create good patterns, and structure in our code, that we 
can reuse later. So we will continue to use the Construction struct, and the LegoBox struct, as before.

**Note:** For most of the use cases, and pages you will build, you will not need to manage a huge amount of memory, as you will see soon enough, when we 
take advantage of Vapor's memory management. 
