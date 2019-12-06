import React, { useState, useEffect, useCallback, useRef, Fragment } from "react";
import search from "../../assets/images/icons/search.svg";
import minus from "../../assets/images/icons/dark-minus.svg";
import plus from "../../assets/images/icons/dark-plus.svg";


const SearchFilter = ({filter_name: filterName, params}) => {
  const [isShowOptions, setShowOptions] = useState(false);
  const [selectedList, setSelectedList] = useState([]);
  const [searchValue, setSearchValue ] = useState('');
  const optionsContainer = useRef(null);

  let listBlocks = [];
  for (let i in params) {
      listBlocks[i] = Object.assign({}, params[i]);
    if (searchValue) {
      listBlocks[i].options = listBlocks[i].options.concat().filter(item => item.label.toLowerCase().includes(searchValue.toLowerCase()));
    }
  }

  const handleClickOutside = useCallback((event) => {
    if (optionsContainer.current && !optionsContainer.current.contains(event.target)) {
      setShowOptions(false);
    }
  }, []);

  const handleCheckItem = (value) => {
    let list = selectedList.concat();
    if (selectedList.includes(value)) {
      list = selectedList.filter(item => item !== value);
    } else {
      list.push(value);
    }
    setSelectedList(list);
  };

  const handleSearchInput = e => setSearchValue(e.target.value);

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    }
  }, []);

  const renderBlockList = (block, index) => {
    const {options, field_name: fieldName} = block;
    if ((options || []).length === 0) return null;
    return (
      <Fragment key={fieldName}>
        {index !== 0 && <hr/>}
        <ul>
          {options.map(option => (
            <li key={option.value} onClick={()=>handleCheckItem(option.value)}>
              <input type="checkbox" hidden checked={selectedList.includes(option.value)} onChange={() => {}} />
              <div
                className={`${selectedList.includes(option.value) ? 'checked' : 'unchecked'} select-checkbox`}>
                {selectedList.includes(option.value) && <i className="fa fa-check"></i>}
              </div>
              <label>{option.label}</label>
            </li>
          ))}
        </ul>
      </Fragment>
  )};


  const renderOptions = () => (
    <div className="options-container" ref={optionsContainer}>
      <div className="select-field" onClick={()=>setShowOptions(false)}>
        <span>{filterName}</span><span className="toggle-indicator"><img src={minus} alt=""/></span>
      </div>
      <div>
        <div className="search-input-container">
          <input id="search-input" type="text" onChange={handleSearchInput}/>
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
            <span>Regions and countries</span><span className="toggle-indicator"><img src={plus} alt=""/></span>
          </div>
          {selectedList.length !== 0 && <div className="selected-count">{selectedList.length} selected</div>}
        </div>
        { isShowOptions && renderOptions()}
      </div>
    </Fragment>
  )
};

export default SearchFilter;
