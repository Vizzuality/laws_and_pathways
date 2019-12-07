import React from 'react';
import Select, {components} from 'react-select';

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

const MultiSelect = (props) => (
  <Select
    components={{ Option, ValueContainer }}
    isMulti
    {...props}
  />
);

export default MultiSelect;
