import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { format } from 'd3-format';

function TooltipContent({ content, context, iso, geographiesDB }) {
  const geography = useMemo(() => (geographiesDB.find(g => g.iso === iso)), [iso, geographiesDB]);

  if (!geography) return null;

  const contentValue = content
    && content.values.find(v => geography && v.geography_iso === geography.iso);
  const contextValue = context
    && context.values.find(v => geography && v.geography_iso === geography.iso);

  return (
    <div className="world-map__tooltip-container">
      {geography && (
      <>
        <p className="world-map__tooltip-title">{geography.name}</p>
        <div className="world-map__tooltip-row">
          <p className="world-map__tooltip-text">{content && content.name}</p>
          <p className="world-map__tooltip-number">{contentValue && format(',')(contentValue.value)}</p>
        </div>
        <div className="world-map__tooltip-row">
          <p className="world-map__tooltip-text">{context && context.name}</p>
          <p className="world-map__tooltip-number">{contextValue && format(',')(contextValue.value)} {context.unit}</p>
        </div>
        <a href={geography.link} target="_blank" rel="noopener noreferrer" className="world-map__tooltip-link">Go to full profile</a>
      </>
      )}

    </div>
  );
}

TooltipContent.propTypes = {
  content: PropTypes.object.isRequired,
  context: PropTypes.object.isRequired,
  geographiesDB: PropTypes.array.isRequired,
  iso: PropTypes.string.isRequired
};

export default TooltipContent;
