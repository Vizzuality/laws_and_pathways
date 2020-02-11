import React from 'react';
import PropTypes from 'prop-types';

function Line({ dashStyle, color, width }) {
  const style = {
    borderBottomStyle: dashStyle === 'dot' ? 'dotted' : 'solid',
    borderBottomColor: color,
    width
  };

  return (
    <span className="line" style={style} />
  );
}

function Tooltip({ xValue, yValues, unit }) {
  const companyValues = yValues.filter(v => !v.isBenchmark);
  const benchmarkValues = yValues.filter(v => v.isBenchmark);

  return (
    <div className="cp-tooltip">
      <div className="cp-tooltip__row cp-tooltip__row--bold">
        <span>{xValue}</span>
        <span>{unit}</span>
      </div>

      {companyValues.map(y => (
        <div className="cp-tooltip__row cp-tooltip__row--bold">
          <span className="cp-tooltip__value-title">
            <Line dashStyle={y.dashStyle} color={y.color} />
            {y.title}
            {y.isTargeted && (<small>(targeted)</small>)}
          </span>
          <span>{y.value}</span>
        </div>
      ))}

      <div className="cp-tooltip__targets">
        TARGETS
      </div>

      {benchmarkValues.map(y => (
        <div className="cp-tooltip__row">
          <span>{y.title}</span>
          <span>{y.value}</span>
        </div>
      ))}
    </div>
  );
}

Tooltip.propTypes = {
  xValue: PropTypes.number.isRequired,
  yValues: PropTypes.array.isRequired,
  unit: PropTypes.string.isRequired
};

export default Tooltip;
