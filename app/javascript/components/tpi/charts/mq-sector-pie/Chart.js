import React, { useMemo } from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { getOptions } from './options';
import { useChartData } from '../hooks';
import hoverIcon from 'images/icons/hover-cursor.svg';
import InfoTooltip from '../../InfoTooltip';

const LEVELS_SUBTITLES = {
  0: 'Unaware',
  1: 'Awareness',
  2: 'Building capacity',
  3: 'Integrating into operational decision making',
  4: 'Strategic assessment',
  5: 'Transition planning and implementation'
};

function MQSectorChart({ dataUrl }) {
  const { data, loading, error } = useChartData(dataUrl);
  const options = getOptions({ chartData: data });

  const ref = React.useRef(null);

  if (window.innerWidth < 600) {
    options.chart.width = 290;
  }

  const legendData = useMemo(() => {
    if (!data) return [];
    const total = data.reduce((acc, [, value]) => acc + value, 0);

    return data.map(([name, value]) => ({
      name,
      value,
      percentage: ((value / total) * 100).toFixed(1)
    }));
  }, [data]);

  return (
    <div className="mq-sector-pie-chart">
      <div className="mq-sector-pie-chart-title">
        <img src={hoverIcon} alt="Hover icon" />
        <p>
          <span className="--mobile">Click on</span>
          <span className="--desktop">Hover over</span>{' '}
          the chart sections to see each level value.
        </p>
      </div>
      <div className="chart--styled chart--mq-sector-pie-chart">
        {loading ? (
          <p>Loading...</p>
        ) : (
          <React.Fragment>
            {error ? (
              <p>{error}</p>
            ) : (
              <React.Fragment>
                <HighchartsReact
                  ref={ref}
                  highcharts={Highcharts}
                  options={options}
                />

              </React.Fragment>
            )}
            <div className="chart-legends">
              {legendData?.map((item, index) => (
                <div key={index} className="chart-legend-item">
                  <div>
                    <div className="chart-legend-item__name">
                      <div
                        className="chart-legend-item__color"
                        style={{ backgroundColor: options.colors[index] }}
                      />
                      <p>Level {item.name}</p>
                      <InfoTooltip
                        content={LEVELS_SUBTITLES[index]}
                        trigger={<span className="button is-secondary is-info" type="button">?</span>}
                      />
                    </div>
                    <p className="chart-legend-item__value">
                      {item.value} {item.value === 1 ? 'company' : 'companies'} - {item.percentage}%
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </React.Fragment>
        )}
      </div>
    </div>
  );
}

MQSectorChart.propTypes = {
  dataUrl: PropTypes.string.isRequired
};

export default MQSectorChart;
