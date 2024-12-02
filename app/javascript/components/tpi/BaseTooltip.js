import React, { useState } from 'react';
import PropTypes from 'prop-types';

const BaseTooltip = ({ trigger, content }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <span className="base-tooltip">
      <span
        onMouseEnter={() => setIsOpen(true)}
        onMouseLeave={() => setIsOpen(false)}
      >
        {trigger}
      </span>
      {isOpen && (
        <div className="base-tooltip__content">
          {content}
        </div>
      )}
    </span>
  );
};

BaseTooltip.propTypes = {
  trigger: PropTypes.any,
  content: PropTypes.any.isRequired
};

BaseTooltip.defaultProps = {
  trigger: (
    <span className="base-tooltip__default-trigger">i</span>
  )
};

export default BaseTooltip;
