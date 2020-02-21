/* eslint-disable react/no-this-in-sfc */

import React, { useEffect, useRef, useMemo, useState } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

import PlusIcon from 'images/icons/plus.svg';

import { getOptions, COLORS } from './options';
import { useOutsideClick } from 'shared/hooks';

import CompanySelector from './CompanySelector';
import CompanyTag from './CompanyTag';
import NestedDropdown from 'components/NestedDropdown';

function getLegendItems(data) {
  return applyColorsToLegendItems(
    data
      .filter(d => d.type !== 'area')
      .slice(0, 10)
  );
}

function applyColorsToLegendItems(items) {
  return items.map((d, idx) => ({...d, color: COLORS[idx % 10]}));
}

function CPPerformance({ geographies, regions, dataUrl, companySelector, unit }) {
  const [data, setData] = useState([]);
  const [legendItems, setLegendItems] = useState([]);
  const [showCompanySelector, setCompanySelectorVisible] = useState(false);

  const companySelectorWrapper = useRef();

  // TODO: add error handling
  useEffect(() => {
    fetch(dataUrl)
      .then((r) => r.json())
      .then((chartData) => {
        setData(chartData);
        setLegendItems(getLegendItems(chartData));
      });
  }, []);
  useOutsideClick(companySelectorWrapper, () => setCompanySelectorVisible(false));

  const companies = useMemo(
    () => data.filter(d => d.type !== 'area').map(i => i.name).sort(),
    [data]
  );
  const selectedCompanies = useMemo(() => legendItems.map(i => i.name), [legendItems]);
  const chartData = useMemo(
    () => data.filter(d => d.type === 'area' || selectedCompanies.includes(d.name)),
    [data, selectedCompanies]
  );

  // handlers
  const handleAddCompaniesClick = (e) => {
    if (e.currentTarget) e.currentTarget.blur();
    setCompanySelectorVisible(!showCompanySelector);
  };
  const handleLegendItemRemove = (item) => {
    setLegendItems(
      applyColorsToLegendItems(
        legendItems.filter(l => l.name !== item.name)
      )
    );
  };
  const handleSelectedCompaniesChange = (selected) => {
    setLegendItems(getLegendItems(data.filter((d) => selected.includes(d.name))));
  };

  const options = getOptions({ chartData, unit });

  const dropdownOptions = [
    {
      value: 'top_10',
      label: 'Top 10 Emitters'
    },
    {
      value: 'market_cap',
      label: 'by Market Cap',
      items: [
        { value: 'market_cap_small', label: 'small' },
        { value: 'market_cap_medium', label: 'medium' },
        { value: 'market_cap_big', label: 'big' }
      ]
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
  const [selectedShowBy, setSelectedShowBy] = useState(dropdownOptions[0]);
  const subTitle = ((item) => {
    if (item.value === 'top_10') return null;
    if (item.value.startsWith('market_cap')) return `${item.label} market cap`;

    return item.label;
  })(selectedShowBy);

  const renderDropdown = () => ReactDOM.createPortal(
    <NestedDropdown
      title="Top 10 Emitters"
      subTitle={subTitle}
      items={dropdownOptions}
      onSelect={(item) => setSelectedShowBy(item)}
    />,
    document.querySelector('#show-by-dropdown-placeholder')
  );

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
              <span className="separator" />

              <div className="chart-company-selector-wrapper" ref={companySelectorWrapper}>
                <button type="button" className="button is-primary with-icon" onClick={handleAddCompaniesClick}>
                  <img src={PlusIcon} />
                  Add companies to the chart
                </button>

                {showCompanySelector && (
                  <CompanySelector
                    companies={companies}
                    selected={selectedCompanies}
                    onChange={handleSelectedCompaniesChange}
                    onClose={() => setCompanySelectorVisible(false)}
                  />
                )}
              </div>
            </React.Fragment>
          )}
        </div>
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

      <HighchartsReact
        highcharts={Highcharts}
        options={options}
      />
    </div>
  );
}

CPPerformance.defaultProps = {
  companySelector: true,
  geographies: [],
  regions: []
};

CPPerformance.propTypes = {
  companySelector: PropTypes.bool,
  geographies: PropTypes.array,
  regions: PropTypes.array,
  dataUrl: PropTypes.string.isRequired,
  unit: PropTypes.string.isRequired
};

export default CPPerformance;
