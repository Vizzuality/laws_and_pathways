function createSVGLine(x1, y1, x2, y2) {
  const line = createSVGElement('line');
  line.setAttribute('x1', x1);
  line.setAttribute('y1', y1);
  line.setAttribute('x2', x2);
  line.setAttribute('y2', y2);
  line.setAttribute('stroke', '#666666');
  line.setAttribute('stroke-width', 1);
  line.setAttribute('class', 'generated');
  return line;
}

function createSVGText(x, y, innerText) {
  const text = createSVGElement('text');
  text.setAttribute('x', x);
  text.setAttribute('y', y);
  text.setAttribute('opacity', 1);
  text.setAttribute('style', 'fill:#666666;color:#666666;font-size:12px;');
  text.setAttribute('text-anchor', 'middle');
  text.setAttribute('class', 'generated');
  text.innerHTML = innerText;
  return text;
}

function createSVGElement(element) {
  return document.createElementNS('http://www.w3.org/2000/svg', element);
}

export function createSVGLineBelowElements(element1, element2, barWidth, offset) {
  const y = parseFloat(element1.getAttribute('y'), 10) + offset;
  return createSVGLine(
    parseFloat(element1.getAttribute('x'), 10) - barWidth / 2,
    y,
    parseFloat(element2.getAttribute('x'), 10) + barWidth / 2,
    y
  );
}

export function createSVGTextBetweenElements(element1, element2, text, offset) {
  const y = parseFloat(element1.getAttribute('y'), 10) + offset;
  const x1 = parseFloat(element1.getAttribute('x'), 10);
  const x2 = parseFloat(element2.getAttribute('x'), 10);
  const dx = x2 - x1;

  return createSVGText(x1 + dx / 2, y, text);
}
