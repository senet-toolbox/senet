createChartWasm: (idPtr, idLen, configPtr, configLen) => {
  requestAnimationFrame(() => {
    const id = readWasmString(idPtr, idLen);
    const config = readWasmString(configPtr, configLen);
    const configJson = JSON.parse(config);
    const ctx = document.getElementById(id);
    const newChart = new Chart(ctx, configJson);
    charts.set(id, newChart);
  });
},
