import React from 'react';
import PropTypes from 'prop-types';
import orderBy from 'lodash/orderBy';

function Tooltip({ xValue, yValues, unit }) {
  const companyValues = yValues.filter(v => !v.isBenchmark);
  const benchmarkValues = yValues.filter(v => v.isBenchmark);
  const companyValuesSorted = orderBy(companyValues, 'value', 'desc');
  const noTargets = benchmarkValues.length === 0;

  return (
    <div className="cp-tooltip">
      <div className="cp-tooltip__header">
        <span>{xValue}</span>
        <span className="cp-tooltip__value">{unit}</span>
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
      {noTargets ? 'Financed emissions reduction targets not disclosed'
        : benchmarkValues.map(y => (
          <div key={y.title} className="cp-tooltip__row cp-tooltip__row--targets">
            <span className="cp-tooltip__value-title">
              <span
                className="circle"
                style={{ backgroundColor: y.color }}
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
  unit: PropTypes.string.isRequired
};

export default Tooltip;
