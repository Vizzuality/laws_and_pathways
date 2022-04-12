import React from 'react';
import PropTypes from 'prop-types';

import DarkXIcon from 'images/icons/dark-x.svg';

function CompanyTag({ className, item, hideRemoveIcon, onRemove }) {
  return (
    <div className={`company-tag ${className}`}>
      {item.color && (
        <span
          className="circle"
          style={{backgroundColor: item.color}}
        />
      )}
      {item.name}
      {!hideRemoveIcon && (
        <span className="company-tag__remove" onClick={() => onRemove(item)}>
          <img src={DarkXIcon} alt="Remove" />
        </span>
      )}
    </div>
  );
}

CompanyTag.defaultProps = {
  hideRemoveIcon: false
};

CompanyTag.propTypes = {
  hideRemoveIcon: PropTypes.bool,
  className: PropTypes.string.isRequired,
  item: PropTypes.object.isRequired,
  onRemove: PropTypes.func.isRequired
};

export default CompanyTag;
