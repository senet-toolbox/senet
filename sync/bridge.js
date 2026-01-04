// ============ host.js (the glue) ============
class WasmModuleBridge {
  constructor() {
    this.cacheModule = null;
    this.syncModule = null;
  }

  async load() {
    // Load cache module first (no imports needed)
    const cacheWasm = await WebAssembly.instantiateStreaming(
      fetch("cache_layer.wasm"),
      { env: {} },
    );
    this.cacheModule = cacheWasm.instance;

    // Load sync module with imports that bridge to cache
    const syncWasm = await WebAssembly.instantiateStreaming(
      fetch("sync_engine.wasm"),
      {
        env: {
          db_get: (keyPtr, keyLen, outPtr, outMax) => {
            return this.bridgeGet(keyPtr, keyLen, outPtr, outMax);
          },
          db_set: (keyPtr, keyLen, valPtr, valLen) => {
            return this.bridgeSet(keyPtr, keyLen, valPtr, valLen);
          },
        },
      },
    );
    this.syncModule = syncWasm.instance;
  }

  bridgeGet(keyPtr, keyLen, outPtr, outMax) {
    const cache = this.cacheModule.exports;
    const sync = this.syncModule.exports;

    // Read key from sync module's memory
    const syncMem = new Uint8Array(sync.memory.buffer);
    const key = syncMem.slice(keyPtr, keyPtr + keyLen);

    // Allocate in cache module, copy key there
    const cacheKeyPtr = cache.alloc(keyLen);
    const cacheMem = new Uint8Array(cache.memory.buffer);
    cacheMem.set(key, cacheKeyPtr);

    // Allocate output buffer in cache module
    const cacheOutPtr = cache.alloc(outMax);

    // Call cache_get
    const result = cache.cache_get(cacheKeyPtr, keyLen, cacheOutPtr, outMax);

    // If successful, copy result back to sync module
    if (result > 0) {
      const value = cacheMem.slice(cacheOutPtr, cacheOutPtr + result);
      syncMem.set(value, outPtr);
    }

    // Free cache module allocations
    cache.dealloc(cacheKeyPtr, keyLen);
    cache.dealloc(cacheOutPtr, outMax);

    return result;
  }

  bridgeSet(keyPtr, keyLen, valPtr, valLen) {
    const cache = this.cacheModule.exports;
    const sync = this.syncModule.exports;

    // Read from sync module
    const syncMem = new Uint8Array(sync.memory.buffer);
    const key = syncMem.slice(keyPtr, keyPtr + keyLen);
    const val = syncMem.slice(valPtr, valPtr + valLen);

    // Allocate and copy to cache module
    const cacheMem = new Uint8Array(cache.memory.buffer);
    const cacheKeyPtr = cache.alloc(keyLen);
    const cacheValPtr = cache.alloc(valLen);
    cacheMem.set(key, cacheKeyPtr);
    cacheMem.set(val, cacheValPtr);

    // Call cache_set
    const result = cache.cache_set(cacheKeyPtr, keyLen, cacheValPtr, valLen);

    // Free (cache_set dupes internally)
    cache.dealloc(cacheKeyPtr, keyLen);
    cache.dealloc(cacheValPtr, valLen);

    return result;
  }
}
