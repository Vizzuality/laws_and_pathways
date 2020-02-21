/* eslint-disable react/no-this-in-sfc */

import React, { useEffect, useRef, useMemo, useState } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import uniqBy from 'lodash/uniqBy';
import sortBy from 'lodash/sortBy';
import get from 'lodash/get';

import PlusIcon from 'images/icons/plus.svg';

import { getOptions, COLORS } from './options';
import { useOutsideClick } from 'shared/hooks';

import CompanySelector from './CompanySelector';
import CompanyTag from './CompanyTag';
import NestedDropdown from 'components/NestedDropdown';

function getLegendItems(data, showByValue) {
  let companyData = data.filter(d => d.type !== 'area');

  if (showByValue) {
    // get last emission also looking at targeted
    // const getLastEmission = (d) => d.data && d.data.length && d.data.slice(-1)[0][1];
    const getLastEmission = (d) => {
      const lastEmissionYear = get(d, 'data.zones[0].value');
      let lastEmission;
      if (!lastEmissionYear) {
        // get last emission
        lastEmission = d.data && d.data.length && d.data.slice(-1)[0][1];
      } else {
        lastEmission = d.data && d.data.length && d.data.find(x => x[0] === lastEmissionYear)[1];
      }
      return parseFloat(lastEmission, 10);
    };

    companyData = companyData.filter(d => {
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
    companyData = companyData.sort((a, b) => getLastEmission(b) - getLastEmission(a));
  }

  return applyColorsToLegendItems(companyData.slice(0, 10));
}

function applyColorsToLegendItems(items) {
  return items.map((d, idx) => ({...d, color: COLORS[idx % 10]}));
}

function getDropdownOptions(geographies, regions) {
  return [
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
}

function CPPerformance({ dataUrl, companySelector, unit }) {
  const [data, setData] = useState([]);
  const [legendItems, setLegendItems] = useState([]);
  const [showCompanySelector, setCompanySelectorVisible] = useState(false);
  const { geographies, regions } = useMemo(() => {
    const companyData = data
      .map(d => d.company)
      .filter(d => d);

    return {
      geographies: sortBy(
        uniqBy(
          companyData.map(c => ({ id: c.geography_id, name: c.geography_name })),
          'id'
        ),
        'name'
      ),
      regions: [...new Set(companyData.map(c => c.region).sort())]
    };
  }, [data]);
  const dropdownOptions = getDropdownOptions(geographies, regions);
  const [selectedShowBy, setSelectedShowBy] = useState(dropdownOptions[0]);

  const companySelectorWrapper = useRef();

  // TODO: add error handling
  useEffect(() => {
    fetch(dataUrl)
      .then((r) => r.json())
      .then((chartData) => {
        setData(chartData);
        setLegendItems(getLegendItems(chartData, selectedShowBy.value));
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
    setLegendItems(
      getLegendItems(data.filter((d) => selected.includes(d.name)))
    );
  };
  const handleShowBySelect = (selected) => {
    setSelectedShowBy(selected);
    setLegendItems(getLegendItems(data, selected.value));
  };

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
      onSelect={handleShowBySelect}
    />,
    document.querySelector('#show-by-dropdown-placeholder')
  );

  const options = getOptions({ chartData, unit });

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
  companySelector: true
};

CPPerformance.propTypes = {
  companySelector: PropTypes.bool,
  dataUrl: PropTypes.string.isRequired,
  unit: PropTypes.string.isRequired
};

export default CPPerformance;
