import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import { getOptions } from './options';

function MQLevelChart({ dataUrl }) {
  const [data, setData] = useState([]);
  const [error, setError] = useState('');

  const options = getOptions({ chartData: data });

  useEffect(() => {
    fetch(dataUrl)
      .then((r) => r.json())
      .then((chartData) => {
        setData(chartData);
      })
      .catch(() => setError('Error while loading the data'));
  }, [dataUrl]);

  return (
    <div className="chart chart--mq-level">
      {error && (
        <div>
          <p>{error}</p>
        </div>
      )}

      <HighchartsReact
        highcharts={Highcharts}
        options={options}
      />
    </div>
  );
}

MQLevelChart.propTypes = {
  dataUrl: PropTypes.string.isRequired
};

export default MQLevelChart;
