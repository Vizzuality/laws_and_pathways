import React from 'react';
import PropTypes from 'prop-types';
import orderBy from 'lodash/orderBy';
import hexToRgba from 'hex-to-rgba';

function Tooltip({ xValue, yValues, unit, onClose }) {
  const companyValues = yValues.filter(v => !v.isBenchmark);
  const benchmarkValues = yValues.filter(v => v.isBenchmark);
  const companyValuesSorted = orderBy(companyValues, 'value', 'desc');

  return (
    <div className="cp-tooltip">
      <div className="cp-tooltip__header">
        <span>{xValue}</span>
        <span className="cp-tooltip__value">{unit}</span>

        <span className="cp-tooltip__close" onClick={onClose} />
      </div>

      {companyValuesSorted.map(y => (
        <div key={y.title} className="cp-tooltip__row cp-tooltip__row--bold">
          <span className="cp-tooltip__value-title">
            <span
              className={`line line--${y.dashStyle === 'dot' ? 'dotted' : 'solid'}`}
              style={{borderBottomColor: y.color}}
            />
            {y.title}
            {y.isTargeted && (<small>(targeted)</small>)}
          </span>
          <span className="cp-tooltip__value">{Number.isInteger(y.value) ? y.value : y.value.toFixed(2)}</span>
        </div>
      ))}

      <div className="cp-tooltip__targets">
        TARGETS
      </div>

      {benchmarkValues.map(y => (
        <div key={y.title} className="cp-tooltip__row cp-tooltip__row--targets">
          <span className="cp-tooltip__value-title">
            <span
              className="circle"
              style={{backgroundColor: hexToRgba(y.color, 0.2)}}
            />
            {y.title}
          </span>
          <span className="cp-tooltip__value">{y.value}</span>
        </div>
      ))}
    </div>
  );
}

Tooltip.propTypes = {
  xValue: PropTypes.number.isRequired,
  yValues: PropTypes.array.isRequired,
  unit: PropTypes.string.isRequired,
  onClose: PropTypes.func.isRequired
};

export default Tooltip;
