import React, { useState, useEffect } from 'react';
import cx from 'classnames';
import PropTypes from 'prop-types';
import filterIcon from '../../assets/images/icons/filter-white.svg';
import filterBlueIcon from '../../assets/images/icons/filter-blue.svg';

const ALL_OPTION_NAME = 'All';

const Filters = ({ tags, sectors, resultsSize }) => {
  const [isFilterOpen, setIsFiltersOpen] = useState(false);
  const [resultsCount, setResultsCount] = useState(resultsSize);

  const tagsWithAllOption = [ALL_OPTION_NAME, ...tags];
  const sectorsWithAlloption = [ALL_OPTION_NAME, ...sectors];

  const defaultActiveTags = tagsWithAllOption.map(tag => ({
    name: tag,
    active: tag === ALL_OPTION_NAME
  }));

  const defaultActiveSectors = sectorsWithAlloption.map(sector => ({
    name: sector,
    active: sector === ALL_OPTION_NAME
  }));

  const [activeTags, setActiveTags] = useState(defaultActiveTags);
  const [activeSectors, setActiveSectors] = useState(defaultActiveSectors);

  const isAllClicked = (option) => option.name === ALL_OPTION_NAME;
  const isAllSelected = (options) => options.filter(o => o.active).length === 0;
  const optionsWithoutALL = (options) => options.filter(t => t.name !== ALL_OPTION_NAME);
  const isOtherOptionsActive = (options) => !!options.filter(o => o.active).length;

  const buttonTitle = isFilterOpen ? 'Hide filters' : 'Show filters';

  const handleButtonClick = () => {
    setIsFiltersOpen(!isFilterOpen);
  };

  const refreshPublicationsHtml = (query) => {
    const url = `/tpi/publications/partial?${query}`;

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
      .map(t => t.name)
      .join(', ');
    const activeSectorsQueryParam = activeSectors
      .filter(s => s.active && s.name !== ALL_OPTION_NAME)
      .map(s => s.name)
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
      setActiveTags(tagsWithALLSelected);
    } else {
      const updatedTags = activeTags.map(t => {
        if (t.name === tag.name) { return { name: t.name, active: !t.active }; }
        if (t.name === ALL_OPTION_NAME) { return { name: t.name, active: false }; }
        return { name: t.name, active: t.active };
      });
      setActiveTags(updatedTags);
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
      setActiveSectors(sectorsWithALLSelected);
    } else {
      const updatedSectors = activeSectors.map(s => {
        if (s.name === sector.name) { return { name: s.name, active: !s.active }; }
        if (s.name === ALL_OPTION_NAME) { return { name: s.name, active: false }; }
        return { name: s.name, active: s.active };
      });
      setActiveSectors(updatedSectors);
    }
  };

  return (
    <div className={cx('filters__wrapper-margin', { 'filters__wrapper-background': isFilterOpen })}>
      <div className="container publications">
        <div className="filters__wrapper">
          <div className="">
            <p>Showing <strong>{resultsCount}</strong> items in <strong>All Publications and news</strong></p>
          </div>
          <div className="filters__button">
            <button
              type="button"
              className={cx('button is-centered', { 'filters__button-active': !isFilterOpen, 'filters__button-notactive': isFilterOpen})}
              onClick={handleButtonClick}
            >
              <img
                src={isFilterOpen ? filterIcon : filterBlueIcon}
                className="filters__filter-icon"
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
