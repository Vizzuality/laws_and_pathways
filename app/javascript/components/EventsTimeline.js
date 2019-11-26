import React, { useState } from "react";
import Select, {components} from 'react-select';
import PropTypes from "prop-types";
import Testimonials from "./Testimonials";

Testimonials.propTypes = {
  events: PropTypes.array,
};

const blueDarkColor = '#2E3152';

const customStyles = {
  option: (provided, state) => ({
    ...provided,
    color: blueDarkColor,
    backgroundColor: state.isSelected ? 'inherit' : 'inherit',
  }),
  container: (provided) => ({
    ...provided,
    display: 'inline-block',
  }),
  control: (provided, state) => ({
    ...provided,
    borderRadius: '0',
    borderColor: state.isFocused ? blueDarkColor : blueDarkColor,
    minWidth: 200,
  }),
  menu: (provided) => ({
    ...provided,
    borderRadius: '0',
    borderWidth: '4px',
    marginTop: '0',
    width: '250px',
    right: '0',
    marginRight: '0',
    zIndex: 9,
  }),
}

const Option = props => (
  <div>
    <components.Option {...props}>
      <input type="checkbox" hidden checked={props.isSelected} onChange={() => null} />
      {props.isSelected && <div className="checked select-checkbox"><i className="fa fa-check"></i></div>}
      {!props.isSelected && <div className="unchecked select-checkbox"></div>}
      <label>{props.value}</label>
    </components.Option>
  </div>
);
const EventsTimeline = ({ events }) => {
  const [currentTypes, setCurrentTypes] = useState(false);
  let options = [...new Set(events.map((item)=>item.event_type))];
  options = options.map((item) => ({value: item, label: item}));
  if ((currentTypes || []).length !== 0) {
    const types = currentTypes.map(e => e.value);
    events = events.filter(e=> types.includes(e.event_type));
  }

  const el = React.createRef();
  return (
    <div className="timeline-events-container">
      <div className="title-block">
        <h5>Timeline of events</h5>
        <div className="filter-block">
          <span>Show events:</span>
          <Select
            components={{ Option }}
            styles={customStyles}
            options={options}
            isMulti
            placeholder='All events'
            closeMenuOnSelect={false}
            hideSelectedOptions={false}
            onChange={(e) => setCurrentTypes(e)} />
        </div>
      </div>
      <div className="topic-details">
        Use the dropdown menu to select the different events you wish to see displayed on the country timeline.
      </div>

      <div className="timeline-events">
        <div className="arrow-left" onClick={() => {el.current.scrollBy(-40,0)}}>
          <i className="fa fa-arrow-left"></i>
        </div>
        <div ref={ el } className="events-container">
          <div className="timeline">
            {events.map((event, i) => (
              <div key={i} className="time-point">
                <div className="event-title">{ event.title }</div>
                <div className="point"></div>
                <div className="date">{ event.date }</div>
              </div>
            ))}
          </div>
        </div>
        <div className="arrow-right" onClick={() => el.current.scrollBy(40,0)}>
          <i className="fa fa-arrow-right"></i>
        </div>
      </div>
    </div>
  )
}

export default EventsTimeline;
