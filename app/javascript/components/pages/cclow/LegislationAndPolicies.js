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
      count
    };
  }

  filterList = (filterParams) => {
    const params = {
      ...getQueryFilters,
      ...filterParams
    };

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

  render() {
    const {legislations, count} = this.state;
    const {filter_option: filterOption} = this.props;

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
                      <h5 className="title" dangerouslySetInnerHTML={{__html: legislation.link}} />
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
  filter_option: []
};

LegislationAndPolicies.propTypes = {
  legislations: PropTypes.array.isRequired,
  count: PropTypes.number,
  filter_option: PropTypes.array
};

export default LegislationAndPolicies;
