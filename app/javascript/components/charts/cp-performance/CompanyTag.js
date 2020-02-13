import React from 'react';
import PropTypes from 'prop-types';

import XIcon from 'images/icons/x.svg';

function CompanyTag({ className, item, onRemove }) {
  return (
    <div className={`company-tag ${className}`}>
      {item.color && (
        <span
          className="circle"
          style={{backgroundColor: item.color}}
        />
      )}
      {item.name}
      <span className="company-tag__remove" onClick={() => onRemove(item)}>
        <img src={XIcon} />
      </span>
    </div>
  );
}

CompanyTag.propTypes = {
  className: PropTypes.string.isRequired,
  item: PropTypes.object.isRequired,
  onRemove: PropTypes.func.isRequired
};

export default CompanyTag;
