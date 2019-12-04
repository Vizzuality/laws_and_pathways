import React, { useState } from "react";
import cx from 'classnames';
import qs from 'qs';
import filterIcon from '../../assets/images/icons/filter-white.svg';
import filterBlueIcon from '../../assets/images/icons/filter-blue.svg';

const Filters = ({ tags, activeTags, filtersOpen, activeSectors, sectors, resultsSize }) => {
  const [isFilterOpen, setIsFiltersOpen] = useState(filtersOpen);

  const buttonTitle = isFilterOpen ? 'Hide filters' : 'Show filters';

  const tagsWithAllOption = ['All', ...tags];
  const sectorsWithAlloption = ['All', ...sectors];

  const tagsMap = tagsWithAllOption.map(tag => ({
    name: tag,
    active: (activeTags && activeTags.length && activeTags.includes(tag))
      || (tag === 'All' && activeTags && !activeTags.length)
  }))

  const sectorsMap = sectorsWithAlloption.map(sector => ({
    name: sector,
    active: (activeSectors && activeSectors.length && activeSectors.includes(sector))
      || (sector === 'All' && activeSectors && !activeSectors.length)
  }))

  const handleButtonClick = () => {
    setIsFiltersOpen(!isFilterOpen);
  }

  const handleTagClick = (tag) => {
    const isAllClicked = tag.name === 'All';
    const otherOptions = tagsMap.filter(t => t.name !== 'All');
    const shouldALLbeSelected = isAllClicked && !!otherOptions.filter(o => o.active).length;

    const mapOfTags = tagsMap.map(originalTag => {
      if(originalTag.name === tag.name) { return { name: originalTag.name, active: !originalTag.active }; }
      else { return { name: originalTag.name, active: originalTag.active }; }
    })

    const currentQueryParams = window.location.search;
    const queryParams = qs.parse(currentQueryParams, { ignoreQueryPrefix: true });

    if (shouldALLbeSelected) {
      queryParams['activeTags'] = '';
      queryParams['filtersOpen'] = true;
      const stringifiedQuery = qs.stringify(queryParams);
      window.open(`/tpi/publications?${stringifiedQuery}`, "_self");
    } else {
      const activeTagsQueryParam = mapOfTags.filter(t => t.active && t.name !== 'All').map(t => t.name).join(', ');
    
      if (currentQueryParams) {
        queryParams['activeTags'] = activeTagsQueryParam;
        queryParams['filtersOpen'] = true;
        const stringifiedQuery = qs.stringify(queryParams);

        window.open(`/tpi/publications?${stringifiedQuery}`, "_self");
      } else {
        window.open(`/tpi/publications?activeTags=${activeTagsQueryParam}&filtersOpen=true`, "_self");
      }
    }
  }

  const handleSectorClick = (sector) => {
    const isAllClicked = sector.name === 'All';
    const otherOptions = sectorsMap.filter(s => s.name !== 'All');
    const shouldALLbeSelected = isAllClicked && !!otherOptions.filter(o => o.active).length;

    const mapOfSectors = sectorsMap.map(originalSector => {
      if(originalSector.name === sector.name) { return { name: originalSector.name, active: !originalSector.active }; }
      else { return { name: originalSector.name, active: originalSector.active }; }
    })

    const currentQueryParams = window.location.search;
    const queryParams = qs.parse(currentQueryParams, { ignoreQueryPrefix: true });

    if (shouldALLbeSelected) {
      queryParams['activeSectors'] = '';
      queryParams['filtersOpen'] = true;
      const stringifiedQuery = qs.stringify(queryParams);
      window.open(`/tpi/publications?${stringifiedQuery}`, "_self");
    } else {
      const activeSectorsQueryParam = mapOfSectors.filter(s => s.active && s.name !== 'All').map(s => s.name).join(', ');

      if (currentQueryParams) {
        queryParams['activeSectors'] = activeSectorsQueryParam;
        queryParams['filtersOpen'] = true;
        const stringifiedQuery = qs.stringify(queryParams);

        window.open(`/tpi/publications?${stringifiedQuery}`, "_self");
      } else {
        window.open(`/tpi/publications?activeSectors=${activeSectorsQueryParam}&filtersOpen=true`, "_self");
      }
    }
  }

  return (
    <div className={cx("filters__wrapper-margin", { ["filters__wrapper-background"]: isFilterOpen })}>
      <div className="container publications">
        <div className="filters__wrapper">
          <div className="">
            <p>Showing <strong>{resultsSize}</strong> items in <strong>All Publications and news</strong></p>
          </div>
          <div className="filters__button">
            <button className={cx("button is-centered", { ['filters__button-active']: !isFilterOpen, ['filters__button-notactive']: isFilterOpen} )} onClick={handleButtonClick}>
              <img
                src={isFilterOpen ? filterIcon : filterBlueIcon}
                className='filters__filter-icon'
              />
              <span>{buttonTitle}</span>
            </button>
          </div>
        </div>
        {isFilterOpen && <div className="filters__container">
          <div className="filters__title">Tag</div>
          <div className="filters__tags-container">
            {tagsMap.length && tagsMap.map(tag => (
              <button onClick={() => handleTagClick(tag)} className={cx("filters__tag", {["filters__tag-selected"]: tag.active})}>{tag.name}</button>
            ))}
          </div>
          <div className="filters__title">Sector</div>
          <div className="filters__tags-container">
            {sectorsMap.length && sectorsMap.map(sector => (
              <button onClick={() => handleSectorClick(sector)} className={cx("filters__tag", {["filters__tag-selected"]: sector.active})}>{sector.name}</button>
            ))}
          </div>
        </div>}
      </div>
    </div>
  )
}

export default Filters;
