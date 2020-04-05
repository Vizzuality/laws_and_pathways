import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import List from './List';

import {
  paramInteger,
  paramIntegerArray,
  paramStringArray
} from './helpers';

import ExecutiveSVG from 'images/icons/legislation_types/executive.svg';
import LegislativeSVG from 'images/icons/legislation_types/legislative.svg';

function LegislationAndPolicies(props) {
  const {
    legislations,
    count,
    geo_filter_options,
    keywords_filter_options,
    responses_filter_options,
    frameworks_filter_options,
    types_filter_options,
    instruments_filter_options,
    natural_hazards_filter_options,
    governances_filter_options,
    sectors_options
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
      name: 'timeRange',
      timeRange: true,
      mainFilter: true,
      params: {
        from_date: paramInteger,
        to_date: paramInteger
      }
    },
    {
      name: 'type',
      title: 'Executive / Legislative',
      options: types_filter_options,
      mainFilter: true,
      props: {
        isSearchable: false
      },
      params: {
        type: paramStringArray
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
      name: 'keywords',
      title: 'Keywords',
      options: keywords_filter_options,
      params: {
        keywords: paramIntegerArray
      }
    },
    {
      name: 'responses',
      title: 'Mitigation / Adaptation / DRM',
      options: responses_filter_options,
      params: {
        responses: paramIntegerArray
      }
    },
    {
      name: 'frameworks',
      title: 'Frameworks',
      options: frameworks_filter_options,
      params: {
        frameworks: paramIntegerArray
      }
    },
    {
      name: 'instruments',
      title: 'Instruments',
      options: instruments_filter_options,
      params: {
        instruments: paramIntegerArray
      }
    },
    {
      name: 'naturalHazards',
      title: 'Natural Hazards',
      options: natural_hazards_filter_options,
      params: {
        natural_hazards: paramIntegerArray
      }
    },
    {
      name: 'governances',
      title: 'Governances',
      options: governances_filter_options,
      params: {
        governances: paramIntegerArray
      }
    }
  ];

  return (
    <List
      items={legislations}
      count={count}
      filterConfigs={filters}
      url="/cclow/legislation_and_policies"
      title="Laws and Policies"
      allTitle="Laws and policies"
      renderContentItem={(legislation) => (
        <Fragment>
          <h5 className="title" dangerouslySetInnerHTML={{__html: legislation.link}} />
          <div className="meta">
            {legislation.geography && (
              <a href={legislation.geography_path}>
                <img src={`/images/flags/${legislation.geography.iso}.svg`} alt="" />
                {legislation.geography.name}
              </a>
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
        </Fragment>
      )}
    />
  );
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
