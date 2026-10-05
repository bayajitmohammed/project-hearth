async page => {
  // Run after joining a live room in the exported Web build.
  const errors = [];
  const onConsole = message => {
    if (message.type() === 'error' && message.text().includes('Buffer payload full')) {
      errors.push(message.text());
    }
  };
  page.on('console', onConsole);
  try {
    for (let attempt = 0; attempt < 3; attempt++) {
      await page.evaluate(() => {
        const until = performance.now() + 1200;
        while (performance.now() < until) { /* Simulate a brief main-thread stall. */ }
      });
      await page.waitForTimeout(300);
    }
    if (errors.length) throw new Error(`Snapshot buffer overflow: ${errors.length} errors`);
    return {bufferErrors: errors.length, stalls: 3, stallMilliseconds: 1200};
  } finally {
    page.off('console', onConsole);
  }
}
