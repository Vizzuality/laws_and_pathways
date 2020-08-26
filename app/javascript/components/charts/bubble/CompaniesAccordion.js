import React, {useState} from 'react';
import PropTypes from 'prop-types';
import Select, { components } from 'react-select';

import chevronDownIconBlack from '../../../../assets/images/icon_chevron_dark/chevron_down_black-1.svg';
import chevronUpIconBlack from '../../../../assets/images/icon_chevron_dark/chevron-up.svg';

const LEVELS_SUBTITLES = {
  0: 'Unaware',
  1: 'Awareness',
  2: 'Building capacity',
  3: 'Integrating into operational decision making',
  4: 'Strategic assessment'
};

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
    <img src={props.selectProps.menuIsOpen ? chevronUpIconBlack : chevronDownIconBlack} />
  </components.DropdownIndicator>
);

DropdownIndicator.propTypes = {
  selectProps: PropTypes.object.isRequired
};

const CompaniesAccordion = ({ levels, by_sector }) => {
  const selectOptions = Object.keys(levels).map((level) => ({label: level, value: level}));
  const levelsSignature = by_sector ? levels && Object.keys(levels[Object.keys(levels)[0]]) : levels && Object.keys(levels);
  const [openItems, setOpenItems] = useState([]);
  const [activeOption, setActiveOption] = useState(selectOptions[0]);
  const activeSector = by_sector ? levels[activeOption.value] : levels;

  function setOpenItemByIndex(index) {
    setOpenItems(openItems.includes(index) ? openItems.filter(i => i !== index) : [...openItems, index]);
  }

  return (
    <div className="mobile_bubble-chart__container is-hidden-desktop">
      {by_sector && (
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
      )}

      <div className="accordions-list">
        {levelsSignature.map((el, i) => (
          <div key={`chart-item-list-${i}`} className={`item-list level-item-color-${el} ${openItems.includes(i) ? ' open' : ''}`}>
            <div className="item-header" onClick={() => setOpenItemByIndex(i)}>
              <div className="item-title">
                <div>level {levelsSignature[el]}</div>
                <div>{activeSector[el].length} {activeSector[el].length === 1 ? 'company' : 'companies'}</div>
              </div>
              <div className="sector-subtitle">{LEVELS_SUBTITLES[el]}</div>
            </div>
            <div className="item-body">
              <hr />
              {activeSector[el].length === 0 && <div className="no-companies">No companies</div>}
              {activeSector[el].length > 0 && (
                <ul className="companies-list">
                  {activeSector[el].map((company, index) => (
                    <li
                      key={`chart-companies-${index}`}
                      onClick={() => { window.location.href = `/tpi/companies/${company.slug}`; }}
                    >
                      {company.name}
                      <span className={`mq-level-trend mq-level-trend--${company.status}`} />
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        ))}
      </div>
      {by_sector && (
        <div className="go-to-button__container">
          <a href={`/tpi/sectors/${activeOption.value.toLowerCase()}`} className="button is-primary is-outlined">Go to sector</a>
        </div>
      )}
    </div>
  );
};

CompaniesAccordion.defaultProps = {
  by_sector: true
};

CompaniesAccordion.propTypes = {
  levels: PropTypes.object.isRequired,
  by_sector: PropTypes.bool
};
export default CompaniesAccordion;
