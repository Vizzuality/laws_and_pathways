/* eslint-disable react/no-this-in-sfc */

import React, { useEffect, useRef, useMemo, useState } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import uniqBy from 'lodash/uniqBy';
import sortBy from 'lodash/sortBy';
import cloneDeep from 'lodash/cloneDeep';
import get from 'lodash/get';

import PlusIcon from 'images/icons/plus.svg';

import { getOptions, getMobileOptions, COLORS } from './options';
import { useOutsideClick } from 'shared/hooks';
import { useChartData } from '../hooks';
import { useDeviceInfo } from 'components/Responsive';

import CompanySelector from './CompanySelector';
import CompanyTag from './CompanyTag';
import NestedDropdown from 'components/tpi/NestedDropdown';

// get last emission also looking at targeted
// const getLastEmission = (d) => d.data && d.data.length && d.data.slice(-1)[0][1];
function getLastEmission(d) {
  const lastEmissionYear = get(d, 'data.zones[0].value');
  let lastEmission;
  if (!lastEmissionYear) {
    // get last emission
    lastEmission = d.data && d.data.length && d.data.slice(-1)[0][1];
  } else {
    lastEmission = d.data && d.data.length && d.data.find(x => x[0] === lastEmissionYear)[1];
  }
  return parseFloat(lastEmission, 10);
}

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

function applyColors(items) {
  return items.map((d, idx) => ({...d, color: COLORS[idx % 10]}));
}

function ensure10sorted(companyData) {
  return [...companyData]
    .sort((a, b) => getLastEmission(b) - getLastEmission(a))
    .slice(0, 10);
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
  const companySelectorWrapper = useRef();
  const { isMobile } = useDeviceInfo();

  const { data, error, loading } = useChartData(dataUrl);
  const [selectedCompanies, setSelectedCompanies] = useState([]); // Array of company names
  const [showCompanySelector, setCompanySelectorVisible] = useState(false);

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

  useOutsideClick(companySelectorWrapper, () => setCompanySelectorVisible(false));

  const chartData = useMemo(
    () => {
      const benchmarks = data.filter(d => d.type === 'area');
      const restData = applyColors(
        companySelector
          ? selectedCompanies.map(c => data.find(d => get(d, 'company.name') === c))
          : data.filter(d => d.type !== 'area')
      );

      // do not why cloneDeep is needed, but highchart seems to mutate the data
      return cloneDeep([...benchmarks, ...restData]);
    },
    [data, companySelector, selectedCompanies]
  );
  const legendItems = chartData.filter(d => d.type !== 'area' && d.name !== 'Target Years');

  // handlers
  const handleAddCompaniesClick = (e) => {
    if (e.currentTarget) e.currentTarget.blur();
    setCompanySelectorVisible(!showCompanySelector);
  };
  const handleLegendItemRemove = (item) => {
    setSelectedCompanies((selected) => selected.filter(s => s !== item.name));
  };
  const handleSelectedCompaniesChange = (selected) => {
    setSelectedCompanies(
      ensure10sorted(
        companyData.filter(c => selected.includes(c.company.name))
      ).map(c => c.name)
    );
  };

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
      <div className="legend">
        <div className="legend-row">
          {legendItems.map(
            i => (
              <CompanyTag
                key={i.name}
                className="legend-item"
                item={i}
                hideRemoveIcon={!companySelector}
                onRemove={handleLegendItemRemove}
              />
            )
          )}

          {companySelector && (
            <React.Fragment>
              <span className="separator is-hidden-touch" />

              <div className="chart-company-selector-wrapper is-hidden-touch" ref={companySelectorWrapper}>
                <button type="button" className="button is-primary with-icon" onClick={handleAddCompaniesClick}>
                  <img src={PlusIcon} alt="Add companies to the chart" />
                  Add companies to the chart
                </button>

                {showCompanySelector && (
                  <CompanySelector
                    companies={companies.map(c => c.name).sort()}
                    selected={selectedCompanies}
                    onChange={handleSelectedCompaniesChange}
                    onClose={() => setCompanySelectorVisible(false)}
                  />
                )}
              </div>
            </React.Fragment>
          )}
        </div>
        {sectorUrl && (
          <div className="legend-row">
            <button
              type="button"
              onClick={() => { window.location.href = sectorUrl; }}
              className="see-full-sector-btn is-hidden-desktop"
            >See full sector chart
            </button>
          </div>
        )}
        <div className="legend-row">
          <span className="legend-item">
            <span className="line line--solid" />
            Reported
          </span>
          <span className="legend-item">
            <span className="line line--dotted" />
            Targeted
          </span>
        </div>
      </div>

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
