import {
  eventHandlers,
  elementDimensions,
  eventStorage,
  beforeHooksHandlers,
  afterHooksHandlers,
  observers,
  timeouts,
} from "./maps.js";
import {
  allocString,
  readWasmString,
  rerenderRoute,
  requestRerender,
  styleSheet,
  checkMemoryGrowth,
} from "./wasi_obj.js";

let wasmInstance = null;

let structBridge = undefined;

function scheduleTick() {
  requestAnimationFrame(() => wasmInstance.exports.tick());
}

export class PerformanceMonitor {
  constructor() {
    this.fps = 0;
    this.frameTime = 0;
    this.frameTimes = [];
    this.maxSamples = 60; // Sample over 60 frames
    this.lastFrameTime = performance.now();
    this.startMonitoring();
  }

  startMonitoring() {
    const measure = (currentTime) => {
      // Calculate time since last frame
      const delta = currentTime - this.lastFrameTime;
      this.lastFrameTime = currentTime;

      // Store frame time
      this.frameTimes.push(delta);
      if (this.frameTimes.length > this.maxSamples) {
        this.frameTimes.shift();
      }

      // Calculate average FPS over the samples
      const avgFrameTime =
        this.frameTimes.reduce((a, b) => a + b, 0) / this.frameTimes.length;
      this.fps = Math.round(1000 / avgFrameTime);
      this.frameTime = Math.round(avgFrameTime * 100) / 100;

      // Update display
      const fpsElement = document.getElementById("fps");
      const frameTimeElement = document.getElementById("frameTime");

      if (fpsElement) fpsElement.textContent = this.fps;
      if (frameTimeElement) frameTimeElement.textContent = this.frameTime;

      requestAnimationFrame(measure);
    };

    requestAnimationFrame(measure);
  }
}
export function setWasiStructBridge() {
  // Initialize the bridge
  structBridge = new WasmStructBridge(wasmInstance);

  // Register schemas once at startup
  structBridge.registerSchema(
    "ObserverOptions",
    "getObserverOptionsSchema",
    "getObserverOptionsSchemaLength",
  );
}

export class WasmStructBridge {
  constructor(wasmInstance) {
    this.wasm = wasmInstance;
    this.schemas = new Map();
  }

  // Register a schema for a struct type
  registerSchema(name, getSchemaFn, getSchemaLengthFn) {
    // Register a schema for a struct type
    const length = this.wasm[getSchemaLengthFn]();
    const schemaPtr = this.wasm[getSchemaFn]();

    const fields = [];
    const memory = new DataView(this.wasm.memory.buffer);

    const FIELD_DESCRIPTOR_SIZE = 16; // 1 + 4 + 4 + 4

    for (let i = 0; i < length; i++) {
      const offset = schemaPtr + i * FIELD_DESCRIPTOR_SIZE; // ✅ 13 bytes per field

      const fieldType = memory.getUint8(offset);
      const fieldOffset = memory.getUint32(offset + 1, true); // ✅ Starts at byte 1
      const namePtr = memory.getUint32(offset + 5, true); // ✅ Starts at byte 5
      const nameLen = memory.getUint32(offset + 9, true); // ✅ Starts at byte 9

      const fieldName = readWasmString(namePtr, nameLen);

      fields.push({
        name: fieldName,
        type: fieldType,
        offset: fieldOffset,
      });
    }

    this.schemas.set(name, fields);
  }

  readField(memory, ptr, fieldType) {
    const FieldType = {
      u8_type: 0,
      i8_type: 1,
      u16_type: 2,
      i16_type: 3,
      u32_type: 4,
      i32_type: 5,
      u64_type: 6,
      i64_type: 7,
      f32_type: 8,
      f64_type: 9,
      bool_type: 10,
      string_type: 11,
    };

    switch (fieldType) {
      case FieldType.u8_type:
        return memory.getUint8(ptr);
      case FieldType.i8_type:
        return memory.getInt8(ptr);
      case FieldType.u16_type:
        return memory.getUint16(ptr, true);
      case FieldType.i16_type:
        return memory.getInt16(ptr, true);
      case FieldType.u32_type:
        return memory.getUint32(ptr, true);
      case FieldType.i32_type:
        return memory.getInt32(ptr, true);
      case FieldType.u64_type:
        return memory.getBigUint64(ptr, true);
      case FieldType.i64_type:
        return memory.getBigInt64(ptr, true);
      case FieldType.f32_type:
        return memory.getFloat32(ptr, true);
      case FieldType.f64_type:
        return memory.getFloat64(ptr, true);
      case FieldType.bool_type:
        return memory.getUint8(ptr) !== 0;
      case FieldType.string_type:
        const strPtr = memory.getUint32(ptr, true);
        const strLen = memory.getUint32(ptr + 4, true);
        return readWasmString(strPtr, strLen);
      default:
        throw new Error(`Unknown field type: ${fieldType}`);
    }
  }
}

class StructReader {
  constructor(wasmMemory, ptr) {
    this.view = new DataView(wasmMemory.buffer);
    this.ptr = ptr;
    this.offset = 0;
  }

  f32() {
    const val = this.view.getFloat32(this.ptr + this.offset, true);
    this.offset += 4;
    return val;
  }

  i32() {
    const val = this.view.getInt32(this.ptr + this.offset, true);
    this.offset += 4;
    return val;
  }

  u32() {
    const val = this.view.getUint32(this.ptr + this.offset, true);
    this.offset += 4;
    return val;
  }

  bool() {
    const val = this.view.getUint8(this.ptr + this.offset);
    this.offset += 1;
    return val !== 0;
  }

  string() {
    const ptr = this.u32();
    const len = this.u32();
    return readWasmString(ptr, len);
  }
}

export const env = {
  /**
   * Call this function whenever you want to trigger a re-render.
   * It uses a flag to throttle calls to once per animation frame.
   */
  requestRerenderWasm: () => {
    requestRerender();
  },
  performance_now: () => performance.now(),

  consoleLogWasm: (ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const str = new TextDecoder().decode(memory.subarray(ptr, ptr + len));
    console.log(str);
  },

  consoleLogColoredWasm: (
    ptr,
    len,
    stylePtr1,
    styleLen1,
    stylePtr2,
    styleLen2,
  ) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const str = readWasmString(ptr, len);
    const style1 = readWasmString(stylePtr1, styleLen1);
    const style2 = readWasmString(stylePtr2, styleLen2);
    console.log(str, style1, style2);
  },
  consoleLogColoredWarnWasm: (
    ptr,
    len,
    stylePtr1,
    styleLen1,
    stylePtr2,
    styleLen2,
  ) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const str = readWasmString(ptr, len);
    const style1 = readWasmString(stylePtr1, styleLen1);
    const style2 = readWasmString(stylePtr2, styleLen2);
    console.warn(str, style1, style2);
  },

  trackAlloc: () => {
    const err = new Error();
    Error.captureStackTrace(err, wasmInstance.trackAlloc);
    console.log(err.stack);
  },

  copyTextWasm: (ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const text = new TextDecoder().decode(memory.subarray(ptr, ptr + len));

    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).catch((err) => {
        console.error("Clipboard write failed:", err);
      });
    }
  },
  removeElementEventListener: (idPtr, idLen, ptr, len, onid) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);

    const elementId = new TextDecoder().decode(
      memory.subarray(idPtr, idPtr + idLen),
    );

    const element = document.getElementById(elementId);

    const eventType = readWasmString(ptr, len);
    const eventData = eventHandlers.get(elementId);
    if (!eventData) return;

    const handler = eventData[eventType];
    if (handler) {
      element.removeEventListener(eventType, handler);
      delete eventData[eventType];

      if (Object.keys(eventData).length === 0) {
        eventHandlers.delete(elementId);
      }
    }
  },
  createElementEventInstListener: (idPtr, idLen, ptr, len, onid) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);

    const elementId = new TextDecoder().decode(
      memory.subarray(idPtr, idPtr + idLen),
    );

    const element = document.getElementById(elementId);
    if (element === null) {
      console.warn(
        "Element is not commited yet, please attach listeners after mounting to the DOM",
      );
      return;
    }

    const event_id = onid >>> 0;
    const event_type = readWasmString(ptr, len);
    let eventData = eventHandlers.get(elementId);
    const handler = (event) => {
      eventStorage[event_id] = event;
      wasmInstance.eventInstCallback(event_id);
    };

    if (eventData === undefined) {
      eventData = {};
      eventData[event_type] = handler;
      element.addEventListener(event_type, handler);
    } else {
      if (eventData[event_type] === undefined) {
        eventData[event_type] = handler;
        element.addEventListener(event_type, handler);
      }
    }
    eventHandlers.set(elementId, eventData);
  },

  createElementEventListener: (idPtr, idLen, ptr, len, onid) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);

    const elementId = new TextDecoder().decode(
      memory.subarray(idPtr, idPtr + idLen),
    );

    const element = document.getElementById(elementId);
    if (element === null) {
      console.log("Could not attach listener element is Null", elementId);
      return;
    }

    const event_id = onid >>> 0;
    const event_type = readWasmString(ptr, len);
    const eventData = eventHandlers.get(elementId);
    const handler = (event) => {
      if (event_type === "pointerdown") {
        element.setPointerCapture(event.pointerId);
      }
      eventStorage[event_id] = event;
      wasmInstance.eventCallback(event_id);
    };

    if (event_type === "pointerdown") {
      element.style.contain = "layout style paint";
      element.style.willChange = "transform";
    }

    if (eventData === undefined) {
      const newEventData = {};
      newEventData[event_type] = handler;
      element.addEventListener(event_type, handler);
      eventHandlers.set(elementId, newEventData);
    } else {
      if (eventData[event_type] === undefined) {
        eventData[event_type] = handler;
        element.addEventListener(event_type, handler);
        eventHandlers.set(elementId, eventData);
      }
    }
  },

  elementFocusedWasm: (idPtr, idLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const elementId = readWasmString(idPtr, idLen);
    const element = document.getElementById(elementId);
    if (element) {
      const isFocused = document.activeElement === element;
      return isFocused;
    }
    console.log("Element is null, could not add focus", elementId);
  },

  elementFocusWasm: (idPtr, idLen) => {
    requestAnimationFrame(() => {
      if (!wasmInstance) {
        console.error("WASM instance not initialized");
        return;
      }
      const elementId = readWasmString(idPtr, idLen);
      const element = document.getElementById(elementId);
      if (element) {
        element.focus();
        return;
      }
      console.log("Element is null, could not add focus", elementId);
    });
  },
  createEventListenerCtx: (ptr, len, onid) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const event_id = onid >>> 0;
    const event_type = readWasmString(ptr, len);
    let eventData = eventHandlers.get("vapor-document");
    console.log("eventData", event_type, event_id);
    const handler = (event) => {
      eventStorage[event_id] = event;
      wasmInstance.eventInstCallback(event_id);
    };

    if (eventData === undefined) {
      eventData = {};
      eventData[event_type] = handler;
      document.addEventListener(event_type, handler);
    } else {
      if (eventData[event_type] === undefined) {
        eventData[event_type] = handler;
        document.addEventListener(event_type, handler);
      }
    }
    eventHandlers.set("vapor-document", eventData);
  },

  createEventListener: (ptr, len, id) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const event_type = new TextDecoder().decode(
      memory.subarray(ptr, ptr + len),
    );
    document.addEventListener(event_type, (event) => {
      eventStorage[id] = event;
      console.log("Event", event);
      wasmInstance.eventCallback(id);
    });
  },

  removeEventListener: (ptr, len, onid) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const eventType = readWasmString(ptr, len);
    const eventData = eventHandlers.get("vapor-document");
    if (!eventData) return;

    const handler = eventData[eventType];
    if (handler) {
      document.removeEventListener(eventType, handler);
      delete eventData[eventType];

      if (Object.keys(eventData).length === 0) {
        eventHandlers.delete("vapor-document");
      }
    }
  },

  highlightHoverTargetNode: (ptr, len, type) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const target_id = readWasmString(ptr, len);
    const element = document.getElementById(target_id);
    if (!element) {
      console.warn(`Element with id "${target_id}" not found`);
      return;
    }

    // Remove any existing highlight
    const existingHighlight = document.getElementById("highlight-overlay");
    if (existingHighlight) {
      existingHighlight.remove();
    }

    // Get element position
    const rect = element.getBoundingClientRect();

    // Create highlight overlay
    const highlight = document.createElement("div");
    // highlight.id = "highlight-overlay";
    highlight.className = "highlight-hover-overlay"; // 👈 use class, not id
    highlight.style.position = "absolute";
    highlight.style.top = `${rect.top + window.scrollY - 4}px`;
    highlight.style.left = `${rect.left + window.scrollX - 4}px`;
    highlight.style.width = `${rect.width + 8}px`;
    highlight.style.height = `${rect.height + 8}px`;

    // 🔶 Highlight style similar to DevTools
    highlight.style.backgroundColor =
      type === 0 ? "rgba(255, 165, 0, 0.35)" : "rgba(255, 0, 0, 0.35)"; // 👈 orange/red
    highlight.style.outline =
      type === 0 ? "solid 2px #FF9100" : "solid 2px #ff0000"; // 👈 orange/red
    // highlight.style.borderRadius = "4px";

    highlight.style.pointerEvents = "none"; // Don’t block clicks
    highlight.style.zIndex = "9999"; // float above

    document.body.appendChild(highlight);
  },

  highlightTargetNode: (ptr, len, type) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const target_id = readWasmString(ptr, len);
    const element = document.getElementById(target_id);
    if (!element) {
      console.warn(`Element with id "${target_id}" not found`);
      return;
    }

    // Remove any existing highlight
    const existingHighlight = document.getElementById("highlight-overlay");
    if (existingHighlight) {
      existingHighlight.remove();
    }

    // Get element position
    const rect = element.getBoundingClientRect();

    // Create highlight overlay
    const highlight = document.createElement("div");
    // highlight.id = "highlight-overlay";
    highlight.className = "highlight-overlay"; // 👈 use class, not id
    highlight.style.position = "absolute";
    highlight.style.top = `${rect.top + window.scrollY - 4}px`;
    highlight.style.left = `${rect.left + window.scrollX - 4}px`;
    highlight.style.width = `${rect.width + 8}px`;
    highlight.style.height = `${rect.height + 8}px`;

    // 🔶 Highlight style similar to DevTools
    highlight.style.backgroundColor =
      type === 0 ? "rgba(255, 165, 0, 0.35)" : "rgba(255, 0, 0, 0.35)"; // 👈 orange/red
    highlight.style.outline =
      type === 0 ? "solid 2px #FF9100" : "solid 2px #ff0000"; // 👈 orange/red
    // highlight.style.borderRadius = "4px";

    highlight.style.pointerEvents = "none"; // Don’t block clicks
    highlight.style.zIndex = "9999"; // float above

    document.body.appendChild(highlight);
  },
  clearHighlight: () => {
    document
      .querySelectorAll(".highlight-overlay")
      .forEach((el) => el.remove());
  },
  clearHoverHighlight: () => {
    document
      .querySelectorAll(".highlight-hover-overlay")
      .forEach((el) => el.remove());
  },

  getEventDataInputWasm: (id) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    id = id >>> 0;
    const event = eventStorage[id];
    const value = event.target.value;
    return allocString(value);
  },
  getEventDataWasm: (id, ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const key = new TextDecoder().decode(memory.subarray(ptr, ptr + len));
    id = id >>> 0;
    const event = eventStorage[id];
    const keyValue = event[key];
    return allocString(keyValue);
  },

  getAttributeWasmNumber: (ptr, len, attributePtr, attributeLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const id = new TextDecoder().decode(memory.subarray(ptr, ptr + len));
    const attribute = new TextDecoder().decode(
      memory.subarray(attributePtr, attributePtr + attributeLen),
    );
    const element = document.getElementById(id);
    const value = element[attribute];
    return value;
  },

  getInputValueWasm: (ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const id = new TextDecoder().decode(memory.subarray(ptr, ptr + len));
    const element = document.getElementById(id);
    const value = element.value;
    return allocString(value);
  },
  setInputValueWasm: (ptr, len, textPtr, textLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const id = readWasmString(ptr, len);
    const text = readWasmString(textPtr, textLen);
    const element = document.getElementById(id);
    element.value = text;
  },

  getEventDataNumberWasm: (onid, ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const event_id = onid >>> 0;
    const key = readWasmString(ptr, len);
    const event = eventStorage[event_id];
    const keyValue = event[key];
    return keyValue;
  },
  getOffsetsWasm: (idPtr, idLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);

    const id = new TextDecoder().decode(memory.subarray(idPtr, idPtr + idLen));

    const element = document.getElementById(id);
    if (!element) {
      console.error(`Element with id ${id} not found`);
      return 0; // Return null pointer if element doesn't exist
    }

    const currentTime = performance.now();
    const cachedDimensions = elementDimensions.get(id);

    // Use cached dimensions if they exist and are recent enough
    if (
      cachedDimensions &&
      currentTime - cachedDimensions.lastUpdateTime < 16
    ) {
      // Reuse existing dimensions without querying the DOM
      const ptr = wasmInstance.allocate(6);
      const bounds = new Float32Array(memory.buffer, ptr, 6);
      bounds[0] = cachedDimensions.offsetTop;
      bounds[1] = cachedDimensions.offsetLeft;
      bounds[2] = cachedDimensions.offsetRight;
      bounds[3] = cachedDimensions.offsetBottom;
      bounds[4] = cachedDimensions.offsetWidth;
      bounds[5] = cachedDimensions.offsetHeight;

      return ptr;
    }

    // Otherwise read from DOM and update cache
    const dimensions = {
      offsetTop: element.offsetTop,
      offsetLeft: element.offsetLeft,
      offsetRight: element.offsetLeft + element.offsetWidth, // offsetRight is not a standard property
      offsetBottom: element.offsetTop + element.offsetHeight, // offsetBottom is not a standard property
      offsetWidth: element.offsetWidth,
      offsetHeight: element.offsetHeight,
      lastUpdateTime: currentTime,
    };

    // Store in cache
    elementDimensions.set(id, dimensions);

    // Allocate memory and return pointer to WASM
    const ptr = wasmInstance.allocate(6);
    const bounds = new Float32Array(memory.buffer, ptr, 6);

    bounds[0] = dimensions.offsetTop;
    bounds[1] = dimensions.offsetLeft;
    bounds[2] = dimensions.offsetRight;
    bounds[3] = dimensions.offsetBottom;
    bounds[4] = dimensions.offsetWidth;
    bounds[5] = dimensions.offsetHeight;

    return ptr;
  },
  getClientPos: (idPtr, idLen) => {
    requestAnimationFrame(() => {
      if (!wasmInstance) {
        console.error("WASM instance not initialized");
        return;
      }
      const memory = new Uint8Array(wasmInstance.memory.buffer);

      const elementId = new TextDecoder().decode(
        memory.subarray(idPtr, idPtr + idLen),
      );

      const ptr = wasmInstance.allocate(6);
      const bounds = new Float32Array(memory.buffer, ptr, 6);

      const element = document.getElementById(elementId);
      const rectBounds = element.getBoundingClientRect();
      bounds[0] = rectBounds.top;
      bounds[1] = rectBounds.left;
      bounds[2] = rectBounds.right;
      bounds[3] = rectBounds.bottom;
      bounds[4] = rectBounds.width;
      bounds[5] = rectBounds.height;
      return ptr;
    });
  },

  getBoundingClientRectWasm: (idPtr, idLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const elementId = new TextDecoder().decode(
      memory.subarray(idPtr, idPtr + idLen),
    );
    const ptr = wasmInstance.allocate(6);
    const bounds = new Float32Array(memory.buffer, ptr, 6);
    const element = document.getElementById(elementId);
    const rectBounds = element.getBoundingClientRect();

    // Add scroll offsets to get document-relative positions
    bounds[0] = rectBounds.top + window.scrollY; // top
    bounds[1] = rectBounds.left + window.scrollX; // left
    bounds[2] = rectBounds.right + window.scrollX; // right
    bounds[3] = rectBounds.bottom + window.scrollY; // bottom
    bounds[4] = rectBounds.width;
    bounds[5] = rectBounds.height;

    return ptr;
  },
  getElementData: (id, ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const key = new TextDecoder().decode(memory.subarray(ptr, ptr + len));
    const event = eventStorage[id];
    const keyValue = event[key];
    return allocString(keyValue);
  },

  eventPreventDefault: (onid, ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const eventId = onid >>> 0;
    const event = eventStorage[eventId];
    if (!event) {
      console.error("Event not found");
      return;
    }
    event.preventDefault();
  },

  timeout: (ms, callbackId) => {
    setTimeout(() => {
      wasmInstance.timeoutCallBackId(callbackId);
    }, ms);
  },

  timeoutCtx: (ms, id) => {
    const callbackId = id >>> 0;
    const timeoutId = setTimeout(() => {
      try {
        wasmInstance.callbackCtx(callbackId, null);
      } catch (e) {
      } finally {
        // ✅ Clean up after callback runs (success or failure)
        timeouts.delete(callbackId);
      }
    }, ms);

    timeouts.set(callbackId, timeoutId);
    return timeoutId;
  },

  cancelTimeoutWasm: (id) => {
    const callbackId = id >>> 0;
    const timeoutId = timeouts.get(callbackId);
    clearTimeout(timeoutId);
  },

  // id element_type function
  createElement: (idPtr, idLen, elementType, btnId, textPtr, textLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const id = new TextDecoder().decode(memory.subarray(idPtr, idPtr + idLen));

    const text = new TextDecoder().decode(
      memory.subarray(textPtr, textPtr + textLen),
    );

    const elementDetails = {
      id,
      elementType,
      btnId,
      text,
    };
    console.log(elementDetails);
  },
  createInterval: (namePtr, nameLen, delay) => {
    const name = readWasmString(namePtr, nameLen);
    setInterval(() => {
      const ptr = allocString(name);
      wasmInstance.timeOutCtxCallback(ptr);
    }, delay);
  },
  showDialog: (idPtr, idLen) => {
    requestAnimationFrame(() => {
      if (!wasmInstance) {
        console.error("WASM instance not initialized");
        return;
      }
      const memory = new Uint8Array(wasmInstance.memory.buffer);
      const id = new TextDecoder().decode(
        memory.subarray(idPtr, idPtr + idLen),
      );
      const dialog = document.getElementById(id);
      if (dialog === null) {
        console.log("Is Null");
        return;
      }
      dialog.showModal();
    });
  },
  closeDialog: (idPtr, idLen) => {
    requestAnimationFrame(() => {
      if (!wasmInstance) {
        console.error("WASM instance not initialized");
        return;
      }
      const memory = new Uint8Array(wasmInstance.memory.buffer);
      const id = new TextDecoder().decode(
        memory.subarray(idPtr, idPtr + idLen),
      );
      const dialog = document.getElementById(id);
      if (dialog === null) {
        console.log("Is Null");
        return;
      }
      dialog.close();
    });
  },
  callClickWASM: (idPtr, idLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const id = readWasmString(idPtr, idLen);
    const element = document.getElementById(id);
    if (element === null) {
      console.log("Is Null");
      return;
    }

    console.log(element);
    element.click();
  },
  mutateDomElementStyleWasm: (
    idPtr,
    idLen,
    attributePtr,
    attributeLen,
    value,
  ) => {
    requestAnimationFrame(() => {
      if (!wasmInstance) {
        console.error("WASM instance not initialized");
        return;
      }
      const memory = new Uint8Array(wasmInstance.memory.buffer);
      const id = new TextDecoder().decode(
        memory.subarray(idPtr, idPtr + idLen),
      );
      const attribute = new TextDecoder().decode(
        memory.subarray(attributePtr, attributePtr + attributeLen),
      );
      const element = document.getElementById(id);
      if (element === null) {
        console.log("Is Null");
        return;
      }

      console.log("element", element, attribute, value);
      if (attribute === "top" || attribute === "left") {
        element.style[attribute] = `${value}px`;
      } else {
        element.style[attribute] = value;
      }
    });
  },
  removeFromParent: (idPtr, idLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const id = new TextDecoder().decode(memory.subarray(idPtr, idPtr + idLen));
    const element = document.getElementById(id);
    if (element === null) {
      console.log("Is Null");
      return;
    }
    const parent = element.parentNode;
    parent.removeChild(element);
  },
  addChild: (idPtr, idLen, idChildPtr, idChildLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const id = new TextDecoder().decode(memory.subarray(idPtr, idPtr + idLen));
    const element = document.getElementById(id);
    if (element === null) {
      console.log("Is Null");
      return;
    }
    const childId = new TextDecoder().decode(
      memory.subarray(idChildPtr, idChildPtr + idChildLen),
    );
    const childElement = document.getElementById(childId);
    if (childElement === null) {
      console.log("Is Null");
      return;
    }
    element.appendChild(childElement);
  },
  // this is not synchornous
  addClass: (idPtr, idLen, idClassPtr, idClassLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const id = new TextDecoder().decode(memory.subarray(idPtr, idPtr + idLen));
    const element = document.getElementById(id);
    if (element === null) {
      console.log("Is Null");
      return;
    }
    const classId = new TextDecoder().decode(
      memory.subarray(idClassPtr, idClassPtr + idClassLen),
    );
    element.classList.add(classId);
  },
  createClass: (classPtr, classLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const classStyle = new TextDecoder().decode(
      memory.subarray(classPtr, classPtr + classLen),
    );
    // Check if we already have this class
    const newIndex = styleSheet.cssRules.length;

    styleSheet.insertRule(`${classStyle}`, newIndex);
  },
  removeClass: (idPtr, idLen, idClassPtr, idClassLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const id = new TextDecoder().decode(memory.subarray(idPtr, idPtr + idLen));
    const element = document.getElementById(id);
    if (element === null) {
      console.log("Is Null");
      return;
    }
    const classId = new TextDecoder().decode(
      memory.subarray(idClassPtr, idClassPtr + idClassLen),
    );
    element.classList.remove(classId);
  },
  mutateDomElementStyleStringWasm: (
    idPtr,
    idLen,
    attributePtr,
    attributeLen,
    valuePtr,
    valueLen,
  ) => {
    requestAnimationFrame(() => {
      if (!wasmInstance) {
        console.error("WASM instance not initialized");
        return;
      }
      const memory = new Uint8Array(wasmInstance.memory.buffer);
      const id = new TextDecoder().decode(
        memory.subarray(idPtr, idPtr + idLen),
      );
      const attribute = new TextDecoder().decode(
        memory.subarray(attributePtr, attributePtr + attributeLen),
      );
      const value = new TextDecoder().decode(
        memory.subarray(valuePtr, valuePtr + valueLen),
      );
      const element = document.getElementById(id);
      if (element === null) {
        console.log("Is Null");
        return;
      }

      element.style[attribute] = value;
    });
  },
  mutateDomElementWasm: (idPtr, idLen, attributePtr, attributeLen, value) => {
    requestAnimationFrame(() => {
      if (!wasmInstance) {
        console.error("WASM instance not initialized");
        return;
      }
      const memory = new Uint8Array(wasmInstance.memory.buffer);
      const id = new TextDecoder().decode(
        memory.subarray(idPtr, idPtr + idLen),
      );
      const attribute = new TextDecoder().decode(
        memory.subarray(attributePtr, attributePtr + attributeLen),
      );
      const element = document.getElementById(id);
      if (element === null) {
        console.log("Is Null");
        return;
      }

      element[attribute] = value;
    });
  },

  setCursorPositionWasm: (idPtr, idLen, pos) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const id = new TextDecoder().decode(memory.subarray(idPtr, idPtr + idLen));
    const element = document.getElementById(id);
    if (element === null) {
      console.log("Is Null");
      return;
    }
    element.setSelectionRange(pos, pos);
    // element.dispatchEvent(new Event("input", { bubbles: true }));
  },

  setLocalStorageStringWasm: (ptr, len, valuePtr, valueLen) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const key = readWasmString(ptr, len);
    const value = readWasmString(valuePtr, valueLen);
    localStorage.setItem(key, value);
  },

  setLocalStorageNumberWasm: (ptr, len, value) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const key = readWasmString(ptr, len);
    localStorage.setItem(key, value);
  },

  getLocalStorageNumberWasm: (ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const key = readWasmString(ptr, len);
    const value = localStorage.getItem(key);
    return value;
  },

  getLocalStorageI32Wasm: (ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const key = readWasmString(ptr, len);
    const value = localStorage.getItem(key);
    return value;
  },

  getLocalStorageU32Wasm: (ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const key = readWasmString(ptr, len);
    const value = localStorage.getItem(key);
    return value;
  },

  getLocalStorageStringWasm: (ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const key = readWasmString(ptr, len);
    const value = localStorage.getItem(key);
    return allocString(value);
  },

  removeLocalStorageWasm: (ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const key = readWasmString(ptr, len);
    localStorage.removeItem(key);
  },

  clearLocalStorageWasm: () => {
    localStorage.clear();
  },

  getWindowInformationWasm: () => {
    return allocString(window.location.pathname);
  },

  getWindowParamsWasm: () => {
    return allocString(window.location.search);
  },

  setWindowLocationWasm: (urlPtr, urlLen) => {
    const url = readWasmString(urlPtr, urlLen);
    window.location.href = url;
  },

  backWasm: () => {
    console.log("Back");
    window.history.back();
  },

  navigateWasm: (pathPtr, pathLen) => {
    const path = readWasmString(pathPtr, pathLen);
    const currentPath = window.location.pathname;
    requestAnimationFrame(() => {
      if (currentPath !== path) {
        rerenderRoute(path);
        // wasmInstance.callAllMountedCallbacks();
      }

      requestAnimationFrame(() => {
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
        } else {
          // window.scrollTo({
          //   top: 0,
          // });
        }
        // wasmInstance.callAllMountedCallbacks();
      });
    });
  },
  setCookieWasm: (cookieStrPtr, cookieStrLen) => {
    const cookie = readWasmString(cookieStrPtr, cookieStrLen);
    document.cookie = cookie;
  },

  getCookiesWasm: () => {
    return allocString(document.cookie);
  },

  getCookieWasm: (cookieStrPtr, cookieStrLen) => {
    const cookie = readWasmString(cookieStrPtr, cookieStrLen);
    const match = document.cookie.match(new RegExp(`(^| )${cookie}=([^;]+)`));
    return match ? allocString(decodeURIComponent(match[2])) : null;
  },

  fetchParamsWasm: (urlPtr, urlLen, callback_id, httpPtr, httpLen) => {
    // Decode URL string out of WASM memory

    const url = readWasmString(urlPtr, urlLen);
    const data = readWasmString(httpPtr, httpLen);

    const Request = JSON.parse(data);

    // Fire off the fetch
    const response = {};
    fetch(url, Request)
      .then((res) => {
        response.code = res.status;
        response.text = res.statusText;
        response.type = res.type;
        return res.text();
      })
      .then((text) => {
        // Encode the response back into WASM memory
        response.body = text;
        const respString = JSON.stringify(response);
        const ptr = allocString(respString); // assume you exposed an `alloc` func

        // Call back into Zig
        wasmInstance.resumeCallback(callback_id, ptr);
      })
      .catch((err) => {
        console.error("Fetch failed:", err);
        // You could call callback with ptr=0,len=0 or export an error handler
      });
  },

  tick: (id) => {
    while (true) {
      // requestAnimationFrame(() => {
      console.log("tick");
      // wasmInstance.scheduleTick(id);
      // wasmInstance.tick();
      // });
    }
    return false;
  },

  fetchWasm: (urlPtr, urlLen, callback_id, httpPtr, httpLen) => {
    // Decode URL string out of WASM memory
    const urlBytes = new Uint8Array(wasmInstance.memory.buffer, urlPtr, urlLen);
    const url = new TextDecoder().decode(urlBytes);

    const data = readWasmString(httpPtr, httpLen);

    const Request = JSON.parse(data);

    // Fire off the fetch
    const response = {};
    fetch(url, Request)
      .then((res) => {
        response.code = res.status;
        response.message = res.statusText;
        response.type = res.type;
        response.ok = res.ok;

        // Even if status is 404, 500, etc., we still want the body
        return res.text();
      })
      .then((text) => {
        response.body = text;
        const respString = JSON.stringify({
          ok: response,
        });
        const ptr = allocString(respString);
        wasmInstance.resumeCallback(callback_id, ptr);
      })
      .catch((err) => {
        console.error("Fetch failed:", err);

        // Network error (CORS, connection refused, timeout, etc.)
        response.code = 0;
        response.type = "error";
        response.message = err.message;
        response.ok = false;

        const respString = JSON.stringify({
          err: response,
        });
        const ptr = allocString(respString);
        console.log("Fetch error", err);
        wasmInstance.resumeCallback(callback_id, ptr);
      });
  },

  destroyObserverWasm(ptr, len) {
    observers.delete(readWasmString(ptr, len));
  },

  reinitObserverWasm(id_ptr) {
    const id = id_ptr >>> 0;
    const observer = observers.get(id);

    if (!observer) {
      console.warn(`Observer ${id} not found`);
      return;
    }

    observer.disconnect();
  },

  createObserverWasm(id_ptr, optionsPtr) {
    const id = id_ptr >>> 0;
    optionsPtr = optionsPtr >>> 0;
    // const reader = new StructReader(wasmInstance.memory, optionsPtr);

    const instansePtr = wasmInstance.getObserverOptions(optionsPtr);
    if (instansePtr) {
      const fieldCount = wasmInstance.getObserverFieldCount();
      const reader = new DynamicStructReader(wasmInstance, wasmInstance.memory);
      const fieldStruct = reader.readStruct(
        null,
        instansePtr,
        fieldCount,
        "getObserverFieldDescriptor",
      );
      const opts = fieldStruct;

      const options = {
        threshold: reader.threshold,
        rootMargin: `${opts.rootMargin_top}px ${opts.rootMargin_right}px ${opts.rootMargin_bottom}px ${opts.rootMargin_left}px`,
        root: null,
      };

      const builder = new WasmObjectBuilder(wasmInstance, wasmInstance.memory);

      const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          // Get the actual index from the dataset
          const actualIndex = parseInt(entry.target.dataset.index, 10);
          const data = {
            id: entry.target.id,
            isIntersecting: entry.isIntersecting,
            actualIndex,
          };
          const object_ptr = builder.passObject(data);
          wasmInstance.callbackCtx(id, object_ptr);
        });
      }, options);
      observers.set(id, observer);
    }
  },

  observeWasm(id_ptr, elementPtr, elementLen, index) {
    const id = id_ptr >>> 0;
    const elementId = readWasmString(elementPtr, elementLen);
    const observer = observers.get(id);
    const element = document.getElementById(elementId);
    if (element === null) {
      console.warn(`Element with id ${elementId} not found`);
      return;
    }
    element.dataset.index = index;
    observer.observe(element);
  },

  toggleThemeWasm: () => {
    const body = document.documentElement; // or document.body
    const currentTheme = body.getAttribute("data-theme");

    if (currentTheme === "dark") {
      body.removeAttribute("data-theme"); // Switch to light (default)
      localStorage.setItem("theme", "light");
    } else {
      body.setAttribute("data-theme", "dark"); // Switch to dark
      localStorage.setItem("theme", "dark");
    }
  },

  createHookWASM: (endpointPtr, endpointLen, id, hookType) => {
    const endpoint = readWasmString(endpointPtr, endpointLen);
    const hookId = `${endpoint}-${id}`;

    if (hookType === 0) {
      beforeHooksHandlers.set(hookId, () => {
        wasmInstance.hookInstCallback(id);
      });
    } else if (hookType === 1) {
      afterHooksHandlers.set(hookId, () => {
        wasmInstance.hookInstCallback(id);
      });
    }
  },
  startVideoWasm: (idPtr, idLen) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);
    if (video === null) return;

    async function startCamera() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: true,
          audio: false,
        });
        video.srcObject = stream;
      } catch (error) {
        console.error("Camera access denied:", error);
      }
    }

    startCamera();
  },
  // play video
  playVideoWasm: (idPtr, idLen) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);
    video.play();
  },

  // pause video
  pauseVideoWasm: (idPtr, idLen) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);
    video.pause();
  },

  // stop camera & remove stream
  stopCameraWasm: (idPtr, idLen) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);

    if (video.srcObject) {
      const tracks = video.srcObject.getTracks();
      tracks.forEach((track) => track.stop());
      video.srcObject = null;
    }
  },

  // seek to seconds
  seekVideoWasm: (idPtr, idLen, seconds) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);
    video.currentTime = seconds;
  },

  // set volume (0.0 – 1.0)
  setVolumeWasm: (idPtr, idLen, volume) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);
    video.volume = volume;
  },

  // mute/unmute
  muteVideoWasm: (idPtr, idLen, mute) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);
    video.muted = !!mute;
  },

  // get duration (returns seconds)
  getVideoDurationWasm: (idPtr, idLen) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);
    return video.duration;
  },

  // get current playback time
  getVideoCurrentTimeWasm: (idPtr, idLen) => {
    const id = readWasmString(idPtr, idLen);
    const video = document.getElementById(id);
    return video.currentTime;
  },
  scrollToWasm: (x, y) => {
    window.scrollTo(x, y);
  },
  windowWidth: () => {
    return window.innerWidth;
  },
  windowHeight: () => {
    return window.innerHeight;
  },
  translate3dWasm: (idPtr, idLen, translationPtr, translationLen) => {
    requestAnimationFrame(() => {
      if (!wasmInstance) {
        console.error("WASM instance not initialized");
        return;
      }
      const id = readWasmString(idPtr, idLen);
      const translation = readWasmString(translationPtr, translationLen);
      const element = document.getElementById(id);
      if (element === null) {
        console.log("Is Null");
        return;
      }
      element.style.transform = translation;
    });
  },
  getElementUnderMouse: (x, y) => {
    const element = document.elementFromPoint(x, y);
    if (element === null) {
      return 0;
    }
    const ptr = allocString(element.id);
    return ptr;
  },
  alertWasm: (ptr, len) => {
    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const str = new TextDecoder().decode(memory.subarray(ptr, ptr + len));
    alert(str);
  },
  formDataWasm: (id) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    id = id >>> 0;
    const event = eventStorage[id];
    const formData = new FormData(event.target);
    const data = Object.fromEntries(formData.entries()); // Convert to object
    const builder = new WasmObjectBuilder(wasmInstance, wasmInstance.memory);
    const handle = builder.passObject(data);
    return handle;
  },
  checkMemoryGrowthWasm: () => {
    checkMemoryGrowth();
  },
  // Get current hash
  getWindowHashWasm: () => {
    return allocString(window.location.hash);
  },

  // Set hash without navigation
  setWindowHashWasm: (hashPtr, hashLen) => {
    const hash = readWasmString(hashPtr, hashLen);
    window.location.hash = hash;
  },

  // Replace current history entry (no back button entry)
  replaceStateWasm: (pathPtr, pathLen) => {
    const path = readWasmString(pathPtr, pathLen);
    window.history.replaceState(null, "", path);
  },

  // Forward navigation
  forwardWasm: () => {
    window.history.forward();
  },
  // Async clipboard read
  readClipboardWasm: (callbackId) => {
    navigator.clipboard
      .readText()
      .then((text) => {
        const ptr = allocString(text);
        wasmInstance.resumeCallback(callbackId, ptr);
      })
      .catch((err) => {
        wasmInstance.resumeCallback(callbackId, 0);
      });
  },
  isDocumentVisibleWasm: () => {
    return document.visibilityState === "visible" ? 1 : 0;
  },

  isWindowFocusedWasm: () => {
    return document.hasFocus() ? 1 : 0;
  },

  onVisibilityChangeWasm: (callbackId) => {
    document.addEventListener("visibilitychange", () => {
      wasmInstance.callbackCtx(callbackId, document.hidden ? 0 : 1);
    });
  },
  getScrollPositionWasm: () => {
    const ptr = wasmInstance.allocate(2);
    const view = new Float32Array(wasmInstance.memory.buffer, ptr, 2);
    view[0] = window.scrollX;
    view[1] = window.scrollY;
    return ptr;
  },

  scrollIntoViewWasm: (idPtr, idLen, behavior, block) => {
    const id = readWasmString(idPtr, idLen);
    const element = document.getElementById(id);
    const behaviors = ["auto", "smooth"];
    const blocks = ["start", "center", "end", "nearest"];
    element?.scrollIntoView({
      behavior: behaviors[behavior] || "auto",
      block: blocks[block] || "start",
    });
  },

  getElementScrollWasm: (idPtr, idLen) => {
    const id = readWasmString(idPtr, idLen);
    const el = document.getElementById(id);
    if (!el) return 0;

    const ptr = wasmInstance.allocate(4);
    const view = new Float32Array(wasmInstance.memory.buffer, ptr, 4);
    view[0] = el.scrollTop;
    view[1] = el.scrollLeft;
    view[2] = el.scrollHeight;
    view[3] = el.scrollWidth;
    return ptr;
  },

  setElementScrollWasm: (idPtr, idLen, top, left) => {
    const id = readWasmString(idPtr, idLen);
    const el = document.getElementById(id);
    if (el) {
      el.scrollTop = top;
      el.scrollLeft = left;
    }
  },
  getDevicePixelRatioWasm: () => {
    return window.devicePixelRatio;
  },

  getUserAgentWasm: () => {
    return allocString(navigator.userAgent);
  },

  getLanguageWasm: () => {
    return allocString(navigator.language);
  },

  isOnlineWasm: () => {
    return navigator.onLine ? 1 : 0;
  },
};

export function setWasiInstance(instance) {
  wasmInstance = instance;
}

// JS Side
class WasmObjectBuilder {
  constructor(wasmInstance, memory) {
    this.wasm = wasmInstance;
    this.memory = memory;
  }

  passObject(obj) {
    // Start a new object in WASM
    const handle = this.wasm.startObject();

    for (const [key, value] of Object.entries(obj)) {
      const keyPtr = allocString(key);

      switch (typeof value) {
        case "string":
          const strPtr = allocString(value);
          this.wasm.addStringField(handle, keyPtr, strPtr);
          break;
        case "number":
          if (Number.isInteger(value)) {
            this.wasm.addIntField(handle, keyPtr, value);
          } else {
            this.wasm.addFloatField(handle, keyPtr, value);
          }
          break;
        case "boolean":
          this.wasm.addBoolField(handle, keyPtr, value ? 1 : 0);
          break;
        // Add more types as needed
      }
    }

    return handle;
  }
}

// JS Side - Generic struct reader
export class DynamicStructReader {
  constructor(wasmInstance, memory) {
    this.wasm = wasmInstance;
    this.memory = memory;
    this.decoder = new TextDecoder();
  }
  readStruct(node_ptr, structPtr, fieldCount, getFieldDescriptor) {
    const result = {};

    for (let i = 0; i < fieldCount; i++) {
      let descPtr;
      if (node_ptr === null) {
        descPtr = this.wasm[getFieldDescriptor](i);
      } else {
        descPtr = this.wasm[getFieldDescriptor](node_ptr, i);
      }
      const descriptor = this.readDescriptor(descPtr);
      const fieldName = readWasmString(descriptor.namePtr, descriptor.nameLen);
      let fieldValue;
      if (descriptor.typeId === 7) {
        // Pointer scenario
        // If the field is a pointer, check if it's the start of a slice.

        const view = new DataView(this.memory.buffer, structPtr);
        const ptr = view.getUint32(descriptor.offset, true);
        // Peeking at the next descriptor (i+1)
        if (i + 1 < fieldCount) {
          const nextDescPtr = this.wasm[getFieldDescriptor](node_ptr, i + 1);
          const nextDescriptor = this.readDescriptor(nextDescPtr);

          const nextfieldName = readWasmString(
            nextDescriptor.namePtr,
            nextDescriptor.nameLen,
          );
          // Read the length from the next field's memory offset
          const len = this.readField(
            structPtr + nextDescriptor.offset,
            nextDescriptor.typeId,
            nextDescriptor.size,
            nextDescriptor.canBeNull,
          );

          // Read the string using the pair (ptr, len)
          fieldValue = readWasmString(ptr, len);

          // Skip the next iteration since we processed the length field
          i++;
        } else {
          // Not a slice, just a bare pointer.
          fieldValue = ptr;
        }
      } else {
        // --- 3. Read other types as normal ---
        fieldValue = this.readField(
          structPtr + descriptor.offset,
          descriptor.typeId,
          descriptor.size,
          descriptor.canBeNull,
        );
      }
      result[fieldName.replace("_ptr", "")] = fieldValue;
    }
    return result;
  }

  readDescriptor(ptr) {
    const view = new DataView(this.memory.buffer, ptr);
    return {
      namePtr: view.getUint32(0, true),
      nameLen: view.getUint32(4, true),
      offset: view.getUint32(8, true),
      typeId: view.getUint8(12),
      size: view.getUint32(16, true),
      canBeNull: view.getUint32(20, true),
    };
  }

  readField(ptr, typeId, size, canBeNull) {
    const view = new DataView(this.memory.buffer, ptr);

    if (canBeNull) {
      const isNull = view.getUint32(0, true);
      if (isNull === 0) {
        return null;
      }
    }

    switch (typeId) {
      case 1: // unsigned int
        return size === 1
          ? view.getUint8(0)
          : size === 2
            ? view.getUint16(0, true)
            : size === 4
              ? view.getUint32(0, true)
              : view.getBigUint64(0, true);
      case 2: // signed int
        return size === 1
          ? view.getInt8(0)
          : size === 2
            ? view.getInt16(0, true)
            : size === 4
              ? view.getInt32(0, true)
              : size === 8
                ? view.getInt32(0, true)
                : view.getBigInt64(0, true);

      case 3: // float
        return size === 4 ? view.getFloat32(0, true) : view.getFloat64(0, true);
      case 4: // bool
        return Boolean(view.getUint8(0));
      case 5: // string (u8 array) this is only when we have something liek [12]u8 i assume
        return readWasmString(ptr, size);
      case 7:
        return;
      case 8: // enum
        return view.getUint8(0, true);

      default:
        return null;
    }
  }
}
