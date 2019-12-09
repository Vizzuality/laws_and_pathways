import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import SearchFilter from '../../SearchFilter';


class LegislationAndPolicies extends Component {
  constructor(props) {
    super(props);
    const {
      legislations,
      count
    } = this.props;

    this.state = {
      legislations,
      count
    };
  }

  filterList = (filterParams) => {
    let url = '/cclow/legislation_and_policies.json?';
    url += $.param(filterParams);
    fetch(url).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          this.setState({legislations: data.legislations, count: data.count});
        }
      });
    });
  };

  render() {
    const {legislations, count} = this.state;
    const {filter_option: filterOption} = this.props;
    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="title-page">
            <h5>All Legislation and policies</h5>
          </div>
          <hr />
          <div className="columns">
            <div className="column is-one-quarter filter-column">
              <div className="search-by">Narrow this search by</div>
              <SearchFilter filterName="Regions and countries" params={filterOption} onChange={(event) => this.filterList(event)} />
            </div>
            <main className="column is-three-quarters" data-controller="content-list">
              <div className="columns pre-content">
                <span className="column is-half">Showing {count} results</span>
                <span className="column is-half download-link">
                  <a className="download-link" href="#">Download results (CSV in .zip)</a>
                </span>
              </div>
              <ul className="content-list">
                {legislations.map((legislation, i) => (
                  <Fragment key={i}>
                    <li className="content-item">
                      <h5 className="title">{legislation.title}</h5>
                      <div className="description">{legislation.description}</div>
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
  filter_option: []
};

LegislationAndPolicies.propTypes = {
  legislations: PropTypes.array.isRequired,
  count: PropTypes.number,
  filter_option: PropTypes.array
};

export default LegislationAndPolicies;
