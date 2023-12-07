import React, { useState } from 'react';

import PropTypes from 'prop-types';

const CountrySelector = ({
  countries,
  selectedCountries: defaultSelectedCountries,
  maxSelectedCountries,
  onSaveCountries
}) => {
  const [countriesOpen, setCountriesOpen] = useState(false);
  const [selectedCountries, setSelectedCountries] = useState(
    defaultSelectedCountries
  );

  const _countries = countries.sort((a, b) => (a.name < b.name ? -1 : 1));

  const handleSelectedCountry = (event) => {
    const { checked, value } = event.target;

    if (checked && selectedCountries.length >= maxSelectedCountries) {
      return;
    }

    const parsedValue = parseInt(value, 10);

    if (checked) {
      setSelectedCountries([...selectedCountries, parsedValue]);
    } else {
      setSelectedCountries(
        selectedCountries.filter((id) => id !== parsedValue)
      );
    }
  };

  const handleSaveCountries = () => {
    setCountriesOpen(false);
    onSaveCountries(selectedCountries);
  };

  return (
    <div className="emissions__filters__country-selector">
      <button
        className="button is-emphasis"
        onClick={() => setCountriesOpen((open) => !open)}
        type="button"
      >
        Choose countries to show
      </button>
      <div
        className={`emissions__filters__country-selector__countries ${
          countriesOpen ? '--countries-open' : ''
        }`}
      >
        <div className="emissions__filters__country-selector__countries__wrapper">
          <p className="emissions__filters__country-selector__countries__label">
            Add up to 10 countries simultaneously
          </p>
          <ul className="emissions__filters__country-selector__countries__list">
            {_countries.map((_country) => (
              <li key={_country.id}>
                <input
                  checked={selectedCountries?.includes(_country.id)}
                  id={_country.id}
                  type="checkbox"
                  value={_country.id}
                  onChange={handleSelectedCountry}
                />
                <label htmlFor={_country.id}>{_country.name}</label>
              </li>
            ))}
          </ul>
          <div className="emissions__filters__country-selector__countries__button">
            <button
              onClick={handleSaveCountries}
              type="button"
              className="button is-secondary"
            >
              Save
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

CountrySelector.propTypes = {
  countries: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      iso: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired
    })
  ).isRequired,
  selectedCountries: PropTypes.arrayOf(PropTypes.number),
  maxSelectedCountries: PropTypes.number.isRequired,
  onSaveCountries: PropTypes.func.isRequired
};

CountrySelector.defaultProps = {
  selectedCountries: []
};

export default CountrySelector;
