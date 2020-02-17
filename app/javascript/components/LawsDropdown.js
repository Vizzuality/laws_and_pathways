/* eslint-disable max-len */

import React, { useState, useRef, useEffect, useCallback } from 'react';
import PropTypes from 'prop-types';

import { useDebounce, useOutsideClick } from 'shared/hooks';

import searchAgain from 'images/icons/search-again.svg';
import countryFlag from 'images/icons/country-flag.svg';
import laws from 'images/icons/laws.svg';
import legalScale from 'images/icons/legal-scale.svg';
import target from 'images/icons/target.svg';

const ESCAPE_KEY = 27;
const SEARCH_DEBOUNCE = 500;

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
  const [sValue, setSearchValue] = useState(null);
  const searchValue = useDebounce(sValue, SEARCH_DEBOUNCE);
  const dropdownContainer = useRef(null);

  const lastSearch = localStorage.getItem('lastSearch');
  const lastSearchCategory = localStorage.getItem('lastSearchCategory');
  const lastSearchLink = localStorage.getItem('lastSearchLink');

  const [counts, setCounts] = useState({});
  const [results, setResults] = useState({});

  const setLastSearch = (s, category, link) => {
    localStorage.setItem('lastSearch', s);
    localStorage.setItem('lastSearchCategory', category);
    localStorage.setItem('lastSearchLink', link);
  };

  // SEARCH RESULTS for each category
  const searchGeographiesResults = results.geographies || [];
  const lawsResultsCount = results.legislationCount || 0;
  const litigationsResultsCount = results.litigationCount || 0;
  const targetsResultsCount = results.targetCount || 0;
  // end of search results

  const allSearchResultsCount = searchGeographiesResults.length + lawsResultsCount + litigationsResultsCount + targetsResultsCount;
  const noMatches = allSearchResultsCount === 0;

  const handleInput = e => {
    setSearchValue(e.target.value);
  };

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

  useOutsideClick(dropdownContainer, handleCloseDropdown);

  // loading data

  // just for initial load
  useEffect(() => {
    fetch('/cclow/api/search_counts')
      .then((r) => r.json())
      .then((data) => {
        setCounts(data);
      });
  }, []);

  // searching
  useEffect(() => {
    if (!searchValue) {
      setResults({});
      return;
    }

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

  const renderContent = useCallback(() => {
    if (!searchValue) return renderAllOptions();
    if (noMatches) {
      return (
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
      );
    }

    return (
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
    );
  }, [results]);

  return (
    <div ref={dropdownContainer} className="laws-dropdown__container container">
      <div className="laws-dropdown__input-container">
        <input
          id="search-input"
          onChange={handleInput}
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
          {renderContent()}
        </div>
      )}
    </div>
  );
};

export default LawsDropdown;
