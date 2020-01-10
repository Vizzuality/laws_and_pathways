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
      isMoreSearchOptionsVisible: false,
      activeGeoFilter: {},
      activeTagFilter: {},
      activeTimeRangeFilter: {},
      activeStatusesFilter: {},
      activeSideTypesFilter: {},
      activePartyTypesFilter: {},
      activeJurisdictionsFilter: {}
    };

    this.geoFilter = React.createRef();
    this.tagsFilter = React.createRef();
    this.timeRangeFilter = React.createRef();
    this.statusFilter = React.createRef();
    this.sideTypeFilter = React.createRef();
    this.partyTypeFilter = React.createRef();
    this.jurisdictionFilter = React.createRef();
  }

  handleLoadMore = () => {
    const { litigations } = this.state;
    this.setState({ offset: litigations.length }, this.fetchData.bind(this));
  }

  filterList = (activeFilterName, filterParams) => {
    this.setState({[activeFilterName]: filterParams, offset: 0}, this.fetchData.bind(this));
  };

  fetchData() {
    const {
      activeGeoFilter,
      activeTagFilter,
      activeTimeRangeFilter,
      activeStatusesFilter,
      activePartyTypesFilter,
      activeSideTypesFilter,
      activeJurisdictionsFilter,
      offset
    } = this.state;
    const params = {
      ...getQueryFilters(),
      ...activeGeoFilter,
      ...activeTagFilter,
      ...activeTimeRangeFilter,
      ...activeStatusesFilter,
      ...activeSideTypesFilter,
      ...activePartyTypesFilter,
      ...activeJurisdictionsFilter,
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
    const {
      activeGeoFilter,
      activeTagFilter,
      activeTimeRangeFilter,
      activeStatusesFilter,
      activeSideTypesFilter,
      activePartyTypesFilter,
      activeJurisdictionsFilter
    } = this.state;
    const {
      geo_filter_options: geoFilterOptions,
      tags_filter_options: tagsFilterOptions,
      statuses_filter_options: statusesFilterOptions,
      litigation_side_types_options: litigationSideTypesOptions,
      litigation_party_types_options: litigationPartyTypesOptions,
      litigation_jurisdictions_options: litigationJurisdictionsOptions
    } = this.props;
    if (!Object.keys(activeGeoFilter).length
      && !Object.keys(activeTagFilter).length
      && !Object.keys(activeStatusesFilter).length
      && !Object.keys(activeTimeRangeFilter).length
      && !Object.keys(activeSideTypesFilter).length
      && !Object.keys(activePartyTypesFilter).length) return null;
    return (
      <div className="filter-tags">
        {this.renderTagsGroup(activeGeoFilter, geoFilterOptions, 'geoFilter')}
        {this.renderTagsGroup(activeTagFilter, tagsFilterOptions, 'tagsFilter')}
        {this.renderTagsGroup(activeStatusesFilter, statusesFilterOptions, 'statusFilter')}
        {this.renderTagsGroup(activeSideTypesFilter, litigationSideTypesOptions, 'sideTypeFilter')}
        {this.renderTagsGroup(activePartyTypesFilter, litigationPartyTypesOptions, 'partyTypeFilter')}
        {this.renderTagsGroup(activeJurisdictionsFilter, litigationJurisdictionsOptions, 'jurisdictionFilter')}
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

  renderMoreOptions() {
    const { isMoreSearchOptionsVisible } = this.state;
    const {
      litigation_side_types_options: litigationSideTypesOptions,
      litigation_party_types_options: litigationPartyTypesOptions,
      litigation_jurisdictions_options: litigationJurisdictionsOptions
    } = this.props;

    return (
      <>
        {!isMoreSearchOptionsVisible && (
          <button
            type="button"
            onClick={() => this.setState({isMoreSearchOptionsVisible: true})}
            className="more-options"
          >
            + Show more search options
          </button>
        )}
        {isMoreSearchOptionsVisible && (
          <>
            <SearchFilter
              ref={this.sideTypeFilter}
              filterName="Side types"
              params={litigationSideTypesOptions}
              onChange={(event) => this.filterList('activeSideTypesFilter', event)}
            />
            <SearchFilter
              ref={this.partyTypeFilter}
              filterName="Party types"
              params={litigationPartyTypesOptions}
              onChange={(event) => this.filterList('activePartyTypesFilter', event)}
            />
            <SearchFilter
              ref={this.jurisdictionFilter}
              filterName="Jurisdiction"
              params={litigationJurisdictionsOptions}
              onChange={(event) => this.filterList('activeJurisdictionsFilter', event)}
            />
            <button
              type="button"
              onClick={() => this.setState({isMoreSearchOptionsVisible: false})}
              className="more-options"
            >
              - Show less search options
            </button>
          </>
        )}
      </>
    );
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
                {this.renderMoreOptions()}
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
                              {litigation.last_development_in && <div>Last development in {litigation.last_development_in}</div>}
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
  statuses_filter_options: [],
  litigation_side_types_options: [],
  litigation_party_types_options: [],
  litigation_jurisdictions_options: []
};

LitigationCases.propTypes = {
  litigations: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  tags_filter_options: PropTypes.array,
  statuses_filter_options: PropTypes.array,
  litigation_party_types_options: PropTypes.array,
  litigation_side_types_options: PropTypes.array,
  litigation_jurisdictions_options: PropTypes.array
};

export default LitigationCases;
