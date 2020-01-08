import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import qs from 'qs';
import SearchFilter from '../../SearchFilter';
import TimeRangeFilter from '../../TimeRangeFilter';

function getQueryFilters() {
  return qs.parse(window.location.search.slice(1));
}

class LitigationCases extends Component {
  constructor(props) {
    super(props);
    const {
      litigations,
      count
    } = this.props;

    this.state = {
      litigations,
      count,
      offset: 0,
      activeGeoFilter: {},
      activeTagFilter: {},
      activeTimeRangeFilter: {},
      activeStatusesFilter: {}
    };

    this.geoFilter = React.createRef();
    this.tagsFilter = React.createRef();
    this.timeRangeFilter = React.createRef();
    this.statusFilter = React.createRef();
  }

  handleLoadMore = () => {
    const { litigations } = this.state;
    this.setState({ offset: litigations.length }, this.fetchData.bind(this));
  }

  filterList = (activeFilterName, filterParams) => {
    this.setState({[activeFilterName]: filterParams, offset: 0}, this.fetchData.bind(this));
  };

  fetchData() {
    const {activeGeoFilter, activeTagFilter, activeTimeRangeFilter, activeStatusesFilter, offset} = this.state;
    const params = {
      ...getQueryFilters(),
      ...activeGeoFilter,
      ...activeTagFilter,
      ...activeTimeRangeFilter,
      ...activeStatusesFilter,
      offset
    };

    const newQs = qs.stringify(params, { arrayFormat: 'brackets' });

    fetch(`/cclow/litigation_cases.json?${newQs}`).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          if (offset > 0) {
            this.setState(({ litigations }) => ({
              litigations: litigations.concat(data.litigations)
            }));
          } else {
            this.setState({litigations: data.litigations, count: data.count});
          }
        }
      });
    });
  }

  renderTags = () => {
    const {activeGeoFilter, activeTagFilter, activeTimeRangeFilter, activeStatusesFilter} = this.state;
    const {
      geo_filter_options: geoFilterOptions,
      tags_filter_options: tagsFilterOptions,
      statuses_filter_options: statusesFilterOptions
    } = this.props;
    if (Object.keys(activeGeoFilter).length === 0
      && Object.keys(activeTagFilter).length === 0
      && Object.keys(activeStatusesFilter).length === 0
      && Object.keys(activeTimeRangeFilter).length === 0) return null;
    return (
      <div className="filter-tags">
        {this.renderTagsGroup(activeGeoFilter, geoFilterOptions, 'geoFilter')}
        {this.renderTagsGroup(activeTagFilter, tagsFilterOptions, 'tagsFilter')}
        {this.renderTagsGroup(activeStatusesFilter, statusesFilterOptions, 'statusFilter')}
        {this.renderTimeRangeTags(activeTimeRangeFilter)}
      </div>
    );
  };

  renderTimeRangeTags = (value) => (
    <Fragment>
      {value.from_date && (
        <span key="tag-time-range-from" className="tag">
          From {value.from_date}
          <button
            type="button"
            onClick={() => this.timeRangeFilter.current.handleChange({from_date: null})}
            className="delete"
          />
        </span>
      )}
      {value.to_date && (
        <span key="tag-time-range-to" className="tag">
          To {value.to_date}
          <button
            type="button"
            onClick={() => this.timeRangeFilter.current.handleChange({to_date: null})}
            className="delete"
          />
        </span>
      )}
    </Fragment>
  );

  renderTagsGroup = (activeTags, options, filterEl) => (
    <Fragment>
      {Object.keys(activeTags).map((keyBlock) => (
        activeTags[keyBlock].map((key, i) => (
          <span key={`tag_${keyBlock}_${i}`} className="tag">
            {options.filter(item => item.field_name === keyBlock)[0].options.filter(l => l.value === key)[0].label}
            <button type="button" onClick={() => this[filterEl].current.handleCheckItem(keyBlock, key)} className="delete" />
          </span>
        ))
      ))}
    </Fragment>
  );

  renderPageTitle() {
    const qFilters = getQueryFilters();

    const filterText = qFilters.q || (qFilters.recent && 'recent additions');

    if (filterText) {
      return (
        <h5 className="search-title">
          Search results: <strong>{filterText}</strong> in Litigation Cases
        </h5>
      );
    }

    return (<h5>All Litigation Cases</h5>);
  }

  render() {
    const {litigations, count} = this.state;
    const {
      geo_filter_options: geoFilterOptions,
      tags_filter_options: tagsFilterOptions,
      statuses_filter_options: statusesFilterOptions
    } = this.props;
    const hasMore = litigations.length < count;
    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="container">
            {this.renderPageTitle()}
            <hr />
            <div className="columns">
              <div className="column is-one-quarter filter-column">
                <div className="search-by">Narrow this search by</div>
                <SearchFilter
                  ref={this.geoFilter}
                  filterName="Regions and countries"
                  params={geoFilterOptions}
                  onChange={(event) => this.filterList('activeGeoFilter', event)}
                />
                <TimeRangeFilter
                  ref={this.timeRangeFilter}
                  onChange={(event) => this.filterList('activeTimeRangeFilter', event)}
                />
                <SearchFilter
                  ref={this.statusFilter}
                  filterName="Status"
                  params={statusesFilterOptions}
                  onChange={(event) => this.filterList('activeStatusesFilter', event)}
                />
                <SearchFilter
                  ref={this.tagsFilter}
                  filterName="Tags"
                  params={tagsFilterOptions}
                  onChange={(event) => this.filterList('activeTagFilter', event)}
                />
              </div>
              <main className="column is-three-quarters">
                <div className="columns pre-content">
                  <span className="column is-half">Showing {count} results</span>
                  <a className="column is-half download-link" href="#">Download results (CSV in .zip)</a>
                </div>
                {this.renderTags()}
                <ul className="content-list">
                  {litigations.map((litigation, i) => (
                    <Fragment key={i}>
                      <li className="content-item">
                        <h5 className="title" dangerouslySetInnerHTML={{__html: litigation.link}} />
                        <div className="meta">
                          {litigation.geography && (
                            <Fragment>
                              <div>
                                <img src={`/images/flags/${litigation.geography.iso}.svg`} alt="" />
                                {litigation.geography.name}
                              </div>
                              {litigation.opened_in && <div>Opened in {litigation.opened_in}</div>}
                            </Fragment>
                          )}
                        </div>
                        <div className="description" dangerouslySetInnerHTML={{__html: litigation.summary}} />
                      </li>
                    </Fragment>
                  ))}
                </ul>
                {hasMore && (
                  <div className="column is-offset-5">
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


LitigationCases.defaultProps = {
  count: 0,
  geo_filter_options: [],
  tags_filter_options: [],
  statuses_filter_options: []
};

LitigationCases.propTypes = {
  litigations: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  tags_filter_options: PropTypes.array,
  statuses_filter_options: PropTypes.array
};

export default LitigationCases;
