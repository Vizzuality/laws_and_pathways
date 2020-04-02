import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import List from './List';

import {
  paramIntegerArray,
  paramStringArray
} from './helpers';

function ClimateTargets(props) {
  const {
    climate_targets,
    count,
    geo_filter_options,
    types_filter_options,
    sectors_options,
    target_years_options
  } = props;

  const filters = [
    {
      name: 'geo',
      title: 'Regions and countries',
      options: geo_filter_options,
      mainFilter: true,
      params: {
        geography: paramIntegerArray,
        region: paramIntegerArray
      }
    },
    {
      name: 'sectors',
      title: 'Sectors',
      options: sectors_options,
      mainFilter: true,
      params: {
        law_sector: paramIntegerArray
      }
    },
    {
      name: 'type',
      title: 'Target types',
      options: types_filter_options,
      mainFilter: true,
      params: {
        type: paramStringArray
      }
    },
    {
      name: 'year',
      title: 'Target years',
      options: target_years_options,
      mainFilter: true,
      params: {
        target_year: paramIntegerArray
      }
    }
  ];

  return (
    <List
      items={climate_targets}
      count={count}
      filterConfigs={filters}
      url="/cclow/climate_targets"
      title="Climate Targets"
      allTitle="All Climate Targets"
      renderContentItem={(target) => (
        <Fragment>
          <h5 className="title" dangerouslySetInnerHTML={{__html: target.link}} />
          <div className="meta">
            {target.geography && (
              <Fragment>
                <a href={target.geography_path}>
                  <img src={`/images/flags/${target.geography.iso}.svg`} alt="" />
                  {target.geography.name}
                </a>
              </Fragment>
            )}
            <div>{target.target_tags && target.target_tags.join(' | ')}</div>
          </div>
        </Fragment>
      )}
    />
  );
}

ClimateTargets.defaultProps = {
  count: 0,
  geo_filter_options: [],
  types_filter_options: [],
  sectors_options: [],
  target_years_options: []
};

ClimateTargets.propTypes = {
  climate_targets: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  types_filter_options: PropTypes.array,
  sectors_options: PropTypes.array,
  target_years_options: PropTypes.array
};

export default ClimateTargets;
