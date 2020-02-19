import React, { useState, useMemo } from 'react';
import PropTypes from 'prop-types';

import Fuse from 'fuse.js';
import cx from 'classnames';
import xor from 'lodash/xor';

import SearchIcon from 'images/icons/search.svg';

const useSearch = (options, searchText) => useMemo(
  () => {
    if (!searchText) return options;

    const config = {
      threshold: 0.3,
      keys: ['label']
    };
    const fuzzy = new Fuse(options, config);
    return fuzzy.search(searchText);
  },
  [options, searchText]
);

function CheckList({ isSearchable, options, selected, onChange, maxSelectedCount }) {
  const [searchText, setSearchText] = useState('');
  const selectingMoreDisabled = selected.length >= maxSelectedCount;

  const handleCheckItem = (option) => {
    if (isDisabled(option)) return;

    onChange(xor(selected, [option.value]));
  };
  const isSelected = (option) => selected.includes(option.value);
  const isDisabled = (option) => selectingMoreDisabled && !isSelected(option);

  const filteredOptions = useSearch(options, searchText);

  return (
    <div className="check-list">
      {isSearchable && (
        <div className="check-list__search">
          <label>
            <input type="text" value={searchText} onChange={(e) => setSearchText(e.target.value)} />
            <img src={SearchIcon} />
          </label>
        </div>
      )}

      <ul className="check-list__items">
        {filteredOptions.map(option => (
          <li
            key={option.value}
            className={cx('check-list__item', { disabled: isDisabled(option) })}
            onClick={() => handleCheckItem(option)}
          >
            <div className={cx('check-list__item_checkbox', { checked: isSelected(option) })}>
              {isSelected(option) && <i className="fa fa-check" />}
            </div>
            {option.label}
          </li>
        ))}
      </ul>
    </div>
  );
}

CheckList.defaultProps = {
  options: [],
  selected: [],
  maxSelectedCount: 10,
  isSearchable: true,
  onChange: () => {}
};

CheckList.propTypes = {
  maxSelectedCount: PropTypes.number,
  isSearchable: PropTypes.bool,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      value: PropTypes.string.isRequired
    })
  ),
  selected: PropTypes.arrayOf(PropTypes.string),
  onChange: PropTypes.func
};

export default CheckList;
