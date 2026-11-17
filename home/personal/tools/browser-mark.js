// browser-mark.js — draw a mark over a page to show something to the user (USER.PREF.11).
// Run: Claude in Chrome → javascript_tool, paste this file, then call one line at the end, e.g.
//   mark({row: /täiustatud/, also: /6,000/, cell: /^\s*1[\s  ]?500,0\s*$/})
//   mark({selector: '#total'}, {color: '#FF3B30', shape: 'box', label: 'here', blink: true})
//   unmark()
// Defaults: blinks and disappears after 7 s (blink: false, ttl: 0 = stays). Returns x/y — then hover the cursor there.
// Only visual: an absolutely positioned div inside the target (clicks pass through), gone on reload.
// Right-aligned numbers: the mark hugs the right edge of the cell (align: 'right', default for table cells).

// The same text may also exist under an overlay (e.g. the page behind a modal) → prefer the copy that is on top.
function isOnTop(el) {
  const r = el.getBoundingClientRect();
  const hit = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2);
  return !!hit && (hit === el || el.contains(hit) || hit.contains(el));
}

function findText(re) {
  const leaves = [...document.querySelectorAll('body *')]
    .filter(e => re.test(e.textContent) && ![...e.children].some(c => re.test(c.textContent)));
  return leaves.find(isOnTop) || leaves[0] || null;
}

function findTarget(q) {
  if (q.selector) return document.querySelector(q.selector);
  if (q.text) return findText(q.text);
  const rows = [...document.querySelectorAll('tr')]
    .filter(r => q.row.test(r.textContent) && (!q.also || q.also.test(r.textContent)));
  for (const r of rows) {
    const td = [...r.querySelectorAll('td,th')].find(c => q.cell.test(c.textContent));
    if (td) return td;
  }
  return null;
}

function mark(q, o = {}) {
  const el = findTarget(q);
  if (!el) return {found: false};
  const color = o.color || '#FFD400', w = o.width || 84, h = o.height || 56;
  const align = o.align || (el.tagName === 'TD' || el.tagName === 'TH' ? 'right' : 'center');
  if (getComputedStyle(el).position === 'static') el.style.position = 'relative';
  const m = document.createElement('div');
  m.className = 'claude-mark';
  m.style.cssText = `position:absolute;top:50%;width:${w}px;height:${h}px;border:6px solid ${color};`
    + `border-radius:${o.shape === 'box' ? '6px' : '50%'};pointer-events:none;z-index:9999;`
    + 'box-shadow:0 0 6px rgba(0,0,0,.4);'
    + (align === 'right' ? 'right:-6px;transform:translateY(-50%);' : 'left:50%;transform:translate(-50%,-50%);');
  if (o.label) {
    const t = document.createElement('span');
    t.textContent = o.label;
    t.style.cssText = `position:absolute;bottom:100%;right:0;background:${color};color:#000;`
      + 'font:bold 12px sans-serif;padding:1px 4px;border-radius:3px;white-space:nowrap';
    m.appendChild(t);
  }
  // with a label: steady and kept until the page / dialog goes away; without: blinks for 7 s
  const blink = o.blink ?? !o.label, ttl = o.ttl ?? (o.label ? 0 : 7);
  if (blink) {
    if (!document.getElementById('claude-mark-style')) {
      const s = document.createElement('style');
      s.id = 'claude-mark-style';
      s.textContent = '@keyframes claudeBlink{0%,100%{opacity:1}50%{opacity:.1}}'
        + ' .claude-blink{animation:claudeBlink .8s ease-in-out infinite}';
      document.head.appendChild(s);
    }
    m.classList.add('claude-blink');
  }
  el.appendChild(m);
  el.scrollIntoView({block: 'center'});
  if (ttl > 0) setTimeout(() => m.remove(), ttl * 1000);
  // cursor: hover (computer tool) at x/y — CSS pixels; screenshot frame may differ (page zoom / DPR):
  // multiply by <screenshot frame width> / vw (≈ 0.75 here), or take a screenshot and aim from it
  const r = el.getBoundingClientRect();
  return {found: true, text: el.textContent.trim(), vw: window.innerWidth,
    x: Math.round(align === 'right' ? r.right - 30 : r.left + r.width / 2), y: Math.round(r.top + r.height / 2)};
}

function unmark() {
  document.querySelectorAll('.claude-mark').forEach(m => m.remove());
  return 'removed';
}

// keep for later calls in this tab (until reload); check: typeof window.mark
Object.assign(window, {isOnTop, findText, findTarget, mark, unmark});
