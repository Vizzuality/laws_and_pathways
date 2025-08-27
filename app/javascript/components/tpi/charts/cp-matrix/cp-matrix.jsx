import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { useChartData } from '../hooks';
import CPMatrixTable from './cp-matrix-table';

function Tabs({ selectedTabIndex, setSelectedTabIndex }) {
  return (
    <div className="matrix-tabs">
      {[
        'Short-term alignment 2030',
        'Medium-term alignment 2035',
        'Long-term alignment 2050'
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
  const [params, setParams] = useState({});

  useEffect(() => {
    const select = document.querySelector('select[name="cp_assessment_date"]');
    const onChange = () => setParams(select?.value ? { cp_assessment_date: select.value } : {});
    onChange();
    select?.addEventListener('change', onChange);
    return () => select?.removeEventListener('change', onChange);
  }, []);

  const { data, error, loading } = useChartData(dataUrl, params);
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
