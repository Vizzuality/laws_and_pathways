import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import qs from 'qs';
import SearchFilter from '../../SearchFilter';

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
      activeGeoFilter: {},
      activeTagFilter: {}
    };

    this.geoFilter = React.createRef();
    this.tagsFilter = React.createRef();
  }

  filterList = (activeFilterName, filterParams) => {
    const {activeGeoFilter, activeTagFilter} = this.state;
    const filterList = {activeGeoFilter, activeTagFilter};
    const params = {...getQueryFilters};

    this.setState({[activeFilterName]: filterParams});
    filterList[activeFilterName] = filterParams;
    Object.assign(params, ...Object.values(filterList));
    const newQs = qs.stringify(params, { arrayFormat: 'brackets' });

    fetch(`/cclow/legislation_and_policies.json?${newQs}`).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          this.setState({legislations: data.legislations, count: data.count});
        }
      });
    });
  };

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

    return (<h5 className="search-title">All Legislation and policies</h5>);
  }

  renderTags = () => {
    const {activeGeoFilter, activeTagFilter} = this.state;
    const {geo_filter_options: geoFilterOptions, tags_filter_options: tagsFilterOptions} = this.props;
    if (Object.keys(activeGeoFilter).length === 0 && Object.keys(activeTagFilter).length === 0) return null;
    return (
      <div className="tags">
        {this.renderTagsGroup(activeGeoFilter, geoFilterOptions, 'geoFilter')}
        {this.renderTagsGroup(activeTagFilter, tagsFilterOptions, 'tagsFilter')}
      </div>
    );
  };

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
    const {geo_filter_options: geoFilterOptions, tags_filter_options: tagsFilterOptions} = this.props;
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
              <SearchFilter
                ref={this.tagsFilter}
                filterName="Tags"
                params={tagsFilterOptions}
                onChange={(event) => this.filterList('activeTagFilter', event)}
              />
            </div>
            <main className="column is-three-quarters" data-controller="content-list">
              <div className="columns pre-content">
                <span className="column is-half">Showing {count} results</span>
                <span className="column is-half download-link">
                  <a className="download-link" href="#">Download results (CSV in .zip)</a>
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
                            <div>
                              <img src={`/images/flags/${legislation.geography.iso}.svg`} alt="" />
                              {legislation.geography.name}
                            </div>
                          </Fragment>
                        )}
                        <div>
                          <img src={`/icons/legislation_types/${legislation.legislation_type}.svg`} alt="" />
                          {legislation.legislation_type_humanize}
                        </div>
                        {legislation.date_passed && <div>{new Date(legislation.date_passed).getFullYear()}</div>}
                      </div>
                      <div className="description" dangerouslySetInnerHTML={{__html: legislation.description}} />
                    </li>
                  </Fragment>
                ))}
              </ul>
              <div className="column is-offset-5">
                <button type="button" className="button is-primary load-more-btn">Load 10 more entries</button>
              </div>
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
  tags_filter_options: []
};

LegislationAndPolicies.propTypes = {
  legislations: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  tags_filter_options: PropTypes.array
};

export default LegislationAndPolicies;
