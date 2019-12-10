/* eslint-disable max-len */

import React, { useState, useRef, useEffect, useCallback } from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash/debounce';
// import search from '../../assets/images/icons/search.svg';
import searchAgain from '../../assets/images/icons/search-again.svg';
import countryFlag from '../../assets/images/icons/country-flag.svg';
import laws from '../../assets/images/icons/laws.svg';
import legalScale from '../../assets/images/icons/legal-scale.svg';
import target from '../../assets/images/icons/target.svg';

const ESCAPE_KEY = 27;

const GEOGRAPHY_TYPES = {
  national: 'Country profile',
  supranational: 'Country group profile',
  subnational: 'Subnational profile',
  local: 'Local profile'
};

const CATEGORIES = {
  countries: 'Countries and territories',
  laws: 'Laws and policies',
  litigations: 'Litigation cases',
  targets: 'Climate targets'
};

function LawsDropdownCategory({ title, icon, children }) {
  return (
    <div className="laws-dropdown__category">
      <div className="laws-dropdown__category-title">
        <img className="laws-dropdown__category-icon" src={icon} />
        <span>{title}</span>
      </div>
      {children}
    </div>
  );
}

LawsDropdownCategory.propTypes = {
  title: PropTypes.string.isRequired,
  icon: PropTypes.object.isRequired,
  children: PropTypes.any.isRequired
};

const LawsDropdown = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchValue, setSearchValue] = useState('');
  const dropdownContainer = useRef(null);

  const lastSearch = localStorage.getItem('lastSearch');
  const lastSearchCategory = localStorage.getItem('lastSearchCategory');
  const lastSearchLink = localStorage.getItem('lastSearchLink');

  const [counts, setCounts] = useState({});
  const [results, setResults] = useState({});

  const handleInput = input => {
    setSearchValue(input);
  };

  const delaySettingInput = useCallback(debounce(value => handleInput(value), 300));
  const handleInputThrottled = e => delaySettingInput(e.target.value);

  const setLastSearch = (s, category, link) => {
    localStorage.setItem('lastSearch', s);
    localStorage.setItem('lastSearchCategory', category);
    localStorage.setItem('lastSearchLink', link);
  };

  // SEARCH RESULTS for each category
  const searchGeographiesResults = results.geographies || [];
  const searchLawsResults = results.legislationCount;
  const searchLitigationsResults = results.litigationCount;
  const searchTargetsResults = results.targetCount;
  // end of search results

  const allSearchResultsCount = searchGeographiesResults.length + searchLawsResults + searchLitigationsResults + searchTargetsResults;
  const noMatches = allSearchResultsCount === 0;

  const handleCloseDropdown = () => {
    setIsOpen(false);
  };

  const handleInputClick = () => {
    if (!isOpen) setIsOpen(true);
  };

  const escFunction = useCallback((event) => {
    if (event.keyCode === ESCAPE_KEY) {
      handleCloseDropdown();
    }
  }, []);

  const handleClickOutside = useCallback((event) => {
    if (dropdownContainer.current && !dropdownContainer.current.contains(event.target)) {
      handleCloseDropdown();
    }
  }, []);


  // loading data
  useEffect(() => {
    fetch('/cclow/api/search_counts')
      .then((r) => r.json())
      .then((data) => {
        setCounts(data);
      });
  }, []);

  useEffect(() => {
    fetch(`/cclow/api/search?q=${encodeURIComponent(searchValue)}`)
      .then((r) => r.json())
      .then((data) => {
        setResults(data);
      });
  }, [searchValue]);

  const renderAllOptions = (withLastSearch = true) => (
    <>
      {withLastSearch && lastSearch && (
        <LawsDropdownCategory title="Last search" icon={searchAgain}>
          <a href={lastSearchLink} className="laws-dropdown__option">
            <span className="laws-dropdown__option-in-bold">{lastSearch}</span>&nbsp;in {lastSearchCategory}
          </a>
        </LawsDropdownCategory>
      )}

      <LawsDropdownCategory title="Countries and territories" icon={countryFlag}>
        {(counts.geographies || []).map(geography => (
          <a href={`/cclow/geographies/${geography.id}`} key={geography.slug} className="laws-dropdown__option">
            <span>{geography.name}</span>
            <span className="laws-dropdown__disclaimer">{GEOGRAPHY_TYPES[geography.geography_type]}</span>
          </a>
        ))}
      </LawsDropdownCategory>

      <LawsDropdownCategory title="Laws and policies" icon={laws}>
        <a href="/cclow/legislation_and_policies" className="laws-dropdown__option">
          <span>All Laws and policies</span>
          <span className="laws-dropdown__disclaimer">{counts.legislationCount}</span>
        </a>
        <a href="/cclow/legislation_and_policies?recent=true" className="laws-dropdown__option">
          <span>Most recent additions in Laws and policies</span>
          <span className="laws-dropdown__disclaimer">{counts.recentLegislationCount}</span>
        </a>
      </LawsDropdownCategory>

      <LawsDropdownCategory title="Litigation cases" icon={legalScale}>
        <a href="/cclow/litigation_cases" className="laws-dropdown__option">
          <span>All litigation entries</span>
          <span className="laws-dropdown__disclaimer">{counts.litigationCount}</span>
        </a>
        <a href="/cclow/litigation_cases?recent=true" className="laws-dropdown__option">
          <span>Most recent additions in Litigation</span>
          <span className="laws-dropdown__disclaimer">{counts.recentLitigationCount}</span>
        </a>
      </LawsDropdownCategory>

      <LawsDropdownCategory title="Climate targets" icon={target}>
        <a href="/cclow/climate_targets" className="laws-dropdown__option">
          <span>All Climate targets</span>
          <span className="laws-dropdown__disclaimer">{counts.targetCount}</span>
        </a>
        <a href="/cclow/climate_targets?recent=true" className="laws-dropdown__option">
          <span>Most recent additions in Climate targets</span>
          <span className="laws-dropdown__disclaimer">{counts.recentTargetCount}</span>
        </a>
      </LawsDropdownCategory>
    </>
  );

  // hooks
  useEffect(() => {
    document.addEventListener('keydown', escFunction, false);

    return () => {
      document.removeEventListener('keydown', escFunction, false);
    };
  }, []);

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  return (
    <div ref={dropdownContainer} className="laws-dropdown__container container">
      <div className="laws-dropdown__input-container">
        <input
          id="search-input"
          onChange={handleInputThrottled}
          placeholder="Search for countries, legislation and policies and litigation cases"
          className="laws-input"
          onClick={handleInputClick}
        />
        <a className="search-input__icon">
          <span className="icon icon__search" />
        </a>
      </div>
      {isOpen && (
        <div className="laws-dropdown__content">
          {!searchValue && renderAllOptions()}
          {searchValue && (
            <>
              {!!searchGeographiesResults.length && (
                <LawsDropdownCategory title={CATEGORIES.countries} icon={countryFlag}>
                  {searchGeographiesResults.map(geography => (
                    <a
                      href={`/cclow/geographies/${geography.id}`}
                      onClick={() => setLastSearch(searchValue, CATEGORIES.countries, `/cclow/geographies/${geography.id}`)}
                      key={geography.slug}
                      className="laws-dropdown__option"
                    >
                      <span className="laws-dropdown__option-in-bold">{geography.name}</span>
                      <span className="laws-dropdown__disclaimer">{GEOGRAPHY_TYPES[geography.geography_type]}</span>
                    </a>
                  ))}
                </LawsDropdownCategory>
              )}
              {!!results.legislationCount && (
                <LawsDropdownCategory title={CATEGORIES.laws} icon={laws}>
                  <a
                    href={`/cclow/legislation_and_policies?q=${searchValue}`}
                    onClick={() => setLastSearch(searchValue, CATEGORIES.laws, `/cclow/legislation_and_policies?q=${searchValue}`)}
                    className="laws-dropdown__option"
                  >
                    <span>Search&nbsp;</span>
                    <span className="laws-dropdown__option-in-bold">{searchValue}</span>&nbsp;in Laws and policies
                    <span className="laws-dropdown__disclaimer">{results.legislationCount}</span>
                  </a>
                </LawsDropdownCategory>
              )}
              {!!results.litigationCount && (
                <LawsDropdownCategory title={CATEGORIES.litigations} icon={legalScale}>
                  <a
                    href={`/cclow/litigation_cases?q=${searchValue}`}
                    onClick={() => setLastSearch(searchValue, CATEGORIES.litigations, `/cclow/litigation_cases?q=${searchValue}`)}
                    className="laws-dropdown__option"
                  >
                    <span>Search&nbsp;</span>
                    <span className="laws-dropdown__option-in-bold">{searchValue}</span>&nbsp;in Litigation
                    <span className="laws-dropdown__disclaimer">{results.litigationCount}</span>
                  </a>
                </LawsDropdownCategory>
              )}
              {!!results.targetCount && (
                <LawsDropdownCategory title={CATEGORIES.targets} icon={target}>
                  <a
                    href={`/cclow/climate_targets?q=${searchValue}`}
                    onClick={() => setLastSearch(searchValue, CATEGORIES.targets, `/cclow/climate_targets?q=${searchValue}`)}
                    className="laws-dropdown__option"
                  >
                    <span>Search&nbsp;</span>
                    <span className="laws-dropdown__option-in-bold">{searchValue}</span>&nbsp;in Climate targets
                    <span className="laws-dropdown__disclaimer">{results.targetCount}</span>
                  </a>
                </LawsDropdownCategory>
              )}
            </>
          )}
          {searchValue && noMatches && (
            <>
              <div className="laws-dropdown__category">
                <div className="no-matches-text">
                  No matches for&nbsp;
                  <span className="laws-dropdown__option-in-bold">{searchValue}</span>,
            please try another term or browse the link below
                </div>
              </div>
              {renderAllOptions(false)}
            </>
          )}
        </div>
      )}
    </div>
  );
};

export default LawsDropdown;
