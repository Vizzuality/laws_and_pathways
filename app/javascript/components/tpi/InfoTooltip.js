import React from 'react';
import PropTypes from 'prop-types';
import ReactTooltip from 'react-tooltip';

const InfoTooltip = ({ trigger, content, html }) => (
  <div className="base-tooltip">
    {html ? <div data-tip={content} dangerouslySetInnerHTML={{ __html: trigger }} /> : <div data-tip={content}>{trigger}</div>}
    <ReactTooltip className="info-tooltip" />
  </div>
);

InfoTooltip.propTypes = {
  trigger: PropTypes.any,
  content: PropTypes.any.isRequired,
  html: PropTypes.bool
};

InfoTooltip.defaultProps = {
  trigger: (
    <span className="base-tooltip__default-trigger">?</span>
  ),
  html: false
};

export default InfoTooltip;
