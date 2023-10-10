import React from 'react';
import PropTypes from 'prop-types';
import Select from './Select';
import CountrySelector from './CountrySelector';

const MAX_SELECTED_COUNTRIES = 10;

const Filters = ({
  metrics,
  boundaries,
  countries,
  filters: { emissions_metric, emissions_boundary, country_ids },
  onChangeFilters
}) => {
  const handleSelect = (opt) => {
    onChangeFilters({ [opt.name]: opt.value });
  };

  const handleSelectCountry = (_countries) => {
    onChangeFilters({ country_ids: _countries });
  };

  return (
    <div className="emissions__filters">
      <div className="emissions__filters__emissions">
        <Select
          options={metrics}
          onSelect={handleSelect}
          value={emissions_metric}
          name="emissions_metric"
          placeholder="Emissions Metric"
          label="Emissions Metric"
        />
        <Select
          options={boundaries}
          onSelect={handleSelect}
          value={emissions_boundary}
          name="emissions_boundary"
          placeholder="Emissions Boundary"
          label="Emissions Boundary"
        />
      </div>
      <div>
        <CountrySelector
          countries={countries}
          selectedCountries={country_ids}
          maxSelectedCountries={MAX_SELECTED_COUNTRIES}
          onSaveCountries={handleSelectCountry}
        />
      </div>
    </div>
  );
};

Filters.propTypes = {
  metrics: PropTypes.arrayOf(PropTypes.string).isRequired,
  boundaries: PropTypes.arrayOf(PropTypes.string).isRequired,
  countries: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      iso: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired
    })
  ).isRequired,
  filters: PropTypes.shape({
    emissions_metric: PropTypes.string.isRequired,
    emissions_boundary: PropTypes.string.isRequired,
    country_ids: PropTypes.arrayOf(PropTypes.number).isRequired
  }).isRequired,
  onChangeFilters: PropTypes.func.isRequired
};

export default Filters;
