// Headless smoke test for graph.html: runs the embedded script with a DOM
// stub and asserts the init path completes (no JS errors, sim runs).
// Usage: node scripts/smoke_graph_html.js  (from the repo root)
"use strict";
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const html = fs.readFileSync(path.join(root, "graph.html"), "utf8");

// extract the two <script> blocks: graph-data JSON, then app JS
const blocks = [...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/g)]
  .map(m => m[1]);
if (blocks.length !== 2) {
  console.error("expected 2 script blocks, got", blocks.length);
  process.exit(1);
}
const dataJson = blocks[0];
const appJs = blocks[1];

// syntax check first (throws on parse error)
new Function(appJs);
console.log("syntax check: OK");

// ---- minimal DOM/canvas stub ----
function makeCtx() {
  const noop = () => {};
  return new Proxy({}, {
    get: (t, k) => (k in t ? t[k] : noop),
    set: (t, k, v) => { t[k] = v; return true; },
  });
}
function makeEl(tag) {
  return {
    tagName: tag, children: [], style: {}, classList: {
      _s: new Set(),
      add(c) { this._s.add(c); },
      remove(c) { this._s.delete(c); },
      contains(c) { return this._s.has(c); },
    },
    listeners: {},
    addEventListener(t, fn) { (this.listeners[t] = this.listeners[t] || []).push(fn); },
    fire(t, ev) { (this.listeners[t] || []).forEach(fn => fn(ev || {})); },
    appendChild(c) { this.children.push(c); },
    append(...cs) { this.children.push(...cs); },
    set textContent(v) { this._text = v; },
    get textContent() { return this._text || ""; },
    set innerHTML(v) { this._html = v; },
    get innerHTML() { return this._html || ""; },
    querySelector() { return makeEl("span"); },
    getContext() { return makeCtx(); },
    clientWidth: 1200, clientHeight: 800,
    width: 0, height: 0, value: "",
  };
}
const els = {};
global.document = {
  getElementById(id) {
    if (!els[id]) els[id] = makeEl("div");
    return els[id];
  },
  createElement(tag) { return makeEl(tag); },
  createTextNode(t) { return makeEl("text"); },
};
global.window = {
  devicePixelRatio: 1,
  addEventListener: () => {},
};
els["graph-data"] = makeEl("script");
els["graph-data"].textContent = dataJson;

// run the app script with real timers, then let the sim settle
const timers = [];
const realSetInterval = setInterval;
global.setInterval = (fn, ms) => { timers.push({ fn, ms }); return timers.length; };
global.clearInterval = () => {};

new Function(appJs)();
console.log("app init: OK");

// drive the simulation timer until it stops (virtual ticks)
let guard = 0;
const iv = timers[0];
while (iv && guard < 2100) {
  iv.fn();
  guard++;
  if (!timers.length) break;
}
// simTick stops via stopSim -> clearInterval (stubbed); check status text
const status = els["status"] ? els["status"].textContent : "";
console.log("status after", guard, "timer runs:", JSON.stringify(status));
if (!/nodes/.test(status)) {
  console.error("FAIL: status text missing node count");
  process.exit(1);
}
if (!/layout (running|settled)/.test(status)) {
  console.error("FAIL: unexpected status format");
  process.exit(1);
}
const legendRows = els["legendrows"].children.length;
const filterRows = els["filterrows"].children.length;
console.log("legend rows:", legendRows, "| filter checkboxes:", filterRows);
const typeCount = new Set(JSON.parse(dataJson).edges.map(e => e.type)).size;
if (legendRows < 4 || filterRows !== typeCount) {
  console.error("FAIL: legend/filter rows wrong (expected", typeCount, "edge-type filters,", ">=4 legend rows)");
  process.exit(1);
}
// ---- exercise search and selection via captured listeners ----
// data-driven: use the graph's own nodes, not hardcoded project IDs
const graphData = JSON.parse(dataJson);
const sample = graphData.nodes.find(n => n.excerpt) || graphData.nodes[0];
const sampleId = sample.id;
const frag = sampleId.replace(/^[A-Z]+-?/i, "") || sampleId;
const search = els["search"];
search.value = sampleId;
search.fire("input");
if (search.value !== sampleId) { console.error("FAIL: search wiring"); process.exit(1); }
const mi = els["matchinfo"].textContent;
console.log("search '" + sampleId + "' -> matchinfo:", JSON.stringify(mi));
if (!/^1\/[1-9]/.test(mi) || els["sp-id"].textContent !== sampleId) {
  console.error("FAIL: exact id search (first match must be " + sampleId + ")");
  process.exit(1);
}
// fragment search
search.value = frag;
search.fire("input");
const mi2 = els["matchinfo"].textContent;
console.log("search '" + frag + "' -> matchinfo:", JSON.stringify(mi2));
if (!/^1\/[1-9]/.test(mi2)) { console.error("FAIL: fragment search"); process.exit(1); }
// Enter jumps to next match without throwing
search.fire("keydown", { key: "Enter", preventDefault: () => {} });
console.log("after Enter:", JSON.stringify(els["matchinfo"].textContent));
// side panel opened by focusNode during search: check content
if (!els["sidepanel"].classList.contains("open")) {
  console.error("FAIL: side panel not open after focus"); process.exit(1);
}
console.log("side panel id:", JSON.stringify(els["sp-id"].textContent),
  "| edge groups rendered:", els["sp-body"].children.length > 0);
// ---- excerpt rendering ------------------------------------------------------
const data = JSON.parse(dataJson);
const withEx = data.nodes.filter(n => n.excerpt);
console.log("nodes with excerpt:", withEx.length + "/" + data.nodes.length);
if (!withEx.length) { console.error("FAIL: no excerpts in graph data"); process.exit(1); }
// cap: whitespace-normalized, <= 800 chars, ellipsis when capped
for (const n of withEx) {
  if (n.excerpt.length > 800 || /\s{2,}|\n/.test(n.excerpt)) {
    console.error("FAIL: excerpt cap/normalization violated at", n.id,
      "len", n.excerpt.length); process.exit(1);
  }
}
const capped = withEx.filter(n => n.excerpt.endsWith("…"));
console.log("capped excerpts (<= 800 + ellipsis):", capped.length);
// a capped excerpt only exists when some register entry exceeds 800 chars -
// assert the invariant conditionally (small projects legitimately have none)
if (withEx.some(n => n.excerpt.length === 800 && !n.excerpt.endsWith("…"))) {
  console.error("FAIL: 800-char excerpt without ellipsis (cap violated)"); process.exit(1);
}
// known node: the sampled node must show its register text in the side panel
const req001 = sample;
if (!req001 || !req001.excerpt) {
  console.error("FAIL: sample node excerpt missing in graph data"); process.exit(1);
}
search.value = sampleId;
search.fire("input");
if (els["sp-id"].textContent !== sampleId) {
  console.error("FAIL: could not select " + sampleId); process.exit(1);
}
if (els["sp-excerpt"].textContent !== req001.excerpt) {
  console.error("FAIL: side panel excerpt mismatch for " + sampleId); process.exit(1);
}
console.log(sampleId + " excerpt in panel:",
  JSON.stringify(els["sp-excerpt"].textContent.slice(0, 70)) + "...");
// node without excerpt renders cleanly (element cleared + hidden)
const bare = data.nodes.find(n => !n.excerpt);
search.value = bare.id;
search.fire("input");
if (els["sp-id"].textContent !== bare.id) {
  console.error("FAIL: could not select", bare.id); process.exit(1);
}
if (els["sp-excerpt"].textContent !== "" || els["sp-excerpt"].style.display !== "none") {
  console.error("FAIL: excerpt element not cleared/hidden for", bare.id); process.exit(1);
}
console.log("no-excerpt node", bare.id, "renders cleanly");
// toggle one edge-type filter off/on (only when edge types exist - a fresh
// template project has 0 edges and therefore 0 filter checkboxes)
if (els["filterrows"].children.length) {
  const cb0 = els["filterrows"].children[0].children[0];
  cb0.checked = false;
  cb0.fire("change");
}
console.log("SMOKE TEST PASSED");
