import React, { useEffect, useState, useRef } from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';
import { Range, Handle } from 'rc-slider';

import { useOutsideClick } from 'shared/hooks';

import minus from 'images/icons/dark-minus.svg';
import plus from 'images/icons/dark-plus.svg';

const blueDarkColor = '#2E3152';
const redColor = '#ED3D48';
const greyColor = '#9698A8';

const customStyles = {
  option: (provided, state) => ({
    ...provided,
    color: blueDarkColor,
    backgroundColor: state.isSelected ? 'inherit' : 'inherit'
  }),
  control: (provided, state) => ({
    ...provided,
    borderRadius: 0,
    borderColor: state.isFocused ? blueDarkColor : blueDarkColor,
    boxShadow: state.isFocused ? 0 : 0,
    '&:hover': {
      borderColor: state.isFocused ? blueDarkColor : blueDarkColor
    }
  }),
  menu: (provided) => ({
    ...provided,
    borderRadius: 0,
    marginTop: 0,
    right: 0,
    zIndex: 9
  })
};

function TimeRangeFilter(props) {
  const [showOptions, setShowOptions] = useState(false);
  const [fromDate, setFromDate] = useState(props.fromDate);
  const [toDate, setToDate] = useState(props.toDate);

  const { filterName, className, minDate, maxDate } = props;

  const optionsContainer = useRef();

  useOutsideClick(optionsContainer, () => setShowOptions(false));
  useEffect(() => setFromDate(props.fromDate), [props.fromDate]);
  useEffect(() => setToDate(props.toDate), [props.toDate]);

  const handleChange = (value) => {
    props.onChange({
      fromDate,
      toDate,
      ...value
    });
  };

  const capitalizeFirstLetter = (string) => {
    if (typeof string !== 'string') return null;

    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  const currentFromDate = fromDate || minDate;
  const currentToDate = toDate || maxDate;

  let selectedTitle = fromDate ? `from ${fromDate} ` : '';
  selectedTitle += toDate ? `to ${toDate}` : '';
  if (selectedTitle) selectedTitle = capitalizeFirstLetter(selectedTitle);

  return (
    <div className={`filter-container ${className}`}>
      <div className="control-field" onClick={() => setShowOptions(true)}>
        <div className="select-field">
          <span>{filterName}</span><span className="toggle-indicator"><img src={plus} alt="" /></span>
        </div>
        {selectedTitle && <div className="selected-count">{selectedTitle}</div>}
      </div>
      {showOptions && (
        <div className="options-container" ref={optionsContainer}>
          <div className="select-field" onClick={() => setShowOptions(false)}>
            <span>{filterName}</span><span className="toggle-indicator"><img src={minus} alt="" /></span>
          </div>
          <div className="time-range-options">
            <div className="slider-range-container">
              <Range
                className="slider-range"
                min={minDate}
                max={maxDate}
                trackStyle={[{ backgroundColor: redColor }]}
                handle={(handleProps) => (
                  <Handle {...handleProps} key={handleProps.index} dragging={handleProps.dragging.toString()}>
                    <div className={`time-range-handle handle-${handleProps.index}`}>{handleProps.value}</div>
                  </Handle>
                )}
                handleStyle={[
                  { backgroundColor: redColor, border: 'none', height: '12px', width: '12px', marginTop: '-4px' },
                  { backgroundColor: redColor, border: 'none', height: '18px', width: '18px', marginTop: '-7px' }
                ]}
                value={[currentFromDate, currentToDate]}
                onChange={(e) => {
                  setFromDate(e[0]);
                  setToDate(e[1]);
                }}
                onAfterChange={(e) => handleChange({fromDate: e[0], toDate: e[1]})}
                railStyle={{ backgroundColor: greyColor, maxHeight: '2px', marginTop: '1px' }}
                activeDotStyle={{border: 'none'}}
              />
              <div className="values-row">
                <span>{minDate}</span>
                <span>{maxDate}</span>
              </div>
            </div>
            <div className="filter-item">
              <div className="caption">From</div>
              <Select
                options={
                [...new Array(currentToDate - minDate + 1)].map((v, i) => (
                  {value: currentToDate - i, label: currentToDate - i}
                ))
                }
                styles={customStyles}
                isSearchable={false}
                value={{label: currentFromDate, value: currentFromDate}}
                onChange={(e) => handleChange({fromDate: e.value})}
                components={{IndicatorSeparator: () => null}}
              />
            </div>
            <div className="filter-item">
              <div className="caption">To</div>
              <Select
                options={
                [...new Array(maxDate - currentFromDate + 1)].map((_, i) => (
                  {value: currentFromDate + i, label: currentFromDate + i})).reverse()
                }
                styles={customStyles}
                isSearchable={false}
                value={{label: currentToDate, value: currentToDate}}
                onChange={(e) => handleChange({toDate: e.value})}
                components={{IndicatorSeparator: () => null}}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

TimeRangeFilter.defaultProps = {
  className: '',
  onChange: () => {},
  fromDate: null,
  toDate: null,
  filterName: 'Time range',
  minDate: 1990,
  maxDate: new Date().getUTCFullYear()
};

TimeRangeFilter.propTypes = {
  className: PropTypes.string,
  filterName: PropTypes.string,
  minDate: PropTypes.number,
  maxDate: PropTypes.number,
  fromDate: PropTypes.number,
  toDate: PropTypes.number,
  onChange: PropTypes.func
};

export default TimeRangeFilter;
