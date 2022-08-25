import React, { useState, useCallback, useEffect, useMemo } from 'react';
import uniq from 'lodash/uniq';
import cx from 'classnames';
import PropTypes from 'prop-types';
import filterIcon from 'images/icons/filter-white.svg';
import filterBlueIcon from 'images/icons/filter-blue.svg';

import { useQueryParam } from 'shared/hooks';

const ALL_OPTION_NAME = 'All';

const Filters = ({ tags, sectors, resultsSize }) => {
  const [isFilterOpen, setIsFiltersOpen] = useState(false);
  const [resultsCount, setResultsCount] = useState(resultsSize);
  const [queryTagsParam, setQueryTags] = useQueryParam('tags');
  const [querySectorsParam, setQuerySectors] = useQueryParam('sectors');

  const activeTags = useMemo(() => {
    const queryTags = (queryTagsParam || '').split(',').filter(x => x);
    const tagsWithAllOption = uniq([ALL_OPTION_NAME, ...queryTags, ...tags]);
    return tagsWithAllOption.map(tag => ({
      name: tag,
      active: queryTags.length > 0 ? queryTags.includes(tag) : tag === ALL_OPTION_NAME
    }));
  }, [tags, queryTagsParam]);
  const activeSectors = useMemo(() => {
    const sectorsWithAllOption = [ALL_OPTION_NAME, ...sectors];
    const querySectors = (querySectorsParam || '').split(',').filter(x => x);
    return sectorsWithAllOption.map(sector => ({
      name: sector,
      active: querySectors.length > 0 ? querySectors.includes(sector) : sector === ALL_OPTION_NAME
    }));
  }, [sectors, querySectorsParam]);

  const isAllClicked = (option) => option.name === ALL_OPTION_NAME;
  const isAllSelected = (options) => options.filter(o => o.active).length === 0;
  const optionsWithoutALL = (options) => options.filter(t => t.name !== ALL_OPTION_NAME);
  const isOtherOptionsActive = (options) => !!options.filter(o => o.active).length;

  const buttonTitle = isFilterOpen ? 'Hide filters' : 'Show filters';

  const handleButtonClick = useCallback(() => {
    setIsFiltersOpen(!isFilterOpen);
  }, [isFilterOpen]);
  useEffect(() => {
    document.getElementById('filter-button').addEventListener('click', handleButtonClick);

    return () => {
      document.getElementById('filter-button').removeEventListener('click', handleButtonClick);
    };
  }, [handleButtonClick]);

  const refreshPublicationsHtml = (query) => {
    const url = `/publications/partial?${query}`;

    fetch(url)
      .then(response => response.text())
      .then(html => {
        document.querySelector('#publications').innerHTML = html;
        const newPublicationsCount = document.querySelector('#input_publications_count').value;
        setResultsCount(newPublicationsCount);
      });
  };

  useEffect(() => {
    const activeTagsQueryParam = activeTags
      .filter(t => t.active && t.name !== ALL_OPTION_NAME)
      .map(t => encodeURIComponent(t.name))
      .join(', ');
    const activeSectorsQueryParam = activeSectors
      .filter(s => s.active && s.name !== ALL_OPTION_NAME)
      .map(s => encodeURIComponent(s.name))
      .join(', ');
    refreshPublicationsHtml(`tags=${activeTagsQueryParam}&sectors=${activeSectorsQueryParam}`);
  }, [activeTags, activeSectors]);

  const handleTagClick = (tag) => {
    const otherOptions = optionsWithoutALL(activeTags);

    const shouldALLbeSelected = isAllClicked(tag) && (isOtherOptionsActive(otherOptions) || isAllSelected(otherOptions));

    if (shouldALLbeSelected) {
      const tagsWithALLSelected = activeTags.map(t => ({
        name: t.name,
        active: t.name === ALL_OPTION_NAME
      }));
      setQueryTags(tagsWithALLSelected.filter(t => t.active).map((t) => t.name).join(','));
    } else {
      const updatedTags = activeTags.map(t => {
        if (t.name === tag.name) { return { name: t.name, active: !t.active }; }
        if (t.name === ALL_OPTION_NAME) { return { name: t.name, active: false }; }
        return { name: t.name, active: t.active };
      });
      setQueryTags(updatedTags.filter(t => t.active).map((t) => t.name).join(','));
    }
  };

  const handleSectorClick = (sector) => {
    const otherOptions = optionsWithoutALL(activeSectors);

    const shouldALLbeSelected = isAllClicked(sector) && (isOtherOptionsActive(otherOptions) || isAllSelected(otherOptions));

    if (shouldALLbeSelected) {
      const sectorsWithALLSelected = activeSectors.map(s => ({
        name: s.name,
        active: s.name === ALL_OPTION_NAME
      }));
      setQuerySectors(sectorsWithALLSelected.filter(s => s.active).map((s) => s.name).join(','));
    } else {
      const updatedSectors = activeSectors.map(s => {
        if (s.name === sector.name) { return { name: s.name, active: !s.active }; }
        if (s.name === ALL_OPTION_NAME) { return { name: s.name, active: false }; }
        return { name: s.name, active: s.active };
      });
      setQuerySectors(updatedSectors.filter(s => s.active).map((s) => s.name).join(','));
    }
  };

  return (
    <div className={cx('filters__wrapper-margin', { 'filters__wrapper-background': isFilterOpen })}>
      <div className="container publications">
        <div className="filters__wrapper">
          <div className="showing-count">
            <p>Showing <strong>{resultsCount}</strong> items in <strong>All Publications and news</strong></p>
          </div>
          <div className="filters__button is-hidden-touch">
            <button
              type="button"
              className={cx('button is-centered is-hidden-touch', { 'filters__button-active': !isFilterOpen, 'filters__button-notactive': isFilterOpen})}
              onClick={handleButtonClick}
            >
              <img
                src={isFilterOpen ? filterIcon : filterBlueIcon}
                className="filters__filter-icon"
                alt="Filter icon"
              />
              <span>{buttonTitle}</span>
            </button>
          </div>
        </div>
        {isFilterOpen
          && (
            <div className="filters__container">
              <div className="filters__title">Tag</div>
              <div className="filters__tags-container">
                {activeTags.length && activeTags.map(tag => (
                  <button
                    type="button"
                    onClick={() => handleTagClick(tag)}
                    className={cx('filters__tag', {'filters__tag-selected': tag.active})}
                  >
                    {tag.name}
                  </button>
                ))}
              </div>
              <div className="filters__title">Sector</div>
              <div className="filters__tags-container">
                {activeSectors.length && activeSectors.map(sector => (
                  <button
                    type="button"
                    onClick={() => handleSectorClick(sector)}
                    className={cx('filters__tag', {'filters__tag-selected': sector.active})}
                  >
                    {sector.name}
                  </button>
                ))}
              </div>
            </div>
          )}
      </div>
    </div>
  );
};

Filters.propTypes = {
  tags: PropTypes.array.isRequired,
  sectors: PropTypes.array.isRequired,
  resultsSize: PropTypes.number.isRequired
};

export default Filters;
