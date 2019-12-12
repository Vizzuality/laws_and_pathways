import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import SearchFilter from '../../SearchFilter';


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
      activeGeoFilter: {},
      activeTagFilter: {}
    };

    this.geoFilter = React.createRef();
    this.tagsFilter = React.createRef();
  }

  filterList = (activeFilterName, filterParams) => {
    const {activeGeoFilter, activeTagFilter} = this.state;
    const filterList = {activeGeoFilter, activeTagFilter};
    const params = {};

    this.setState({[activeFilterName]: filterParams});
    filterList[activeFilterName] = filterParams;
    Object.assign(params, Object.values(filterList));

    let url = '/cclow/litigation_cases.json?';
    url += $.param(params);
    fetch(url).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          this.setState({
            litigations: data.litigations, count: data.count
          });
        }
      });
    });
  };

  renderTags = () => {
    const {activeGeoFilter, activeTagFilter} = this.state;
    const {geo_filter_options: geoFilterOptions, tags_filter_options: tagsFilterOptions} = this.props;
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
    const {litigations, count} = this.state;
    const {geo_filter_options: geoFilterOptions, tags_filter_options: tagsFilterOptions} = this.props;
    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="container">
            <h5>All Litigation cases</h5>
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
                  <a className="column is-half download-link" href="#">Download results (CSV in .zip)</a>
                </div>
                {this.renderTags()}
                <ul className="content-list">
                  {litigations.map((litigation, i) => (
                    <Fragment key={i}>
                      <li className="content-item">
                        <h5 className="title" dangerouslySetInnerHTML={{__html: litigation.link}} />
                        <div className="meta">
                          <div>
                            <img src={`../../../../assets/flags/${litigation.geography.iso}.svg`} alt="" />
                            {litigation.geography.name}
                          </div>
                          {litigation.opened_in && <div>Opened in {litigation.opened_in}</div>}
                        </div>
                        <div className="description" dangerouslySetInnerHTML={{__html: litigation.summary}} />
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
        </div>
      </Fragment>
    );
  }
}


LitigationCases.defaultProps = {
  count: 0,
  geo_filter_options: [],
  tags_filter_options: []
};

LitigationCases.propTypes = {
  litigations: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  tags_filter_options: PropTypes.array
};

export default LitigationCases;
