import React, { Fragment, Component } from 'react';
import PropTypes from 'prop-types';
import search from '../../assets/images/icons/search.svg';
import minus from '../../assets/images/icons/dark-minus.svg';
import plus from '../../assets/images/icons/dark-plus.svg';


class SearchFilter extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isShowOptions: false,
      selectedList: {},
      searchValue: ''
    };

    this.optionsContainer = React.createRef();
  }

  componentDidMount() {
    document.addEventListener('mousedown', this.handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', this.handleClickOutside);
    };
  }

  setShowOptions = value => this.setState({isShowOptions: value});

  setSelectedList = value => this.setState({selectedList: value});

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
    const {selectedList} = this.state;
    const {onChange} = this.props;
    const blocks = Object.assign({}, selectedList);
    if ((blocks[blockName] || []).includes(value)) {
      blocks[blockName] = blocks[blockName].filter(item => item !== value);
      if (blocks[blockName].length === 0) delete blocks[blockName];
    } else {
      if (!blocks[blockName]) blocks[blockName] = [];
      blocks[blockName].push(value);
    }
    onChange(blocks);
    this.setSelectedList(blocks);
  };

  handleSearchInput = e => this.setSearchValue(e.target.value);

  itemIsSelected = (fieldName, value) => this.state.selectedList[fieldName] && this.state.selectedList[fieldName].includes(value);

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
    const {filterName, params, isSearchable} = this.props;
    const listBlocks = [];
    for (let i = 0; i < params.length; i += 1) {
      listBlocks[i] = Object.assign({}, params[i]);
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
            {listBlocks.map((blockList, i) => this.renderBlockList(blockList, i))}
          </div>
        </div>
      </div>
    );
  };

  render() {
    const {selectedList, isShowOptions} = this.state;
    const {filterName} = this.props;
    let selectedCount = 0;
    Object.values(selectedList).forEach(list => { selectedCount += list.length; });

    return (
      <Fragment>
        <div className="filter-container">
          <div className="control-field" onClick={() => this.setShowOptions(true)}>
            <div className="select-field">
              <span>{filterName}</span><span className="toggle-indicator"><img src={plus} alt="" /></span>
            </div>
            {selectedCount !== 0 && <div className="selected-count">{selectedCount} selected</div>}
          </div>
          { isShowOptions && this.renderOptions()}
        </div>
      </Fragment>
    );
  }
}

SearchFilter.defaultProps = {
  onChange: () => {},
  isSearchable: true
};

SearchFilter.propTypes = {
  filterName: PropTypes.string.isRequired,
  params: PropTypes.array.isRequired,
  onChange: PropTypes.func,
  isSearchable: PropTypes.bool
};

export default SearchFilter;
