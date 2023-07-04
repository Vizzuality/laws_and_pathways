import React, { useRef, useState } from 'react';
import PropTypes from 'prop-types';
import { useOutsideClick } from 'shared/hooks';
import PlusIcon from 'images/icons/plus.svg';
import CompanySelector from './CompanySelector';
import CompanyTag from './CompanyTag';
import { ensure10sorted } from './chart-utils';

function Legend({ chartData, setSelectedCompanies, selectedCompanies, sectorUrl, companyData, companySelector, companies }) {
  const companySelectorWrapper = useRef();
  const [showCompanySelector, setCompanySelectorVisible] = useState(false);
  useOutsideClick(companySelectorWrapper, () => setCompanySelectorVisible(false));

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

  return (
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
  );
}

Legend.defaultProps = {
  setSelectedCompanies: null,
  selectedCompanies: null,
  companySelector: false,
  companyData: [],
  companies: [],
  sectorUrl: null
};

Legend.propTypes = {
  chartData: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  setSelectedCompanies: PropTypes.func,
  selectedCompanies: PropTypes.arrayOf(PropTypes.string),
  sectorUrl: PropTypes.string,
  companyData: PropTypes.arrayOf(PropTypes.shape({})),
  companySelector: PropTypes.bool,
  companies: PropTypes.arrayOf(PropTypes.shape({}))
};

export default Legend;
