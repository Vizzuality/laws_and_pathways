import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import List from './List';

import {
  paramInteger,
  paramIntegerArray,
  paramStringArray
} from './helpers';

function LitigationCases(props) {
  const {
    litigations,
    count,
    geo_filter_options,
    keywords_filter_options,
    responses_filter_options,
    statuses_filter_options,
    litigation_party_types_options,
    litigation_side_a_names_options,
    litigation_side_b_names_options,
    litigation_side_c_names_options,
    litigation_side_a_party_type_options,
    litigation_side_b_party_type_options,
    litigation_side_c_party_type_options,
    litigation_jurisdictions_options,
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
      name: 'dateOfCaseStarted',
      title: 'Date of case started',
      timeRange: true,
      mainFilter: true,
      fromParam: 'case_started_from',
      toParam: 'case_started_to',
      params: {
        case_started_from: paramInteger,
        case_started_to: paramInteger
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
      name: 'status',
      title: 'Status',
      options: statuses_filter_options,
      mainFilter: true,
      props: {
        isSearchable: false
      },
      params: {
        status: paramStringArray
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
      name: 'jurisdiction',
      title: 'Jurisdiction',
      options: litigation_jurisdictions_options,
      params: {
        jurisdiction: paramStringArray
      }
    },
    {
      name: 'partyTypes',
      title: 'Party types',
      options: litigation_party_types_options,
      params: {
        party_type: paramStringArray
      }
    },
    {
      name: 'sectors',
      title: 'Sectors',
      options: sectors_options,
      params: {
        law_sector: paramIntegerArray
      }
    },
    {
      name: 'sideAType',
      title: 'Side A type',
      options: litigation_side_a_party_type_options,
      params: {
        a_party_type: paramStringArray
      }
    },
    {
      name: 'sideAName',
      title: 'Side A name',
      options: litigation_side_a_names_options,
      params: {
        side_a: paramStringArray
      }
    },
    {
      name: 'sideBType',
      title: 'Side B type',
      options: litigation_side_b_party_type_options,
      params: {
        b_party_type: paramStringArray
      }
    },
    {
      name: 'sideBName',
      title: 'Side B name',
      options: litigation_side_b_names_options,
      params: {
        side_b: paramStringArray
      }
    },
    {
      name: 'sideCType',
      title: 'Side C type',
      options: litigation_side_c_party_type_options,
      params: {
        c_party_type: paramStringArray
      }
    },
    {
      name: 'sideCName',
      title: 'Side C name',
      options: litigation_side_c_names_options,
      params: {
        side_c: paramStringArray
      }
    }
  ];

  return (
    <List
      items={litigations}
      count={count}
      filterConfigs={filters}
      url="/litigation_cases"
      title="Litigation Cases"
      allTitle="Litigation Cases"
      renderContentItem={(litigation) => (
        <Fragment>
          <h5 className="title" dangerouslySetInnerHTML={{__html: litigation.link}} />
          <div className="meta">
            {litigation.geography && (
              <a href={litigation.geography_path}>
                <img src={`/images/flags/${litigation.geography.iso}.svg`} alt="" />
                {litigation.geography.name}
              </a>
            )}
            {litigation.opened_in && <div>Opened in {litigation.opened_in}</div>}
            {litigation.last_development_in && <div>Last development in {litigation.last_development_in}</div>}
          </div>
          <div className="description" dangerouslySetInnerHTML={{__html: litigation.short_summary}} />
        </Fragment>
      )}
    />
  );
}

LitigationCases.defaultProps = {
  count: 0,
  geo_filter_options: [],
  keywords_filter_options: [],
  responses_filter_options: [],
  statuses_filter_options: [],
  litigation_side_a_names_options: [],
  litigation_side_b_names_options: [],
  litigation_side_c_names_options: [],
  litigation_party_types_options: [],
  litigation_side_a_party_type_options: [],
  litigation_side_b_party_type_options: [],
  litigation_side_c_party_type_options: [],
  litigation_jurisdictions_options: [],
  sectors_options: []
};

LitigationCases.propTypes = {
  litigations: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  keywords_filter_options: PropTypes.array,
  responses_filter_options: PropTypes.array,
  statuses_filter_options: PropTypes.array,
  litigation_party_types_options: PropTypes.array,
  litigation_side_a_names_options: PropTypes.array,
  litigation_side_b_names_options: PropTypes.array,
  litigation_side_c_names_options: PropTypes.array,
  litigation_side_a_party_type_options: PropTypes.array,
  litigation_side_b_party_type_options: PropTypes.array,
  litigation_side_c_party_type_options: PropTypes.array,
  litigation_jurisdictions_options: PropTypes.array,
  sectors_options: PropTypes.array
};

export default LitigationCases;
