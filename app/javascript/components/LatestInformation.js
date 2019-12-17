import React, { useState } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import plusIcon from 'images/icons/plus.svg';
import minusIcon from 'images/icons/minus.svg';

const LatestInformation = ({ company }) => {
  const [expanded, setExpanded] = useState(false);

  const buttonText = expanded ? 'Read less' : 'Read more';

  return (
    <section className="container latest-information__wrapper">
      <div className="latest-information__container">
        <h6 className="latest-information__header">Latest information available on {company.name}</h6>
        <p
          className={cx('latest-information__description', { 'latest-information__description--folded': !expanded })}
        >
          {company.latest_information}
        </p>
        <button onClick={() => setExpanded(!expanded)} type="button" className="latest-information__button-container">
          <img src={expanded ? minusIcon : plusIcon} className="latest-information__button" />
          <span className="latest-information__button-text">{buttonText}</span>
        </button>
      </div>
    </section>
  );
};

LatestInformation.propTypes = {
  company: PropTypes.shape({
    name: PropTypes.string.isRequired,
    latest_information: PropTypes.string.isRequired
  }).isRequired
};

export default LatestInformation;
