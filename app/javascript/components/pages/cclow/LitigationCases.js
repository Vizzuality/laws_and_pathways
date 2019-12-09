import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import qs from 'qs';
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
      count
    };
  }

  filterList = (filterParams) => {
    const params = qs.parse(window.location.search.slice(1));
    const newParams = {
      ...params,
      ...filterParams
    };

    const newQs = qs.stringify(newParams, { arrayFormat: 'brackets' });

    fetch(`/cclow/litigation_cases.json?${newQs}`).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          this.setState({litigations: data.litigations, count: data.count});
        }
      });
    });
  };

  render() {
    const {litigations, count} = this.state;
    const {filter_option: filterOption} = this.props;
    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="container">
            <h5>All Litigation cases</h5>
            <hr />
            <div className="columns">
              <div className="column is-one-quarter filter-column">
                <div className="search-by">Narrow this search by</div>
                <SearchFilter filterName="Regions and countries" params={filterOption} onChange={(event) => this.filterList(event)} />
              </div>
              <main className="column is-three-quarters" data-controller="content-list">
                <div className="columns pre-content">
                  <span className="column is-half">Showing {count} results</span>
                  <a className="column is-half download-link" href="#">Download results (CSV in .zip)</a>
                </div>
                <ul className="content-list">
                  {litigations.map((litigation, i) => (
                    <Fragment key={i}>
                      <li className="content-item">
                        <h5 className="title" dangerouslySetInnerHTML={{__html: litigation.link}} />
                        <div className="meta" />
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
  filter_option: []
};

LitigationCases.propTypes = {
  litigations: PropTypes.array.isRequired,
  count: PropTypes.number,
  filter_option: PropTypes.array
};

export default LitigationCases;
