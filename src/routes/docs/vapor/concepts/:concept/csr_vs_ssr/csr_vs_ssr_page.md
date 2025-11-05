{#csr-vs-ssr}

# CSR vs SSR

In the beginning, the web was simple: static HTML files on servers, browsers requesting and rendering them. No JavaScript, no dynamic content. Just text.

I find the entire process somewhat absurd—write HTML, compress it, serve it over the network, run it through a rendering engine that binds to native draw commands... all to display text on a screen.

JavaScript was invented because a project manager wanted dynamic content. Its original purpose: add a bit of interactivity to static pages.

Today's computers are absurdly powerful. NASA went to the moon with 72KB of memory. A default React app? 100-130KB compressed. **We are the problem.**

So you might expect me to advocate for server-side rendering—generate everything on the server, send small chunks to the client.

**No.**

The only reason to do that is if your application is megabytes in size. And the only reason your site is megabytes in size is JavaScript dependencies and bloated content. Yes, Next.js generates HTML files—just text. But the idea that incrementing a simple counter requires a full server round trip to inject new text is ridiculous.

{#architecture}

## The Right Architecture

Servers are fast, highly optimized pieces of software designed to handle many requests simultaneously—not to chunk and process data. That's why Canopy lets you implement functions that run directly on the database server. **Process data as close to the source as possible**, then send it to the server, which handles delivery to the client.

Think of it this way:

- **Databases are the kitchen**

- **Servers are the waiters**

- **Clients are the diners**

Imagine ordering bolognese and watching the waiter grab ingredients from the kitchen and cook it at your table. Absurd, right? Waiters distribute food; they don't prepare it. Similarly, servers should distribute data—not transform it.

Databases should handle data construction. Creating two sources of truth is always a mistake.

{#better-way}

## The Better Way

Clients shouldn't need a stable connection just to use an application. Your browser is a rendering engine—it can draw whatever it wants.

The optimal approach: **pre-render HTML for each route at build time** and send it with a tiny WASM framework. The user sees content immediately (limited only by network physics), and once WASM loads, it takes over with instant client-side routing. Best of both worlds: fast first paint and no subsequent page loads.

**A complete "Hello World" app is 26KB.** This includes:

- The HTML file

- JS bridge

{#wasm-framework}

### WASM framework with:

- Router

- Styling system

- Deduplication system

- Reconciler

- Virtual DOM

- Layout engine

- State management

For comparison, a minimal Next.js app starts at ~80KB+ _before you write any code_. React alone is ~40KB gzipped.

For reference, **this entire documentation site is only 180KB** and contains 40+ pages, code snippets, animations, images, SVGs, extensive text, code blocks, and more. That's less than a single hero image on most modern websites.

**Performance on real devices matters.** But first, let's talk about physics.

On a 3G network, even an empty HTML file takes ~2.5 seconds to display due to connection overhead—DNS lookup, TCP handshake, TLS handshake. This is a physics constraint, not a software one. You cannot beat network latency.

This is why the app shell approach makes sense: pre-render your HTML at build time and send it with the first response. The user sees content in 2.5 seconds (the theoretical minimum). While they're reading, your WASM framework loads in parallel. By ~5 seconds, the app is fully interactive and all subsequent navigation is instant—pure client-side routing, no more server round trips.

Compare this to Next.js's own marketing site (https://nextjs.org/), which takes 9-10 seconds before anything is visible on 3G with cache disabled. They're not just slower—they're **4x slower than the theoretical minimum** while shipping megabytes of JavaScript to achieve "server-side rendering."

{#example}

### Example: Fetching Top Posts

- Client sends a user ID and request to the server

- Server forwards it to the database with instructions (sort order, limit to 10 results)

- Database looks up the user-posts relationship and returns the top 10 sorted posts

- Server sends the data to the client

- Client renders it

It's like ordering a meal with sauce on the side. It's not typical, but the waiter handles it and informs the kitchen. It would be absurd if the kitchen prepared the dish with sauce, then the waiter had to meticulously transfer the sauce into a separate container at your table. Even worse: serving the dish and making the diner do it themselves.

{#seo}

## The SEO Red Herring

Let's address the elephant in the room: "But what about SEO?"

SEO is a **discovery problem**, not an application architecture problem. You wouldn't redesign how your restaurant operates by making the waiters stand outside handing out flyers instead of serving food. Marketing is a separate concern.

If you need SEO, use a static site generator. Pre-render your public pages as static HTML. This is literally what they're designed for. Your marketing pages, blog posts, and documentation can all be static HTML that gets indexed perfectly by search engines.

Your *application* doesn't need to be server-rendered just because your landing page needs to rank on Google. These are different problems requiring different solutions. Conflating them is how we ended up with frameworks that are simultaneously too heavy for applications and too complex for content sites.

{#real-time-data}

## Real-Time Data Doesn't Require SSR

"But what about a counter synchronized across multiple users?"

That's just a request. Or a WebSocket. When you receive updated data, you redraw the element. You don't inject an entire HTML file from the server.

Think about it: when the kitchen finishes a dish, the waiter doesn't bring out the entire table setting again. They bring the new dish and place it where it belongs.

The client already knows how to render a counter. Send it the new number—not the HTML, not the component tree, just the data. Let the client do what it does best: render.

{#synchronization-problem}

## The Synchronization Problem

Here's the biggest issue with SSR: **you need to synchronize both sides.** The server needs to know the layout of the client. You're maintaining the same component tree in two places, in two different languages (JavaScript on both ends, but one runs in Node, one in the browser).

When something breaks—and it will—you have to debug:

- Why did the server render X?

- Why did the client expect Y?

- Where did the hydration mismatch happen?

- Which state is the source of truth?

You've created two sources of truth. The server thinks the UI looks one way, the client thinks it looks another way, and now you're playing detective to figure out where they diverged.

With CSR, there's one source of truth: the client. The server sends data. The client renders it. If something's wrong, you know exactly where to look.

**Let each layer do what it does best.**
