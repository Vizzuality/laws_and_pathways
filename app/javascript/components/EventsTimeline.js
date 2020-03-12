import React, { useState, useEffect, Fragment } from 'react';
import PropTypes from 'prop-types';
import { format } from 'date-fns';
import ReactTooltip from 'react-tooltip';
import cx from 'classnames';
import Testimonials from './Testimonials';
import MultiSelect from './MultiSelect';

Testimonials.propTypes = {
  events: PropTypes.array,
  options: PropTypes.array
};

const blueDarkColor = '#2E3152';
const eventSliderMoveBy = 300;

const customStyles = {
  option: (provided, state) => ({
    ...provided,
    color: blueDarkColor,
    backgroundColor: state.isSelected ? 'inherit' : 'inherit'
  }),
  container: (provided) => ({
    ...provided,
    display: window.innerWidth < 1024 ? 'block' : 'inline-block'
  }),
  control: (provided, state) => ({
    ...provided,
    borderRadius: 0,
    borderColor: state.isFocused ? blueDarkColor : blueDarkColor,
    minWidth: 200
  }),
  menu: (provided) => ({
    ...provided,
    borderRadius: 0,
    marginTop: 0,
    width: 250,
    right: 0,
    zIndex: 9
  })
};

const EventsTimeline = ({ events, options, isFiltered = false }) => {
  const [currentTypes, setCurrentTypes] = useState(false);
  const [isShowRightBtn, setIsShowRightBtn] = useState(true);
  const [isShowLeftBtn, setIsShowLeftBtn] = useState(true);
  const [tooltip, setTooltip] = useState(null);
  const eventsContainerEl = React.createRef();
  useEffect(() => checkButtons());
  useEffect(() => {
    if (isShowRightBtn) {
      eventsContainerEl.current.scrollBy({left: events.length * eventSliderMoveBy});
    }
  }, []);

  let currentEvents = events.concat();
  if (isFiltered && (currentTypes || []).length !== 0) {
    const types = currentTypes.map(e => e.value);
    currentEvents = currentEvents.filter(e => types.includes(e.event_type));
  }

  const checkButtons = () => {
    const {scrollLeft, scrollWidth, offsetWidth} = eventsContainerEl.current;
    if (isShowLeftBtn && scrollLeft === 0) setIsShowLeftBtn(false);
    if (!isShowLeftBtn && scrollLeft !== 0) setIsShowLeftBtn(true);

    if (isShowRightBtn && scrollWidth - scrollLeft - offsetWidth === 0) setIsShowRightBtn(false);
    if (!isShowRightBtn && scrollWidth - scrollLeft - offsetWidth !== 0) setIsShowRightBtn(true);
  };

  return (
    <div className="timeline-events-container">
      { !isFiltered && (
        <Fragment>
          <h5>Timeline of events</h5>
          <div className="topic-details is-hidden-desktop">
            Use the dropdown menu to select the different events you wish to see displayed on the country timeline.
          </div>
        </Fragment>
      ) }
      {isFiltered && (
        <Fragment>
          <div className="title-block">
            <h5>Timeline of events</h5>
            <div className="topic-details is-hidden-desktop">
              Use the dropdown menu to select the different events you wish to see displayed on the country timeline.
            </div>
            <div className="filter-block">
              <span>Show events:</span>
              <MultiSelect
                styles={customStyles}
                options={options}
                placeholder="All events"
                closeMenuOnSelect={false}
                hideSelectedOptions={false}
                onChange={(e) => setCurrentTypes(e)}
              />
            </div>
          </div>
          <div className="topic-details is-hidden-touch">
            Use the dropdown menu to select the different events you wish to see displayed on the country timeline.
          </div>
        </Fragment>
      )}
      <div className="timeline-events">
        {isShowLeftBtn && (
          <div className="arrow-left" onClick={() => eventsContainerEl.current.scrollBy({left: -eventSliderMoveBy, behavior: 'smooth'})}>
            <i className="fa fa-arrow-left" />
          </div>
        )}
        <div ref={eventsContainerEl} onScroll={checkButtons} className="events-container">
          <div className="timeline">
            {currentEvents.map((event, i) => (
              <div key={`${event.title}-${i}`} className={cx('time-point', { 'time-point-multiple-events': currentEvents.length > 1 })}>
                <div className="event-title">{event.title}</div>
                <div
                  className="point"
                  data-tip
                  onClick={() => window.open(event.link, '_self')}
                  onMouseEnter={() => setTooltip(event.eventable_title)}
                />
                <div className="date">{ format(new Date(event.date), 'MMMM Y') }</div>
              </div>
            ))}
          </div>
        </div>
        {isShowRightBtn && (
          <div className="arrow-right" onClick={() => eventsContainerEl.current.scrollBy({left: eventSliderMoveBy, behavior: 'smooth'})}>
            <i className="fa fa-arrow-right" />
          </div>
        )}
      </div>
      {tooltip && (
        <ReactTooltip class="cclow-tooltip">
          {tooltip}
        </ReactTooltip>
      )}
    </div>
  );
};

EventsTimeline.propTypes = {
  events: PropTypes.array.isRequired,
  options: PropTypes.array.isRequired,
  isFiltered: PropTypes.bool.isRequired
};

export default EventsTimeline;
