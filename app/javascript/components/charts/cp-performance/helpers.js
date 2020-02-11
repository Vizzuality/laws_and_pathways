export function createSVGGroup(className) {
  const group = createSVGElement('g');
  group.setAttribute('class', className);
  group.setAttribute('opacity', 0.3);
  return group;
}

export function createSVGElement(element) {
  return document.createElementNS('http://www.w3.org/2000/svg', element);
}
