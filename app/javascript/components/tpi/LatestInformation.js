import React, { useState } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import plusIcon from 'images/icons/plus.svg';
import minusIcon from 'images/icons/minus.svg';

const LatestInformation = ({ name, latestInformation }) => {
  const [expanded, setExpanded] = useState(false);

  const buttonText = expanded ? 'Read less' : 'Read more';
  const textLength = latestInformation.length;
  const MAX_CHARACTERS_FOR_THREE_LINES = 270;
  const showButton = textLength > MAX_CHARACTERS_FOR_THREE_LINES;

  function parseLinks(text) {
    return (text || '').replace(
      /([^\S]|^)(((https?:\/\/)|(www\.))(\S+))/gi,

      function (_, space, url) {
        let link = url;
        if (!link.match('^https?:')) link = `http://${link}`;
        return `${space}<a target="_blank" rel="noopener noreferrer" href="${link}">${url}</a>`;
      }
    );
  }

  return (
    <section className="container latest-information__wrapper">
      <div className="latest-information__container">
        <h6 className="latest-information__header">Latest information available on {name}</h6>
        <p
          className={cx('latest-information__description', { 'latest-information__description--folded': showButton && !expanded })}
          dangerouslySetInnerHTML={{__html: parseLinks(latestInformation) }}
        />

        {showButton && (
          <button onClick={() => setExpanded(!expanded)} type="button" className="latest-information__button-container">
            <img src={expanded ? minusIcon : plusIcon} className="latest-information__button" alt="Toggle icon" />
            <span className="latest-information__button-text">{buttonText}</span>
          </button>
        )}
      </div>
    </section>
  );
};

LatestInformation.propTypes = {
  name: PropTypes.string.isRequired,
  latestInformation: PropTypes.string.isRequired
};

export default LatestInformation;
