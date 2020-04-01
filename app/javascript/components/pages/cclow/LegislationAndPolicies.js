import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import qs from 'qs';
import pick from 'lodash/pick';
import pickBy from 'lodash/pickBy';

import SearchFilter from '../../SearchFilter';
import TimeRangeFilter from '../../TimeRangeFilter';

import {
  getQueryFilters,
  useInteger,
  useIntegerArray,
  useStringArray
} from './helpers';

import ExecutiveSVG from 'images/icons/legislation_types/executive.svg';
import LegislativeSVG from 'images/icons/legislation_types/legislative.svg';

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
      isMoreSearchOptionsVisible: false,
      ...this.resolveStateFromQueryString()
    };

    this.isMobile = window.innerWidth < 1024;

    this.geoFilter = React.createRef();
    this.keywordsFilter = React.createRef();
    this.responsesFilter = React.createRef();
    this.frameworksFilter = React.createRef();
    this.timeRangeFilter = React.createRef();
    this.typesFilter = React.createRef();
    this.instrumentsFilter = React.createRef();
    this.naturalHazardsFilter = React.createRef();
    this.governancesFilter = React.createRef();
    this.sectorsFilter = React.createRef();
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
    const { legislations } = this.state;
    this.setState({ offset: legislations.length }, this.fetchData.bind(this));
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

    return qs.stringify(params, { arrayFormat: 'brackets' });
  }

  resolveStateFromQueryString() {
    const query = getQueryFilters();

    return {
      filters: {
        geography: useIntegerArray(query.geography),
        region: useIntegerArray(query.region),
        keywords: useIntegerArray(query.keywords),
        responses: useIntegerArray(query.responses),
        frameworks: useIntegerArray(query.frameworks),
        from_date: useInteger(query.from_date),
        to_date: useInteger(query.from_date),
        type: useStringArray(query.type),
        instruments: useIntegerArray(query.instruments),
        natural_hazards: useIntegerArray(query.natural_hazards),
        governances: useIntegerArray(query.governances),
        law_sector: useIntegerArray(query.law_sector)
      }
    };
  }

  updateHistory() {
    const newQs = this.createQueryString();
    window.history.pushState(null, null, `?${newQs}`);
  }

  fetchData() {
    const { offset } = this.state;
    const newQs = this.createQueryString({ offset });

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

  renderMoreOptions() {
    const { isMoreSearchOptionsVisible, filters } = this.state;
    const {
      keywords_filter_options: keywordsFilterOptions,
      responses_filter_options: responsesFilterOptions,
      frameworks_filter_options: frameworksFilterOptions,
      instruments_filter_options: instrumentsFilterOptions,
      natural_hazards_filter_options: naturalHazardsFilterOptions,
      governances_filter_options: governancesFilterOptions
    } = this.props;

    return (
      <Fragment>
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
            selectedList={pick(filters, 'keywords')}
            onChange={this.handleFilterChange}
          />
          <SearchFilter
            ref={this.responsesFilter}
            filterName="Mitigation / Adaptation / DRM"
            params={responsesFilterOptions}
            selectedList={pick(filters, 'responses')}
            onChange={this.handleFilterChange}
          />
          <SearchFilter
            ref={this.frameworksFilter}
            filterName="Frameworks"
            params={frameworksFilterOptions}
            selectedList={pick(filters, 'frameworks')}
            onChange={this.handleFilterChange}
          />
          <SearchFilter
            ref={this.instrumentsFilter}
            filterName="Instruments"
            params={instrumentsFilterOptions}
            selectedList={pick(filters, 'instruments')}
            onChange={this.handleFilterChange}
          />
          <SearchFilter
            ref={this.naturalHazardsFilter}
            filterName="Natural Hazards"
            params={naturalHazardsFilterOptions}
            selectedList={pick(filters, 'natural_hazards')}
            onChange={this.handleFilterChange}
          />
          <SearchFilter
            ref={this.governancesFilter}
            filterName="Governances"
            params={governancesFilterOptions}
            selectedList={pick(filters, 'governances')}
            onChange={this.handleFilterChange}
          />
          {!this.isMobile && (
            <button
              type="button"
              onClick={() => this.setState({isMoreSearchOptionsVisible: false})}
              className="more-options"
            >
              - Show fewer search options
            </button>
          )}
        </div>
      </Fragment>
    );
  }

  renderTags = () => {
    const { filters } = this.state;
    const {
      geo_filter_options: geoFilterOptions,
      keywords_filter_options: keywordsFilterOptions,
      responses_filter_options: responsesFilterOptions,
      frameworks_filter_options: frameworksFilterOptions,
      types_filter_options: typesFilterOptions,
      instruments_filter_options: instrumentsFilterOptions,
      natural_hazards_filter_options: naturalHazardsFilterOptions,
      governances_filter_options: governancesFilterOptions,
      sectors_options: sectorsOptions
    } = this.props;

    if (Object.keys(filters).every(x => !x)) return null;

    return (
      <div className="filter-tags tags">
        {this.renderTagsGroup(pick(filters, 'geography', 'region'), geoFilterOptions, 'geoFilter')}
        {this.renderTagsGroup(pick(filters, 'keywords'), keywordsFilterOptions, 'keywordsFilter')}
        {this.renderTagsGroup(pick(filters, 'responses'), responsesFilterOptions, 'responsesFilter')}
        {this.renderTagsGroup(pick(filters, 'frameworks'), frameworksFilterOptions, 'frameworksFilter')}
        {this.renderTagsGroup(pick(filters, 'type'), typesFilterOptions, 'typesFilter')}
        {this.renderTagsGroup(pick(filters, 'law_sector'), sectorsOptions, 'sectorsFilter')}
        {this.renderTagsGroup(pick(filters, 'instruments'), instrumentsFilterOptions, 'instrumentsFilter')}
        {this.renderTagsGroup(pick(filters, 'natural_hazards'), naturalHazardsFilterOptions, 'naturalHazardsFilter')}
        {this.renderTagsGroup(pick(filters, 'governances'), governancesFilterOptions, 'governancesFilter')}
        {this.renderTimeRangeTags(pick(filters, 'from_date', 'to_date'))}
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
        activeTags[keyBlock].filter(x => x).map((key, i) => (
          <span key={`tag_${keyBlock}_${i}`} className="tag">
            {options.filter(item => item.field_name === keyBlock)[0].options.filter(l => l.value === key)[0].label}
            <button type="button" onClick={() => this[filterEl].current.handleCheckItem(keyBlock, key)} className="delete" />
          </span>
        ))
      ))}
    </Fragment>
  );

  renderMainFilters = () => {
    const {
      geo_filter_options: geoFilterOptions,
      types_filter_options: typesFilterOptions,
      sectors_options: sectorsOptions
    } = this.props;
    const { filters } = this.state;

    return (
      <Fragment>
        <SearchFilter
          ref={this.geoFilter}
          filterName="Regions and countries"
          params={geoFilterOptions}
          selectedList={pick(filters, 'geography', 'region')}
          onChange={this.handleFilterChange}
        />
        <TimeRangeFilter
          ref={this.timeRangeFilter}
          onChange={this.handleFilterChange}
        />
        <SearchFilter
          ref={this.typesFilter}
          filterName="Executive / Legislative"
          params={typesFilterOptions}
          selectedList={pick(filters, 'type')}
          isSearchable={false}
          onChange={this.handleFilterChange}
        />
        <SearchFilter
          ref={this.sectorsFilter}
          filterName="Sectors"
          selectedList={pick(filters, 'law_sector')}
          params={sectorsOptions}
          onChange={this.handleFilterChange}
        />
      </Fragment>
    );
  }

  render() {
    const {legislations, count} = this.state;
    const hasMore = legislations.length < count;
    const downloadResultsLink = `/cclow/legislation_and_policies.csv?${this.createQueryString()}`;

    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="container">
            <div className="title-page">
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
              <main className="column is-three-quarters">
                <div className="columns pre-content">
                  <span className="column is-half">Showing {count} results</span>
                  <span className="column is-half download-link is-hidden-touch">
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
                        <div className="description" dangerouslySetInnerHTML={{__html: legislation.short_description}} />
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


LegislationAndPolicies.defaultProps = {
  count: 0,
  geo_filter_options: [],
  keywords_filter_options: [],
  responses_filter_options: [],
  frameworks_filter_options: [],
  types_filter_options: [],
  instruments_filter_options: [],
  natural_hazards_filter_options: [],
  governances_filter_options: [],
  sectors_options: []
};

LegislationAndPolicies.propTypes = {
  legislations: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  keywords_filter_options: PropTypes.array,
  responses_filter_options: PropTypes.array,
  frameworks_filter_options: PropTypes.array,
  types_filter_options: PropTypes.array,
  instruments_filter_options: PropTypes.array,
  natural_hazards_filter_options: PropTypes.array,
  governances_filter_options: PropTypes.array,
  sectors_options: PropTypes.array
};

export default LegislationAndPolicies;
