import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { range } from 'd3-array';
import { select } from 'd3-selection';
import * as d3 from 'd3-force';

import { partialGradient } from './constants';

const SingleCell = ({
  width,
  height,
  handleNodeClick,
  data,
  uniqueKey,
  showTooltip,
  hideTooltip
}) => {
  const computizedKey = uniqueKey.split(' ').join('_');
  const key = `${computizedKey.replace(/[&]/g, '_')}-${(
    Math.random() * 100
  ).toFixed()}`;

  const nodes = range(data.length).map(function (index) {
    return {
      color: data[index].color,
      tooltipContent: data[index].tooltipContent,
      path: data[index].path,
      radius: data[index].value,
      value: data[index].result
    };
  });

  const simulation = () => {
    d3.forceSimulation(nodes)
      .force('charge', d3.forceManyBody().strength(60))
      .force('y', d3.forceY().strength(0.45).y(0))
      .force(
        'collision',
        d3.forceCollide().radius(function (d) {
          return d.radius + 1;
        })
      )
      .on('tick', ticked);
  };

  const ticked = () => {
    const u = select(`#${key}`).select('g').selectAll('circle').data(nodes);

    u.enter()
      .append('circle')
      .attr('r', (d) => d.radius)
      .style('fill', (d) => (d.value === 'Partial' ? 'url(#partial-gradient)' : d.color))
      .style('stroke', (d) => d.color)
      .merge(u)
      .attr('cx', (d) => d.x)
      .attr('cy', (d) => d.y)
      .on('mouseover', (d) => showTooltip(d, u))
      .on('mouseout', hideTooltip)
      .on('click', (d) => handleNodeClick(d));

    u.exit().remove();
  };

  simulation();

  return (
    <Fragment>
      <svg
        id={key}
        width="100%"
        height="100%"
        viewBox={`0 0 ${width} ${height}`}
      >
        <defs>
          <pattern
            id="partial-gradient"
            patternUnits="userSpaceOnUse"
            width="2"
            height="8"
            patternTransform="rotate(90)"
          >
            <rect
              width="1"
              height="8"
              transform="translate(0,0)"
              fill={partialGradient.color}
            />
          </pattern>
        </defs>
        <g
          className="bubble-chart_circle_country"
          transform={`translate(${width / 2}, ${height / 2})`}
        />
      </svg>
    </Fragment>
  );
};

SingleCell.propTypes = {
  showTooltip: PropTypes.func.isRequired,
  hideTooltip: PropTypes.func.isRequired,
  width: PropTypes.number.isRequired,
  height: PropTypes.number.isRequired,
  handleNodeClick: PropTypes.func.isRequired,
  data: PropTypes.oneOfType([PropTypes.number, PropTypes.array]).isRequired,
  uniqueKey: PropTypes.string.isRequired
};

export default SingleCell;
