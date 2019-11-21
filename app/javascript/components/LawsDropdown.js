import React, { useState, useRef, useEffect, useCallback, useMemo } from 'react';
import Fuse from "fuse.js";
import search from '../../assets/images/icons/search.svg';
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
}

const CATEGORIES = {
  countries: 'Countries and territories',
  laws: 'Laws and policies',
  litigations: 'Litigation cases',
  targets: 'Climate targets'
}

const LawsDropdown = ({ geographies, lawsAndPolicies, litigations, targets, recentDate }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchValue, setSearchValue ] = useState('');
  const dropdownContainer = useRef(null);

  const lastSearch = localStorage.getItem("lastSearch");
  const lastSearchCategory = localStorage.getItem("lastSearchCategory");
  const lastSearchLink = localStorage.getItem("lastSearchLink")
  const setLastSearch = (search, category, link) => { 
    localStorage.setItem("lastSearch", search);
    localStorage.setItem("lastSearchCategory", category);
    localStorage.setItem("lastSearchLink", link);
  }

  // REFACTOR THIS to be one function that takes options and KEYS to search from
  const fuseGeographies = (opt) => {
    const config = {
      shouldSort: true,
      threshold: 0.3,
      keys: ['name']
    };
    const fuse = new Fuse(opt, config);
    const searchResults = fuse.search(searchValue);
    return searchResults;
  }

  const fuseLaws = (opt) => {
    const config = {
      shouldSort: true,
      threshold: 0.3,
      keys: ['name', 'geography_name']
    };
    const fuse = new Fuse(opt, config);
    const searchResults = fuse.search(searchValue);
    return searchResults;
  }

  const fuseLitigations = (opt) => {
    const config = {
      shouldSort: true,
      threshold: 0.3,
      keys: ['name', 'jurisdiction_name']
    };
    const fuse = new Fuse(opt, config);
    const searchResults = fuse.search(searchValue);
    return searchResults;
  }

  const fuseTargets = (opt) => {
    const config = {
      shouldSort: true,
      threshold: 0.3,
      keys: ['name', 'geography_name']
    };
    const fuse = new Fuse(opt, config);
    const searchResults = fuse.search(searchValue);
    return searchResults;
  }
  // END OF FUSE FUNCTIONS


  // SEARCH RESULTS for each category
  const searchGeographiesResults = useMemo(() => searchValue ? fuseGeographies(geographies) : [], [searchValue]);
  const searchLawsResults = useMemo(() => searchValue ? fuseLaws(lawsAndPolicies) : [], [searchValue]);
  const searchLitigationsResults = useMemo(() => searchValue ? fuseLitigations(litigations) : [], [searchValue]);
  const searchTargetsResults = useMemo(() => searchValue ? fuseTargets(targets) : [], [searchValue]);
  // end of search results

  const allSearchResults = [...searchGeographiesResults, ...searchLawsResults, ...searchLitigationsResults, ...searchTargetsResults];

  const first3Geographies = geographies.slice(0, 3);

  const handleCloseDropdown = () => {
    setIsOpen(false);
  }

  const handleInputClick = () => {
    !isOpen && setIsOpen(true);
  }

  const escFunction = useCallback((event) => {
    if(event.keyCode === ESCAPE_KEY) {
      handleCloseDropdown();
    }
  }, []);

  const handleClickOutside = useCallback((event) => {
    if (dropdownContainer.current && !dropdownContainer.current.contains(event.target)) {
      handleCloseDropdown();
    }
  }, [])

  const renderAllOptions = (withLastSearch = true) => (
    <>
      {withLastSearch && lastSearch && (
        <div className="laws-dropdown__category">
          <div className="laws-dropdown__category-title">
            <img className="laws-dropdown__category-icon" src={searchAgain} />
            <span>Last search</span>
          </div>
          <a href={lastSearchLink} className="laws-dropdown__option">
            <span className="laws-dropdown__last-search-key">{lastSearch}</span>&nbsp;in {lastSearchCategory}
          </a>
        </div>
      )}

      <div className="laws-dropdown__category">
        {/* category title */}
        <div className="laws-dropdown__category-title">
          <img className="laws-dropdown__category-icon" src={countryFlag} />
          <span>Countries and territories</span>
        </div>
        {/* options */}
        {first3Geographies.map(geography => (
          <a href={`/cclow/geographies/${geography.id}`} key={geography.slug} className="laws-dropdown__option">
            <span>{geography.name}</span>
            <span className="laws-dropdown__disclaimer">{GEOGRAPHY_TYPES[geography.geography_type]}</span>
          </a>
        ))}
      </div>

      <div className="laws-dropdown__category">
        {/* category title */}
        <div className="laws-dropdown__category-title">
          <img className="laws-dropdown__category-icon" src={laws} />
          <span>Laws and policies</span>
        </div>
        {/* options */}
        <a href="/cclow/legislation_and_policies" className="laws-dropdown__option">
          <span>All Laws and policies</span>
          <span className="laws-dropdown__disclaimer">{lawsAndPolicies.length}</span>
        </a>
        <a href={`/cclow/legislation_and_policies?fromDate=${recentDate}`} className="laws-dropdown__option">
          <span>Most recent additions in Laws and policies</span>
          <span className="laws-dropdown__disclaimer">todo</span>
        </a>
      </div>

      <div className="laws-dropdown__category">
        {/* category title */}
        <div className="laws-dropdown__category-title">
          <img className="laws-dropdown__category-icon" src={legalScale} />
          <span>Litigation cases</span>
        </div>
        {/* options */}
        <a href="/cclow/litigation_cases" className="laws-dropdown__option">
          <span>All litigation entries</span>
          <span className="laws-dropdown__disclaimer">{litigations.length}</span>
        </a>
        <div className="laws-dropdown__option">
          <span>Most recent additions in Litigation {/* TODO: no "opened" date in Litigation Case */}</span>
          <span className="laws-dropdown__disclaimer">todo</span>
        </div>
      </div>

      <div className="laws-dropdown__category">
        {/* category title */}
        <div className="laws-dropdown__category-title">
          <img className="laws-dropdown__category-icon" src={target} />
          <span>Climate targets</span>
        </div>
        {/* options */}
        <a href="/cclow/climate_targets" className="laws-dropdown__option">
          <span>All Climate targets</span>
          <span className="laws-dropdown__disclaimer">{targets.length}</span>
        </a>
        <div className="laws-dropdown__option">
          <span>Most recent additions in Climate targets {/* TODO: in what sense recent? set targets? what's the attribute to filter by? */}</span>
          <span className="laws-dropdown__disclaimer">todo</span>
        </div>
      </div>
    </>
  );

  // hooks
  useEffect(() => {
    document.addEventListener("keydown", escFunction, false);

    return () => {
      document.removeEventListener("keydown", escFunction, false);
    };
  }, []);

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    }
  }, []);

  return (
    <div ref={dropdownContainer} className="laws-dropdown__container">
      <div className="laws-dropdown__input-container">
        <input 
          id="search-input"
          onChange={e => setSearchValue(e.target.value)}
          placeholder="Search for countries, legislation and policies and litigation cases" className="laws-input"
          onClick={handleInputClick}
        />
        <label htmlFor="search-input">
          <img className="icon" src={search} />
        </label>
      </div>
      {isOpen && (
        <div className="laws-dropdown__content">
          {!searchValue && renderAllOptions()}
          {searchValue && (
            <>
              {!!searchGeographiesResults.length && (
                <div className="laws-dropdown__category">
                  <div className="laws-dropdown__category-title">
                    <img className="laws-dropdown__category-icon" src={countryFlag} />
                    <span>{CATEGORIES.countries}</span>
                  </div>
                  {searchGeographiesResults.map(geography => (
                    <a
                      href={`/cclow/geographies/${geography.id}`}
                      onClick={() => setLastSearch(searchValue, CATEGORIES.countries, `/cclow/geographies/${geography.id}`)}
                      key={geography.slug}
                      className="laws-dropdown__option"
                    >
                      <span>{geography.name}</span>
                      <span className="laws-dropdown__disclaimer">{GEOGRAPHY_TYPES[geography.geography_type]}</span>
                    </a>
                  ))}
                </div>
              )}
              {!!searchLawsResults.length && (
                <div className="laws-dropdown__category">
                  <div className="laws-dropdown__category-title">
                    <img className="laws-dropdown__category-icon" src={laws} />
                    <span>{CATEGORIES.laws}</span>
                  </div>
                  <a
                    href={`/cclow/legislation_and_policies?ids=${searchLawsResults.map(l => l.id).join(',')}`}
                    onClick={() => setLastSearch(searchValue, CATEGORIES.laws, `/cclow/legislation_and_policies?ids=${searchLawsResults.map(l => l.id).join(',')}`)}
                    className="laws-dropdown__option"
                  >
                    <span>Search&nbsp;</span>
                    <span className="laws-dropdown__last-search-key">{searchValue}</span>&nbsp;in Laws and policies
                    <span className="laws-dropdown__disclaimer">{searchLawsResults.length}</span>
                  </a>
                </div>
              )}
              {!!searchLitigationsResults.length && (
                <div className="laws-dropdown__category">
                  <div className="laws-dropdown__category-title">
                    <img className="laws-dropdown__category-icon" src={legalScale} />
                    <span>{CATEGORIES.litigations}</span>
                  </div>
                  <a
                    href={`/cclow/litigation_cases?ids=${searchLitigationsResults.map(l => l.id).join(',')}`}
                    onClick={() => setLastSearch(searchValue, CATEGORIES.litigations, `/cclow/litigation_cases?ids=${searchLitigationsResults.map(l => l.id).join(',')}`)}
                    className="laws-dropdown__option"
                  >
                    <span>Search&nbsp;</span>
                    <span className="laws-dropdown__last-search-key">{searchValue}</span>&nbsp;in Litigation
                    <span className="laws-dropdown__disclaimer">{searchLitigationsResults.length}</span>
                  </a>
                </div>
              )}
              {!!searchTargetsResults.length && (
                <div className="laws-dropdown__category">
                  <div className="laws-dropdown__category-title">
                    <img className="laws-dropdown__category-icon" src={target} />
                    <span>{CATEGORIES.targets}</span>
                  </div>
                  <a
                    href={`/cclow/climate_targets?ids=${searchTargetsResults.map(l => l.id).join(',')}`}
                    onClick={() => setLastSearch(searchValue, CATEGORIES.targets, `/cclow/climate_targets?ids=${searchTargetsResults.map(l => l.id).join(',')}`)}
                    className="laws-dropdown__option"
                  >
                    <span>Search&nbsp;</span>
                    <span className="laws-dropdown__last-search-key">{searchValue}</span>&nbsp;in Climate targets
                    <span className="laws-dropdown__disclaimer">{searchTargetsResults.length}</span>
                  </a>
                </div>
              )}
            </>
          )}
          {searchValue && !allSearchResults.length && (
            <>
              <div className="laws-dropdown__category">
                <div className="no-matches-text">
                  No matches for&nbsp;
                  <span className="laws-dropdown__last-search-key">{searchValue}</span>,
                  please try another term or browse the link below
                </div>
              </div>
              {renderAllOptions(false)}
            </>
          )}
        </div>
      )}
    </div>
  )
}

export default LawsDropdown;