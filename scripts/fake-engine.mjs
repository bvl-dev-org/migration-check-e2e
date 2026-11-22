// Stand-in for the BVL engine in the end-to-end workflow only. `node scripts/fake-engine.mjs 500 8500` answers every request
// with HTTP 500; `node scripts/fake-engine.mjs hang 8501` accepts requests and never answers (the Action's 30 s timeout).
import http from 'node:http';

const [mode, port] = process.argv.slice(2);
http.createServer((req, res) => {
  req.resume();
  if (mode === '500') {
    res.statusCode = 500;
    res.end('fake engine: HTTP 500');
  }
}).listen(Number(port), '127.0.0.1', () => process.stdout.write(`fake engine (${mode}) on 127.0.0.1:${port}\n`));
