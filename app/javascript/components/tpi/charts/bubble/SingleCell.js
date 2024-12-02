import React, { Fragment, useRef, useState } from 'react';
import PropTypes from 'prop-types';
import { scaleThreshold } from 'd3-scale';
import {
  useFloating,
  autoUpdate,
  offset,
  flip,
  shift,
  useDismiss,
  useRole,
  useClick,
  useInteractions,
  FloatingFocusManager,
  useId,
  FloatingArrow,
  arrow
} from '@floating-ui/react';

/** Circle radios for each value range */
const RANGE = [12, 18, 24, 30];
/** Value ranges */
const DOMAIN = [11, 51, 101];

const SingleCell = ({ width, height, data, uniqueKey }) => {
  const VALUE = data.value;
  const radiusScale = scaleThreshold().domain(DOMAIN).range(RANGE);
  const radius = radiusScale(VALUE);

  const [isOpen, setIsOpen] = useState(false);
  const arrowRef = useRef(null);

  const { refs, floatingStyles, context } = useFloating({
    open: isOpen,
    placement: 'right',
    onOpenChange: setIsOpen,
    middleware: [
      offset(10),
      flip({ fallbackAxisSideDirection: 'end' }),
      shift(),
      arrow({
        element: arrowRef
      })
    ],
    whileElementsMounted: autoUpdate
  });

  const click = useClick(context);
  const dismiss = useDismiss(context);
  const role = useRole(context);

  const { getReferenceProps, getFloatingProps } = useInteractions([
    click,
    dismiss,
    role
  ]);

  const headingId = useId();

  if (!VALUE) {
    return null;
  }

  return (
    <Fragment>
      <svg id={uniqueKey} width={width} height={height} viewBox={`0 0 ${width} ${height}`}>
        <g
          ref={refs.setReference}
          {...getReferenceProps()}
          className="bubble-chart_circle"
          transform={`translate(${width / 2}, ${height / 2})`}
        >
          <circle r={radius} fill={data.color} />
          <text textAnchor="middle" alignmentBaseline="central" fill="white" fontWeight={700} fontSize="14px">
            {VALUE}
          </text>
        </g>
      </svg>

      {isOpen && (
      <FloatingFocusManager context={context} modal={false}>
        <div
          ref={refs.setFloating}
          style={floatingStyles}
          aria-labelledby={headingId}
          className="bubble-chart_tooltip"
          {...getFloatingProps()}
        >
          <h4>{data.tooltipContent.title}</h4>
          <h3 className="bubble-chart_tooltip_header">{data.tooltipContent.level}</h3>
          <p>{VALUE} {VALUE === 1 ? 'company' : 'companies'}</p>
          <ol className="bubble-chart_tooltip_text">
            {data.tooltipContent.companies.map(company => (
              <li className="bubble-chart_tooltip_list_item" key={company.name}>
                <a href={company.url} target="_blank" rel="noreferrer">{company.name}</a>
              </li>
            ))}
          </ol>
          <button
            type="button"
            style={{ float: 'right' }}
            onClick={() => {
              setIsOpen(false);
            }}
            className="button is-secondary is-small"
          >
            Close
          </button>
          <FloatingArrow fill="white" stroke="black" strokeWidth={1} ref={arrowRef} context={context} />
        </div>
      </FloatingFocusManager>
      )}

    </Fragment>
  );
};

SingleCell.propTypes = {
  width: PropTypes.number.isRequired,
  height: PropTypes.number.isRequired,
  data: PropTypes.arrayOf({
    value: PropTypes.number,
    color: PropTypes.string,
    tooltipContent: PropTypes.shape({
      title: PropTypes.string,
      companies: PropTypes.arrayOf({
        name: PropTypes.string,
        url: PropTypes.string
      })
    })
  }).isRequired,
  uniqueKey: PropTypes.string.isRequired
};

export default SingleCell;
