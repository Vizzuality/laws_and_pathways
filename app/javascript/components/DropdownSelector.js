import React, { useState, useMemo } from "react";
import Fuse from "fuse.js";
import cx from 'classnames';
import groupBy from 'lodash/groupBy';
import chevronIcon from '../../assets/images/icons/white-chevron-down.svg';
import chevronIconBlack from '../../assets/images/icon_chevron_dark/chevron_down_black-1.svg';

const FILTER_BY = {
  SECTOR: 'sector',
  COMPANY: 'company'
};

const DropdownSelector = ({ sectors, companies, selectedOption }) => {
  const [searchValue, setSearchValue ] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [activeFilter, setActiveFilter] = useState(FILTER_BY.SECTOR);

  const isFilterBySector = activeFilter === FILTER_BY.SECTOR;
  const isFilterByCompany = activeFilter === FILTER_BY.COMPANY;

  const sectorsWithExtraOption = [{ id: 'all-sectors', name: 'All sectors', slug: '' }, ...sectors];

  const fuse = (opt) => {
    const config = {
      shouldSort: true,
      keys: ['name']
    };
    const fuse = new Fuse(opt, config);
    const searchResults = fuse.search(searchValue);
    return searchResults;
  }

  const filteredByOptions = isFilterBySector ? sectorsWithExtraOption : companies;
  const searchResults = useMemo(() => searchValue ? fuse(filteredByOptions) : [], [searchValue]);

  const options = useMemo(() => searchValue ? 
    searchResults : filteredByOptions,
  [searchValue, filteredByOptions]);

  const companiesBySector = isFilterByCompany && groupBy(options, 'sector_name');

  const input = () => (
    <input 
      className="dropdown-selector__input"
      onChange={e => setSearchValue(e.target.value)}
      placeholder={`Select ${isFilterByCompany ? 'company' : 'sector'}`}
    />
  )

  const header = () => (
    <span>{selectedOption}</span>
  )

  const handleOptionClick = (option) => {
    const url = isFilterBySector ? '/tpi/sectors/' : '/tpi/companies/';
    setIsOpen(false);
    if (!(window.location.pathname === '/tpi/sectors/' && option.id === 'all-sectors')) {
      window.open(`${url}${option.slug}`, "_self");
    }
  }

  const handleCloseDropdown = () => {
    setIsOpen(!isOpen);
    setSearchValue('');
  }

  return (
    <>
      <div className="dropdown-selector__wrapper">
        <div className={cx("dropdown-selector__container", { ["dropdown-selector__container--active"]: isOpen })}>
          <div className="dropdown-selector__buttons">
            <button
              onClick={() => isFilterBySector ? () => {} : setActiveFilter(FILTER_BY.SECTOR)}
              className={cx({ ["dropdown-selector__button"]: isFilterByCompany, ["dropdown-selector__active-button"]: isFilterBySector, ["dropdown-selector__not-active-opened"]: isFilterByCompany && isOpen })}
            >
              Filter by {FILTER_BY.SECTOR}
            </button>
            <button
              onClick={() => isFilterByCompany ? () => {} : setActiveFilter(FILTER_BY.COMPANY)}
              className={cx({ ["dropdown-selector__button"]: isFilterBySector, ["dropdown-selector__active-button"]: isFilterByCompany, ["dropdown-selector__not-active-opened"]: isFilterBySector && isOpen })}
            >
              Filter by {FILTER_BY.COMPANY}
            </button>
          </div>
          <div onClick={() => !isOpen && setIsOpen(!isOpen)} className={cx("dropdown-selector__header", { ["dropdown-selector__header--active"]: isOpen })}>
            {isOpen ? input() : header()}
            <img
              onClick={() => isOpen && handleCloseDropdown()}
              className={cx("chevron-icon", { ["chevron-icon-rotated"]: isOpen })}
              src={isOpen ? chevronIconBlack : chevronIcon} 
            />
          </div>
          {isOpen && (
            <div className="dropdown-selector__options-wrapper">
              {isFilterBySector && (
                <div className="dropdown-selector__options">
                  {options.map(option => {
                    return (
                      <div onClick={() => handleOptionClick(option)} className="dropdown-selector__option">
                        {option.name}
                      </div>
                    )
                  })}
                  {searchValue && !options.length && <div>No results found.</div>}
                </div>
              )}
              {isFilterByCompany && (
                <div className="dropdown-selector__options">
                  {Object.keys(companiesBySector).map(sector => {
                    return (
                      <>
                        <div className="dropdown-selector__sector-name">
                          {sector}
                        </div>
                        {companiesBySector[sector].map(option => (
                          <div onClick={() => handleOptionClick(option)} className={cx("dropdown-selector__option", "dropdown-selector__option-company")}>
                            {option.name}
                          </div>
                        ))}
                      </>
                    )
                  })}
                  {searchValue && !options.length && <div>No results found.</div>}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </>
  )
}

export default DropdownSelector;