export function createSVGGroup(className) {
  const group = createSVGElement('g');
  group.setAttribute('class', className);
  group.setAttribute('opacity', 0.3);
  return group;
}

export function createSVGElement(element) {
  return document.createElementNS('http://www.w3.org/2000/svg', element);
}

export function groupAllAreaSeries() {
  // this will group all area series under one element
  // it will be possible to set opacity for all areas at once to make it looks as on designs
  const seriesGroup = document.querySelector('.chart--cp-performance g.highcharts-series-group');
  const groupedAreas = seriesGroup.querySelector('.areas-group') || createSVGGroup('areas-group');
  const series = [...seriesGroup.querySelectorAll('g.highcharts-area-series')];

  seriesGroup.appendChild(groupedAreas);

  series.forEach(serie => {
    groupedAreas.appendChild(serie);
  });
}
