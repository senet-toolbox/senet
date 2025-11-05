import {
  eventHandlers,
  elementDimensions,
  eventStorage,
  beforeHooksHandlers,
  afterHooksHandlers,
  observers,
} from "./maps.js";
import {
  allocString,
  readWasmString,
  rerenderRoute,
  requestRerender,
  styleSheet,
} from "./wasi_obj.js";

let wasmInstance = null;

let structBridge = undefined;

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

  // Read any struct generically
  readStruct(structName, ptr) {
    const schema = this.schemas.get(structName);
    if (!schema) {
      throw new Error(`Schema not registered for: ${structName}`);
    }

    const memory = new DataView(this.wasm.memory.buffer);
    const result = {};

    for (const field of schema) {
      const fieldPtr = ptr + field.offset;
      result[field.name] = this.readField(memory, fieldPtr, field.type);
    }

    return result;
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
  removeElementEventListener: (idPtr, idLen, ptr, len, id) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const memory = new Uint8Array(wasmInstance.memory.buffer);

    const elementId = new TextDecoder().decode(
      memory.subarray(idPtr, idPtr + idLen),
    );

    const element = document.getElementById(elementId);

    const event_type = new TextDecoder().decode(
      memory.subarray(ptr, ptr + len),
    );

    const cb = eventHandlers.get(`fb-evt-hd-${id}-${elementId}`);
    element.removeEventListener(event_type, cb);
  },
  createElementEventInstListener: (idPtr, idLen, ptr, len, onid) => {
    requestAnimationFrame(() => {
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
        console.log("Is Null");
        return;
      }

      // const event_type = new TextDecoder().decode(
      //   memory.subarray(ptr, ptr + len),
      // );
      //
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
    });
  },

  createElementEventListener: (idPtr, idLen, ptr, len, onid) => {
    // requestAnimationFrame(() => {
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
      eventStorage[event_id] = event;
      wasmInstance.eventCallback(event_id);
    };

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
    // });
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
      wasmInstance.eventCallback(id);
    });
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

  getEventDataNumberWasm: (id, ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }

    const memory = new Uint8Array(wasmInstance.memory.buffer);
    const key = new TextDecoder().decode(memory.subarray(ptr, ptr + len));
    const event = eventStorage[id];
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

  eventPreventDefault: (id, ptr, len) => {
    if (!wasmInstance) {
      console.error("WASM instance not initialized");
      return;
    }
    const event = eventStorage[id];
    event.preventDefault();
  },

  timeout: (ms, callbackId) => {
    setTimeout(() => {
      wasmInstance.buttonCallback(callbackId);
    }, ms);
  },

  timeoutCtx: (ms, callbackId) => {
    setTimeout(() => {
      wasmInstance.timeoutCtxCallBackId(callbackId);
    }, ms);
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
  fetchWasm: (urlPtr, urlLen, callback_id) => {
    // Decode URL string out of WASM memory
    const urlBytes = new Uint8Array(wasmInstance.memory.buffer, urlPtr, urlLen);
    const url = new TextDecoder().decode(urlBytes);

    // Fire off the fetch
    fetch(url)
      .then((res) => res.text())
      .then((text) => {
        // Encode the response back into WASM memory
        const ptr = allocString(text); // assume you exposed an `alloc` func

        // Call back into Zig
        wasmInstance.resumeCallback(callback_id, ptr);
      })
      .catch((err) => {
        console.error("Fetch failed:", err);
        // You could call callback with ptr=0,len=0 or export an error handler
      });
  },

  destroyObserverWasm(ptr, len) {
    observers.delete(readWasmString(ptr, len));
  },

  reinitObserverWasm(ptr, len) {
    const name = readWasmString(ptr, len);
    const observer = observers.get(name);

    if (!observer) {
      console.warn(`Observer ${name} not found`);
      return;
    }

    // Get all sections
    const sections = document.querySelectorAll("section");

    // Note: There's no direct way to get observed elements from IntersectionObserver
    // So we track them or re-observe all

    // Option A: Disconnect and re-observe everything with updated indices
    observer.disconnect();
    sections.forEach((section, index) => {
      section.dataset.sectionIndex = index;
      observer.observe(section);
    });
  },

  createObserverWasm(ptr, len, optionsPtr) {
    const reader = new StructReader(wasmInstance.memory, optionsPtr);

    const opts = structBridge.readStruct("ObserverOptions", optionsPtr);

    const options = {
      threshold: reader.f32(),
      rootMargin: `${opts.rootMargin_top}px ${opts.rootMargin_right}px ${opts.rootMargin_bottom}px ${opts.rootMargin_left}px`,
      root: null,
    };

    const name = readWasmString(ptr, len);
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        const callback_id = allocString(name);
        const data_ptr = allocString(entry.target.id);
        // Get the actual index from the dataset
        const actualIndex = parseInt(entry.target.dataset.sectionIndex, 10);
        // console.log("Section", entry.target.id, actualIndex);
        wasmInstance.callbackCtx(
          callback_id,
          data_ptr,
          entry.isIntersecting,
          actualIndex, // Use the stored index instead of forEach index
        );
      });
    }, options);

    // Store the index on each section as you observe it
    document.querySelectorAll("section").forEach((section, index) => {
      section.dataset.sectionIndex = index;
      observer.observe(section);
    });
    observers.set(name, observer);
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
};

export function setWasiInstance(instance) {
  wasmInstance = instance;
}
