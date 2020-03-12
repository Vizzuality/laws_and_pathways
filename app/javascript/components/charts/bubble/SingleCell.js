import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { range } from 'd3-array';
import { select } from 'd3-selection';
import * as d3 from 'd3-force';

const SingleCell = ({ width, height, handleNodeClick, data, uniqueKey, showTooltip, hideTooltip }) => {
  const computizedKey = uniqueKey.split(' ').join('_');
  const key = `${computizedKey.replace(/[&]/g, '_')}-${(Math.random() * 100).toFixed()}`;

  const nodes = range(data.length).map(function (index) {
    return {
      color: data[index].color,
      tooltipContent: data[index].tooltipContent,
      slug: data[index].slug,
      radius: data[index].value
    };
  });

  const simulation = () => {
    d3.forceSimulation(nodes)
      .force('charge', d3.forceManyBody().strength(3))
      .force('y', d3.forceY().y(0))
      .force('collision',
        d3.forceCollide().radius(function (d) {
          return d.radius + 1;
        }))
      .on('tick', ticked);
  };

  const ticked = () => {
    const u = select(`#${key}`)
      .select('g')
      .selectAll('circle')
      .data(nodes);

    u.enter()
      .append('circle')
      .attr('r', (d) => d.radius)
      .style('fill', (d) => d.color)
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
      <svg id={key} width="100%" height="100%" viewBox={`0 0 ${width} ${height}`}>
        <g className="bubble-chart_circle" transform={`translate(${width / 2}, ${height / 2})`} />
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
  data: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.array
  ]).isRequired,
  uniqueKey: PropTypes.string.isRequired
};

export default SingleCell;
