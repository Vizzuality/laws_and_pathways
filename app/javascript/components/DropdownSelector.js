import React, {
  useState,
  useMemo,
  useRef,
  useEffect,
  useCallback,
  Fragment
} from 'react';
import PropTypes from 'prop-types';
import Fuse from 'fuse.js';
import cx from 'classnames';
import groupBy from 'lodash/groupBy';
import chevronIcon from '../../assets/images/icons/white-chevron-down.svg';
import chevronIconBlack from '../../assets/images/icon_chevron_dark/chevron_down_black-1.svg';

const ESCAPE_KEY = 27;
const ENTER_KEY = 13;

const FILTER_BY = {
  SECTOR: 'sector',
  COMPANY: 'company'
};

const DropdownSelector = ({ sectors, companies, selectedOption, defaultFilter = 'sector' }) => {
  const [searchValue, setSearchValue] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [activeFilter, setActiveFilter] = useState(defaultFilter);
  const inputEl = useRef(null);
  const searchContainer = useRef(null);

  const isFilterBySector = activeFilter === FILTER_BY.SECTOR;
  const isFilterByCompany = activeFilter === FILTER_BY.COMPANY;

  const sectorsWithExtraOption = [{ id: 'all-sectors', name: 'All sectors', slug: '' }, ...sectors];

  const fuse = (opt) => {
    const config = {
      shouldSort: true,
      threshold: 0.3,
      keys: ['name']
    };
    const fuzzy = new Fuse(opt, config);
    const searchResults = fuzzy.search(searchValue);
    return searchResults;
  };

  const filteredByOptions = isFilterBySector ? sectorsWithExtraOption : companies;
  const searchResults = useMemo(() => (searchValue && activeFilter ? fuse(filteredByOptions) : []), [searchValue, activeFilter]);

  const options = useMemo(() => (searchValue
    ? searchResults : filteredByOptions),
  [searchValue, filteredByOptions]);

  const companiesBySector = groupBy(options, 'sector_name');

  const input = () => (
    <input
      ref={inputEl}
      className="dropdown-selector__input"
      onChange={e => setSearchValue(e.target.value)}
      placeholder={`Type or select ${isFilterByCompany ? 'company' : 'sector'}`}
    />
  );

  const setFilter = (filter) => {
    setActiveFilter(filter);
    if (!isOpen) setIsOpen(true);
    if (inputEl.current) inputEl.current.focus();
  };

  const header = () => (
    <span>{selectedOption}</span>
  );

  const handleOptionClick = (option) => {
    const url = isFilterBySector ? '/tpi/sectors/' : '/tpi/companies/';
    setIsOpen(false);
    if (!(window.location.pathname === '/tpi/sectors/' && option.id === 'all-sectors')) {
      window.open(`${url}${option.slug}`, '_self');
    }
  };

  const handleCloseDropdown = () => {
    setIsOpen(false);
    setSearchValue('');
  };

  const handleOpenSearch = () => {
    if (!isOpen) setIsOpen(true);
  };

  // hooks

  useEffect(() => {
    if (isOpen) { inputEl.current.focus(); }
  }, [isOpen]);

  const escFunction = useCallback((event) => {
    if (event.keyCode === ESCAPE_KEY) {
      handleCloseDropdown();
    }
  }, []);

  const enterFunction = (event) => {
    if (event.keyCode === ENTER_KEY) {
      if (isOpen && searchResults.length) {
        handleOptionClick(searchResults[0]);
      }
    }
  };

  const handleClickOutside = useCallback((event) => {
    if (searchContainer.current && !searchContainer.current.contains(event.target)) {
      handleCloseDropdown();
    }
  }, []);

  useEffect(() => {
    document.addEventListener('keydown', escFunction, false);

    return () => {
      document.removeEventListener('keydown', escFunction, false);
    };
  }, []);

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  useEffect(() => {
    document.addEventListener('keydown', enterFunction);

    return () => {
      document.removeEventListener('keydown', enterFunction);
    };
  }, [searchResults]);

  return (
    <Fragment>
      <div className="dropdown-selector__wrapper">
        <div
          ref={searchContainer}
          className={cx('dropdown-selector__container', {
            'dropdown-selector__container--active': isOpen
          })}
        >
          <div className="dropdown-selector__buttons">
            <button
              type="button"
              onClick={() => (isFilterBySector ? () => {} : setFilter(FILTER_BY.SECTOR))}
              className={cx({
                'dropdown-selector__button': isFilterByCompany,
                'dropdown-selector__active-button': isFilterBySector,
                'dropdown-selector__not-active-opened': isFilterByCompany && isOpen
              })}
            >
              Filter by {FILTER_BY.SECTOR}
            </button>
            <button
              type="button"
              onClick={() => (isFilterByCompany ? () => {} : setFilter(FILTER_BY.COMPANY))}
              className={cx({
                'dropdown-selector__button': isFilterBySector,
                'dropdown-selector__active-button': isFilterByCompany,
                'dropdown-selector__not-active-opened': isFilterBySector && isOpen
              })}
            >
              Filter by {FILTER_BY.COMPANY}
            </button>
          </div>
          <div
            onClick={handleOpenSearch}
            className={cx('dropdown-selector__header', {
              'dropdown-selector__header--active': isOpen
            })}
          >
            {isOpen ? input() : header()}
            <img
              onClick={() => isOpen && handleCloseDropdown()}
              className={cx('chevron-icon', { 'chevron-icon-rotated': isOpen })}
              src={isOpen ? chevronIconBlack : chevronIcon}
            />
          </div>
          {isOpen && (
            <div className="dropdown-selector__options-wrapper">
              {isFilterBySector && (
                <div className="dropdown-selector__options">
                  {(options.length && options.map((option, i) => (
                    <div
                      onClick={() => handleOptionClick(option)}
                      className="dropdown-selector__option"
                      key={`${option.name}-${i}`}
                    >
                      {option.name}
                    </div>
                  ))) || (searchValue.length && !options.length && (
                    <div>No results found.</div>
                  ))}
                </div>
              )}
              {isFilterByCompany && (
                <div className="dropdown-selector__options">
                  {(options.length && Object.keys(companiesBySector).map((sector, i) => (
                    <Fragment key={`filter-companies-fragment-${i}`}>
                      <div
                        key={`${sector}-${i}`}
                        className="dropdown-selector__sector-name"
                      >
                        {sector}
                      </div>
                      {companiesBySector[sector].map((option, j) => (
                        <div
                          className={cx('dropdown-selector__option', 'dropdown-selector__option-company')}
                          onClick={() => handleOptionClick(option)}
                          key={`${option.name}-${i}-${j}`}
                        >
                          {option.name}
                        </div>
                      ))}
                    </Fragment>
                  ))) || (searchValue.length && !options.length && (
                    <div>No results found.</div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </Fragment>
  );
};

DropdownSelector.propTypes = {
  sectors: PropTypes.array.isRequired,
  companies: PropTypes.array.isRequired,
  selectedOption: PropTypes.string.isRequired,
  defaultFilter: PropTypes.string
};

DropdownSelector.defaultProps = {
  defaultFilter: 'sector'
};

export default DropdownSelector;
