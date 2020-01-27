import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import qs from 'qs';
import SearchFilter from '../../SearchFilter';
import TimeRangeFilter from '../../TimeRangeFilter';
import ExecutiveSVG from 'images/icons/legislation_types/executive.svg';
import LegislativeSVG from 'images/icons/legislation_types/legislative.svg';

function getQueryFilters() {
  return qs.parse(window.location.search.slice(1));
}

class LegislationAndPolicies extends Component {
  constructor(props) {
    super(props);
    const {
      legislations,
      count
    } = this.props;

    this.state = {
      legislations,
      count,
      offset: 0,
      activeGeoFilter: {},
      activeTagFilter: {},
      activeTimeRangeFilter: {},
      activeTypesFilter: {}
    };

    this.geoFilter = React.createRef();
    this.tagsFilter = React.createRef();
    this.timeRangeFilter = React.createRef();
    this.typesFilter = React.createRef();
  }

  getQueryString(extraParams = {}) {
    const {activeGeoFilter, activeTagFilter, activeTypesFilter, activeTimeRangeFilter} = this.state;

    const params = {
      ...getQueryFilters(),
      ...activeGeoFilter,
      ...activeTagFilter,
      ...activeTypesFilter,
      ...activeTimeRangeFilter,
      ...extraParams
    };

    return qs.stringify(params, { arrayFormat: 'brackets' });
  }

  handleLoadMore = () => {
    const { legislations } = this.state;
    this.setState({ offset: legislations.length }, this.fetchData.bind(this));
  }

  filterList = (activeFilterName, filterParams) => {
    this.setState({[activeFilterName]: filterParams, offset: 0}, this.fetchData.bind(this));
  };

  fetchData() {
    const { offset } = this.state;
    const newQs = this.getQueryString({ offset });

    fetch(`/cclow/legislation_and_policies.json?${newQs}`).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          if (offset > 0) {
            this.setState(({ legislations }) => ({
              legislations: legislations.concat(data.legislations)
            }));
          } else {
            this.setState({legislations: data.legislations, count: data.count});
          }
        }
      });
    });
  }

  renderPageTitle() {
    const qFilters = getQueryFilters();

    const filterText = qFilters.q || (qFilters.recent && 'recent additions');

    if (filterText) {
      return (
        <h5 className="search-title">
          Search results: <strong>{filterText}</strong> in Legislation and policies
        </h5>
      );
    }

    return (<h5>All laws and policies</h5>);
  }

  renderTags = () => {
    const {activeGeoFilter, activeTagFilter, activeTimeRangeFilter, activeTypesFilter} = this.state;
    const {
      geo_filter_options: geoFilterOptions,
      tags_filter_options: tagsFilterOptions,
      types_filter_options: typesFilterOptions
    } = this.props;
    if (Object.keys(activeGeoFilter).length === 0
      && Object.keys(activeTagFilter).length === 0
      && Object.keys(activeTypesFilter).length === 0
      && Object.keys(activeTimeRangeFilter).length === 0) return null;
    return (
      <div className="filter-tags">
        {this.renderTagsGroup(activeGeoFilter, geoFilterOptions, 'geoFilter')}
        {this.renderTagsGroup(activeTagFilter, tagsFilterOptions, 'tagsFilter')}
        {this.renderTagsGroup(activeTypesFilter, typesFilterOptions, 'typesFilter')}
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

  render() {
    const {legislations, count} = this.state;
    const {
      geo_filter_options: geoFilterOptions,
      tags_filter_options: tagsFilterOptions,
      types_filter_options: typesFilterOptions
    } = this.props;
    const hasMore = legislations.length < count;
    const downloadResultsLink = `/cclow/legislation_and_policies.csv?${this.getQueryString()}`;

    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="title-page">
            {this.renderPageTitle()}
          </div>
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
                ref={this.typesFilter}
                filterName="Executive / Legislative"
                params={typesFilterOptions}
                isSearchable={false}
                onChange={(event) => this.filterList('activeTypesFilter', event)}
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
                <span className="column is-half download-link">
                  <a className="download-link" href={downloadResultsLink}>Download results (.csv)</a>
                </span>
              </div>
              {this.renderTags()}
              <ul className="content-list">
                {legislations.map((legislation, i) => (
                  <Fragment key={i}>
                    <li className="content-item">
                      <h5 className="title" dangerouslySetInnerHTML={{__html: legislation.link}} />
                      <div className="meta">
                        {legislation.geography && (
                          <Fragment>
                            <a href={legislation.geography_path}>
                              <img src={`/images/flags/${legislation.geography.iso}.svg`} alt="" />
                              {legislation.geography.name}
                            </a>
                          </Fragment>
                        )}
                        <div>
                          <img
                            src={legislation.legislation_type === 'executive' ? ExecutiveSVG : LegislativeSVG}
                            alt={legislation.legislation_type}
                          />
                          {legislation.legislation_type_humanize}
                        </div>
                        {legislation.date_passed && <div>{legislation.date_passed}</div>}
                        {legislation.last_change && <div>Last change in {legislation.last_change}</div>}
                      </div>
                      <div className="description" dangerouslySetInnerHTML={{__html: legislation.description}} />
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
      </Fragment>
    );
  }
}


LegislationAndPolicies.defaultProps = {
  count: 0,
  geo_filter_options: [],
  tags_filter_options: [],
  types_filter_options: []
};

LegislationAndPolicies.propTypes = {
  legislations: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  tags_filter_options: PropTypes.array,
  types_filter_options: PropTypes.array
};

export default LegislationAndPolicies;
