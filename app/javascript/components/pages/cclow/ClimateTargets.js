import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import qs from 'qs';
import SearchFilter from '../../SearchFilter';
import TimeRangeFilter from '../../TimeRangeFilter';

function getQueryFilters() {
  return qs.parse(window.location.search.slice(1));
}

class ClimateTargets extends Component {
  constructor(props) {
    super(props);
    const {
      climate_targets,
      count
    } = this.props;

    this.state = {
      climate_targets,
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

  handleLoadMore = () => {
    const { climate_targets } = this.state;
    this.setState({ offset: climate_targets.length }, this.fetchData.bind(this));
  }

  filterList = (activeFilterName, filterParams) => {
    this.setState({[activeFilterName]: filterParams, offset: 0}, this.fetchData.bind(this));
  };

  fetchData() {
    const {activeGeoFilter, activeTypesFilter, activeTagFilter, offset} = this.state;
    const params = {
      ...getQueryFilters(),
      ...activeGeoFilter,
      ...activeTagFilter,
      ...activeTypesFilter,
      offset
    };

    const newQs = qs.stringify(params, { arrayFormat: 'brackets' });

    fetch(`/cclow/climate_targets.json?${newQs}`).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          if (offset > 0) {
            this.setState(({ climate_targets }) => ({
              climate_targets: climate_targets.concat(data.climate_targets)
            }));
          } else {
            this.setState({climate_targets: data.climate_targets, count: data.count});
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
          Search results: <strong>{filterText}</strong> in Climate Targets
        </h5>
      );
    }

    return (<h5>All Climate Targets</h5>);
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
      <div className="tags">
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
    const {climate_targets, count} = this.state;
    const {
      geo_filter_options: geoFilterOptions,
      tags_filter_options: tagsFilterOptions,
      types_filter_options: typesFilterOptions
    } = this.props;
    const hasMore = climate_targets.length < count;
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
                  ref={this.typesFilter}
                  filterName="Types"
                  params={typesFilterOptions}
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
                  <a className="column is-half download-link" href="#">Download results (CSV in .zip)</a>
                </div>
                {this.renderTags()}
                <ul className="content-list">
                  {climate_targets.map((target, i) => (
                    <Fragment key={i}>
                      <li>
                        <h5 className="title" dangerouslySetInnerHTML={{__html: target.link}} />
                        <div className="meta">
                          {target.geography && (
                            <Fragment>
                              <div>
                                <img src={`/images/flags/${target.geography.iso}.svg`} alt="" />
                                {target.geography.name}
                              </div>
                            </Fragment>
                          )}
                          <div>{target.target_tags && target.target_tags.join(' | ')}</div>
                        </div>
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


ClimateTargets.defaultProps = {
  count: 0,
  geo_filter_options: [],
  tags_filter_options: [],
  types_filter_options: []
};

ClimateTargets.propTypes = {
  climate_targets: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  tags_filter_options: PropTypes.array,
  types_filter_options: PropTypes.array
};

export default ClimateTargets;
