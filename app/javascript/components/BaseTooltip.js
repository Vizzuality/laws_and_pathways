import React, { useState } from "react";
import PropTypes from "prop-types";

const BaseTooltip = ({ tooltipTrigger, tooltipContent }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <span className="base-tooltip">
      <span
        onMouseEnter={() => setIsOpen(true)}
        onMouseLeave={() => setIsOpen(false)}
      >
        {tooltipTrigger}
      </span>
      {isOpen && <div className="base-tooltip-content">
        {tooltipContent}
      </div>}
    </span>
  )
}

export default BaseTooltip;