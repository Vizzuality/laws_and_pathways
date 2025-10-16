import React, {useState} from 'react';
import PropTypes from 'prop-types';
import Select, { components } from 'react-select';
import uniq from 'lodash/uniq';
import sortBy from 'lodash/sortBy';
import cx from 'classnames';

import chevronDownIconBlack from 'images/icon_chevron_dark/chevron_down_black-1.svg';
import chevronUpIconBlack from 'images/icon_chevron_dark/chevron-up.svg';

import { SCORE_RANGES } from './constants';

const blueDarkColor = '#2E3152';
const secondaryColor = '#828397';

const customSelectTheme = theme => ({
  ...theme,
  colors: {
    ...theme.colors,
    primary50: 'inherit'
  }
});

const customSelectStyles = {
  option: (provided, state) => ({
    ...provided,
    color: state.isSelected ? blueDarkColor : secondaryColor,
    backgroundColor: state.isSelected ? 'inherit' : 'inherit',
    fontWeight: state.isSelected ? '800' : 'normal'
  }),
  control: (provided) => ({
    ...provided,
    border: '1px solid',
    boxShadow: '1px solid #2E3152',
    borderRadius: 0
  }),
  indicatorSeparator: () => ({
    display: 'none'
  }),
  menu: (provided) => ({
    ...provided,
    margin: 0,
    borderRadius: 0
  }),
  container: (provided) => ({
    ...provided,
    margin: '0 0.75rem 1.2rem'
  })
};

const DropdownIndicator = (props) => (
  <components.DropdownIndicator {...props}>
    <img src={props.selectProps.menuIsOpen ? chevronUpIconBlack : chevronDownIconBlack} alt="Accordion toggle" />
  </components.DropdownIndicator>
);

DropdownIndicator.propTypes = {
  selectProps: PropTypes.object.isRequired
};

const CompaniesAccordion = ({ results, disabled_bubbles_areas }) => {
  const areas = uniq((results || []).map(r => r.area)).filter(Boolean);
  const selectOptions = areas.map((level) => ({label: level, value: level}));
  const [openItems, setOpenItems] = useState([]);
  const [activeOption, setActiveOption] = useState(selectOptions.length > 0 ? selectOptions[0] : null);

  const ranges = SCORE_RANGES.map((range) => `${range.min}-${range.max}%`);

  const parsedData = {};
  results.forEach((result) => {
    if (parsedData[result.area] === undefined) {
      parsedData[result.area] = Array.from({ length: ranges.length }, () => []);
    }
    const rangeIndex = SCORE_RANGES.findIndex((range) => result.percentage >= range.min && result.percentage <= range.max);
    if (rangeIndex >= 0) {
      parsedData[result.area][rangeIndex].push({
        ...result,
        color: SCORE_RANGES[rangeIndex].color
      });
    } else {
      console.error('WRONG INDEX', result);
    }
  });

  const emptyArea = Array.from({ length: ranges.length }, () => []);
  const selectedValue = activeOption && activeOption.value;
  const activeArea = selectedValue
    ? (disabled_bubbles_areas.includes(selectedValue) ? emptyArea : (parsedData[selectedValue] || emptyArea))
    : emptyArea;

  function setOpenItemByIndex(index) {
    setOpenItems(openItems.includes(index) ? openItems.filter(i => i !== index) : [...openItems, index]);
  }

  return (
    <div className="mobile_bubble-chart__container is-hidden-desktop">
      <Select
        options={selectOptions}
        value={activeOption}
        className="is-hidden-desktop"
        onChange={(e) => { setActiveOption(e); }}
        isSearchable={false}
        styles={customSelectStyles}
        components={{DropdownIndicator}}
        theme={customSelectTheme}
      />

      <div className="accordions-list">
        {SCORE_RANGES.map((range, i) => (
          <div
            key={`chart-item-list-${i}`}
            className={cx('item-list', { open: openItems.includes(i) })}
            style={{
              background: range.color
            }}
          >
            <div className="item-header" onClick={() => setOpenItemByIndex(i)}>
              <div className="item-title">
                <div>Score Range</div>
                <div>{activeArea[i].length} {activeArea[i].length === 1 ? 'bank' : 'banks'}</div>
              </div>
              <div className="sector-subtitle">{range.min}-{range.max}%</div>
            </div>
            <div className="item-body">
              <hr />
              {activeArea[i].length === 0 && <div className="no-companies">No banks</div>}
              {activeArea[i].length > 0 && (
                <ul className="companies-list">
                  {sortBy(activeArea[i], 'bank_name').map((bank, index) => (
                    <li
                      key={`chart-companies-${index}`}
                      onClick={() => { window.location.href = bank.bank_path; }}
                    >
                      {bank.bank_name}
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

CompaniesAccordion.defaultProps = {
  disabled_bubbles_areas: []
};

CompaniesAccordion.propTypes = {
  results: PropTypes.arrayOf(PropTypes.shape({
    area: PropTypes.string.isRequired,
    market_cap_group: PropTypes.string.isRequired,
    percentage: PropTypes.number.isRequired,
    bank_id: PropTypes.number.isRequired,
    bank_name: PropTypes.string.isRequired,
    bank_path: PropTypes.string.isRequired
  })).isRequired,
  disabled_bubbles_areas: PropTypes.arrayOf(PropTypes.string)
};
export default CompaniesAccordion;
