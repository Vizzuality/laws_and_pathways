import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { useChartData } from '../hooks';
import CPMatrixTable from './cp-matrix-table';

function Tabs({ selectedTabIndex, setSelectedTabIndex, assessmentDate }) {
  // Determine alignment years based on assessment date
  const getAlignmentYears = (date) => {
    if (!date) return ['2030', '2035', '2050'];

    const year = new Date(date).getFullYear();
    if (year < 2025) {
      return ['2025', '2035', '2050'];
    }
    return ['2030', '2035', '2050'];
  };

  const alignmentYears = getAlignmentYears(assessmentDate);
  const tabLabels = [
    `Short-term alignment ${alignmentYears[0]}`,
    `Medium-term alignment ${alignmentYears[1]}`,
    `Long-term alignment ${alignmentYears[2]}`
  ];

  return (
    <div className="matrix-tabs">
      {tabLabels.map((text, index) => (
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
  setSelectedTabIndex: PropTypes.func.isRequired,
  assessmentDate: PropTypes.string
};

Tabs.defaultProps = {
  assessmentDate: null
};

function CPMatrix({ data: dataUrl }) {
  const [params, setParams] = useState({});
  const [assessmentDate, setAssessmentDate] = useState(null);

  useEffect(() => {
    const select = document.querySelector('select[name="cp_assessment_date"]');
    const onChange = () => {
      const newParams = select?.value ? { cp_assessment_date: select.value } : {};
      setParams(newParams);
      setAssessmentDate(select?.value || null);
    };
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
        assessmentDate={assessmentDate}
      />
      <CPMatrixTable data={tableData} meta={meta} />
    </div>
  );
}

CPMatrix.propTypes = {
  data: PropTypes.string.isRequired
};

export default CPMatrix;
