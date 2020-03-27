export function createSVGGroup(className) {
  const group = createSVGElement('g');
  group.setAttribute('class', className);
  group.setAttribute('opacity', 0.3);
  return group;
}

function createSVGText(x, y, innerText) {
  const text = createSVGElement('text');
  text.setAttribute('x', x);
  text.setAttribute('y', y);
  text.setAttribute('opacity', 1);
  text.setAttribute('style', 'fill:#666666;color:#666666;font-size:12px;');
  text.setAttribute('text-anchor', 'left');
  text.setAttribute('class', 'generated');
  text.innerHTML = innerText;
  return text;
}

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

export function renderBenchmarksLabels(chart, isMobile = false) {
  const g = document.querySelector('.chart--cp-performance g.highcharts-series-group');

  [...g.querySelectorAll('.generated')].forEach((el) => el.remove()); // cleanup

  const areas = chart.series.filter(s => s.type === 'area');
  const benchmarks = areas.map((area) => {
    const lastPoint = area.points.length && area.points.slice(-1)[0];

    if (!lastPoint) return null;

    return {
      name: area.name,
      maxY: area.yAxis.height,
      point: {
        x: area.xAxis.toPixels(lastPoint.x),
        y: area.yAxis.toPixels(lastPoint.y)
      }
    };
  }).filter(x => x);

  let lastLabelY = 0;
  const minLabelSpacing = 20;
  const labelToAreaSpacing = 15;

  // benchmarks from top to bottom
  benchmarks.forEach((benchmark, idx) => {
    const lastPointX = benchmark.point.x;
    let lastPointY = benchmark.point.y;

    const nextBenchmark = benchmarks[idx + 1];
    const offsetTo = nextBenchmark ? nextBenchmark.point.y : benchmark.maxY;
    lastPointY += Math.abs((offsetTo - lastPointY) / 2);

    const textX = lastPointX + labelToAreaSpacing;
    // ensure minimum spacing to the previous label
    const textY = (lastPointY > lastLabelY + minLabelSpacing)
      ? lastPointY
      : lastLabelY + minLabelSpacing;
    lastLabelY = textY;

    const text = createSVGText(textX, textY, benchmark.name);
    const line = createSVGLine(lastPointX, lastPointY, textX, textY);
    g.appendChild(text);


    if (isMobile) {
      const textWidth = text.getBBox().width;
      const transformAttr = ` translate(-${textWidth + labelToAreaSpacing + 5},0)`;
      text.setAttribute('transform', transformAttr);
    } else {
      g.appendChild(line);
    }
  });
}
