import React, { Fragment, PureComponent } from 'react';
import { range } from 'd3-array';
import { select } from 'd3-selection';
import tip from 'd3-tip';
import * as d3 from 'd3-force';

const CELL_HEIGHT = 55; // same as cell height in bubble_chart.scss

class SingleBubbleChart extends PureComponent {
  render() {
    const {
      width,
      height,
      handleNodeClick,
      data,
      uniqueKey
    } = this.props;

    const computizedKey = uniqueKey.split(' ').join('_');
    const key = `${computizedKey.replace(/[&]/g, "_")}-${(Math.random()*100).toFixed()}`;
    const d3Tip = tip().attr('class', 'd3-tip').html(function(d) { return getTooltipText(d) })
    
    const nodes = range(data.length).map(function(index) {
      return {
        color: data[index].color,
        tooltipContent: data[index].tooltipContent,
        radius: data[index].value
      }
    });

    const getTooltipText = ({ tooltipContent }) => {
      if (tooltipContent && tooltipContent.length) {
        return tooltipContent.join('<br>');
      }
      return '';
    };

    const simulation = () => {
      d3.forceSimulation(nodes)
      .force('charge', d3.forceManyBody().strength(10))
      .force('y', d3.forceY().y(0))
      .force('collision',
        d3.forceCollide().radius(function(d) {  
          return d.radius + 1;
        }))
      .on('tick', ticked);
    };
    
    const ticked = () => {
      const u = select(`#${key}`)
        .select('g')
        .selectAll('circle')
        .data(nodes);
     
      const visualisation = u.enter()
        .append('circle')
        .attr('r', (d) => d.radius)
        .style('fill', (d) => d.color)
        .merge(u)
        .attr('cx', (d) => d.x)
        .attr('cy', (d) => d.y)
        .on('mouseover', d3Tip.show)
        .on('mouseout', d3Tip.hide)
    
      visualisation.call(d3Tip); // bind the d3 tooltip with the visualisation
      u.exit().remove();
    }

    simulation();

    return (
      <Fragment>
        <svg id={key} width={width} height={height} viewBox={`0 -${CELL_HEIGHT} 400 400`}>
          <g className='bubble-chart_circle' transform="translate(200, 100)"></g>
        </svg>
      </Fragment>
    );
  }
}

export default SingleBubbleChart;