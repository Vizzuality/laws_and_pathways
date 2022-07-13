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
import chevronIcon from 'images/icons/white-chevron-down.svg';
import chevronIconBlack from 'images/icon_chevron_dark/chevron_down_black-1.svg';

const ESCAPE_KEY = 27;
const ENTER_KEY = 13;

const BankSelector = ({ banks, selectedOption }) => {
  const [searchValue, setSearchValue] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const inputEl = useRef(null);
  const searchContainer = useRef(null);

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

  const searchResults = useMemo(() => (searchValue ? fuse(banks) : []), [searchValue]);

  const options = useMemo(() => (searchValue
    ? searchResults : banks),
  [searchValue, banks]);

  const input = () => (
    <input
      ref={inputEl}
      className="dropdown-selector__input"
      onChange={e => setSearchValue(e.target.value)}
      placeholder="Type or select bank"
    />
  );

  const header = () => (
    <span>{selectedOption}</span>
  );

  const handleOptionClick = (option) => {
    setIsOpen(false);
    window.location = option.path;
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
              className={cx({
                'dropdown-selector__active-button': true
              })}
            >
              Filter by Banks
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
              alt="chevron"
            />
          </div>
          {isOpen && (
            <div className="dropdown-selector__options-wrapper">
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
            </div>
          )}
        </div>
      </div>
    </Fragment>
  );
};

BankSelector.propTypes = {
  banks: PropTypes.array.isRequired,
  selectedOption: PropTypes.string.isRequired
};

export default BankSelector;
