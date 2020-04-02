import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import qs from 'qs';
import pick from 'lodash/pick';
import pickBy from 'lodash/pickBy';
import flatten from 'lodash/flatten';

import SearchFilter from '../../SearchFilter';
import TimeRangeFilter from '../../TimeRangeFilter';

import { getQueryFilters } from './helpers';

class List extends Component {
  constructor(props) {
    super(props);

    this.state = {
      items: this.props.items,
      count: this.props.count,
      offset: 0,
      showMoreFilters: false,
      ...this.resolveStateFromQueryString()
    };

    this.isMobile = window.innerWidth < 1024;

    this.filterRefs = this.props.filterConfigs
      .map(f => f.name)
      .reduce((acc, filter) => ({...acc, [filter]: React.createRef()}), {});
  }

  componentDidMount() {
    window.addEventListener('popstate', this.handleHistoryChange);
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handleHistoryChange);
  }

  handleHistoryChange = () => {
    this.setState({ ...this.resolveStateFromQueryString() }, this.fetchData.bind(this));
  }

  handleLoadMore = () => {
    const { items } = this.state;
    this.setState({ offset: items.length }, this.fetchData.bind(this));
  }

  handleFilterChange = (changedFilters) => {
    this.setState((state) => ({
      filters: {
        ...state.filters,
        ...changedFilters
      },
      offset: 0
    }), () => {
      this.updateHistory();
      this.fetchData();
    });
  }

  createQueryString(extraParams = {}) {
    const notEmpty = (value) => {
      if (value && value.length) return true;

      return value !== undefined && value !== null;
    };

    const params = pickBy({
      ...this.state.filters,
      ...extraParams
    }, notEmpty);

    return qs.stringify(params, { addQueryPrefix: true, arrayFormat: 'brackets' });
  }

  resolveStateFromQueryString() {
    const query = getQueryFilters();
    const { filterConfigs } = this.props;

    // [['geography', paramIntegerArray], ['keywords', paramIntegerArray]]
    const allParamsArray = flatten(
      filterConfigs.map((fConfig) => Object.entries(fConfig.params))
    );

    // { geography: paramIntegerArray(query.geography), ... }
    const filters = allParamsArray
      .reduce((acc, param) => ({
        ...acc,
        [param[0]]: param[1](query[param[0]])
      }), {});

    return { filters };
  }

  updateHistory() {
    const query = this.createQueryString();
    window.history.pushState(null, null, query || window.location.pathname);
  }

  fetchData() {
    const { offset } = this.state;
    const { url } = this.props;
    const newQs = this.createQueryString({ offset });

    fetch(`${url}.json${newQs}`).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          if (offset > 0) {
            this.setState(({ items }) => ({
              items: items.concat(data.items)
            }));
          } else {
            this.setState({items: data.items, count: data.count});
          }
        }
      });
    });
  }

  renderPageTitle() {
    const { title, allTitle } = this.props;

    const qFilters = getQueryFilters();

    const filterText = qFilters.q || (qFilters.recent && 'recent additions');

    if (filterText) {
      return (
        <h5 className="search-title">
          Search results: <strong>{filterText}</strong> in {title}
        </h5>
      );
    }

    return (<h5>{allTitle}</h5>);
  }

  renderFilter = (filterConfig) => {
    const { filters, showMoreFilters } = this.state;
    const {
      name,
      options,
      title,
      mainFilter,
      props
    } = filterConfig;
    const params = Object.keys(filterConfig.params);
    // filter must remain visible in DOM because refs are being used
    // TODO: refactor to not use refs
    const className = (!showMoreFilters && !mainFilter) ? 'hidden' : '';

    if (filterConfig.timeRange) {
      return (
        <TimeRangeFilter
          ref={this.filterRefs[name]}
          className={className}
          onChange={this.handleFilterChange}
        />
      );
    }

    return (
      <SearchFilter
        ref={this.filterRefs[name]}
        className={className}
        filterName={title}
        items={options}
        selectedList={pick(filters, params)}
        onChange={this.handleFilterChange}
        {...props}
      />
    );
  }

  renderFilters() {
    const { showMoreFilters } = this.state;
    const { filterConfigs } = this.props;

    const toggleShowMoreFilters = () => {
      this.setState((state) => ({ showMoreFilters: !state.showMoreFilters }));
    };
    const anySecondaryFilters = Boolean(filterConfigs.filter(c => !c.mainFilter).length);

    return (
      <Fragment>
        {filterConfigs.map(this.renderFilter)}

        {anySecondaryFilters && (
          <button
            type="button"
            onClick={toggleShowMoreFilters}
            className="more-options"
          >
            {showMoreFilters ? '- Show fewer search options' : '+ Show more search options'}
          </button>
        )}
      </Fragment>
    );
  }

  renderTags = () => {
    const { filters } = this.state;
    const { filterConfigs } = this.props;

    if (Object.keys(filters).every(x => !x)) return null;

    return (
      <div className="filter-tags tags">
        {filterConfigs.map(this.renderTagsGroup)}
      </div>
    );
  };

  renderTagsGroup = (filterConfig) => {
    const { filters } = this.state;
    const { name, options, timeRange } = filterConfig;
    const activeTags = pick(filters, Object.keys(filterConfig.params));
    const filterEl = this.filterRefs[name];

    if (timeRange) return this.renderTimeRangeTags(activeTags, filterEl);

    return (
      <Fragment>
        {Object.keys(activeTags).map((keyBlock) => (
          activeTags[keyBlock].filter(x => x).map((key, i) => (
            <span key={`tag_${keyBlock}_${i}`} className="tag">
              {options.filter(item => item.field_name === keyBlock)[0].options.filter(l => l.value === key)[0].label}
              <button type="button" onClick={() => filterEl.current.handleCheckItem(keyBlock, key)} className="delete" />
            </span>
          ))
        ))}
      </Fragment>
    );
  }

  renderTimeRangeTags = (value, filterEl) => (
    <Fragment>
      {value.from_date && (
        <span key="tag-time-range-from" className="tag">
          From {value.from_date}
          <button
            type="button"
            onClick={() => filterEl.current.handleChange({from_date: null})}
            className="delete"
          />
        </span>
      )}
      {value.to_date && (
        <span key="tag-time-range-to" className="tag">
          To {value.to_date}
          <button
            type="button"
            onClick={() => filterEl.current.handleChange({to_date: null})}
            className="delete"
          />
        </span>
      )}
    </Fragment>
  );

  render() {
    const { items, count } = this.state;
    const { url } = this.props;
    const hasMore = items.length < count;
    const downloadResultsLink = `${url}.csv${this.createQueryString()}`;

    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="container">
            <div className="title-page">
              {this.renderPageTitle()}
            </div>
            {this.isMobile && (<div className="filter-column">{this.renderFilters()}</div>)}
            <hr />
            <div className="columns">
              {!this.isMobile && (
                <div className="column is-one-quarter filter-column">
                  <div className="search-by">Narrow this search by</div>
                  {this.renderFilters()}
                </div>
              )}
              <main className="column is-three-quarters">
                <div className="columns pre-content">
                  <span className="column is-half">Showing {count} results</span>
                  <span className="column is-half download-link is-hidden-touch">
                    <a className="download-link" href={downloadResultsLink}>Download results (.csv)</a>
                  </span>
                </div>
                {this.renderTags()}
                <ul className="content-list">
                  {items.map((legislation, i) => (
                    <Fragment key={i}>
                      <li key={i} className="content-item">
                        {this.props.renderContentItem(legislation)}
                      </li>
                    </Fragment>
                  ))}
                </ul>
                {hasMore && (
                  <div className={`column load-more-container${!this.isMobile ? ' is-offset-5' : ''}`}>
                    <button type="button" className="button is-primary load-more-btn" onClick={this.handleLoadMore}>
                      Load 10 more entries
                    </button>
                  </div>
                )}
              </main>
            </div>
          </div>
        </div>
      </Fragment>
    );
  }
}

List.defaultProps = {};

List.propTypes = {
  filterConfigs: PropTypes.array.isRequired,
  items: PropTypes.array.isRequired,
  url: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  allTitle: PropTypes.string.isRequired,
  renderContentItem: PropTypes.func.isRequired,
  count: PropTypes.number.isRequired
};

export default List;
