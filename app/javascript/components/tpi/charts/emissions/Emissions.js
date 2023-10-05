import React, { useMemo, useState } from 'react';

import PropTypes from 'prop-types';
import Filters from './Filters';
import EmissionsChart from './Chart';
// import { useChartData } from '../hooks';
import mockedData from './mockedData';

const initialData = {
  data: [],
  metadata: {
    unit: ''
  }
};

const Emissions = ({
  emissions_metric_filter,
  default_emissions_metric_filter,
  emissions_boundary_filter,
  default_emissions_boundary_filter,
  countries,
  default_countries
  // emissions_data_url
}) => {
  const [filters, setFilters] = useState({
    emissions_metric: default_emissions_metric_filter,
    emissions_boundary: default_emissions_boundary_filter,
    country_ids: default_countries
  });

  const onChangeFilters = (filter) => {
    setFilters((_filters) => ({ ..._filters, ...filter }));
  };

  // const { data } = useChartData(emissions_data_url, filters);
  const data = mockedData;

  const chartData = useMemo(
    () => (Array.isArray(data)
      ? initialData
      : {
        ...data,
        data: Object.entries(data.data).map(
          ([countryId, { emissions, last_historical_year }]) => ({
            name: countries.find(
              (country) => country.id === Number(countryId)
            ).name,
            data: Object.entries(emissions).map(([year, value]) => ({x: Number(year), y: value})),
            zoneAxis: 'x',
            zones: [
              {
                value: last_historical_year
              },
              {
                dashStyle: 'dash'
              }
            ]
          })
        )
      }),
    [countries, data]
  );

  return (
    <div className="emissions">
      <Filters
        metrics={emissions_metric_filter}
        boundaries={emissions_boundary_filter}
        countries={countries}
        filters={filters}
        onChangeFilters={onChangeFilters}
      />
      <EmissionsChart chartData={chartData} />
    </div>
  );
};

Emissions.propTypes = {
  emissions_metric_filter: PropTypes.arrayOf(PropTypes.string).isRequired,
  default_emissions_metric_filter: PropTypes.string.isRequired,
  emissions_boundary_filter: PropTypes.arrayOf(PropTypes.string).isRequired,
  default_emissions_boundary_filter: PropTypes.string.isRequired,
  countries: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      iso: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired
    })
  ).isRequired,
  default_countries: PropTypes.arrayOf(PropTypes.number).isRequired
  // emissions_data_url: PropTypes.string.isRequired
};

export default Emissions;
