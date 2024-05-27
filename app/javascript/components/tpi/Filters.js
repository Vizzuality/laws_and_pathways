import React, { useState, useCallback, useEffect, useMemo } from 'react';
import cx from 'classnames';
import PropTypes from 'prop-types';
import filterIcon from 'images/icons/filter-white.svg';
import filterBlueIcon from 'images/icons/filter-blue.svg';

import { useQueryParam } from 'shared/hooks';

const ALL_OPTION_NAME = 'All';
const SHOW_ON_PAGE = 9;

const Filters = ({ types, tags, sectors, resultsSize }) => {
  const [isFilterOpen, setIsFiltersOpen] = useState(false);
  const [resultsCount, setResultsCount] = useState(resultsSize);
  const [queryTypesParam, setQueryTypes] = useQueryParam('types');
  const [queryTagsParam, setQueryTags] = useQueryParam('tags');
  const [querySectorsParam, setQuerySectors] = useQueryParam('sectors');
  const [offset, setOffset] = useState(0);

  const activeTypes = useMemo(() => {
    const typesWithAllOption = [ALL_OPTION_NAME, ...types];
    const queryTypes = (queryTypesParam || '').split(',').filter(x => x);
    return typesWithAllOption.map(type => ({
      name: type,
      active: queryTypes.length > 0 ? queryTypes.includes(type) : type === ALL_OPTION_NAME
    }));
  }, [types, queryTypesParam]);
  const activeTags = useMemo(() => {
    const queryTags = (queryTagsParam || '').split(',').filter(x => x);
    const tagsWithAllOption = [ALL_OPTION_NAME, ...tags];
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

  useEffect(() => {
    document.querySelector('.publications__load-more').classList.toggle('is-hidden', offset + SHOW_ON_PAGE > resultsCount);
  }, [offset, resultsCount]);

  const handleLoadMore = useCallback(() => {
    setOffset(offset + SHOW_ON_PAGE);
  }, [offset]);

  useEffect(() => {
    document.getElementById('publications-load-more-button').addEventListener('click', handleLoadMore);

    return () => {
      document.getElementById('publications-load-more-button').removeEventListener('click', handleLoadMore);
    };
  }, [handleLoadMore]);

  const refreshPublicationsHtml = (_types, _tags, _sectors, _offset) => {
    const activeTypesQueryParam = _types
      .filter(t => t.active && t.name !== ALL_OPTION_NAME)
      .map(t => encodeURIComponent(t.name))
      .join(', ');
    const activeTagsQueryParam = _tags
      .filter(t => t.active && t.name !== ALL_OPTION_NAME)
      .map(t => encodeURIComponent(t.name))
      .join(', ');
    const activeSectorsQueryParam = _sectors
      .filter(s => s.active && s.name !== ALL_OPTION_NAME)
      .map(s => encodeURIComponent(s.name))
      .join(', ');

    const query = `types=${activeTypesQueryParam}&tags=${activeTagsQueryParam}&sectors=${activeSectorsQueryParam}&offset=${_offset}`;
    const url = `/publications/partial?${query}`;

    fetch(url)
      .then(response => response.text())
      .then(html => {
        if (_offset > 0) {
          document.querySelector('#publications-list').insertAdjacentHTML('beforeend', html);
        } else {
          document.querySelector('#publications').innerHTML = html;
          const newPublicationsCount = parseInt(document.querySelector('#input_publications_count').value, 10);
          setResultsCount(newPublicationsCount);
        }
      });
  };

  useEffect(() => {
    refreshPublicationsHtml(activeTypes, activeTags, activeSectors, offset);
  }, [activeTypes, activeTags, activeSectors, offset]);

  const handleTypeClick = (type) => {
    const otherOptions = optionsWithoutALL(activeTypes);

    const shouldALLbeSelected = isAllClicked(type) && (isOtherOptionsActive(otherOptions) || isAllSelected(otherOptions));

    if (shouldALLbeSelected) {
      const typesWithALLSelected = activeTypes.map(s => ({
        name: s.name,
        active: s.name === ALL_OPTION_NAME
      }));
      setOffset(0);
      setQueryTypes(typesWithALLSelected.filter(s => s.active).map((s) => s.name).join(','));
    } else {
      const updatedTypes = activeTypes.map(s => {
        if (s.name === type.name) { return { name: s.name, active: !s.active }; }
        if (s.name === ALL_OPTION_NAME) { return { name: s.name, active: false }; }
        return { name: s.name, active: s.active };
      });
      setOffset(0);
      setQueryTypes(updatedTypes.filter(s => s.active).map((s) => s.name).join(','));
    }
  };

  const handleTagClick = (tag) => {
    const otherOptions = optionsWithoutALL(activeTags);

    const shouldALLbeSelected = isAllClicked(tag) && (isOtherOptionsActive(otherOptions) || isAllSelected(otherOptions));

    if (shouldALLbeSelected) {
      const tagsWithALLSelected = activeTags.map(t => ({
        name: t.name,
        active: t.name === ALL_OPTION_NAME
      }));
      setOffset(0);
      setQueryTags(tagsWithALLSelected.filter(t => t.active).map((t) => t.name).join(','));
    } else {
      const updatedTags = activeTags.map(t => {
        if (t.name === tag.name) { return { name: t.name, active: !t.active }; }
        if (t.name === ALL_OPTION_NAME) { return { name: t.name, active: false }; }
        return { name: t.name, active: t.active };
      });
      setOffset(0);
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
      setOffset(0);
      setQuerySectors(sectorsWithALLSelected.filter(s => s.active).map((s) => s.name).join(','));
    } else {
      const updatedSectors = activeSectors.map(s => {
        if (s.name === sector.name) { return { name: s.name, active: !s.active }; }
        if (s.name === ALL_OPTION_NAME) { return { name: s.name, active: false }; }
        return { name: s.name, active: s.active };
      });
      setOffset(0);
      setQuerySectors(updatedSectors.filter(s => s.active).map((s) => s.name).join(','));
    }
  };

  return (
    <div className={cx('filters__wrapper-margin', { 'filters__wrapper-background': isFilterOpen })}>
      <div className="container publications">
        <div className="filters__wrapper">
          <div className="showing-count">
            <p>Showing <strong>{resultsCount}</strong> items in <strong>All Publications, news and events</strong></p>
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
              <div className="filters__title">Type</div>
              <div className="filters__tags-container">
                {activeTypes.length && activeTypes.map(type => (
                  <button
                    type="button"
                    onClick={() => handleTypeClick(type)}
                    className={cx('filters__tag', {'filters__tag-selected': type.active})}
                  >
                    {type.name}
                  </button>
                ))}
              </div>
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
  types: PropTypes.array.isRequired,
  tags: PropTypes.array.isRequired,
  sectors: PropTypes.array.isRequired,
  resultsSize: PropTypes.number.isRequired
};

export default Filters;
