import React, {
  useState,
  useMemo,
  useRef,
  useEffect,
  useCallback
} from 'react';
import PropTypes from 'prop-types';
import Fuse from 'fuse.js';
import cx from 'classnames';
import chevronIconBlack from 'images/icon_chevron_dark/chevron_down_black-1.svg';

const ESCAPE_KEY = 27;
const ENTER_KEY = 13;

const Select = ({
  options,
  name,
  onSelect,
  value,
  allowSearch,
  placeholder,
  label
}) => {
  const [searchValue, setSearchValue] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const inputEl = useRef(null);
  const headerRef = useRef(null);
  const searchContainer = useRef(null);

  const fuse = useCallback(
    (opt) => {
      const config = {
        shouldSort: true,
        threshold: 0.3,
        keys: ['label']
      };
      const fuzzy = new Fuse(opt, config);
      const searchResults = fuzzy.search(searchValue);
      return searchResults;
    },
    [searchValue]
  );

  const _options = useMemo(
    () => options.map((option) => (option.label && option.value ? option : { label: option, value: option })),
    [options]
  );

  const searchResults = useMemo(
    () => (searchValue ? fuse(_options) : []),
    [searchValue, fuse, _options]
  );

  const filteredOptions = useMemo(
    () => (searchValue ? searchResults : _options),
    [searchValue, searchResults, _options]
  );

  const handleOptionClick = (opt) => {
    setIsOpen(false);
    onSelect({ name, value: opt.value, label: opt.label });
  };

  const handleCloseDropdown = () => {
    setIsOpen(false);
    setSearchValue('');
  };

  const handleOpenSearch = () => {
    setIsOpen((open) => !open);
  };

  // hooks

  useEffect(() => {
    if (inputEl.current && isOpen) {
      inputEl.current.focus();
    }
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
    if (
      searchContainer.current
      && !searchContainer.current.contains(event.target)
    ) {
      handleCloseDropdown();
    }
  }, []);

  useEffect(() => {
    document.addEventListener('keydown', escFunction, false);
    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('keydown', enterFunction);

    return () => {
      document.removeEventListener('keydown', escFunction, false);
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', enterFunction);
    };
  }, []);

  const handleListKeyDown = (event) => {
    if (event.keyCode === ENTER_KEY) {
      handleOpenSearch();
    }
  };

  useEffect(() => {
    headerRef.current?.addEventListener('keydown', handleListKeyDown);
    return () => {
      headerRef.current.removeEventListener('keydown', handleListKeyDown);
    };
  }, []);

  return (
    <div className="selector__wrapper">
      <ul
        ref={searchContainer}
        className={cx('selector__container', {
          'selector__container--active': isOpen
        })}
      >
        <li ref={headerRef}>
          <div
            onClick={handleOpenSearch}
            className={cx('selector__header', {
              'selector__header--active': isOpen
            })}
            role="button"
            aria-label={isOpen ? 'Close dropdown' : 'Open dropdown'}
          >
            {isOpen && allowSearch ? (
              <input
                ref={inputEl}
                className="selector__input"
                onChange={(e) => setSearchValue(e.target.value)}
                placeholder="Type or select"
              />
            ) : (
              <span aria-label={label} className="selector__value">
                {value || placeholder}
              </span>
            )}
            <img
              onClick={() => isOpen && handleCloseDropdown()}
              className={cx('chevron-icon', {
                'chevron-icon-rotated': isOpen
              })}
              src={chevronIconBlack}
              alt="chevron"
              title={isOpen ? 'Close dropdown' : 'Open dropdown'}
            />
          </div>
        </li>
        <li>
          <div
            className={`selector__options-wrapper ${
              isOpen ? 'selector__options-wrapper--open' : ''
            }`}
          >
            <ul
              role="listbox"
              className="selector__options"
              aria-expanded={isOpen}
            >
              {(filteredOptions.length
                && filteredOptions.map((option, i) => (
                  <li
                    onClick={() => handleOptionClick(option)}
                    className={`selector__option ${
                      option.value === value && 'selector__option--selected'
                    }`}
                    key={`${option.label}-${i}`}
                  >
                    {option.label}
                  </li>
                )))
                || (searchValue.length && !_options.length && (
                  <li>No results found.</li>
                ))}
            </ul>
          </div>
        </li>
      </ul>
    </div>
  );
};

Select.propTypes = {
  options: PropTypes.oneOfType([
    PropTypes.arrayOf(
      PropTypes.shape({
        value: PropTypes.string.isRequired,
        label: PropTypes.string.isRequired
      })
    ).isRequired,
    PropTypes.arrayOf(PropTypes.string).isRequired
  ]).isRequired,
  onSelect: PropTypes.func.isRequired,
  value: PropTypes.string,
  allowSearch: PropTypes.bool,
  placeholder: PropTypes.string,
  label: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired
};

Select.defaultProps = {
  value: '',
  allowSearch: false,
  placeholder: ''
};

export default Select;
