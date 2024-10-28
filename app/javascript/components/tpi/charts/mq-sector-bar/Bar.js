import React, { useRef, useState } from 'react';
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
import PropTypes from 'prop-types';

const LEVELS_COLORS = [
  '#86A9F9',
  '#5587F7',
  '#2465F5',
  '#0A4BDC',
  '#083AAB',
  '#9747FF'
];

const LEVELS_SUBTITLES = {
  0: 'Unaware',
  1: 'Awareness',
  2: 'Building capacity',
  3: 'Integrating into operational decision making',
  4: 'Strategic assessment',
  5: 'Transition planning and implementation'
};

function Bar({ level, companies, sector, height }) {
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

  return (
    <div key={level} className="sector-level column">
      <div className="sector-level__title">
        <h5>Level {level}</h5>
        <p>{LEVELS_SUBTITLES[level]}</p>
      </div>

      {!!companies.length && (
      <div className="sector-level__companies">
        <div
          style={{
            height,
            backgroundColor: LEVELS_COLORS[level]
          }}
          ref={refs.setReference}
          {...getReferenceProps()}
        >
          {companies.length}
        </div>

        {isOpen && (
        <FloatingFocusManager initialFocus={-1} context={context} modal={false}>
          <div
            ref={refs.setFloating}
            style={floatingStyles}
            aria-labelledby={headingId}
            className="sector-level__popover"
            {...getFloatingProps()}
          >
            <h4>{sector}</h4>
            <h3 className="sector-level__popover_header">
              Level {level} - {LEVELS_SUBTITLES[level]}
            </h3>
            <p>{companies.length} {companies.length === 1 ? 'company' : 'companies'}</p>
            <ol className="sector-level__popover_text">
              {companies.map((company, i) => (
                <li
                  className="sector-level__popover_list_item"
                  key={i}
                >
                  <a
                    href={`/companies/${company.slug}`}
                    target="_blank"
                    rel="noreferrer"
                  >
                    {company.name}
                  </a>
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
      </div>
      )}
    </div>
  );
}

Bar.propTypes = {
  level: PropTypes.number.isRequired,
  companies: PropTypes.array.isRequired,
  sector: PropTypes.string.isRequired,
  height: PropTypes.number.isRequired
};
export default Bar;
