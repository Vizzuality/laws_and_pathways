import React, { useState, useRef } from 'react';
import PropTypes from 'prop-types';
import { useOutsideClick } from 'shared/hooks';
import chevronIconBlack from 'images/icon_chevron_dark/chevron_down_black-1.svg';

function List({data, onSelect}) {
  return (
    <ul className="nested-dropdown__list">
      {data.map((item, i) => (
        <li key={`list-${item.value}-${i}`} className="nested-dropdown__item" onClick={() => onSelect(item)}>
          <div>
            <span>{item.label}</span>
          </div>
        </li>
      ))}
    </ul>
  );
}

List.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      value: PropTypes.oneOfType([PropTypes.string.isRequired, PropTypes.number.isRequired])
    })
  ).isRequired,
  onSelect: PropTypes.func.isRequired
};

function RemoteDropdown({ url, data, name }) {
  const Dropdown = useRef(null);
  const Select = useRef(null);
  const [isOpen, setIsOpen] = useState(false);
  const [label, setLabel] = useState(false);

  useOutsideClick(Dropdown, () => setIsOpen(false));

  const handleSelect = (item) => {
    setIsOpen(false);
    Select.current.querySelectorAll(`[value="${item.value}"]`)[0].selected = true;
    window.Rails.fire(Select.current, 'change');
    setLabel(item.label);
  };

  return (
    <>
      <div ref={Dropdown} className="nested-dropdown">
        <div className="nested-dropdown__title" onClick={() => setIsOpen(!isOpen)}>
          <div className="nested-dropdown__title-header">{label || data[0].label}</div>
          <img src={chevronIconBlack} />
        </div>
        {isOpen && <List url={url} data={data} onSelect={handleSelect} />}
      </div>
      <select hidden ref={Select} name={name} className="input" data-remote="true" data-url={url}>
        {data.map((option, i) => (
          <option key={`${option.value}-${i}`} value={option.value}>{option.label}</option>
        ))}
      </select>
    </>
  );
}

RemoteDropdown.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      value: PropTypes.oneOfType([PropTypes.string.isRequired, PropTypes.number.isRequired])
    }).isRequired
  ).isRequired,
  url: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired
};

export default RemoteDropdown;
