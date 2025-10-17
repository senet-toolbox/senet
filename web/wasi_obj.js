import { importObject } from "./wasi_env.js";
import { setWasiInstance } from "./wasi.js";
import {
  domNodeRegistry,
  moduleCache,
  moduleRoutes,
  hooksHandlers,
  observeredSections,
  loadedSections,
  pureNodeRegistry,
} from "./maps.js";
import {
  traverse,
  traverseRemove,
  COMPONENT_TYPES,
  isLayout,
  stripNonLayout,
  recurseDestroy,
} from "./traversal.js";
import { state } from "./state.js";
import { styleRuleCache } from "./wasi_styling.js";

export let wasmInstance;
export let activeNodeIds = new Set();
export let rootNodeId = "root";
export let layoutInfo;

let tree_node;

let isDragging = false;
let offsetX, offsetY;
let draggableElement;

function startDrag(e) {
  isDragging = true;

  // Calculate the offset from the mouse position to the element's top-left corner
  const rect = draggableElement.getBoundingClientRect();
  offsetX = e.clientX - rect.left;
  offsetY = e.clientY - rect.top;
}

function drag(e) {
  if (!isDragging) return;

  // Prevent any default behavior
  e.preventDefault();

  // Calculate new position
  let left = e.clientX - offsetX;
  let top = e.clientY - offsetY;

  // Apply new position
  draggableElement.style.left = left + "px";
  draggableElement.style.top = top + "px";
}

function startDragTouch(e) {
  const touch = e.touches[0];
  const mouseEvent = new MouseEvent("mousedown", {
    clientX: touch.clientX,
    clientY: touch.clientY,
  });
  startDrag(mouseEvent);
}

function dragTouch(e) {
  if (!isDragging) return;

  const touch = e.touches[0];
  const mouseEvent = new MouseEvent("mousemove", {
    clientX: touch.clientX,
    clientY: touch.clientY,
  });
  drag(mouseEvent);
}

function endDrag() {
  isDragging = false;
}
// const socket = new WebSocket("ws://localhost:3003");
//
// // This fires when the connection is successfully established
// socket.onopen = function (event) {
//   console.log("WebSocket connection established!");
//   // Maybe update UI to show connected status
// };
//
// // Handle incoming messages
// socket.onmessage = async function (event) {
//   if (event.data === "refresh") {
//     // window.location.reload();
//     // updatePageContent();
//     if (state.initial_render === true) {
//       const rootElement = document.getElementById("contents");
//       rootElement.innerHTML = "";
//       initWasi();
//       // state.initial_render = true;
//       // state.initial_render = false;
//     } else {
//       currentPath = window.location.pathname;
//       clearIntervalsForRoute(currentPath);
//
//       // Update the browser URL without reloading the page
//       // window.history.pushState({}, "", currentPath);
//
//       if (currentPath === "/") {
//         encodeString("/root");
//       } else {
//         encodeString(currentPath);
//       }
//       console.log(rootNodeId);
//       const rootElement = document.getElementById(rootNodeId);
//       rootElement.innerHTML = "";
//       tree_node = wasmInstance.getRenderTreePtr();
//       state.initial_render = true;
//       traverse(rootElement, tree_node, layoutInfo);
//       state.initial_render = false;
//       return;
//     }
//   }
// };
//
// // Handle errors
// socket.onerror = function (error) {
//   console.error("WebSocket error:", error);
// };
//
// // Handle disconnection
// socket.onclose = function (event) {
//   console.log("WebSocket connection closed:", event.code, event.reason);
// };

let layoutInfoPtr;

window.addEventListener("popstate", async function(event) {
  event.preventDefault();
  const path = window.location.pathname;

  rerenderRoute(path === "/" ? "/root" : `/root${path}`);
  requestAnimationFrame(() => {
    // wasmInstance.setRerenderTrue();
  });
});

window.addEventListener("load", async () => {
  // const url = new URL(window.location.href);
  // for (const [key, handler] of hooksHandlers.entries()) {
  // }
  const fontLink = document.createElement("link");
  fontLink.href =
    "https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap";
  fontLink.rel = "stylesheet";
  document.head.appendChild(fontLink);

  const iconLink = document.createElement("link");
  iconLink.href =
    "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css";
  iconLink.rel = "stylesheet";
  document.head.appendChild(iconLink);
});

async function loadWasm(path, imports = {}) {
  const response = await fetch(path); // cache-bust
  const bytes = await response.arrayBuffer();
  const { instance } = await WebAssembly.instantiate(bytes, imports);
  return instance;
}

export async function hotSwapWasmWithState(newPath) {
  console.log("🔄 Swapping WASM with state preservation:", newPath);

  // Grab old memory (if exists)
  let oldMemory;
  if (wasmInstance) {
    oldMemory = wasmInstance.memory;
    // oldMemory = new Uint8Array(wasmInstance.memory.buffer).slice();
  }

  // Load new instance
  const newInstance = await loadWasm(
    `/zig-out/bin/${pathname}.wasm`,
    importObject,
  );

  // If memory layouts match, restore old memory into new instance
  if (oldMemory) {
    const newMem = new Uint8Array(newInstance.exports.memory.buffer);
    // console.log("oldMemory", oldMemory.buffer.byteLength);
    // console.log("oldMemory", newInstance.exports.memory.buffer.byteLength);
    // console.log("newMemory", newMem.length);
    newMem.set(oldMemory.subarray(0, oldMemory.length));
  }

  newInstance.exports.memory.buffer = oldMemory.buffer;
  wasmInstance = newInstance.exports;
  window.myWasmAPI = wasmInstance;

  console.log("✅ Hot swap complete (state copied if compatible)");
  init();
}

let pathname;
export let text_data;
async function loadWasiModule() {
  pathname = window.location.pathname;
  pathname = "fabric";
  loadWasm(`/zig-out/bin/${pathname}.wasm`, importObject)
    .then((instance) => {
      const exports = instance.exports;

      // Initialize WASI (calls Zig's main)
      if (exports._start) {
        try {
          exports._start(); // Triggers Zig's `main()`
        } catch (e) {
          // console.log("WASI exited:", e);
        }
      }

      moduleCache.set(pathname, exports);
      moduleRoutes.add(pathname);
      wasmInstance = exports;
      setWasiInstance(wasmInstance);
    })
    .then(async () => {
      // const text_json = await fetch("/dist/text_data.json");
      text_data = {};
      init(); // Your app initialization
    })
    .catch("Error", console.error);
  // WebAssembly.instantiateStreaming(
  //   fetch(`/zig-out/bin/${pathname}.wasm`),
  //   importObject,
  // )
  //   .then((result) => {
  //     const exports = result.instance.exports;
  //
  //     // Initialize WASI (calls Zig's main)
  //     if (exports._start) {
  //       try {
  //         exports._start(); // Triggers Zig's `main()`
  //       } catch (e) {
  //         // console.log("WASI exited:", e);
  //       }
  //     }
  //
  //     moduleCache.set(pathname, exports);
  //     moduleRoutes.add(pathname);
  //     wasmInstance = exports;
  //     setWasiInstance(wasmInstance);
  //   })
  //   .then(() => {
  //     init(); // Your app initialization
  //   })
  //   .catch("Error", console.error);
}

async function initWasi() {
  wasmInstance = await loadWasiModule();
}

export const encodeString = (string) => {
  const buffer = new TextEncoder().encode(string);
  const pointer = wasmInstance.allocUint8(buffer.length + 1); // ask Zig to allocate memory
  const slice = new Uint8Array(
    wasmInstance.memory.buffer, // memory exported from Zig
    pointer,
    buffer.length + 1,
  );
  slice.set(buffer);
  slice[buffer.length] = 0; // null byte to null-terminate the string
  wasmInstance.setRouteRenderTree(pointer);
};

export const rerenderRoute = (route) => {
  currentPath = window.location.pathname;
  const buffer = new TextEncoder().encode(route);
  const pointer = wasmInstance.allocUint8(buffer.length + 1); // ask Zig to allocate memory
  const slice = new Uint8Array(
    wasmInstance.memory.buffer, // memory exported from Zig
    pointer,
    buffer.length + 1,
  );
  slice.set(buffer);
  slice[buffer.length] = 0; // null byte to null-terminate the string
  wasmInstance.callRouteRenderCycle(pointer);

  const has_dirty = wasmInstance.hasDirty();
  const count = wasmInstance.getRemovedNodeCount();
  /* ───────── main removal loop ───────── */
  for (let i = 0; i < count; i++) {
    const ptr = wasmInstance.getRemovedNode(i);
    const node_index = wasmInstance.getRemovedNodeIndex(i);
    const len = wasmInstance.getRemovedNodeLength(i);
    const id = readWasmString(ptr, len);

    const elements = document.querySelectorAll(`[id="${id}"]`);
    // Here we remove duplicates
    check: if (elements.length > 1) {
      // deduplicate
      for (let element of elements) {
        const target_child = element.parentElement.children[node_index];
        if (target_child.id === id) {
          element.remove();
          break check;
        }
      }
    } else {
      recurseDestroy(elements[0]); // delete everything *except* layouts
    }
  }
  wasmInstance.clearRemovedNodesretainingCapacity();
  clearCSS();
  styleRuleCache.clear();

  loadTheme();
  const global_style_ptr = wasmInstance.getGlobalVariablesPtr();
  const global_style_len = wasmInstance.getGlobalVariablesLen();
  if (global_style_ptr !== 0) {
    const global_css = readWasmString(global_style_ptr, global_style_len);
    injectCSS(global_css);
  }

  const css = readWasmString(wasmInstance.getCSS(), wasmInstance.getCSSLen());
  injectCSS(css);
  // let index = 0;
  // for (const rule of styleSheet.cssRules) {
  //   styleRuleCache.set(rule.selectorText, index);
  //   index += 1;
  // }
  if (has_dirty) {
    tree_node = wasmInstance.getRenderTreePtr();
    if (tree_node === 0) {
      state.initial_render = false;
      wasmInstance.resetRerender();
      requestAnimationFrame(wasmInstance.cleanUp);
      return;
    }
    // this active set does not include the layouts
    activeNodeIds = new Set();
    traverse(root, tree_node, layoutInfo);
    state.initial_render = false;
    wasmInstance.pendingClassesToAdd();
    wasmInstance.pendingClassesToRemove();
    callDestroyFncs();
    // we need to consider the possiblity of has dirty being false and therefore the node tree does not include the current nodes
    // we need to look into this since we dont want to remove the layouts even if they are not in the active set
    // removeInactiveNodes();
    wasmInstance.markCurrentTreeNotDirty();
    wasmInstance.resetRerender();
    handleIntersection();
    requestAnimationFrame(wasmInstance.cleanUp);
    // console.log(pureNodeRegistry);
  } else {
    wasmInstance.resetRerender();
  }
};

export const navToRoute = (string) => {
  const buffer = new TextEncoder().encode(string);
  const pointer = wasmInstance.allocUint8(buffer.length + 1); // ask Zig to allocate memory
  const slice = new Uint8Array(
    wasmInstance.memory.buffer, // memory exported from Zig
    pointer,
    buffer.length + 1,
  );
  slice.set(buffer);
  slice[buffer.length] = 0; // null byte to null-terminate the string
  wasmInstance.setRouteRenderTree(pointer);
};

export const allocString = (string) => {
  const buffer = new TextEncoder().encode(string);
  const pointer = wasmInstance.allocUint8(buffer.length + 1); // ask Zig to allocate memory
  const slice = new Uint8Array(
    wasmInstance.memory.buffer, // memory exported from Zig
    pointer,
    buffer.length + 1,
  );
  slice.set(buffer);
  slice[buffer.length] = 0; // null byte to null-terminate the string
  return pointer;
};

export let root;

function setupLayoutInfo() {
  // Set up listener for back/forward buttons
  // Get the memory layout information
  // So we grab the memory layout of each render command
  // layoutInfoPtr = wasmInstance.allocateLayoutInfo();

  // Corrected JavaScript code to read layout info
  layoutInfoPtr = wasmInstance.allocateLayoutInfo();

  layoutInfo = {
    // Corresponds directly to the corrected Zig struct order
    renderCommandSize: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 0,
      4,
    ).getUint32(0, true),

    // --- Direct offsets in RenderCommand ---
    elemTypeOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 4,
      4,
    ).getUint32(0, true),
    textPtrOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 8,
      4,
    ).getUint32(0, true),
    hrefPtrOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 12,
      4,
    ).getUint32(0, true),
    idPtrOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 16,
      4,
    ).getUint32(0, true),
    indexOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 20,
      4,
    ).getUint32(0, true),
    hooksOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 24,
      4,
    ).getUint32(0, true),
    nodePtrOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 28,
      4,
    ).getUint32(0, true),
    classnamePtrOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 32,
      4,
    ).getUint32(0, true),

    // --- Absolute offsets for fields within the nested 'style' struct ---
    styleBtnIdOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 36,
      4,
    ).getUint32(0, true),
    styleDialogIdPtrOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 40,
      4,
    ).getUint32(0, true),
    styleExitAnimationPtrOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 44,
      4,
    ).getUint32(0, true),

    // --- Nested struct sizes and offsets ---
    hoverSize: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 48,
      4,
    ).getUint32(0, true),
    hoverOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 52,
      4,
    ).getUint32(0, true),
    focusSize: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 56,
      4,
    ).getUint32(0, true),
    focusOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 60,
      4,
    ).getUint32(0, true),
    focusWithinSize: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 64,
      4,
    ).getUint32(0, true),
    focusWithinOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 68,
      4,
    ).getUint32(0, true),
    renderTypeOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 72,
      4,
    ).getUint32(0, true),
    tooltipSize: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 76,
      4,
    ).getUint32(0, true),
    tooltipOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 80,
      4,
    ).getUint32(0, true),
    styleHashOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 84,
      4,
    ).getUint32(0, true),
    propsHashOffset: new DataView(
      wasmInstance.memory.buffer,
      layoutInfoPtr + 88,
      4,
    ).getUint32(0, true),
  };
}

function getSystemTheme() {
  return window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
}

function loadTheme() {
  const savedTheme = localStorage.getItem("theme") || getSystemTheme();
  if (savedTheme === "dark") {
    document.documentElement.setAttribute("data-theme", "dark");
  } else {
    const savedTheme = localStorage.getItem("theme");
    if (savedTheme === "dark") {
      document.documentElement.setAttribute("data-theme", "dark");
    }
  }
}

export const styleSheet = new CSSStyleSheet();
// export const styleSheet =
//   document.styleSheets[0] ||
//   document.head.appendChild(document.createElement("style")).sheet;

export let currentPath;
function setupWasiInstance() {
  wasmInstance.init(window.innerWidth, window.innerHeight); // Example UI function

  const animations_ptr = wasmInstance.getAnimationsPtr();
  if (animations_ptr > 0) {
    const animations_len = wasmInstance.getAnimationsLen();
    const animations_css = readWasmString(animations_ptr, animations_len);
    injectCSS(animations_css);
  }

  loadTheme();
  currentPath = window.location.pathname;
  if (currentPath === "/") {
    route_ptr = allocString("/root");
  } else {
    route_ptr = allocString(`/root${currentPath}`);
  }
  wasmInstance.renderUI(route_ptr);
  wasmInstance.markCurrentTreeDirty();
  tree_node = wasmInstance.getRenderTreePtr();

  activeNodeIds = new Set();

  const global_style_ptr = wasmInstance.getGlobalVariablesPtr();
  const global_style_len = wasmInstance.getGlobalVariablesLen();
  if (global_style_ptr !== 0) {
    const global_css = readWasmString(global_style_ptr, global_style_len);
    injectCSS(global_css);
  }

  const css = readWasmString(wasmInstance.getCSS(), wasmInstance.getCSSLen());
  // console.log(css);
  console.log(css.length);
  injectCSS(css);

  // console.log(styleSheet.cssRules);
  // let index = 0;
  // for (const rule of styleSheet.cssRules) {
  //   styleRuleCache.set(rule.selectorText, index);
  //   index += 1;
  // }

  const start = performance.now();
  traverse(root, tree_node, layoutInfo);
  console.log("--Total render time MS--", performance.now() - start);
  state.initial_render = false;
  wasmInstance.pendingClassesToAdd();
  wasmInstance.pendingClassesToRemove();

  document.body.appendChild(root);
  wasmInstance.markCurrentTreeNotDirty();
  wasmInstance.resetRerender();

  const hash = window.location.hash;
  if (hash) {
    const id = window.location.hash.substring(1, hash.length);
    const element = document.getElementById(id);
    if (element) {
      // Scroll the element into view with options
      element.scrollIntoView({
        block: "center", // Vertically align to the center of the screen
      });
    }
  }

  handleIntersection();

  // const fontLink = document.createElement("link");
  // fontLink.href =
  //   "https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap";
  // fontLink.rel = "stylesheet";
  // document.head.appendChild(fontLink);
  //
  // const iconLink = document.createElement("link");
  // iconLink.href =
  //   "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css&display=swap";
  // iconLink.rel = "stylesheet";
  // document.head.appendChild(iconLink);
}

// function injectCSS(cssString) {
//   const sheet = new CSSStyleSheet();
//   sheet.replaceSync(cssString);
//   document.adoptedStyleSheets = [sheet, ...document.adoptedStyleSheets];
//   console.log(document.adoptedStyleSheets);
// }

// Create ONE global stylesheet
// const styleSheet = new CSSStyleSheet();
document.adoptedStyleSheets = [...document.adoptedStyleSheets, styleSheet];

function clearCSS() {
  styleSheet.replaceSync("");
}

function injectCSS(cssString) {
  // console.log(styleSheet);
  // Append new CSS to the existing sheet
  // read old rules as text
  const existingRules = Array.from(styleSheet.cssRules)
    .map((rule) => rule.cssText)
    .join("\n");

  // replace with old + new rules
  styleSheet.replaceSync(`${existingRules}\n${cssString}`);
}

const frag = document.createDocumentFragment();
async function init() {
  root = document.getElementById("contents");

  // CRITICAL: Minimal setup for first paint
  root.style.width = "100%";
  root.style.height = "100vh";

  // Show a loading state or basic structure immediately
  // root.innerHTML = '<div class="loading">Loading...</div>';
  // document.body.appendChild(root);

  // requestAnimationFrame(() => {
  setupLayoutInfo();
  setupWasiInstance();

  // });
}

function loadSection(element) {
  const id = element.id;
  // if it does not include the id then we have already loaded this section
  if (!observeredSections.has(id)) {
    return;
  }
  const section = observeredSections.get(id);
  wasmInstance.markUINodeTreeDirty(section.renderCmd.nodePtr);
  traverse(element, section.treeNodePtr, layoutInfo);
}
function handleIntersection() {
  const options = {
    root: null,
    rootMargin: "0px", // Only 50px buffer at bottom
    threshold: 0.1,
  };
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting && !loadedSections.has(entry.target.id)) {
        console.log("Intersection", entry.target.id);
        loadedSections.add(entry.target.id);
        loadSection(entry.target);
      }
    });
  }, options);

  // Observe all <section> elements
  document.querySelectorAll("section").forEach((section) => {
    observer.observe(section);
  });
}

let route_ptr = null;

export function requestRerender() {
  if (!state.isRenderScheduled) {
    state.isRenderScheduled = true;
    requestAnimationFrame(render);
  }
}

export function render() {
  // Reset the flag since the scheduled render is now running.
  state.isRenderScheduled = false;

  const globalRerender = wasmInstance.shouldRerender();
  const grainRerender = wasmInstance.grainRerender();
  // const rerenderEverything = wasmInstance.rerenderEverything();
  //
  // if (rerenderEverything) {
  //   document.body.innerHTML = "";
  // }

  // Exit if no re-render is needed.
  if (!globalRerender && !grainRerender) {
    return;
  }

  try {
    if (globalRerender) {
      currentPath = window.location.pathname;
      const route_ptr = allocString(
        currentPath === "/" ? "/root" : `/root${currentPath}`,
      );

      wasmInstance.renderUI(route_ptr);
      const has_dirty = wasmInstance.hasDirty();

      const count = wasmInstance.getRemovedNodeCount();
      // console.log(element);
      /* ───────── main removal loop ───────── */
      for (let i = 0; i < count; i++) {
        const ptr = wasmInstance.getRemovedNode(i);
        const node_index = wasmInstance.getRemovedNodeIndex(i);
        const len = wasmInstance.getRemovedNodeLength(i);
        const id = readWasmString(ptr, len);

        const elements = document.querySelectorAll(`[id="${id}"]`);
        // Here we remove duplicates
        check: if (elements.length > 1) {
          // deduplicate
          for (let element of elements) {
            const target_child = element.parentElement.children[node_index];
            if (target_child.id === id) {
              element.remove();
              break check;
            }
          }
        } else {
          stripNonLayout(elements[0]); // delete everything *except* layouts
        }
      }
      wasmInstance.clearRemovedNodesretainingCapacity();

      if (has_dirty) {
        tree_node = wasmInstance.getRenderTreePtr();
        if (tree_node === 0) {
          state.initial_render = false;
          wasmInstance.resetRerender();
          requestAnimationFrame(wasmInstance.cleanUp);
          return;
        }
        // this active set does not include the layouts
        activeNodeIds = new Set();
        traverse(root, tree_node, layoutInfo);
        state.initial_render = false;
        wasmInstance.pendingClassesToAdd();
        wasmInstance.pendingClassesToRemove();
        callDestroyFncs();
        // we need to consider the possiblity of has dirty being false and therefore the node tree does not include the current nodes
        // we need to look into this since we dont want to remove the layouts even if they are not in the active set
        // removeInactiveNodes();
        wasmInstance.markCurrentTreeNotDirty();
        wasmInstance.resetRerender();
        handleIntersection();
        requestAnimationFrame(wasmInstance.cleanUp);
        // console.log(pureNodeRegistry);
      } else {
        // const count = wasmInstance.getRemovedNodeCount();
        // /* ───────── main removal loop ───────── */
        // for (let i = 0; i < count; i++) {
        //   const ptr = wasmInstance.getRemovedNode(i);
        //   const len = wasmInstance.getRemovedNodeLength(i);
        //   const id = readWasmString(ptr, len);
        //   // console.log(id);
        //
        //   const rec = domNodeRegistry.get(id);
        //   if (!rec) continue; // already gone
        //
        //   const el = rec.domNode;
        //   if (isLayout(el)) continue; // never delete a layout root itself
        //
        //   stripNonLayout(el); // delete everything *except* layouts
        //   wasmInstance.clearRemovedNodesretainingCapacity();
        // }
        //
        // wasmInstance.resetRerender();
      }
    } else {
      // This implies grainRerender is true
      console.log("Grain Rerender");
    }
  } catch (error) {
    console.error("An error occurred during the render cycle:", error);
  }
}

// function renderLoop() {
//   const globalRerender = wasmInstance.shouldRerender();
//   const grainRerender = wasmInstance.grainRerender();
//   try {
//     if (globalRerender) {
//       console.log("attempting to rerender");
//       currentPath = window.location.pathname;
//       if (currentPath === "/") {
//         route_ptr = allocString("/root");
//       } else {
//         route_ptr = allocString(currentPath);
//       }
//       wasmInstance.renderUI(route_ptr);
//       tree_node = wasmInstance.getRenderTreePtr();
//       activeNodeIds = new Set();
//       traverse(root, tree_node, layoutInfo);
//       state.initial_render = false;
//       wasmInstance.pendingClassesToAdd();
//       wasmInstance.pendingClassesToRemove();
//       callDestroyFncs();
//       removeInactiveNodes();
//       wasmInstance.resetRerender();
//       requestAnimationFrame(wasmInstance.cleanUp);
//     } else if (grainRerender) {
//       console.log("Grain Rerender");
//       tree_node = wasmInstance.getRenderTreePtr();
//       activeNodeIds = new Set();
//       traverse(root, tree_node, layoutInfo);
//       wasmInstance.pendingClassesToAdd();
//       wasmInstance.pendingClassesToRemove();
//       callDestroyFncs();
//       removeInactiveNodes();
//       wasmInstance.resetGrainRerender();
//     }
//     requestAnimationFrame(renderLoop);
//   } catch (error) {
//     console.error("Render loop error:", error);
//     // Optionally, implement error recovery or loop stopping mechanism
//   }
// }

export function callDestroyFncs() {
  // Remove any nodes that aren't active in this render
  domNodeRegistry.forEach((node, nodeId) => {
    if (!activeNodeIds.has(nodeId)) {
      const destroyId = node.destroyId;
      if (destroyId !== null) {
        wasmInstance.hooksDestroyCallback(destroyId);
      }
    }
  });
}

function removeNodeWithExitAnimation(domNode, nodeId, animationName) {
  // Wait for animation to complete before removing from DOM
  domNode.addEventListener("animationend", function handler(e) {
    if (e.animationName === animationName) {
      // Only remove if it was the fadeOut animation that ended
      domNode.removeEventListener("animationend", handler);
      // domNode.classList.remove("fade-out");
      domNode.parentNode.removeChild(domNode);
      domNodeRegistry.delete(nodeId);
      pureNodeRegistry.delete(nodeId);
    }
  });
  return;
}

function getDepth(el) {
  let d = 0;
  while (el.parentElement) {
    d++;
    el = el.parentElement;
  }
  return d;
}

function removeAnimatedNodeTree(el) {
  for (const child of el.children) {
    toRemove = removeByIdSwap(toRemove, child.id);
    removeAnimatedNodeTree(child);
  }
}

const removeByIdSwap = (arr, idToRemove) => {
  const idx = arr.findIndex((item) => item.nodeId === idToRemove);
  if (idx !== -1) {
    // Move the last element into the “hole” and pop
    arr[idx] = arr[arr.length - 1];
    arr.pop();
  }
  return arr;
};

let toRemove = [];
export function removeInactiveNodes() {
  // Remove any nodes that aren't active in this render
  toRemove = [];
  domNodeRegistry.forEach((node, nodeId) => {
    if (!activeNodeIds.has(nodeId)) {
      console.log("Removing", nodeId);
      toRemove.push({ node, nodeId });
      domNodeRegistry.delete(nodeId);
      pureNodeRegistry.delete(nodeId);
    }
  });

  // 3) schedule each’s exit animation
  toRemove.forEach(({ node, nodeId }) => {
    const el = node.domNode;
    const exitClass = node.exitAnimationId;
    if (exitClass) {
      removeAnimatedNodeTree(el);
      console.log(toRemove.length);
      // listen → add class → on end remove
      const onEnd = (e) => {
        if (e.animationName === exitClass) {
          el.removeEventListener("animationend", onEnd);
          el.remove();
        }
      };
      el.addEventListener("animationend", onEnd);
      el.classList.add(exitClass);
    } else {
      // no animation, just yank it
      if (node.elementType === COMPONENT_TYPES.HOOKS) {
        const idPtr = allocString(nodeId);
        wasmInstance.hooksRemoveMountedKey(idPtr);
      }
      el.remove();
      // domNodeRegistry.delete(nodeId);
    }
  });
}

export function removeRouteSpecificNodes() {
  const path = window.location.pathname;
  const segments = path.split("/").filter(Boolean); // Remove empty strings
  const parentPath = "/" + segments.slice(0, -1).join("/");
  const fullLayoutPath = `layout-${parentPath}`;
  // Remove any nodes that aren't active in this render
  toRemove = [];
  domNodeRegistry.forEach((node, nodeId) => {
    if (nodeId !== fullLayoutPath) {
      toRemove.push({ node, nodeId });
      domNodeRegistry.delete(nodeId);
      pureNodeRegistry.delete(nodeId);
    }
  });

  // 3) schedule each’s exit animation
  toRemove.forEach(({ node, nodeId }) => {
    const el = node.domNode;
    const exitClass = node.exitAnimationId;
    if (exitClass) {
      removeAnimatedNodeTree(el);
      console.log(toRemove.length);
      // listen → add class → on end remove
      const onEnd = (e) => {
        if (e.animationName === exitClass) {
          el.removeEventListener("animationend", onEnd);
          el.remove();
        }
      };
      el.addEventListener("animationend", onEnd);
      el.classList.add(exitClass);
    } else {
      // no animation, just yank it
      el.remove();
      // domNodeRegistry.delete(nodeId);
    }
  });
}

// Function to read a RenderCommand from memory
// Essentially we are just reading out a giant memory file and using alignment
// and ptr to access the data then we convert the values to readable js values
export function readRenderCommand(offset, layout) {
  // const size = wasmInstance.getRenderCommandSize(offset);
  const view = new DataView(
    wasmInstance.memory.buffer,
    offset,
    layoutInfo.renderCommandSize,
  );

  let css = "";
  let keyFrames = "";
  let styleId = "";
  let id = "";
  let btnId = 0;
  let hoverCss = "";
  let focusCss = "";
  let focusWithinCss = "";
  let tooltipCss = "";
  let tooltipTitle = "";
  let exitAnimationId = null;

  const elemType = view.getUint8(layoutInfo.elemTypeOffset);

  const nodePtr = view.getUint32(layoutInfo.nodePtrOffset, true);
  const isDirty = wasmInstance.getDirtyValue(nodePtr);

  // For text, you need to handle the string slice differently
  const textPtr = view.getUint32(layoutInfo.textPtrOffset, true);
  const textLen = view.getUint32(layoutInfo.textPtrOffset + 4, true);
  const text = textPtr ? readWasmString(textPtr, textLen) : "";

  const hrefPtr = view.getUint32(layoutInfo.hrefPtrOffset, true);
  const hrefLen = view.getUint32(layoutInfo.hrefPtrOffset + 4, true);
  const href = hrefPtr ? readWasmString(hrefPtr, hrefLen) : "";
  const styleHash = view.getUint8(layoutInfo.styleHashOffset, true);
  const propsHash = view.getUint8(layoutInfo.propsHashOffset, true);

  const idPtr = view.getUint32(layoutInfo.idPtrOffset, true);
  const idLen = view.getUint32(layoutInfo.idPtrOffset + 4, true);
  id = idPtr ? readWasmString(idPtr, idLen) : "";
  const index = view.getUint32(layoutInfo.indexOffset, true);
  let hooks = {};

  if (isDirty && (styleHash > 0 || propsHash > 0)) {
    hooks = {
      createdId: view.getUint32(layoutInfo.hooksOffset, true),
      mountedId: view.getUint32(layoutInfo.hooksOffset + 4, true),
      updatedId: view.getUint32(layoutInfo.hooksOffset + 8, true),
      destroyId: view.getUint32(layoutInfo.hooksOffset + 12, true),
    };

    // const dialogIdPtr = propsView.getUint32(layoutInfo.dialogIdPtrOffset, true);
    // const dialogIdLen = propsView.getUint32(layoutInfo.dialogIdLenOffset, true);
    // dialogId = dialogIdPtr ? readWasmString(dialogIdPtr, dialogIdLen) : "";

    const propsHoverOffset = offset + layoutInfo.hoverOffset;
    const propsHoverView = new DataView(
      wasmInstance.memory.buffer,
      propsHoverOffset, // propsOffset is relative to the start of RenderCommand
      layoutInfo.hoverSize,
    );
    // const hoverExists = propsHoverView.getUint8(0, true);
    // if (hoverExists > 0) {
    //   const cssHoverPtr = wasmInstance.getVisualStyle(nodePtr, 0);
    //   const cssHoverLen = wasmInstance.getVisualLen();
    //   hoverCss = readWasmString(cssHoverPtr, cssHoverLen);
    // }

    const propsFocusOffset = offset + layoutInfo.focusOffset;
    const propsFocusView = new DataView(
      wasmInstance.memory.buffer,
      propsFocusOffset, // propsOffset is relative to the start of RenderCommand
      layoutInfo.focusSize,
    );
    const focusExists = propsFocusView.getUint8(0, true);
    if (focusExists > 0) {
      const cssHoverPtr = wasmInstance.getVisualStyle(nodePtr, 1);
      const cssHoverLen = wasmInstance.getVisualLen();
      focusCss = readWasmString(cssHoverPtr, cssHoverLen);
    }

    const propsFocusWithinOffset = offset + layoutInfo.focusWithinOffset;
    const propsFocusWithinView = new DataView(
      wasmInstance.memory.buffer,
      propsFocusWithinOffset, // propsOffset is relative to the start of RenderCommand
      layoutInfo.focusWithinSize,
    );
    const focusWithinExists = propsFocusWithinView.getUint8(0, true);
    if (focusWithinExists > 0) {
      const cssHoverPtr = wasmInstance.getVisualStyle(nodePtr, 2);
      const cssHoverLen = wasmInstance.getVisualLen();
      focusWithinCss = readWasmString(cssHoverPtr, cssHoverLen);
    }

    const toolTipOffset = offset + layoutInfo.tooltipOffset;
    const toolTipView = new DataView(
      wasmInstance.memory.buffer,
      toolTipOffset, // propsOffset is relative to the start of RenderCommand
      layoutInfo.tooltipSize,
    );
    const toolTipExists = toolTipView.getUint32(0, true);
    if (toolTipExists > 0) {
      const toolTipTextLen = toolTipView.getUint32(4, true);
      tooltipTitle = readWasmString(toolTipExists, toolTipTextLen);
      const tooltip_stylePtr = wasmInstance.getTooltipStyle(nodePtr);
      if (tooltip_stylePtr !== 0) {
        const tooltip_styleLen = wasmInstance.getTooltipStyleLen();
        tooltipCss = readWasmString(tooltip_stylePtr, tooltip_styleLen);
      }
    }

    // const exitAnimPtr = propsView.getUint32(layoutInfo.propsExitAnimation, true);
    // if (exitAnimPtr) {
    //   const exitAnimLen = propsView.getUint32(
    //     layoutInfo.propsExitAnimationLength,
    //     true,
    //   );
    //   exitAnimationId = readWasmString(exitAnimPtr, exitAnimLen);
    // }

    // if (cssStylePtr !== 0) {
    // 1. Get the offset of the classname's POINTER from our new layout object.
    const classnamePtrOffset = layoutInfo.classnamePtrOffset;

    // 2. Read the actual pointer value from the RenderCommand struct.
    const classnamePtr = view.getUint32(classnamePtrOffset, true);

    // 3. If the pointer is not null, read the length and then the string.
    if (classnamePtr) {
      // The length is ALWAYS 4 bytes after the pointer for a slice.
      const classnameLen = view.getUint32(classnamePtrOffset + 4, true);

      const classname = readWasmString(classnamePtr, classnameLen);
      styleId = classname;
    }
    // }

    // if (wasmInstance.hasEctClasses(nodePtr)) {
    //   wasmInstance.addEctClasses(nodePtr);
    // }
  }

  const stateType = view.getUint32(layoutInfo.renderTypeOffset, true);

  const props = {
    css,
    hoverCss,
    focusCss,
    focusWithinCss,
    btnId,
    keyFrames,
    text,
    tooltipCss,
    tooltipTitle,
  };

  return {
    elemType,
    href,
    props,
    id,
    index,
    hooks,
    nodePtr,
    exitAnimationId,
    styleId,
    isDirty,
    stateType,
    styleHash,
    propsHash,
    // ... other fields
  };
}

export function readWasmString(ptr, len) {
  const bytes = new Uint8Array(wasmInstance.memory.buffer, ptr, len);
  return new TextDecoder().decode(bytes);
}

// Check if memory is growing over time
function getWasmMemoryUsage() {
  const memory = wasmInstance.memory;
  return memory.buffer.byteLength;
}
let lastMemorySize = 0;
function checkMemoryGrowth() {
  const currentSize = getWasmMemoryUsage();
  console.log(`Memory size: ${currentSize / 1024 / 1024} MB`);
  if (currentSize > lastMemorySize) {
    console.log(
      `Memory increased by ${(currentSize - lastMemorySize) / 1024} KB`,
    );
  }
  lastMemorySize = currentSize;
}

initWasi();
