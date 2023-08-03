/* eslint-disable react/no-this-in-sfc */

import React, { useEffect, useMemo, useState } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { ensure10sorted, useParsedChartData } from './chart-utils';
import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import uniqBy from 'lodash/uniqBy';
import sortBy from 'lodash/sortBy';

import { getOptions, getMobileOptions } from './options';

import { useChartData } from '../hooks';
import { useDeviceInfo } from 'components/Responsive';

import NestedDropdown from 'components/tpi/NestedDropdown';
import Legend from './Legend';

function filterByShowValue(companyData, showByValue) {
  if (!showByValue) return companyData;

  return companyData.filter(d => {
    if (showByValue.startsWith('market_cap')) {
      return d.company.market_cap_group === showByValue.replace('market_cap_', '');
    }

    if (showByValue.startsWith('by_country')) {
      return parseInt(d.company.geography_id, 10) === parseInt(showByValue.replace('by_country_', ''), 10);
    }

    if (showByValue.startsWith('by_region')) {
      return d.company.region === showByValue.replace('by_region_', '');
    }

    return true;
  });
}

function getDropdownOptions(geographies, regions, marketCapGroups) {
  return [
    {
      value: 'top_10',
      label: 'Top 10 Emitters'
    },
    {
      value: 'market_cap',
      label: 'by Market Cap',
      items: marketCapGroups.map(g => ({ label: g, value: `market_cap_${g}` }))
    },
    {
      value: 'geographies',
      label: 'by Country',
      items: geographies.map(c => ({ label: c.name, value: `by_country_${c.id}` }))
    },
    {
      value: 'regions',
      label: 'by Region',
      items: regions.map(r => ({ label: r, value: `by_region_${r}` }))
    }
  ];
}

function CPPerformance({ dataUrl, companySelector, unit, sectorUrl }) {
  const { isMobile } = useDeviceInfo();

  const { data, error, loading } = useChartData(dataUrl);
  const [selectedCompanies, setSelectedCompanies] = useState([]); // Array of company names

  const companyData = useMemo(() => data.filter(d => d.company), [data]);
  const companies = useMemo(() => companyData.map(d => d.company), [companyData]);
  const dropdownOptions = useMemo(() => {
    const geographies = sortBy(
      uniqBy(
        companies.map(c => ({ id: c.geography_id, name: c.geography_name })),
        'id'
      ),
      'name'
    );
    const regions = [...new Set(companies.map(c => c.region))].sort();
    const marketCapGroups = [...new Set(companies.map(c => c.market_cap_group))];

    return getDropdownOptions(geographies, regions, marketCapGroups);
  }, [companies]);
  const [selectedShowBy, setSelectedShowBy] = useState(dropdownOptions[0]);

  useEffect(() => {
    setSelectedCompanies(
      ensure10sorted(
        filterByShowValue(companyData, selectedShowBy.value)
      ).map(c => c.name)
    );
  }, [companyData, selectedShowBy]);

  const chartData = useParsedChartData(data, companySelector, selectedCompanies);

  const subTitle = ((item) => {
    if (item.value === 'top_10') return null;
    if (item.value.startsWith('market_cap')) return `${item.label} market cap`;

    return item.label;
  })(selectedShowBy);

  const renderDropdown = () => {
    const element = document.querySelector('#show-by-dropdown-placeholder');

    if (!element) return null;

    return ReactDOM.createPortal(
      <NestedDropdown
        title="Top 10 Emitters"
        subTitle={subTitle}
        items={dropdownOptions}
        onSelect={setSelectedShowBy}
      />,
      element
    );
  };

  const options = isMobile ? getMobileOptions({ chartData, unit }) : getOptions({ chartData, unit });

  return (
    <div className="chart chart--cp-performance">
      {renderDropdown()}
      <Legend
        chartData={chartData}
        setSelectedCompanies={setSelectedCompanies}
        selectedCompanies={selectedCompanies}
        sectorUrl={sectorUrl}
        companyData={companyData}
        companySelector={companySelector}
        companies={companies}
      />
      {loading ? (
        <p>Loading...</p>
      ) : (
        <React.Fragment>
          {error ? (
            <p>{error}</p>
          ) : (
            <HighchartsReact
              highcharts={Highcharts}
              options={options}
            />
          )}
        </React.Fragment>
      )}
    </div>
  );
}

CPPerformance.defaultProps = {
  companySelector: true,
  sectorUrl: null
};

CPPerformance.propTypes = {
  companySelector: PropTypes.bool,
  dataUrl: PropTypes.string.isRequired,
  unit: PropTypes.string.isRequired,
  sectorUrl: PropTypes.string
};

export default CPPerformance;
