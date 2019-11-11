import React, { Fragment, PureComponent } from 'react';
import ReactTooltip from 'react-tooltip';
import { pack, hierarchy } from 'd3-hierarchy';
import { format } from 'd3-format';
import { range } from 'd3-array';
import { select } from 'd3-selection';
import tip from 'd3-tip';
import * as d3 from 'd3-force';
import cx from 'classnames';

class SingleBubbleChart extends PureComponent {
  chartDataCalculation = (width, data) => {
    const diameter = width - 10;
    const bubble = pack().size([ diameter, diameter ]).padding(1.5);
    const parsedData = { name: 'themes', children: data };
    const root = hierarchy(parsedData)
      .sum(d => d.value)
      .sort((a, b) => b.value - a.value);
    return bubble(root);
  };

  render() {
    const {
      width,
      height,
      handleNodeClick,
      data,
      tooltipClassName,
      config,
      uniqueKey
    } = this.props;
    const charData = data && this.chartDataCalculation(width, data);

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
     
      const v = u.enter()
        .append('circle')
        .attr('r', function(d) {
          return d.radius;
        })
        .style('fill', function(d) {
          return d.color;
        })
        .merge(u)
        .attr('cx', function(d) {
          return d.x;
        })
        .attr('cy', function(d) {
          return d.y;
        })
        .attr('data-for', function(d) {
          return "chartTooltip"
        })
        .on('mouseover', d3Tip.show)
        .on('mouseout', d3Tip.hide)
    
      v.call(d3Tip);
      u.exit().remove();
    }

    simulation();

    return (
      <Fragment> {/* 40 -16 ${width} ${height} */}
        <svg id={key} width={width} height={'38px'} viewBox="0 -100 400 400">
          <g className='bubble-chart_circle' transform="translate(200, 100)"></g>
        </svg>
        {/* <svg width={width} height='38px' viewBox={`0 0 ${width} ${height}`}>
          {
            charData && charData.children.map(d => (
              <g
                key={`${d.value}-${Math.random()}`}
                // transform={`translate(${d.x * 2.5},${d.y / 1.8})`}
                transform={`translate(${d.x},${d.y}) scale(1,-1)`}
                className='bubble-chart_circle'
                onClick={e => handleNodeClick(e, d.data.id)}
              >
                <circle
                  r={charData.children.length > 2 ? d.r : d.value}
                  data-for="chartTooltip"
                  data-tip={this.getTooltipText(d.data, config)}
                  fill={d.data.color}
                />
              </g>
              ))
          }
        </svg>*/}
        <ReactTooltip
          place="left"
          id="chartTooltip"
          className={cx('reactTooltipWhite', tooltipClassName)}
          multiline
        />
      </Fragment>
    );
  }
}

export default SingleBubbleChart;