import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Select, { components } from 'react-select';
import chevronDownIconBlack from 'images/icon_chevron_dark/chevron_down_black-1.svg';
import chevronUpIconBlack from 'images/icon_chevron_dark/chevron-up.svg';

const blueDarkColor = '#2E3152';
const secondaryColor = '#828397';

class MobileNavigateMenu extends Component {
  customStyles = {
    option: (provided, state) => ({
      ...provided,
      color: state.isSelected ? blueDarkColor : secondaryColor,
      backgroundColor: state.isSelected ? 'inherit' : 'inherit',
      fontWeight: state.isSelected ? '800' : 'normal'
    }),
    control: (provided) => ({
      ...provided,
      border: '1px solid',
      boxShadow: '1px solid #2E3152',
      borderRadius: 0
    }),
    indicatorSeparator: () => ({
      display: 'none'
    }),
    menu: (provided) => ({
      ...provided,
      margin: 0,
      borderRadius: 0
    }),
    container: (provided) => ({
      ...provided,
      marginBottom: '4rem'
    })
  };

  constructor(props) {
    super(props);
    const {options} = this.props;
    this.value = [...options].reverse().filter(option => window.location.pathname.includes(option.value))[0];
  }

  DropdownIndicator = (props) => (
    <components.DropdownIndicator {...props}>
      <img src={props.selectProps.menuIsOpen ? chevronUpIconBlack : chevronDownIconBlack} />
    </components.DropdownIndicator>
  );

  customTheme = theme => ({
    ...theme,
    colors: {
      ...theme.colors,
      primary50: 'inherit'
    }
  });

  render() {
    const {options} = this.props;
    return (
      <Select
        options={options}
        value={this.value}
        className="is-hidden-desktop"
        onChange={(e) => { window.location.href = e.value; }}
        isSearchable={false}
        styles={this.customStyles}
        components={{DropdownIndicator: this.DropdownIndicator}}
        theme={this.customTheme}
      />
    );
  }
}

MobileNavigateMenu.propTypes = {
  options: PropTypes.array.isRequired
};

export default MobileNavigateMenu;
