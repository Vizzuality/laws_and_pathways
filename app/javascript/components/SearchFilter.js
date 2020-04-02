import React, { Fragment, Component } from 'react';
import PropTypes from 'prop-types';
import sortBy from 'lodash/sortBy';
import search from '../../assets/images/icons/search.svg';
import minus from '../../assets/images/icons/dark-minus.svg';
import plus from '../../assets/images/icons/dark-plus.svg';

class SearchFilter extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isShowOptions: false,
      searchValue: ''
    };

    this.optionsContainer = React.createRef();
  }

  componentDidMount() {
    document.addEventListener('mousedown', this.handleClickOutside);
  }

  componentWillUnmount() {
    document.removeEventListener('mousedown', this.handleClickOutside);
  }

  setShowOptions = value => this.setState({isShowOptions: value});

  setSearchValue = value => this.setState({searchValue: value});

  handleCloseOptions = () => {
    this.setSearchValue('');
    this.setShowOptions(false);
  };

  handleClickOutside = (event) => {
    if (this.optionsContainer.current && !this.optionsContainer.current.contains(event.target)) {
      this.handleCloseOptions();
    }
  };

  handleCheckItem = (blockName, value) => {
    const {onChange, selectedList} = this.props;
    const blocks = Object.assign({}, selectedList);
    if ((blocks[blockName] || []).includes(value)) {
      blocks[blockName] = blocks[blockName].filter(item => item !== value);
    } else {
      if (!blocks[blockName]) blocks[blockName] = [];
      blocks[blockName].push(value);
    }
    onChange(blocks);
  };

  handleSearchInput = e => this.setSearchValue(e.target.value);

  itemIsSelected = (fieldName, value) => this.props.selectedList[fieldName] && this.props.selectedList[fieldName].includes(value);

  renderBlocksList = (blocks) => {
    const options = blocks.map((o) => {
      const optionsWithFieldName = o.options.map((el) => ({ ...el, fieldName: o.field_name }));
      return optionsWithFieldName;
    });

    const sortedOptions = sortBy(options.flat(), 'label');

    return (
      <ul>
        {sortedOptions.map(option => (
          <li key={option.value} onClick={() => this.handleCheckItem(option.fieldName, option.value)}>
            <input type="checkbox" hidden checked={this.itemIsSelected(option.fieldName, option.value) || false} onChange={() => {}} />
            <div className={`${this.itemIsSelected(option.fieldName, option.value) ? 'checked' : 'unchecked'} select-checkbox`}>
              {this.itemIsSelected(option.fieldName, option.value) && <i className="fa fa-check" />}
            </div>
            <label>{option.label}</label>
          </li>
        ))}
      </ul>
    );
  }

  renderBlockList = (block, index) => {
    const {options, field_name: fieldName} = block;
    if ((options || []).length === 0) return null;
    return (
      <Fragment key={fieldName}>
        { index !== 0 && <hr /> }
        <ul>
          {options.map(option => (
            <li key={option.value} onClick={() => this.handleCheckItem(fieldName, option.value)}>
              <input type="checkbox" hidden checked={this.itemIsSelected(fieldName, option.value) || false} onChange={() => {}} />
              <div className={`${this.itemIsSelected(fieldName, option.value) ? 'checked' : 'unchecked'} select-checkbox`}>
                {this.itemIsSelected(fieldName, option.value) && <i className="fa fa-check" />}
              </div>
              <label>{option.label}</label>
            </li>
          ))}
        </ul>
      </Fragment>
    );
  };

  renderOptions = () => {
    const {searchValue} = this.state;
    const {filterName, items, isSearchable} = this.props;
    const listBlocks = [];
    for (let i = 0; i < items.length; i += 1) {
      listBlocks[i] = Object.assign({}, items[i]);
      if (searchValue) {
        listBlocks[i].options = listBlocks[i]
          .options.concat().filter(item => item.label.toLowerCase().includes(searchValue.toLowerCase()));
      }
    }
    return (
      <div className="options-container" ref={this.optionsContainer}>
        <div className="select-field" onClick={this.handleCloseOptions}>
          <span>{filterName}</span><span className="toggle-indicator"><img src={minus} alt="" /></span>
        </div>
        <div>
          {isSearchable && (
            <div className="search-input-container">
              <input id="search-input" type="text" onChange={this.handleSearchInput} />
              <label htmlFor="search-input">
                <img src={search} />
              </label>
            </div>
          )}
          <div className="options-list">
            {listBlocks.length > 1 ? (
              this.renderBlocksList(listBlocks)
            ) : (
              listBlocks.map((blockList, i) => this.renderBlockList(blockList, i))
            )}
          </div>
        </div>
      </div>
    );
  };

  isEmpty = () => {
    const {items} = this.props;
    for (let i = 0; i < items.length; i = 1) {
      if ((items[i].options || []).length !== 0) return false;
    }
    return true;
  };

  render() {
    const {isShowOptions} = this.state;
    const {filterName, selectedList, className} = this.props;
    if (this.isEmpty()) return null;

    let selectedCount = 0;
    Object.values(selectedList).forEach(list => { selectedCount += list.length; });

    return (
      <div className={`filter-container ${className}`}>
        <div className="control-field" onClick={() => this.setShowOptions(true)}>
          <div className="select-field">
            <span>{filterName}</span><span className="toggle-indicator"><img src={plus} alt="" /></span>
          </div>
          {selectedCount !== 0 && <div className="selected-count">{selectedCount} selected</div>}
        </div>
        { isShowOptions && this.renderOptions()}
      </div>
    );
  }
}

SearchFilter.defaultProps = {
  className: '',
  onChange: () => {},
  selectedList: {},
  isSearchable: true
};

SearchFilter.propTypes = {
  className: PropTypes.string,
  filterName: PropTypes.string.isRequired,
  items: PropTypes.array.isRequired,
  onChange: PropTypes.func,
  selectedList: PropTypes.object,
  isSearchable: PropTypes.bool
};

export default SearchFilter;
