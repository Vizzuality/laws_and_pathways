import React, { useState, useEffect, Fragment } from 'react';
import Select, {components} from 'react-select';
import PropTypes from 'prop-types';
import { format } from 'date-fns';
import Testimonials from './Testimonials';

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
    display: 'inline-block'
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

const Option = props => (
  <div>
    <components.Option {...props}>
      <input type="checkbox" hidden checked={props.isSelected} onChange={() => null} />
      {props.isSelected && <div className="checked select-checkbox"><i className="fa fa-check" /></div>}
      {!props.isSelected && <div className="unchecked select-checkbox" />}
      <label>{props.label}</label>
    </components.Option>
  </div>
);

const ValueContainer = ({children, ...props}) => {
  const controls = React.Children.toArray(children).filter(item => ['Input', 'Placeholder'].includes(item.type.name));
  return (
    <components.ValueContainer {...props}>
      {(props.selectProps.value || []).length !== 0 && <span>{props.selectProps.value.length} selected</span>}
      {controls}
    </components.ValueContainer>
  );
};

const EventsTimeline = ({ events, options, isFiltered = false }) => {
  const [currentTypes, setCurrentTypes] = useState(false);
  const [isShowRightBtn, setIsShowRightBtn] = useState(true);
  const [isShowLeftBtn, setIsShowLeftBtn] = useState(true);
  const eventsContainerEl = React.createRef();
  useEffect(() => checkButtons());

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
      { !isFiltered && <h5>Timeline of events</h5> }
      {isFiltered && (
        <Fragment>
          <div className="title-block">
            <h5>Timeline of events</h5>
            <div className="filter-block">
              <span>Show events:</span>
              <Select
                components={{ Option, ValueContainer }}
                styles={customStyles}
                options={options}
                isMulti
                placeholder="All events"
                closeMenuOnSelect={false}
                hideSelectedOptions={false}
                onChange={(e) => setCurrentTypes(e)}
              />
            </div>
          </div>
          <div className="topic-details">
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
            {currentEvents.map((event) => (
              <div key={event.title} className="time-point">
                <div className="event-title">{ event.title }</div>
                <div className="point" />
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
    </div>
  );
};

EventsTimeline.propTypes = {
  events: PropTypes.array.isRequired,
  options: PropTypes.array.isRequired,
  isFiltered: PropTypes.bool.isRequired
};

export default EventsTimeline;
