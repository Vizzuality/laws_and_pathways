import React from 'react';
import ReactDOM from 'react-dom';
import chevronIconBlack from 'images/icon_chevron_dark/chevron_down_black-1.svg';

function List({ items }) {
  return (
    <ul className="nested-dropdown__list">
      {items.map((item) => <Item key={item.value} item={item} />)}
    </ul>
  );
}

function Item({ item }) {
  return (
    <li className="nested-dropdown__item">
      <span>{item.label}</span>
      {item.items && <img src={chevronIconBlack} />}
      {item.items && <List items={item.items} />}
    </li>
  )
}

function NestedDropdown({ items, title }) {
  return (
    <div className="nested-dropdown">
      <div className="nested-dropdown__title">
        <span>{title}</span>
        <img src={chevronIconBlack} />
      </div>
      <List items={items} />
    </div>
  );
}

export {
  NestedDropdown
};

const PortalDropdown = ({ renderTo, ...rest }) => (
  ReactDOM.createPortal(<NestedDropdown {...rest} />, document.querySelector(renderTo))
);

export default PortalDropdown;
