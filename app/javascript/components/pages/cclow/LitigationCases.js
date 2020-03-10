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
      activeKeywordsFilter: {},
      activeResponsesFilter: {},
      activeTimeRangeFilter: {},
      activeStatusesFilter: {},
      activeSideAFilter: {},
      activeSideBFilter: {},
      activeSideCFilter: {},
      activePartyTypesFilter: {},
      activeSideAPartyTypesFilter: {},
      activeSideBPartyTypesFilter: {},
      activeSideCPartyTypesFilter: {},
      activeJurisdictionsFilter: {},
      activeSectorsFilter: {}
    };

    this.isMobile = window.innerWidth < 1024;

    this.geoFilter = React.createRef();
    this.keywordsFilter = React.createRef();
    this.responsesFilter = React.createRef();
    this.timeRangeFilter = React.createRef();
    this.sectorsFilter = React.createRef();
    this.statusFilter = React.createRef();
    this.sideAFilter = React.createRef();
    this.sideBFilter = React.createRef();
    this.sideCFilter = React.createRef();
    this.partyTypeFilter = React.createRef();
    this.jurisdictionFilter = React.createRef();
    this.sideAPartyTypeFilter = React.createRef();
    this.sideBPartyTypeFilter = React.createRef();
    this.sideCPartyTypeFilter = React.createRef();
  }

  getQueryString(extraParams = {}) {
    const {
      activeGeoFilter,
      activeKeywordsFilter,
      activeResponsesFilter,
      activeTimeRangeFilter,
      activeStatusesFilter,
      activePartyTypesFilter,
      activeSideAFilter,
      activeSideBFilter,
      activeSideCFilter,
      activeSectorsFilter,
      activeJurisdictionsFilter,
      activeSideAPartyTypesFilter,
      activeSideBPartyTypesFilter,
      activeSideCPartyTypesFilter
    } = this.state;
    const params = {
      ...getQueryFilters(),
      ...activeGeoFilter,
      ...activeKeywordsFilter,
      ...activeResponsesFilter,
      ...activeTimeRangeFilter,
      ...activeStatusesFilter,
      ...activeSideAFilter,
      ...activeSideBFilter,
      ...activeSideCFilter,
      ...activeSectorsFilter,
      ...activePartyTypesFilter,
      ...activeJurisdictionsFilter,
      ...activeSideAPartyTypesFilter,
      ...activeSideBPartyTypesFilter,
      ...activeSideCPartyTypesFilter,
      ...extraParams
    };

    return qs.stringify(params, { arrayFormat: 'brackets' });
  }

  handleLoadMore = () => {
    const { litigations } = this.state;
    this.setState({ offset: litigations.length }, this.fetchData.bind(this));
  }

  filterList = (activeFilterName, filterParams) => {
    this.setState({[activeFilterName]: filterParams, offset: 0}, this.fetchData.bind(this));
  };

  fetchData() {
    const { offset } = this.state;
    const newQs = this.getQueryString({ offset });

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
      activeKeywordsFilter,
      activeResponsesFilter,
      activeTimeRangeFilter,
      activeStatusesFilter,
      activeSideAFilter,
      activeSideBFilter,
      activeSideCFilter,
      activeSectorsFilter,
      activePartyTypesFilter,
      activeJurisdictionsFilter,
      activeSideAPartyTypesFilter,
      activeSideBPartyTypesFilter,
      activeSideCPartyTypesFilter
    } = this.state;
    const {
      geo_filter_options: geoFilterOptions,
      keywords_filter_options: keywordsFilterOptions,
      responses_filter_options: responsesFilterOptions,
      statuses_filter_options: statusesFilterOptions,
      litigation_side_a_names_options: litigationSideAOptions,
      litigation_side_b_names_options: litigationSideBOptions,
      litigation_side_c_names_options: litigationSideCOptions,
      sectors_options: sectorsOptions,
      litigation_party_types_options: litigationPartyTypesOptions,
      litigation_jurisdictions_options: litigationJurisdictionsOptions,
      litigation_side_a_party_type_options: litigationSideAPartyTypeOptions,
      litigation_side_b_party_type_options: litigationSideBPartyTypeOptions,
      litigation_side_c_party_type_options: litigationSideCPartyTypeOptions
    } = this.props;
    if (!Object.keys(activeGeoFilter).length
      && !Object.keys(activeKeywordsFilter).length
      && !Object.keys(activeResponsesFilter).length
      && !Object.keys(activeStatusesFilter).length
      && !Object.keys(activeTimeRangeFilter).length
      && !Object.keys(activeSideAFilter).length
      && !Object.keys(activeSideBFilter).length
      && !Object.keys(activeSideCFilter).length
      && !Object.keys(activeSectorsFilter).length
      && !Object.keys(activeSideAPartyTypesFilter).length
      && !Object.keys(activeSideBPartyTypesFilter).length
      && !Object.keys(activeSideCPartyTypesFilter).length
      && !Object.keys(activePartyTypesFilter).length) return null;
    return (
      <div className="filter-tags tags">
        {this.renderTagsGroup(activeGeoFilter, geoFilterOptions, 'geoFilter')}
        {this.renderTagsGroup(activeKeywordsFilter, keywordsFilterOptions, 'keywordsFilter')}
        {this.renderTagsGroup(activeResponsesFilter, responsesFilterOptions, 'responsesFilter')}
        {this.renderTagsGroup(activeStatusesFilter, statusesFilterOptions, 'statusFilter')}
        {this.renderTagsGroup(activeSideAFilter, litigationSideAOptions, 'sideAFilter')}
        {this.renderTagsGroup(activeSideBFilter, litigationSideBOptions, 'sideBFilter')}
        {this.renderTagsGroup(activeSideCFilter, litigationSideCOptions, 'sideCFilter')}
        {this.renderTagsGroup(activeSectorsFilter, sectorsOptions, 'sectorsFilter')}
        {this.renderTagsGroup(activePartyTypesFilter, litigationPartyTypesOptions, 'partyTypeFilter')}
        {this.renderTagsGroup(activeJurisdictionsFilter, litigationJurisdictionsOptions, 'jurisdictionFilter')}
        {this.renderTagsGroup(activeSideAPartyTypesFilter, litigationSideAPartyTypeOptions, 'sideAPartyTypeFilter')}
        {this.renderTagsGroup(activeSideBPartyTypesFilter, litigationSideBPartyTypeOptions, 'sideBPartyTypeFilter')}
        {this.renderTagsGroup(activeSideCPartyTypesFilter, litigationSideCPartyTypeOptions, 'sideCPartyTypeFilter')}
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
      keywords_filter_options: keywordsFilterOptions,
      responses_filter_options: responsesFilterOptions,
      litigation_party_types_options: litigationPartyTypesOptions,
      litigation_jurisdictions_options: litigationJurisdictionsOptions,
      litigation_side_a_names_options: litigationSideAOptions,
      litigation_side_b_names_options: litigationSideBOptions,
      litigation_side_c_names_options: litigationSideCOptions,
      litigation_side_a_party_type_options: litigationSideAPartyTypeOptions,
      litigation_side_b_party_type_options: litigationSideBPartyTypeOptions,
      litigation_side_c_party_type_options: litigationSideCPartyTypeOptions,
      sectors_options: sectorsOptions
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
        <div className={isMoreSearchOptionsVisible ? 'more-filters' : 'more-filters hidden'}>
          {this.isMobile && (
            <button
              type="button"
              onClick={() => this.setState({isMoreSearchOptionsVisible: false})}
              className="more-options"
            >
              - Show fewer search options
            </button>
          )}
          {this.isMobile && this.renderMainFilters()}
          <SearchFilter
            ref={this.keywordsFilter}
            filterName="Keywords"
            params={keywordsFilterOptions}
            onChange={(event) => this.filterList('activeKeywordsFilter', event)}
          />
          <SearchFilter
            ref={this.responsesFilter}
            filterName="Responses"
            params={responsesFilterOptions}
            onChange={(event) => this.filterList('activeResponsesFilter', event)}
          />
          <SearchFilter
            ref={this.jurisdictionFilter}
            filterName="Jurisdiction"
            params={litigationJurisdictionsOptions}
            onChange={(event) => this.filterList('activeJurisdictionsFilter', event)}
          />
          <SearchFilter
            ref={this.partyTypeFilter}
            filterName="Party types"
            params={litigationPartyTypesOptions}
            onChange={(event) => this.filterList('activePartyTypesFilter', event)}
          />
          <SearchFilter
            ref={this.sectorsFilter}
            filterName="Sectors"
            params={sectorsOptions}
            onChange={(event) => this.filterList('activeSectorsFilter', event)}
          />
          <SearchFilter
            ref={this.sideAPartyTypeFilter}
            filterName="Side A Type"
            params={litigationSideAPartyTypeOptions}
            onChange={(event) => this.filterList('activeSideAPartyTypesFilter', event)}
          />
          <SearchFilter
            ref={this.sideBPartyTypeFilter}
            filterName="Side B Type"
            params={litigationSideBPartyTypeOptions}
            onChange={(event) => this.filterList('activeSideBPartyTypesFilter', event)}
          />
          <SearchFilter
            ref={this.sideCPartyTypeFilter}
            filterName="Side C Type"
            params={litigationSideCPartyTypeOptions}
            onChange={(event) => this.filterList('activeSideCPartyTypesFilter', event)}
          />
          <SearchFilter
            ref={this.sideAFilter}
            filterName="Side A name"
            params={litigationSideAOptions}
            onChange={(event) => this.filterList('activeSideAFilter', event)}
          />
          <SearchFilter
            ref={this.sideBFilter}
            filterName="Side B name"
            params={litigationSideBOptions}
            onChange={(event) => this.filterList('activeSideBFilter', event)}
          />
          <SearchFilter
            ref={this.sideCFilter}
            filterName="Side C name"
            params={litigationSideCOptions}
            onChange={(event) => this.filterList('activeSideCFilter', event)}
          />
          {!this.isMobile && (
            <button
              type="button"
              onClick={() => this.setState({isMoreSearchOptionsVisible: false})}
              className="more-options"
            >
              - Show less search options
            </button>
          )}
        </div>
      </>
    );
  }

  renderMainFilters = () => {
    const {
      geo_filter_options: geoFilterOptions,
      statuses_filter_options: statusesFilterOptions
    } = this.props;
    return (
      <Fragment>
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
      </Fragment>
    );
  }

  render() {
    const {litigations, count} = this.state;
    const hasMore = litigations.length < count;
    const downloadResultsLink = `/cclow/litigation_cases.csv?${this.getQueryString()}`;
    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="container">
            <div className="flex-container">
              {this.renderPageTitle()}
            </div>
            {this.isMobile && (<div className="filter-column">{this.renderMoreOptions()}</div>)}
            <hr />
            <div className="columns">
              {!this.isMobile && (
                <div className="column is-one-quarter filter-column">
                  <div className="search-by">Narrow this search by</div>
                  {this.renderMainFilters()}
                  {this.renderMoreOptions()}
                </div>
              )}
              <main className={`column${!this.isMobile ? ' is-three-quarters' : ''}`}>
                <div className="columns pre-content">
                  <span className="column is-half">Showing {count} results</span>
                  <span className="column is-half download-link is-hidden-touch">
                    <a className="download-link" href={downloadResultsLink}>Download results (.csv)</a>
                  </span>
                </div>
                {this.renderTags()}
                <ul className="content-list">
                  {litigations.map((litigation, i) => (
                    <Fragment key={i}>
                      <li className="content-item">
                        <h5 className="title" dangerouslySetInnerHTML={{__html: litigation.link}} />
                        <div className="meta">
                          {litigation.geography && (
                            <a href={litigation.geography_path}>
                              <img src={`/images/flags/${litigation.geography.iso}.svg`} alt="" />
                              {litigation.geography.name}
                            </a>
                          )}
                          {litigation.opened_in && <div>Opened in {litigation.opened_in}</div>}
                          {litigation.last_development_in && <div>Last development in {litigation.last_development_in}</div>}
                        </div>
                        <div className="description" dangerouslySetInnerHTML={{__html: litigation.short_summary}} />
                      </li>
                    </Fragment>
                  ))}
                </ul>
                {hasMore && (
                  <div className={`column load-more-container${!this.isMobile ? ' is-offset-5' : ''}`}>
                    <button type="button" className="button is-primary" onClick={this.handleLoadMore}>
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
  keywords_filter_options: [],
  responses_filter_options: [],
  statuses_filter_options: [],
  litigation_side_a_names_options: [],
  litigation_side_b_names_options: [],
  litigation_side_c_names_options: [],
  litigation_party_types_options: [],
  litigation_side_a_party_type_options: [],
  litigation_side_b_party_type_options: [],
  litigation_side_c_party_type_options: [],
  litigation_jurisdictions_options: [],
  sectors_options: []
};

LitigationCases.propTypes = {
  litigations: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  keywords_filter_options: PropTypes.array,
  responses_filter_options: PropTypes.array,
  statuses_filter_options: PropTypes.array,
  litigation_party_types_options: PropTypes.array,
  litigation_side_a_names_options: PropTypes.array,
  litigation_side_b_names_options: PropTypes.array,
  litigation_side_c_names_options: PropTypes.array,
  litigation_side_a_party_type_options: PropTypes.array,
  litigation_side_b_party_type_options: PropTypes.array,
  litigation_side_c_party_type_options: PropTypes.array,
  litigation_jurisdictions_options: PropTypes.array,
  sectors_options: PropTypes.array
};

export default LitigationCases;
