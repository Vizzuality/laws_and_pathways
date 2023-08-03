import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useChartData } from '../hooks';
import CPMatrixTable from './cp-matrix-table';

function Tabs({ selectedTabIndex, setSelectedTabIndex }) {
  return (
    <div className="matrix-tabs">
      {[
        'Short-term alignment',
        'Medium-term alignment',
        'Long-term alignment'
      ].map((text, index) => (
        <div key={`tab${index}`}>
          <button
            className={`button tab ${
              selectedTabIndex === index ? 'active' : ''
            }`}
            onClick={() => setSelectedTabIndex(index)}
            type="button"
          >
            {text}
          </button>
        </div>
      ))}
    </div>
  );
}

Tabs.propTypes = {
  selectedTabIndex: PropTypes.number.isRequired,
  setSelectedTabIndex: PropTypes.func.isRequired
};

function CPMatrix({ data: dataUrl }) {
  const { data, error, loading } = useChartData(dataUrl);
  const { meta, data: chartData } = data || {};
  const [selectedTabIndex, setSelectedTabIndex] = useState(0);
  if (loading) return <p>Loading...</p>;
  if (error) return <p>{error}</p>;
  const tableData = chartData && Object.values(chartData)?.[selectedTabIndex];
  return (
    <div id="cp-matrix">
      <Tabs
        selectedTabIndex={selectedTabIndex}
        setSelectedTabIndex={setSelectedTabIndex}
      />
      <CPMatrixTable data={tableData} meta={meta} />
    </div>
  );
}

CPMatrix.propTypes = {
  data: PropTypes.string.isRequired
};

export default CPMatrix;
