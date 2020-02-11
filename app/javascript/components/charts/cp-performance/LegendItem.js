import React from 'react';
import PropTypes from 'prop-types'

function LegendItem({ name, onRemove }) {
  return (
    <div className="legend-item">
      <span className="legend-item__color" />
      {name}
      <button className="legend-item__remove" type="button" onClick={onRemove}>
        x
      </button>
    </div>
  );
}

LegendItem.propTypes = {
  name: PropTypes.string.isRequired,
  onRemove: PropTypes.func.isRequired
};

export default LegendItem;
