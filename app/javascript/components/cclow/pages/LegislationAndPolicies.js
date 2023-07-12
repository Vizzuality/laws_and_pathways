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
import EUFlag from 'images/flags/EUR.svg';

function LegislationAndPolicies(props) {
  const {
    legislations,
    count,
    eu_members,
    min_law_passed_year,
    geo_filter_options,
    keywords_filter_options,
    responses_filter_options,
    frameworks_filter_options,
    types_filter_options,
    instruments_filter_options,
    natural_hazards_filter_options,
    themes_filter_options,
    sectors_options
  } = props;

  const filterConfigs = [
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
      name: 'dateOfLawPassed',
      title: 'Date of law passed',
      timeRange: true,
      mainFilter: true,
      fromParam: 'law_passed_from',
      toParam: 'law_passed_to',
      minDate: min_law_passed_year,
      params: {
        law_passed_from: paramInteger,
        law_passed_to: paramInteger
      }
    },
    {
      name: 'dateOfLastChange',
      title: 'Date of last change',
      timeRange: true,
      mainFilter: true,
      fromParam: 'last_change_from',
      toParam: 'last_change_to',
      params: {
        last_change_from: paramInteger,
        last_change_to: paramInteger
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
        instrument: paramIntegerArray
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
      name: 'themes',
      title: 'Themes',
      options: themes_filter_options,
      params: {
        theme: paramIntegerArray
      }
    }
  ];

  const renderExtraMessage = ({ filters }) => { /* eslint-disable-line react/prop-types */
    if (filters.geography && filters.geography.length > 0
        && filters.geography.some((gId) => eu_members.includes(gId))) {
      return (
        <div className="extra-message eu-member">
          <img className="flag" src={EUFlag} alt="European Union flag" />
          <div>
            Your selection includes EU members and so EU legislation also applies.
            For further information, please see the <a href="/geographies/european-union" title="EU profile link">EU profile</a>.
          </div>
        </div>
      );
    }

    return null;
  };

  return (
    <List
      items={legislations}
      count={count}
      filterConfigs={filterConfigs}
      url="/legislation_and_policies"
      title="Laws and Policies"
      allTitle="Laws and policies"
      renderExtraMessage={renderExtraMessage}
      renderContentItem={(legislation) => (
        <Fragment>
          <h5 className="title" dangerouslySetInnerHTML={{__html: legislation.link}} />
          <div className="meta">
            {legislation.geography && (
              <a href={legislation.geography_path}>
                <img src={`/images/flags/${legislation.geography.iso}.svg`} alt={`${legislation.geography.name} flag`} />
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
  min_law_passed_year: 1990,
  eu_members: [],
  geo_filter_options: [],
  keywords_filter_options: [],
  responses_filter_options: [],
  frameworks_filter_options: [],
  types_filter_options: [],
  instruments_filter_options: [],
  natural_hazards_filter_options: [],
  themes_filter_options: [],
  sectors_options: []
};

LegislationAndPolicies.propTypes = {
  legislations: PropTypes.array.isRequired,
  count: PropTypes.number,
  eu_members: PropTypes.array,
  min_law_passed_year: PropTypes.number,
  geo_filter_options: PropTypes.array,
  keywords_filter_options: PropTypes.array,
  responses_filter_options: PropTypes.array,
  frameworks_filter_options: PropTypes.array,
  types_filter_options: PropTypes.array,
  instruments_filter_options: PropTypes.array,
  natural_hazards_filter_options: PropTypes.array,
  themes_filter_options: PropTypes.array,
  sectors_options: PropTypes.array
};

export default LegislationAndPolicies;
