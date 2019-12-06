import React, { useState, useEffect, useCallback, useRef, Fragment } from 'react';
import PropTypes from 'prop-types';
import search from '../../assets/images/icons/search.svg';
import minus from '../../assets/images/icons/dark-minus.svg';
import plus from '../../assets/images/icons/dark-plus.svg';


const SearchFilter = ({filterName, params, onChange}) => {
  const [isShowOptions, setShowOptions] = useState(false);
  const [selectedList, setSelectedList] = useState({});
  const [searchValue, setSearchValue] = useState('');
  const optionsContainer = useRef(null);
  let selectedCount = 0;
  Object.values(selectedList).forEach(list => { selectedCount += list.length; });

  const listBlocks = [];
  for (let i = 0; i < params.length; i += 1) {
    listBlocks[i] = Object.assign({}, params[i]);
    if (searchValue) {
      listBlocks[i].options = listBlocks[i].options.concat().filter(item => item.label.toLowerCase().includes(searchValue.toLowerCase()));
    }
  }

  const handleCloseOptions = () => {
    setSearchValue('');
    setShowOptions(false);
  };

  const handleClickOutside = useCallback((event) => {
    if (optionsContainer.current && !optionsContainer.current.contains(event.target)) {
      handleCloseOptions();
    }
  }, []);

  const handleCheckItem = (blockName, value) => {
    const blocks = Object.assign({}, selectedList);
    if ((blocks[blockName] || []).includes(value)) {
      blocks[blockName] = blocks[blockName].filter(item => item !== value);
      if (blocks[blockName].length === 0) delete blocks[blockName];
    } else {
      if (!blocks[blockName]) blocks[blockName] = [];
      blocks[blockName].push(value);
    }
    onChange(blocks);
    setSelectedList(blocks);
  };

  const handleSearchInput = e => setSearchValue(e.target.value);
  const itemIsSelected = (fieldName, value) => selectedList[fieldName] && selectedList[fieldName].includes(value);


  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const renderBlockList = (block, index) => {
    const {options, field_name: fieldName} = block;
    if ((options || []).length === 0) return null;
    return (
      <Fragment key={fieldName}>
        { index !== 0 && <hr /> }
        <ul>
          {options.map(option => (
            <li key={option.value} onClick={() => handleCheckItem(fieldName, option.value)}>
              <input type="checkbox" hidden checked={itemIsSelected(fieldName, option.value) || false} onChange={() => {}} />
              <div className={`${itemIsSelected(fieldName, option.value) ? 'checked' : 'unchecked'} select-checkbox`}>
                {itemIsSelected(fieldName, option.value) && <i className="fa fa-check" />}
              </div>
              <label>{option.label}</label>
            </li>
          ))}
        </ul>
      </Fragment>
    );
  };

  const renderOptions = () => (
    <div className="options-container" ref={optionsContainer}>
      <div className="select-field" onClick={handleCloseOptions}>
        <span>{filterName}</span><span className="toggle-indicator"><img src={minus} alt="" /></span>
      </div>
      <div>
        <div className="search-input-container">
          <input id="search-input" type="text" onChange={handleSearchInput} />
          <label htmlFor="search-input">
            <img src={search} />
          </label>
        </div>
        <div className="options-list">
          {listBlocks.map((blockList, i) => renderBlockList(blockList, i))}
        </div>
      </div>
    </div>
  );

  return (
    <Fragment>
      <div className="filter-container">
        <div className="control-field" onClick={() => setShowOptions(true)}>
          <div className="select-field">
            <span>{filterName}</span><span className="toggle-indicator"><img src={plus} alt="" /></span>
          </div>
          {selectedCount !== 0 && <div className="selected-count">{selectedCount} selected</div>}
        </div>
        { isShowOptions && renderOptions()}
      </div>
    </Fragment>
  );
};

SearchFilter.defaultProps = {
  onChange: () => {}
};

SearchFilter.propTypes = {
  filterName: PropTypes.string.isRequired,
  params: PropTypes.array.isRequired,
  onChange: PropTypes.func
};

export default SearchFilter;
