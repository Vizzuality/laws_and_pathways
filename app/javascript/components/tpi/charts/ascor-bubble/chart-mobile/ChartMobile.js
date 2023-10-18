import React, { useState } from 'react';
import PropTypes from 'prop-types';
import chevronIcon from 'images/icons/white-chevron-down.svg';
import chevronIconBlack from 'images/icon_chevron_dark/chevron_down_black-1.svg';
import { SCORE_RANGES } from '../constants';

const Item = ({ title, children, className, isOpen, onOpen, icon }) => (
  <li>
    <div
      className={`country-bubble-mobile__item ${className} ${isOpen ? '--open' : ''}`}
      onClick={onOpen}
    >
      <span>{title}</span>
      <img
        className="chevron-icon"
        style={{
          transform: !isOpen ? 'rotate(180deg)' : 'rotate(0deg)'
        }}
        src={icon}
        alt="chevron"
      />
    </div>
    <div
      style={{
        display: isOpen ? 'block' : 'none'
      }}
    >
      {children}
    </div>
  </li>
);

Item.propTypes = {
  title: PropTypes.string.isRequired,
  className: PropTypes.string,
  children: PropTypes.node,
  onOpen: PropTypes.func.isRequired,
  isOpen: PropTypes.bool,
  icon: PropTypes.string.isRequired
};
Item.defaultProps = {
  className: '',
  children: null,
  isOpen: false
};

const ResultItem = ({ result, i }) => {
  const [isOpen, setIsOpen] = useState(false);
  {
    const color = Object.values(SCORE_RANGES)[i];
    const title = `${result.length} countries`;

    return (
      <li
        key={title}
        className={`country-bubble-mobile__item__result ${
          isOpen ? '--open' : ''
        }`}
      >
        <div
          className="country-bubble-mobile__item__result__title"
          onClick={() => setIsOpen((prevState) => !prevState)}
        >
          <div
            style={{
              backgroundColor: color
            }}
          />
          {!isOpen && <span>{title}</span>}
        </div>

        {isOpen && (
          <ul className="country-bubble-mobile__item__result__countries">
            {result.length ? (
              result.map((country) => (
                <li key={country.country_name}>{country.country_name}</li>
              ))
            ) : (
              <li>No countries</li>
            )}
          </ul>
        )}
      </li>
    );
  }
};

const ChartMobile = ({ data }) => {
  const [openPillars, setOpenPillars] = useState([]);
  const [openAreas, setOpenAreas] = useState([]);

  const handleOpenAreas = (key) => {
    setOpenAreas((prevState) => {
      if (prevState.includes(key)) {
        return prevState.filter((area) => area !== key);
      }
      return [...prevState, key];
    });
  };

  const handleOpenPillars = (key) => {
    if (openPillars.includes(key)) {
      setOpenPillars((prevState) => prevState.filter((pillar) => pillar !== key));
      setOpenAreas((prevState) => prevState.filter((area) => !area.includes(`${key}.`)));
      return;
    }
    setOpenPillars((prevState) => [...prevState, key]);
  };

  return (
    <div className="country-bubble-mobile">
      <ul>
        {data.map((pillar) => (
          <Item
            key={pillar.pillar}
            className="--pillar"
            title={pillar.pillar}
            isOpen={openPillars.includes(pillar.pillar)}
            onOpen={() => handleOpenPillars(pillar.pillar)}
            icon={chevronIcon}
          >
            <ul>
              {pillar.values.map((area, areaIndex) => {
                const pillarAcronym = pillar.pillar
                  .split(' ')
                  .map((word) => word[0])
                  .join('');
                const title = `${pillarAcronym} ${areaIndex + 1}. ${area.area}`;
                return (
                  <Item
                    className="--area"
                    isOpen={openAreas.includes(`${pillar.pillar}.${area.area}`)}
                    title={title}
                    key={area.area}
                    onOpen={() => handleOpenAreas(`${pillar.pillar}.${area.area}`)}
                    icon={chevronIconBlack}
                  >
                    <ul className="country-bubble-mobile__countries">
                      {area.values.map((result, i) => (
                        <ResultItem key={i} result={result} i={i} />
                      ))}
                    </ul>
                  </Item>
                );
              })}
            </ul>
          </Item>
        ))}
      </ul>
    </div>
  );
};

ChartMobile.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      pillar: PropTypes.string,
      values: PropTypes.arrayOf(
        PropTypes.shape({
          area: PropTypes.string,
          values: PropTypes.array
        })
      )
    })
  )
};

ChartMobile.defaultProps = {
  data: []
};

export default ChartMobile;
