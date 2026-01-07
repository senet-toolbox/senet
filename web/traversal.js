import {
  wasmInstance,
  readRenderCommand,
  readUINode,
  activeNodeIds,
  readWasmString,
  rerenderRoute,
  allocString,
  text_data,
  currentPath,
  render,
} from "./wasi_obj.js";
import {
  applyHoverClass,
  applyFocusClass,
  updateComponentStyle,
  applyFocusWithinClass,
  setRuleStyle,
  applyTooltipClass,
} from "./wasi_styling.js";
import {
  domNodeRegistry,
  eventHandlers,
  eventStorage,
  hooksCtxCreated,
  hooksDestroyCtx,
  hooksMounted,
  hooksMountedCtx,
  loadedSections,
  observeredSections,
  pureNodeRegistry,
} from "./maps.js";
import { state } from "./state.js";
import { DynamicStructReader } from "./wasi.js";

// Component type constants
export const COMPONENT_TYPES = {
  RECTANGLE: 0,
  TEXT: 1,
  IMAGE: 2,
  FLEXBOX: 3,
  TEXT_FIELD: 4,
  BUTTON: 5,
  BLOCK: 6,
  BOX: 7,
  HEADER: 8,
  SVG: 9,
  LINK: 10,
  EMBEDLINK: 11,
  LIST: 12,
  LISTITEM: 13,
  IF: 14,
  HOOKS: 15,
  LAYOUT: 16,
  PAGE: 17,
  BIND: 18,
  DIALOG: 19,
  DIALOG_SHOW: 20,
  DIALOG_CLOSE: 21,
  DRAGGABLE: 22,
  REDIRECT_LINK: 23,
  SELECT: 24,
  SELECT_ITEM: 25,
  BUTTON_CTX: 26,
  EMBEDICON: 27,
  ICON: 28,
  LABEL: 29,
  FORM: 30,
  ALLOC_TEXT: 31,
  TABLE: 32,
  TABLE_ROW: 33,
  TABLE_CELL: 34,
  TABLE_HEADER: 35,
  TABLE_BODY: 36,
  TEXT_AREA: 37,
  CANVAS: 38,
  SUBMIT_BUTTON: 39,
  HOOKS_CTX: 40,
  JSON_EDITOR: 41,
  HTML_TEXT: 42,
  CODE: 43,
  SPAN: 44,
  LAZY_IMAGE: 45,
  INTERSECTION: 46,
  PRE_IMAGE: 47,
  TEXT_GRADIENT: 48,
  GRADIENT: 49,
  VIRTUALIZE: 50,
  BUTTON_CYCLE: 51,
  GRAPHIC: 52,
  HEADING: 53,
  VIDEO: 54,
  NOOP: 55,
  TABLE_HEAD: 56,
  ANCHOR: 57,
};

const STATE_TYPES = {
  STATIC: 0,
  PURE: 1,
  DYNAMIC: 2,
  GRAIN: 3,
};

// Store intervals by route for cleanup
const routeIntervals = new Map();

/**
 * Clear all intervals for a specific route
 * @param {string} path - The route path to clear intervals for
 */
export function clearIntervalsForRoute(path) {
  if (routeIntervals.has(path)) {
    routeIntervals.get(path).forEach((intervalId) => {
      clearInterval(intervalId);
    });
    routeIntervals.delete(path);
  }
}

/**
 * Process input elements based on their type
 * @param {HTMLElement} element - The input element
 * @param {Object} renderCmd - The render command
 */
function processInputElement(element, renderCmd) {
  const idPtr = allocString(renderCmd.id);
  const elementPtr = wasmInstance.getElementPtr(idPtr);
  if (elementPtr === 0) return;
  // const elementView = new DataView(
  //   wasmInstance.memory.buffer,
  //   elementPtr,
  //   elementSize,
  // );

  // const onBlur = wasmInstance.getOnBlurCallback(elementPtr) >>> 0;
  // if (onBlur > 0) {
  //   requestAnimationFrame(() => {
  //     eventHandlers.set(`fb-evt-hd-${onBlur}-${renderCmd.id}`, (event) => {
  //       eventStorage[onBlur] = event;
  //       wasmInstance.eventCallback(onBlur);
  //     });
  //     element.addEventListener("focusout", (event) => {
  //       eventHandlers.get(`fb-evt-hd-${onBlur}-${renderCmd.id}`)(event);
  //     });
  //   });
  // }

  let onChange = wasmInstance.getOnChangeCallback(elementPtr) >>> 0;
  if (onChange > 0) {
    // element.addEventListener("input", async (event) => {
    //   event.preventDefault();
    //   event.stopPropagation();
    // });
    requestAnimationFrame(() => {
      eventHandlers.set(`fb-evt-hd-${onChange}-${renderCmd.id}`, (event) => {
        eventStorage[onChange] = event;
        wasmInstance.eventCallback(onChange);
      });
      element.addEventListener("input", (event) => {
        const idPtr = allocString(renderCmd.id);
        wasmInstance.inputCallback(idPtr);
        eventHandlers.get(`fb-evt-hd-${onChange}-${renderCmd.id}`)(event);
      });
    });
  } else {
    element.addEventListener("input", async (event) => {
      event.preventDefault();
      const idPtr = allocString(renderCmd.id);
      wasmInstance.inputCallback(idPtr);
    });
  }

  // const onFocus = wasmInstance.getOnChangeCallback(elementPtr) >>> 0;
  // if (onFocus > 0) {
  //   requestAnimationFrame(() => {
  //     eventHandlers.set(`fb-evt-hd-${onFocus}-${renderCmd.id}`, (event) => {
  //       eventStorage[onFocus] = event;
  //       wasmInstance.eventCallback(onFocus);
  //     });
  //     element.addEventListener("focus", (event) => {
  //       eventHandlers.get(`fb-evt-hd-${onFocus}-${renderCmd.id}`)(event);
  //     });
  //   });
  // }

  // element.addEventListener("input", async (event) => {
  //   // if (renderCmd.id === "swap-wasm") {
  //   //   await hotSwapWasmWithState("/zig-out/bin/fabric.wasm");
  //   // } else {
  //   event.preventDefault();
  //   event.stopPropagation();
  //   const idPtr = allocString(renderCmd.id);
  //   wasmInstance.inputCallback(idPtr);
  //   // }
  // });

  // const type = wasmInstance.getInputType(nodePtr);
  // const inputPtr = wasmInstance.createInput(nodePtr);
  // const inputSize = wasmInstance.getInputSize(nodePtr);
  // const inputCallback = wasmInstance.getOnInputCallback(nodePtr);
  // const inputView = new DataView(
  //   wasmInstance.memory.buffer,
  //   inputPtr,
  //   inputSize,
  // );
  //
  // let offset = 0;
  // offset += 8; // Skip initial bytes
  //
  // // Process name attribute
  // const namePtr = inputView.getUint32(offset, true);
  // offset += 4;
  // if (namePtr) {
  //   const nameLen = inputView.getUint32(offset, true);
  //   const name = readWasmString(namePtr, nameLen);
  //   element.name = name;
  // }
  // offset += 8;
  //
  // // Process type-specific attributes
  // if (type === 0) {
  //   // Number input
  //   const placeholder = inputView.getUint32(offset, true);
  //   if (placeholder) {
  //     element.placeholder = placeholder;
  //   }
  //   offset += 8;
  //   const value = inputView.getUint32(offset, true);
  //   if (value) {
  //     element.value = value;
  //   }
  //   element.type = "number";
  // } else if (type === 2) {
  //   // Text input
  //   const placeholderPtr = inputView.getUint32(offset, true);
  //   offset += 4;
  //   if (placeholderPtr) {
  //     const placeholderLen = inputView.getUint32(offset, true);
  //     const placeholder = readWasmString(placeholderPtr, placeholderLen);
  //     element.placeholder = placeholder;
  //   }
  //   offset += 8;
  //   const valuePtr = inputView.getUint32(offset, true);
  //   offset += 4;
  //   if (valuePtr) {
  //     const valueLen = inputView.getUint32(offset, true);
  //     const value = readWasmString(valuePtr, valueLen);
  //     element.value = value;
  //   }
  //   offset += 8;
  //   const minLen = inputView.getUint32(offset, true);
  //   if (minLen) {
  //     element.ariaValueMin = minLen;
  //     element.minLength = minLen;
  //   }
  //   offset += 8;
  //   const maxLen = inputView.getUint32(offset, true);
  //   if (maxLen) {
  //     element.ariaValueMin = maxLen;
  //     element.maxLength = maxLen;
  //   }
  //
  //   element.type = "text";
  // } else if (type === 4) {
  //   // Radio input
  //   const valuePtr = inputView.getUint32(offset, true);
  //   offset += 4;
  //   if (valuePtr) {
  //     const valueLen = inputView.getUint32(offset, true);
  //     const value = readWasmString(valuePtr, valueLen);
  //     element.value = value;
  //   }
  //   element.type = "radio";
  //
  //   // Apply checkmark styling if available
  //   const cssCheckMarkPtr = wasmInstance.getCheckMarkStylePtr(nodePtr);
  //   if (cssCheckMarkPtr > 0) {
  //     const cssCheckMarkLen = wasmInstance.getCheckMarkLen();
  //     const checkMarkCss = readWasmString(cssCheckMarkPtr, cssCheckMarkLen);
  //     if (checkMarkCss.length > 0) {
  //       checkMarkStyling(
  //         renderCmd.id,
  //         element,
  //         renderCmd.styleId,
  //         checkMarkCss,
  //       );
  //     }
  //   }
  // } else if (type === 5) {
  //   console.log("Password");
  //   // Text input
  //   const placeholderPtr = inputView.getUint32(offset, true);
  //   offset += 4;
  //   if (placeholderPtr) {
  //     const placeholderLen = inputView.getUint32(offset, true);
  //     const placeholder = readWasmString(placeholderPtr, placeholderLen);
  //     element.placeholder = placeholder;
  //   }
  //   offset += 8;
  //   const valuePtr = inputView.getUint32(offset, true);
  //   offset += 4;
  //   if (valuePtr) {
  //     const valueLen = inputView.getUint32(offset, true);
  //     const value = readWasmString(valuePtr, valueLen);
  //     element.value = value;
  //   }
  //   offset += 8;
  //   const minLen = inputView.getUint32(offset, true);
  //   if (minLen) {
  //     element.ariaValueMin = minLen;
  //     element.minLength = minLen;
  //   }
  //   offset += 8;
  //   const maxLen = inputView.getUint32(offset, true);
  //   if (maxLen) {
  //     element.ariaValueMin = maxLen;
  //     element.maxLength = maxLen;
  //     console.log(maxLen);
  //   }
  //   element.type = "password";
  // } else if (type === 6) {
  //   console.log("Email");
  //   // Text input
  //   const placeholderPtr = inputView.getUint32(offset, true);
  //   offset += 4;
  //   if (placeholderPtr) {
  //     const placeholderLen = inputView.getUint32(offset, true);
  //     const placeholder = readWasmString(placeholderPtr, placeholderLen);
  //     element.placeholder = placeholder;
  //   }
  //   offset += 8;
  //   const valuePtr = inputView.getUint32(offset, true);
  //   offset += 4;
  //   if (valuePtr) {
  //     const valueLen = inputView.getUint32(offset, true);
  //     const value = readWasmString(valuePtr, valueLen);
  //     element.value = value;
  //   }
  //   offset += 8;
  //   const minLen = inputView.getUint32(offset, true);
  //   if (minLen) {
  //     element.ariaValueMin = minLen;
  //     element.minLength = minLen;
  //   }
  //   offset += 8;
  //   const maxLen = inputView.getUint32(offset, true);
  //   if (maxLen) {
  //     element.ariaValueMin = maxLen;
  //     element.maxLength = maxLen;
  //     console.log(maxLen);
  //   }
  //   element.type = "email";
  // } else if (type === 7) {
  //   element.type = "file";
  // }
  // if (inputCallback) {
  // requestAnimationFrame(() => {
  //   eventHandlers.set(`fb-evt-hd-${inputCallback}-${renderCmd.id}`, (event) => {
  //     eventStorage[inputCallback] = event;
  //     // console.log(event, event.srcElement);
  //     wasmInstance.eventCallback(inputCallback);
  //   });
  //   element.addEventListener(
  //     "input",
  //     eventHandlers.get(`fb-evt-hd-${inputCallback}-${renderCmd.id}`),
  //   );
  // });
  // }
}

export async function animateExitRecursive(el, index, toRemoveMap) {
  if (!el) return;
  el.dataset.removing = "true";

  // First, recursively handle children that are in the removal set
  const childRemovals = [];
  for (const [id, { el: childEl, index: childIndex }] of toRemoveMap) {
    if (
      childEl !== el &&
      el.contains(childEl) &&
      childEl.parentElement?.closest(`[data-removing="true"]`) === el
    ) {
      // Direct child in removal set
      childRemovals.push(
        animateExitRecursive(childEl, childIndex, toRemoveMap),
      );
    }
  }
  await Promise.all(childRemovals);

  // Now animate this element
  const animPtr = wasmInstance.getRemovalAnimationPtr(index);
  if (animPtr > 0) {
    const animLen = wasmInstance.getRemovalAnimationLen(index);
    const css = readWasmString(animPtr, animLen);
    if (css) {
      el.style.animation = css;
      void el.offsetWidth;
      await new Promise((resolve) => {
        el.addEventListener("animationend", () => resolve(), { once: true });
      });
    }
  }

  // Cleanup
  domNodeRegistry.delete(el.id);
  pureNodeRegistry.delete(el.id);
  loadedSections.delete(el.id);
  const eventData = eventHandlers.get(el.id);
  if (eventData) {
    for (const [eventType, handler] of Object.entries(eventData)) {
      el.removeEventListener(eventType, handler);
    }
    eventHandlers.delete(el.id);
  }
  el.remove();
}

export async function animateExit(el, index = -1, skipAnimation = false) {
  if (!el) return;

  el.dataset.removing = "true";

  let shouldAnimate = !skipAnimation;

  if (shouldAnimate && index > -1) {
    const animPtr = wasmInstance.getRemovalAnimationPtr(index);

    if (animPtr > 0) {
      const animLen = wasmInstance.getRemovalAnimationLen(index);
      const css = readWasmString(animPtr, animLen);

      if (css) {
        // DEBUG: Check if element is still in DOM
        el.style.animation = css;

        // Force reflow
        void el.offsetWidth;

        // DEBUG: Check computed style
        await new Promise((resolve) => {
          el.addEventListener(
            "animationend",
            () => {
              resolve();
            },
            { once: true },
          );
        });
      }
    }
  }

  // Cleanup children (skip their animations)
  for (const child of Array.from(el.children)) {
    await animateExit(child, 0, true);
  }

  // Cleanup registries
  domNodeRegistry.delete(el.id);
  pureNodeRegistry.delete(el.id);
  loadedSections.delete(el.id);

  const eventData = eventHandlers.get(el.id);
  if (eventData) {
    for (const [eventType, handler] of Object.entries(eventData)) {
      el.removeEventListener(eventType, handler);
    }
    eventHandlers.delete(el.id);
  }
  el.remove();
}

export async function recurseDestroy(el, skipAnimation = false) {
  if (!el) return;

  el.dataset.removing = "true";
  const domNode = domNodeRegistry.get(el.id);
  const nodePtr = domNode?.node_ptr;

  let shouldAnimate = !skipAnimation;

  if (shouldAnimate && nodePtr) {
    const exitAnimationPtr = wasmInstance.getExitAnimationStyle(nodePtr);

    if (exitAnimationPtr > 0) {
      const exitAnimationLen = wasmInstance.getAnimationLen();
      const exitAnimationCss = readWasmString(
        exitAnimationPtr,
        exitAnimationLen,
      );

      if (exitAnimationCss) {
        // DEBUG: Check if element is still in DOM
        el.style.animation = exitAnimationCss;

        // Force reflow
        void el.offsetWidth;

        // DEBUG: Check computed style
        await new Promise((resolve) => {
          el.addEventListener(
            "animationend",
            () => {
              resolve();
            },
            { once: true },
          );
        });
      }
    }
  }

  // Cleanup children (skip their animations)
  for (const child of Array.from(el.children)) {
    await recurseDestroy(child, true);
  }

  // Cleanup registries
  domNodeRegistry.delete(el.id);
  pureNodeRegistry.delete(el.id);
  loadedSections.delete(el.id);

  const eventData = eventHandlers.get(el.id);
  if (eventData) {
    for (const [eventType, handler] of Object.entries(eventData)) {
      el.removeEventListener(eventType, handler);
    }
    eventHandlers.delete(el.id);
  }

  el.remove();
}

/**
 * Create a link element with route handling
 * @param {Object} renderCmd - The render command
 * @param {HTMLElement} tree_node - The current tree node
 * @param {Object} layout - The layout information
 * @returns {HTMLAnchorElement} - The created link element
 */
function createLinkElement(element, uinode) {
  let href =
    uinode.hrefLen > 0 ? readWasmString(uinode.hrefPtr, uinode.hrefLen) : "";
  if (href === null) {
    element.href = href;
  } else {
    element.href = href;
  }

  const label = wasmInstance.getAriaLabel(uinode.offset);
  if (label) {
    const length = wasmInstance.getAriaLabelLen();
    element.ariaLabel = readWasmString(label, length);
  }

  element.addEventListener("click", function(event) {
    event.preventDefault();

    const clickedHref = event.currentTarget.href;

    const urlObj = new URL(clickedHref);
    const path = urlObj.pathname;
    const currentPath = window.location.pathname;
    window.history.pushState({}, "", path);
    // we push the state and renderCycle the new path
    requestAnimationFrame(() => {
      if (currentPath !== path) {
        rerenderRoute(path);
      }
      requestAnimationFrame(() => {
        const hash = urlObj.hash;
        if (hash) {
          const id = hash.substring(1, hash.length);
          const element = document.getElementById(id);
          if (element) {
            // Scroll the element into view with options
            element.scrollIntoView({
              block: "center", // Vertically align to the center of the screen
            });
          }
          window.history.pushState({}, "", path + hash);
        }
      });
    });
  });

  return element;
}

function initJsonEditor(parent, element) {
  element.style.caretColor = "black";
  // ——— Setup status/log pane ———
  const status = document.createElement("div");
  status.className = "json-editor-status";
  Object.assign(status.style, {
    fontFamily: "monospace",
    fontSize: "0.9em",
    marginTop: "12px",
    maxHeight: "160px",
    minHeight: "60px",
    width: "100%",
    overflowY: "auto",
    padding: "8px",
    border: "1px solid #27272a",
    borderRadius: "8px",
    boxSizing: "border-box",
  });
  parent.parentNode.insertBefore(status, element.nextSibling);

  function log(msg, isError = false) {
    // console[isError ? "error" : "log"](msg);
    const p = document.createElement("div");
    p.textContent = msg;
    p.style.color = isError ? "#FF3838" : "#555";
    status.appendChild(p);
    status.scrollTop = status.scrollHeight;
  }

  function clearStatus() {
    status.textContent = "";
  }

  function showError(err) {
    clearStatus();
    const msg = err.message || err;
    const m = msg.match(/position (\d+)/);
    let info = msg;
    if (m) {
      const pos = +m[1];
      const before = element.value.slice(0, pos);
      const line = before.split("\n").length;
      const col = pos - (before.lastIndexOf("\n") + 1);
      info = `Line ${line}, Col ${col}: ${msg}`;
      element.setSelectionRange(pos, pos);
    }
    log(`❌ ${info}`, true);
    element.style.borderColor = "#FF3838";
  }

  // ——— New: detect duplicate keys at the same depth ———
  function detectDuplicateKeys(str) {
    const duplicates = [];
    const seen = Object.create(null); // { depth: { key: true } }
    let depth = 0;
    for (let i = 0; i < str.length; i++) {
      const ch = str[i];
      if (ch === "{") {
        depth++;
      } else if (ch === "}") {
        // clear seen for this depth when exiting object
        delete seen[depth];
        depth = Math.max(depth - 1, 0);
      } else if (ch === '"') {
        // read string literal
        let j = i + 1,
          esc = false,
          key = "";
        while (j < str.length) {
          const c = str[j];
          if (!esc && c === "\\") {
            esc = true;
            j++;
          } else if (!esc && c === '"') {
            break;
          } else {
            key += c;
            esc = false;
            j++;
          }
        }
        if (str[j] === '"') {
          // check for colon after it
          const rest = str.slice(j + 1);
          if (/^\s*:/.test(rest)) {
            seen[depth] = seen[depth] || Object.create(null);
            if (seen[depth][key]) {
              duplicates.push({ key, position: i });
            } else {
              seen[depth][key] = true;
            }
          }
          i = j;
        }
      }
    }
    return duplicates;
  }

  // ——— Pretty-print on Ctrl+S, with duplicate-check ———
  function formatJSON() {
    clearStatus();
    const dups = detectDuplicateKeys(element.value);
    if (dups.length) {
      const keys = [...new Set(dups.map((d) => d.key))].join(", ");
      showError(new Error(`Duplicate keys found: ${keys}`));
      return;
    }
    try {
      const obj = JSON.parse(element.value);
      element.value = JSON.stringify(obj, null, 2) + "\n";
      element.style.borderColor = "";
      log("✅ JSON formatted");
      element.dispatchEvent(new Event("input", { bubbles: true }));
    } catch (err) {
      showError(err);
    }
  }

  // ——— Wrap helpers ———
  function wrapSelection(open, close = open) {
    const { selectionStart: s, selectionEnd: e, value: v } = element;
    element.value = v.slice(0, s) + open + v.slice(s, e) + close + v.slice(e);
    element.setSelectionRange(s + 1, e + 1);
    element.focus();
    log(`Wrapped selection with "${open}${close}"`);
  }

  // ——— Debounced live validation + duplicate-check ———
  let tid;
  element.addEventListener("input", () => {
    clearTimeout(tid);
    tid = setTimeout(() => {
      try {
        const dups = detectDuplicateKeys(element.value);
        if (dups.length) {
          const keys = [...new Set(dups.map((d) => d.key))].join(", ");
          throw new Error(`Duplicate keys found: ${keys}`);
        }
        JSON.parse(element.value);
        element.style.borderColor = "";
        clearStatus();
      } catch (err) {
        showError(err);
      }
    }, 300);
  });

  // ——— Key handling ———
  const pairs = { "{": "}", "[": "]", '"': '"' };
  element.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      const { selectionStart: s, selectionEnd: e0, value: v } = element;
      const lineStart = v.lastIndexOf("\n", s - 1) + 1;
      const prefix = v.slice(lineStart, s).match(/^[ \t]*/)[0];
      const insert = "\n" + prefix;
      element.value = v.slice(0, s) + insert + v.slice(e0);
      const pos = s + insert.length;
      element.setSelectionRange(pos, pos);
      log("↵ Auto-indented");
      element.dispatchEvent(new Event("input", { bubbles: true }));
    } else if (e.key === "Tab") {
      e.preventDefault();
      const { selectionStart: s, selectionEnd: e0, value: v } = element;
      const tab = "  ";
      element.value = v.slice(0, s) + tab + v.slice(e0);
      element.setSelectionRange(s + tab.length, s + tab.length);
      log("⇥ Inserted tab");
      element.dispatchEvent(new Event("input", { bubbles: true }));
    } else if (pairs[e.key] && !e.ctrlKey && !e.metaKey) {
      e.preventDefault();
      const { selectionStart: s, selectionEnd: e0, value: v } = element;
      const open = e.key,
        close = pairs[open];
      element.value = v.slice(0, s) + open + close + v.slice(e0);
      element.setSelectionRange(s + 1, s + 1);
      log(`Auto-paired "${open}${close}"`);
      element.dispatchEvent(new Event("input", { bubbles: true }));
    } else if ((e.key === "}" || e.key === "]") && !e.ctrlKey) {
      // e.preventDefault();
      // smartOutdent(e.key);
    } else if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "s") {
      e.preventDefault();
      formatJSON();
    } else if ((e.ctrlKey || e.metaKey) && e.key === "'") {
      e.preventDefault();
      wrapSelection('"');
    } else if (e.ctrlKey && e.shiftKey && e.key === "{") {
      e.preventDefault();
      wrapSelection("{", "}");
    } else if (e.ctrlKey && e.shiftKey && e.key === "[") {
      e.preventDefault();
      wrapSelection("[", "]");
    }
  });

  // ——— Paste → pretty-format if valid ———
  element.addEventListener("paste", (e) => {
    e.preventDefault();
    const paste = (e.clipboardData || window.clipboardData).getData("text");
    try {
      const obj = JSON.parse(paste);
      const pretty = JSON.stringify(obj, null, 2) + "\n";
      const { selectionStart: s, selectionEnd: e0, value: v } = element;
      element.value = v.slice(0, s) + pretty + v.slice(e0);
      const pos = s + pretty.length;
      element.setSelectionRange(pos, pos);
      log("📋 Pasted & formatted JSON");
      element.dispatchEvent(new Event("input", { bubbles: true }));
    } catch {
      document.execCommand("insertText", false, paste);
      log("📋 Pasted raw text");
    }
  });
}

function getTextData(route, id) {
  if (text_data !== undefined) {
    if (text_data[route] === undefined) {
      return null;
    }
    return text_data[route][id];
  }
  return null;
}

/**
 * Create an element based on its type
 * @param {Object} uinode - The render command
 * @returns {HTMLElement} - The created element
 */
export function attachElementListeners(element, renderCmd) {
  switch (renderCmd.elemType) {
    case COMPONENT_TYPES.GRAPHIC:
      const href = readWasmString(renderCmd.hrefPtr, renderCmd.hrefLen);
      fetch(href)
        .then((res) => res.text())
        .then((text) => {
          element.innerHTML = text.replace(/^\s+|\s+$/g, "");
        })
        .catch((err) => {
          // console.error("Fetch failed:", err);
        });
      break;

    case COMPONENT_TYPES.BUTTON:
    case COMPONENT_TYPES.BUTTON_CYCLE:
      const label = wasmInstance.getAriaLabel(renderCmd.nodePtr);
      if (label) {
        const length = wasmInstance.getAriaLabelLen();
        element.ariaLabel = readWasmString(label, length);
      }
      element.addEventListener("click", async (event) => {
        state.currentDepthNode = renderCmd.id;
        event.preventDefault();
        event.stopPropagation();
        const idPtr = allocString(renderCmd.id);
        if (renderCmd.elemType === COMPONENT_TYPES.BUTTON_CYCLE) {
          wasmInstance.buttonCycleCallback(idPtr);
        } else {
          wasmInstance.buttonCallback(idPtr);
        }
      });
      break;

    case COMPONENT_TYPES.BUTTON_CTX:
      element.type = "button";
      element.addEventListener("click", (event) => {
        console.log("Button CTX", event);
        // event.preventDefault();
        // event.stopPropagation();
        const idPtr = allocString(renderCmd.id);
        wasmInstance.ctxButtonCallback(idPtr);
      });
      break;

    case COMPONENT_TYPES.LINK:
      element = createLinkElement(element, renderCmd);
      break;

    case COMPONENT_TYPES.VIDEO:
      console.log("Video");
      const offset = wasmInstance.getVideo(renderCmd.nodePtr);
      console.log("Offset", offset);
      if (offset === 0) break; // Use break, not return
      const videoView = new DataView(wasmInstance.memory.buffer, offset);
      const srcPtr = videoView.getUint32(0, true);
      if (srcPtr) {
        const srcLen = videoView.getUint32(4, true);
        element.src = readWasmString(srcPtr, srcLen);
      }
      element.autoplay = videoView.getUint8(8) === 1;
      break;

    default:
      break;
  }
}

/**
 * Create an element based on its type
 * @param {Object} renderCmd - The render command
 * @returns {HTMLElement} - The created element
 */
export function createElementByType(uinode) {
  let element;
  let text;
  let label;
  let route = currentPath === "/" ? "/root" : `/root${currentPath}`;

  switch (uinode.elemType) {
    case COMPONENT_TYPES.TEXT:
      element = document.createElement("p");
      text = readWasmString(uinode.textPtr, uinode.textLen);
      element.textContent = text;
      break;

    case COMPONENT_TYPES.TEXT_GRADIENT:
      element = document.createElement("p");
      element.style.background =
        "-webkit-linear-gradient(45deg, #E04F67, #C72C4A, #4800FF)";
      element.style["-webkit-background-clip"] = "text";
      element.style["-webkit-text-fill-color"] = "transparent";
      element.textContent = uinode.text;
      break;

    case COMPONENT_TYPES.TEXT_AREA:
      const textareaPtr = wasmInstance.getTextFieldParams(uinode.offset) >>> 0;
      element = document.createElement("textarea");
      // element.lang = "json";
      if (textareaPtr) {
        const fieldCount = wasmInstance.getTextFieldCount(uinode.offset);
        const reader = new DynamicStructReader(
          wasmInstance,
          wasmInstance.memory,
        );
        const fieldStruct = reader.readStruct(
          uinode.offset,
          textareaPtr,
          fieldCount,
          "getTextFieldDescriptor",
        );
        console.log(fieldStruct);
        element.value =
          fieldStruct.value !== null
            ? String(fieldStruct.value)
            : fieldStruct.default !== null
              ? String(fieldStruct.default)
              : "";
      }
      break;

    case COMPONENT_TYPES.HTML_TEXT:
      element = document.createElement("p");
      text =
        getTextData(route, uinode.id) ??
        readWasmString(uinode.textPtr, uinode.textLen);
      element.innerHTML = text;
      break;

    case COMPONENT_TYPES.CODE:
      element = document.createElement("code");
      text = readWasmString(uinode.textPtr, uinode.textLen);
      element.textContent = text;
      break;

    case COMPONENT_TYPES.SPAN:
      element = document.createElement("span");
      text = readWasmString(uinode.textPtr, uinode.textLen);
      element.innerText = text;
      break;

    case COMPONENT_TYPES.JSON_EDITOR:
      element = document.createElement("textarea");
      text = readWasmString(uinode.textPtr, uinode.textLen);
      element.textContent = text;
      break;

    case COMPONENT_TYPES.ALLOC_TEXT:
      element = document.createElement("p");
      text = readWasmString(uinode.textPtr, uinode.textLen);
      element.textContent = text;
      break;

    case COMPONENT_TYPES.IMAGE:
      element = document.createElement("img");
      const alt = wasmInstance.getAlt(uinode.offset);
      if (alt >>> 0) {
        const length = wasmInstance.getAltLen();
        const altText = readWasmString(alt, length);
        element.setAttribute("alt", altText);
      }
      const src = readWasmString(uinode.hrefPtr, uinode.hrefLen);
      console.log("Image", src);
      element.setAttribute("src", src);
      break;

    case COMPONENT_TYPES.LAZY_IMAGE:
      element = document.createElement("img");
      element.src = readWasmString(uinode.hrefPtr, uinode.hrefLen);
      element.loading = "lazy";
      break;

    case COMPONENT_TYPES.PRE_IMAGE:
      element = document.createElement("img");
      element.src = readWasmString(uinode.hrefPtr, uinode.hrefLen);
      element.setAttribute("fetchpriority", "high");
      break;

    case COMPONENT_TYPES.INTERSECTION:
      element = document.createElement("section");
      break;

    case COMPONENT_TYPES.FLEXBOX:
    case COMPONENT_TYPES.BOX:
    case COMPONENT_TYPES.BLOCK:
    case COMPONENT_TYPES.DRAGGABLE:
    case COMPONENT_TYPES.GRADIENT:
    case COMPONENT_TYPES.GRAPHIC:
      element = document.createElement("div");
      if (uinode.elemType === COMPONENT_TYPES.GRADIENT) {
        element.style.background =
          "-webkit-linear-gradient(45deg, #8886f2, #e04597, #ee6994)";
      } else if (uinode.elemType === COMPONENT_TYPES.GRAPHIC) {
        const href = readWasmString(uinode.hrefPtr, uinode.hrefLen);
        fetch(href)
          .then((res) => res.text())
          .then((text) => {
            element.innerHTML = text.replace(/^\s+|\s+$/g, "");
          })
          .catch((err) => {
            // console.error("Fetch failed:", err);
          });
      }
      break;
    case COMPONENT_TYPES.ANCHOR:
      element = document.createElement("div");
      break;

    case COMPONENT_TYPES.TEXT_FIELD:
      element = document.createElement("input");
      text = readWasmString(uinode.textPtr, uinode.textLen);
      const field_ptr = wasmInstance.getFieldName(uinode.offset) >>> 0;
      if (field_ptr) {
        const field_len = wasmInstance.getFieldNameLen();
        const field = readWasmString(field_ptr, field_len);
        element.name = field;
      }
      const instansePtr = wasmInstance.getTextFieldParams(uinode.offset);
      if (instansePtr) {
        const fieldCount = wasmInstance.getTextFieldCount(uinode.offset);
        const reader = new DynamicStructReader(
          wasmInstance,
          wasmInstance.memory,
        );
        const fieldStruct = reader.readStruct(
          uinode.offset,
          instansePtr,
          fieldCount,
          "getTextFieldDescriptor",
        );
        element.placeholder =
          fieldStruct.default !== null ? String(fieldStruct.default) : "";
        element.value =
          fieldStruct.value !== null ? String(fieldStruct.value) : "";

        switch (fieldStruct.type) {
          case 0:
            element.type = "number";
            break;
          case 1:
            element.type = "number";
            break;
          case 2:
            element.type = "text";
            break;
          case 3:
            element.type = "checkbox";
            break;
          case 4:
            element.type = "radio";
            break;
          case 5:
            element.type = "password";
            break;
          case 6:
            element.type = "email";
            break;
          case 7:
            element.type = "file";
            break;
          case 8:
            element.type = "tel";
            break;
        }
        if (element.type !== "number") {
          if (fieldStruct.max_len) {
            element.maxLength = fieldStruct.max_len;
          }
          if (fieldStruct.min_len) {
            element.minLength = fieldStruct.min_len;
          }
        } else {
          element.max = fieldStruct.max_len;
          element.min = fieldStruct.min_len;
        }
      }
      break;

    case COMPONENT_TYPES.BUTTON:
    case COMPONENT_TYPES.BUTTON_CYCLE:
      element = document.createElement("button");
      element.type = "button";
      label = wasmInstance.getAriaLabel(uinode.offset);
      if (label) {
        const length = wasmInstance.getAriaLabelLen();
        element.ariaLabel = readWasmString(label, length);
      }
      // element.addEventListener("click", async (event) => {
      //   state.currentDepthNode = uinode.id;
      //   event.preventDefault();
      //   event.stopPropagation();
      //   const idPtr = allocString(uinode.id);
      //   if (uinode.elemType === COMPONENT_TYPES.BUTTON_CYCLE) {
      //     wasmInstance.buttonCycleCallback(idPtr);
      //   } else {
      //     wasmInstance.buttonCallback(idPtr);
      //   }
      // });
      break;

    case COMPONENT_TYPES.BUTTON_CTX:
      element = document.createElement("button");
      element.type = "button";
      label = wasmInstance.getAriaLabel(uinode.offset);
      if (label) {
        const length = wasmInstance.getAriaLabelLen();
        element.ariaLabel = readWasmString(label, length);
      }
      // element.addEventListener("click", (event) => {
      //   event.preventDefault();
      //   event.stopPropagation();
      //   const idPtr = allocString(uinode.id);
      //   wasmInstance.ctxButtonCallback(idPtr);
      // });
      break;

    case COMPONENT_TYPES.SUBMIT_BUTTON:
      element = document.createElement("button");
      element.type = "submit";
      break;

    case COMPONENT_TYPES.HEADER:
      element = document.createElement("h1"); // Will be replaced by HEADING
      text = readWasmString(uinode.textPtr, uinode.textLen);
      element.textContent = text;
      break;

    case COMPONENT_TYPES.SVG:
      const svgString =
        getTextData(route, uinode.id) ??
        readWasmString(uinode.textPtr, uinode.textLen);
      const cleanSvg = svgString.replace(/^\s+|\s+$/g, "");
      const parser = new DOMParser();
      const doc = parser.parseFromString(cleanSvg, "image/svg+xml");
      element = doc.documentElement;
      break;

    case COMPONENT_TYPES.LINK:
      element = document.createElement("a");
      element = createLinkElement(element, uinode);
      break;

    case COMPONENT_TYPES.REDIRECT_LINK:
      element = document.createElement("a");
      const aria_label = wasmInstance.getAriaLabel(uinode.offset);
      if (aria_label) {
        const length = wasmInstance.getAriaLabelLen();
        element.ariaLabel = readWasmString(aria_label, length);
      }

      element.href =
        uinode.hrefLen > 0
          ? readWasmString(uinode.hrefPtr, uinode.hrefLen)
          : "";
      break;

    case COMPONENT_TYPES.EMBEDLINK:
    case COMPONENT_TYPES.EMBEDICON:
      element = document.createElement("link");
      element.rel =
        uinode.elemType === COMPONENT_TYPES.EMBEDLINK ? "stylesheet" : "icon";
      element.crossorigin = "anonymous";
      element.href = readWasmString(uinode.hrefPtr, uinode.hrefLen);
      break;

    case COMPONENT_TYPES.ICON:
      element = document.createElement("i");
      break;

    case COMPONENT_TYPES.LIST:
      element = document.createElement("ul");
      break;

    case COMPONENT_TYPES.LISTITEM:
      element = document.createElement("li");
      break;

    case COMPONENT_TYPES.SELECT:
      element = document.createElement("select");
      break;

    case COMPONENT_TYPES.SELECT_ITEM:
      element = document.createElement("option");
      break;

    case COMPONENT_TYPES.LABEL:
      element = document.createElement("label");
      // element.htmlFor = readWasmString(
      //   uinode.hrefPtr,
      //   uinode.hrefLen,
      // );
      text = readWasmString(uinode.textPtr, uinode.textLen);
      element.textContent = text;
      break;

    case COMPONENT_TYPES.FORM:
      element = document.createElement("form");
      element.action = "";
      break;

    case COMPONENT_TYPES.TABLE:
      element = document.createElement("table");
      break;

    case COMPONENT_TYPES.TABLE_ROW:
      element = document.createElement("tr");
      break;

    case COMPONENT_TYPES.TABLE_CELL:
      element = document.createElement("td");
      break;

    case COMPONENT_TYPES.TABLE_HEADER:
      element = document.createElement("thead");
      break;

    case COMPONENT_TYPES.TABLE_BODY:
      element = document.createElement("tbody");
      break;

    case COMPONENT_TYPES.TABLE_HEAD:
      element = document.createElement("th");
      break;

    case COMPONENT_TYPES.CANVAS:
      element = document.createElement("canvas");
      break;

    case COMPONENT_TYPES.HEADING:
      const level = wasmInstance.getHeadingLevel(uinode.offset); // Use template literal to create h1-h6, defaulting to h1
      element = document.createElement(
        `h${level > 0 && level < 7 ? level : 1}`,
      );
      text = readWasmString(uinode.textPtr, uinode.textLen);
      element.textContent = text;
      break;

    case COMPONENT_TYPES.VIDEO:
      console.log("Video");
      element = document.createElement("video");
      const offset = wasmInstance.getVideo(uinode.offset);
      console.log("Offset", offset);
      if (offset === 0) break; // Use break, not return
      const videoView = new DataView(wasmInstance.memory.buffer, offset);
      const srcPtr = videoView.getUint32(0, true);
      if (srcPtr) {
        const srcLen = videoView.getUint32(4, true);
        element.src = readWasmString(srcPtr, srcLen);
      }
      console.log("Src", element.src);
      element.autoplay = videoView.getUint8(8) === 1;
      break;

    case COMPONENT_TYPES.NOOP:
      break;

    default:
      element = document.createElement("div");
      break;
  }

  if (element) {
    element.id = uinode.id;
  }
  return element;
}

export let tStyle = 0,
  tRegistry = 0;

/**
 * Setup element with common properties and register it
 * @param {HTMLElement} element - The element to set up
 * @param {Object} renderCmd - The render command
 */
export function setupElement(element, uinode) {
  // let s = performance.now();
  if (state.initial_render && uinode.styleId.length > 0) {
    const inlineStylePtr = wasmInstance.getInlineStyle(uinode.offset);
    const inlineStyleLen = wasmInstance.getInlineStyleLen(uinode.offset);
    if (inlineStylePtr !== 0) {
      const inlineStyle = readWasmString(inlineStylePtr, inlineStyleLen);
      element.setAttribute("style", inlineStyle);
    }
    setRuleStyle(uinode.styleId, element);
  } else if (!state.initial_render && uinode.styleId.length > 0) {
    const inlineStylePtr = wasmInstance.getInlineStyle(uinode.offset);
    if (inlineStylePtr !== 0) {
      const inlineStyleLen = wasmInstance.getInlineStyleLen(uinode.offset);
      const inlineStyle = readWasmString(inlineStylePtr, inlineStyleLen);
      element.setAttribute("style", inlineStyle);
    }

    // Update styling
    updateComponentStyle(uinode.offset, uinode.styleId, "", element);
  }

  // tStyle += performance.now() - s;

  // Register the element

  if (uinode.elemType === COMPONENT_TYPES.ICON) {
    const iconName = readWasmString(uinode.hrefPtr, uinode.hrefLen);
    element.className = iconName + " " + uinode.styleId;
  }

  // s = performance.now();
  domNodeRegistry.set(uinode.id, {
    elementType: uinode.elemType,
    node_ptr: uinode.offset,
    domNode: element,
    exitAnimationId: uinode.exitAnimationId,
    destroyId: uinode.hooks.destroyId > 0 ? uinode.hooks.destroyId : null,
    hash: uinode.hash,
  });
  // tRegistry += performance.now() - s;
}

/**
 * Update an existing element
 * @param {HTMLElement} element - The element to update
 * @param {Object} renderCmd - The render command
 */
export function updateElement(element, uinode) {
  // Update text content if needed
  if (uinode.changedProps > 0) {
    if (
      uinode.elemType === COMPONENT_TYPES.TEXT ||
      uinode.elemType === COMPONENT_TYPES.HEADER ||
      uinode.elemType === COMPONENT_TYPES.ALLOC_TEXT ||
      uinode.elemType === COMPONENT_TYPES.HEADING ||
      uinode.elemType === COMPONENT_TYPES.LABEL
    ) {
      const text = readWasmString(uinode.textPtr, uinode.textLen);
      element.textContent = text;
    } else if (
      uinode.elemType === COMPONENT_TYPES.TEXT_FIELD ||
      uinode.elemType === COMPONENT_TYPES.TEXT_AREA
    ) {
      const instansePtr = wasmInstance.getTextFieldParams(uinode.offset) >>> 0;
      if (instansePtr) {
        const fieldCount = wasmInstance.getTextFieldCount(uinode.offset);
        const reader = new DynamicStructReader(
          wasmInstance,
          wasmInstance.memory,
        );
        const fieldStruct = reader.readStruct(
          uinode.offset,
          instansePtr,
          fieldCount,
          "getTextFieldDescriptor",
        );
        element.value =
          fieldStruct.value !== null ? String(fieldStruct.value) : "";
      }

      // const text = readWasmString(
      //   uinode.textPtr,
      //   uinode.textLen,
      // );
    } else if (uinode.elemType === COMPONENT_TYPES.ICON) {
      const iconName = readWasmString(uinode.hrefPtr, uinode.hrefLen);
      element.className = iconName + " " + uinode.styleId;
      uinode.styleId = iconName + " " + uinode.styleId;
      // const href = readWasmString(
      //   uinode.hrefPtr,
      //   uinode.hrefLen,
      // );
      // element.className = href;
    } else if (uinode.elemType === COMPONENT_TYPES.HTML_TEXT) {
      const text = readWasmString(uinode.textPtr, uinode.textLen);
      element.innerHTML = text;
    } else if (uinode.elemType === COMPONENT_TYPES.IMAGE) {
      const src = readWasmString(uinode.hrefPtr, uinode.hrefLen);
      console.log("Image", src);
      console.log("Image", element);
      element.src = src;
    } else if (uinode.elemType === COMPONENT_TYPES.SVG) {
      const svgString = readWasmString(uinode.textPtr, uinode.textLen);
      const cleanSvg = svgString.replace(/^\s+|\s+$/g, "");
      const parser = new DOMParser();
      const doc = parser.parseFromString(cleanSvg, "image/svg+xml");
      element.innerHTML = doc.documentElement.outerHTML;
    }
  }

  // This means that the style hash has changed and we need to update
  if (uinode.changedStyle > 0) {
    // let css = "";
    // const cssStylePtr = wasmInstance.getStyle(uinode.offset);
    // if (cssStylePtr !== 0) {
    //   const cssStyleLen = wasmInstance.getStyleLen();
    //   css = readWasmString(cssStylePtr, cssStyleLen);
    // }
    // Update styling
    updateComponentStyle(uinode.offset, uinode.styleId, "", element);

    const inlineStylePtr = wasmInstance.getInlineStyle(uinode.offset);
    const inlineStyleLen = wasmInstance.getInlineStyleLen(uinode.offset);
    if (inlineStylePtr !== 0) {
      const inlineStyle = readWasmString(inlineStylePtr, inlineStyleLen);
      element.setAttribute("style", inlineStyle);
    } else if (uinode.elemType === COMPONENT_TYPES.ICON) {
      const iconName = readWasmString(uinode.hrefPtr, uinode.hrefLen);
      element.className = iconName + " " + uinode.styleId;
      uinode.styleId = iconName + " " + uinode.styleId;
    }
  } else {
    // element.className = uinode.styleId;
  }

  // if (uinode.hoverCss.length > 0) {
  //   applyHoverClass(element, uinode.styleId, uinode.hoverCss);
  // }
  //
  // if (uinode.focusCss.length > 0) {
  //   applyFocusClass(element, uinode.styleId, uinode.focusCss);
  // }
  //
  // if (uinode.focusWithinCss.length > 0) {
  //   applyFocusWithinClass(element, uinode.styleId, uinode.focusWithinCss);
  // }
  // if (uinode.stateType === STATE_TYPES.PURE) {
  //   pureNodeRegistry.set(uinode.id, {
  //     id: uinode.id,
  //     state: uinode,
  //     index: uinode.index,
  //   });
  // }
}

/**
 * Traverse and render the component tree
 * @param {HTMLElement} parent - The parent element html element
 * @param {HTMLElement} tree_node - The current tree node  *UINode
 * @param {Object} layout - The layout information
 */
export function generateSections(virtual, virtual_ptr, layout) {
  if (!virtual) return;

  const children_count = wasmInstance.getTreeNodeChildrenCount(virtual_ptr);

  for (let i = 0; i < children_count; i++) {
    const child_ptr = wasmInstance.getTreeNodeChild(virtual_ptr, i);
    const rndcmd_ptr = wasmInstance.getRenderCommandPtr(child_ptr);
    const renderCmd = readRenderCommand(rndcmd_ptr, layout);

    if (renderCmd.elemType !== COMPONENT_TYPES.INTERSECTION) {
      console.error(
        "Virtualized element must contain only intersection elements",
      );
      return;
    }

    activeNodeIds.add(renderCmd.id);

    let element = createElementByType(renderCmd);

    if (!element) continue; // Skip if element creation failed

    // Set up the element
    setupElement(element, renderCmd);

    // Append to parent
    virtual.appendChild(element);
    observeredSections.set(renderCmd.id, {
      renderCmd,
      treeNodePtr: child_ptr,
    });
  }
}

export let t1 = 0,
  t2 = 0,
  t3 = 0,
  t4 = 0,
  t5 = 0,
  t6 = 0,
  t7 = 0,
  t8 = 0;

export function resetTimers() {
  t1 = 0;
  t2 = 0;
  t3 = 0;
  t4 = 0;
  t5 = 0;
  t6 = 0;
  t7 = 0;
  t8 = 0;
  tStyle = 0;
  tRegistry = 0;
}

/**
 * Traverse and render the component tree
 * @param {HTMLElement} parent - The parent element html element
 * @param {HTMLElement} tree_node - The current tree node  *UINode
 * @param {Object} layout - The layout information
 */
export function traverseUINodes(parent, parentUINode) {
  if (!parent) return;

  // const children_count = wasmInstance.getUINodeChildrenCount(parentUINode);
  const uinodes = [];
  // let s = performance.now();

  // Collect children by walking the linked list - O(n)
  let childPtr = wasmInstance.getUINodeFirstChild(parentUINode);

  while (childPtr) {
    // s = performance.now();
    const uiNode = readUINode(childPtr);
    // t1 += performance.now() - s;

    // s = performance.now();
    uinodes.push([uiNode, childPtr]);
    // t7 += performance.now() - s;

    // s = performance.now();
    childPtr = wasmInstance.getUINodeNextSibling(childPtr);
    // t2 += performance.now() - s;
  }

  for (let i = uinodes.length - 1; i >= 0; i--) {
    const uinode = uinodes[i][0];
    const child_ptr = uinodes[i][1];
    activeNodeIds.add(uinode.id);
    let element = null;
    if (uinode.isDirty) {
      // s = performance.now();
      // element = domNodeRegistry.get(uinode.id)?.domNode;
      element = document.getElementById(uinode.id);
      // t3 += performance.now() - s;
      if (element && state.initial_render) {
        attachElementListeners(element, uinode);
        traverseUINodes(element, child_ptr);
      } else if (!element || state.initial_render) {
        // Create new element
        // s = performance.now();
        element = createElementByType(uinode);
        // t6 += performance.now() - s;

        if (!element) continue; // Skip if element creation failed

        // Set up the element
        // s = performance.now();
        setupElement(element, uinode);
        // t5 += performance.now() - s;

        // Append to parent
        const next = uinodes[i + 1];
        let anchor = null;
        if (next) {
          const nextId = next[0]?.id; // id of the next sibling
          anchor = nextId ? document.getElementById(nextId) : null;
        }

        // s = performance.now();
        parent.insertBefore(element, anchor);
        // t4 += performance.now() - s;
        traverseUINodes(element, child_ptr);

        if (uinode.elemType === COMPONENT_TYPES.HOOKS_CTX) {
          const hooks_type = wasmInstance.getHooksType(uinode.offset);
          switch (hooks_type) {
            case 0:
              hooksMountedCtx.set(uinode.hash, true);
              break;
            case 1:
              hooksDestroyCtx.set(uinode.hash, true);
              break;
            case 2:
              hooksCtxCreated.set(uinode.hash, true);
              break;
          }
          element.className = "";
        } else if (uinode.elemType === COMPONENT_TYPES.HOOKS) {
          if (uinode.hooks.mountedId > 0) {
            hooksMounted.set(uinode.id, true);
            element.className = "";
          }
          if (uinode.hooks.createdId > 0) {
            wasmInstance.hooksCreatedCallback(uinode.hooks.createdId);
          }
          if (uinode.hooks.updatedId > 0) {
            wasmInstance.hooksUpdatedCallback(uinode.hooks.updatedId);
          }
        } else if (uinode.hooks.createdId > 0) {
          hooksCtxCreated.set(uinode.id, true);
        }
      } else {
        // Here we may need to change the positions of the elements
        // Update existing element
        updateElement(element, uinode);

        // Calculate the intended anchor (next sibling)
        const next = uinodes[i + 1];
        let anchor = null;
        if (next) {
          const nextId = next[0]?.id;
          anchor = nextId ? document.getElementById(nextId) : null;
          // anchor = nextId ? domNodeRegistry.get(nextId)?.domNode : null;
          // element = domNodeRegistry.get(uinode.id)?.domNode;
        }
        // In traverseUINodes, when checking siblings:
        let actualNextSibling = element.nextSibling;
        while (actualNextSibling?.dataset?.removing) {
          actualNextSibling = actualNextSibling.nextSibling;
        }

        if (element.parentNode !== parent || actualNextSibling !== anchor) {
          parent.insertBefore(element, anchor);
        }

        // Process children
        traverseUINodes(element, child_ptr);
      }
    } else {
      // Element is not dirty, just process its children
      const element = document.getElementById(uinode.id);
      traverseUINodes(element, child_ptr);
    }
  }
}

/**
 * Traverse and render the component tree
 * @param {HTMLElement} parent - The parent element html element
 * @param {HTMLElement} tree_node - The current tree node  *UINode
 * @param {Object} layout - The layout information
 */
export function traverse(parent, has_children, tree_node, layout) {
  // if (has_children === 0) return;
  if (!parent) return;

  const children_count = wasmInstance.getTreeNodeChildrenCount(tree_node);

  // const existingDOMElements = Array.from(parent.children); // Get all existing DOM nodes
  //
  // // Create a map of existing DOM elements by their ID for fast lookups
  // const existingElementsMap = new Map();
  // for (const el of existingDOMElements) {
  //   existingElementsMap.set(el.id, el);
  // }

  const renderCmds = [];

  for (let i = 0; i < children_count; i++) {
    const child_ptr = wasmInstance.getTreeNodeChild(tree_node, i);
    const rndcmd_ptr = wasmInstance.getRenderCommandPtr(child_ptr);
    const renderCmd = readRenderCommand(rndcmd_ptr, layout);

    const uiNode = readUINode(renderCmd.nodePtr);
    console.log(uiNode);
    renderCmds.push([renderCmd, child_ptr]);
  }

  for (let i = children_count - 1; i >= 0; i--) {
    const renderCmd = renderCmds[i][0];
    const child_ptr = renderCmds[i][1];
    activeNodeIds.add(renderCmd.id);
    let element = null;
    if (renderCmd.isDirty) {
      element = document.getElementById(renderCmd.id);
      if (element && state.initial_render) {
        attachElementListeners(element, renderCmd);
        traverse(element, renderCmd.props.has_children, child_ptr, layout);

        // Handle hooks mounted calls
        if (renderCmd.elemType === COMPONENT_TYPES.HOOKS_CTX) {
          console.log("HOOKS_CTX");
          if (renderCmd.hooks.mountedId > 0) {
            hooksMountedCtx.set(renderCmd.id, true);
            element.className = "";
          }
        } else if (renderCmd.elemType === COMPONENT_TYPES.HOOKS) {
          if (renderCmd.hooks.mountedId > 0) {
            hooksMounted.set(renderCmd.id, true);
            element.className = "";
          }
          if (renderCmd.hooks.createdId > 0) {
            wasmInstance.hooksCreatedCallback(renderCmd.hooks.createdId);
          }
          if (renderCmd.hooks.updatedId > 0) {
            wasmInstance.hooksUpdatedCallback(renderCmd.hooks.updatedId);
          }
        } else if (renderCmd.hooks.createdId > 0) {
          hooksCtxCreated.set(renderCmd.id, true);
        }
      } else if (!element || state.initial_render) {
        // Create new element
        element = createElementByType(renderCmd);

        if (!element) continue; // Skip if element creation failed

        // Set up the element
        setupElement(element, renderCmd);

        // Append to parent
        const next = renderCmds[i + 1];
        let anchor = null;
        if (next) {
          const nextId = next[0]?.id; // id of the next sibling
          anchor = nextId ? document.getElementById(nextId) : null;
        }
        parent.insertBefore(element, anchor);
        traverse(element, renderCmd.props.has_children, child_ptr, layout);

        if (renderCmd.elemType === COMPONENT_TYPES.HOOKS_CTX) {
          console.log("HOOKS_CTX");
          if (renderCmd.hooks.mountedId > 0) {
            hooksMountedCtx.set(renderCmd.id, true);
            element.className = "";
          }
        } else if (renderCmd.elemType === COMPONENT_TYPES.HOOKS) {
          if (renderCmd.hooks.mountedId > 0) {
            hooksMounted.set(renderCmd.id, true);
            element.className = "";
          }
          if (renderCmd.hooks.createdId > 0) {
            wasmInstance.hooksCreatedCallback(renderCmd.hooks.createdId);
          }
          if (renderCmd.hooks.updatedId > 0) {
            wasmInstance.hooksUpdatedCallback(renderCmd.hooks.updatedId);
          }
        } else if (renderCmd.hooks.createdId > 0) {
          hooksCtxCreated.set(renderCmd.id, true);
        }
      } else {
        // Here we may need to change the positions of the elements
        // Update existing element
        updateElement(element, renderCmd);

        // Calculate the intended anchor (next sibling)
        const next = renderCmds[i + 1];
        let anchor = null;
        if (next) {
          const nextId = next[0]?.id;
          anchor = nextId ? document.getElementById(nextId) : null;
        }

        // FIX: Check if the element is already in the correct position.
        // We only move it if:
        // 1. The element is not attached to this parent yet, OR
        // 2. The element's current next sibling is different from the intended anchor.
        if (element.parentNode !== parent || element.nextSibling !== anchor) {
          parent.insertBefore(element, anchor);
        }

        // Process children
        traverse(element, renderCmd.props.has_children, child_ptr, layout);
      }
    } else {
      // Element is not dirty, just process its children
      const element = document.getElementById(renderCmd.id);
      traverse(element, renderCmd.props.has_children, child_ptr, layout);
    }
  }
}

export function traverseRemove(parent, tree_node, layout) {
  console.log("traverseRemove", parent, tree_node, layout);
  if (!parent) return;

  const children_count = wasmInstance.getTreeNodeChildrenCount(tree_node);

  for (let i = 0; i < children_count; i++) {
    const child_ptr = wasmInstance.getTreeNodeChild(tree_node, i);
    const rndcmd_ptr = wasmInstance.getRenderCommandPtr(child_ptr);
    const renderCmd = readRenderCommand(rndcmd_ptr, layout);

    if (renderCmd.isDirty) {
      // console.log("flkajsdfl;kajflkjafj", renderCmd.id);
      const node = domNodeRegistry.get(renderCmd.id);
      const el = node.domNode;
      domNodeRegistry.delete(renderCmd.id);
      pureNodeRegistry.delete(renderCmd.id);
      // el.remove();
      el.replaceWith(...Array.from(el.childNodes));
      wasmInstance.setDirtyToFalse(renderCmd.nodePtr);
    }
  }
}
