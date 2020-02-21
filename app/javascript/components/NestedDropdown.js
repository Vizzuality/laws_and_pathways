import React, { useState, useRef } from 'react';
import PropTypes from 'prop-types';

import { useOutsideClick } from 'shared/hooks';

import chevronIconBlack from 'images/icon_chevron_dark/chevron_down_black-1.svg';

function List({ items, onSelect }) {
  return (
    <ul className="nested-dropdown__list">
      {items.map((item) => <Item key={item.value} item={item} onSelect={onSelect} />)}
    </ul>
  );
}

List.propTypes = {
  items: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      value: PropTypes.string.isRequired
    })
  ).isRequired,
  onSelect: PropTypes.func.isRequired
};

function Item({ item, onSelect }) {
  const [isOpen, setIsOpen] = useState(false);
  const itemElement = useRef(null);
  const isNested = Boolean(item.items && item.items.length);

  useOutsideClick(itemElement, () => setIsOpen(false));

  const handleClick = () => {
    setIsOpen(!isOpen);
    if (!isNested) onSelect(item);
  };

  return (
    <li ref={itemElement} className="nested-dropdown__item" onClick={handleClick}>
      <span>{item.label}</span>
      {isNested && <img src={chevronIconBlack} />}
      {isNested && isOpen && <List items={item.items} onSelect={onSelect} />}
    </li>
  );
}

Item.propTypes = {
  item: PropTypes.shape({
    label: PropTypes.string.isRequired,
    value: PropTypes.string.isRequired
  }).isRequired,
  onSelect: PropTypes.func.isRequired
};

function NestedDropdown({ items, title, subTitle, onSelect }) {
  const nestedDropdown = useRef(null);
  const [isOpen, setIsOpen] = useState(false);

  useOutsideClick(nestedDropdown, () => setIsOpen(false));

  const handleSelect = (item) => {
    setIsOpen(false);
    onSelect(item);
  };

  return (
    <div ref={nestedDropdown} className="nested-dropdown">
      <div className="nested-dropdown__title" onClick={() => setIsOpen(!isOpen)}>
        <div className="nested-dropdown__title-header">
          <span>{title}</span>
          {subTitle && <small>{subTitle}</small>}
        </div>
        <img src={chevronIconBlack} />
      </div>
      {isOpen && <List items={items} onSelect={handleSelect} />}
    </div>
  );
}

NestedDropdown.defaultProps = {
  subTitle: ''
};

NestedDropdown.propTypes = {
  title: PropTypes.string.isRequired,
  subTitle: PropTypes.string,
  items: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      value: PropTypes.string.isRequired
    })
  ).isRequired,
  onSelect: PropTypes.func.isRequired
};

export default NestedDropdown;
