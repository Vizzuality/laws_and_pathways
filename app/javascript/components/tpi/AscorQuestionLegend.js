import React, { useState, useEffect } from 'react';
import cx from 'classnames';

const AscorQuestionLegend = () => {
  const [isVisible, setVisible] = useState(false);

  const isCheckedArea = () => {
    let anyChecked = false;

    document
      .querySelectorAll('.country-assessment > .country-assessment__pillar')
      .forEach((section) => {
        let areaChecked = false;

        section.querySelectorAll('.country-assessment__areas > input.toggle').forEach((input) => {
          areaChecked = areaChecked || input.checked;
          anyChecked = anyChecked || input.checked;
        });
        return areaChecked
          ? section.classList.add('active')
          : section.classList.remove('active');
      });
  };

  const isCheckedPillar = () => {
    let anyChecked = false;

    document.querySelectorAll('.country-assessment > input.toggle.pillar').forEach((input) => {
      anyChecked = anyChecked || input.checked;
    });

    setVisible(anyChecked);
  };

  useEffect(() => {
    const eventListeners = [];
    document
      .querySelectorAll(
        '.country-assessment .country-assessment__areas > input.toggle'
      )
      .forEach((input) => {
        const listener = input.addEventListener('click', isCheckedArea);
        eventListeners.push([input, listener]);
      });

    document
      .querySelectorAll(
        '.country-assessment > input.toggle.pillar'
      )
      .forEach((input) => {
        const listener = input.addEventListener('click', isCheckedPillar);
        eventListeners.push([input, listener]);
      });

    return () => {
      eventListeners.forEach(([input, listener]) => {
        input.removeEventListener('click', listener);
      });
    };
  });

  return (
    <div className={cx('banking-question-legend', { 'banking-question-legend--active': isVisible })}>
      <div className="banking-question-legend__header">Legend</div>
      <div className="country-question-legend__content">
        <div className="country-question-legend-answer country-question-legend-answer--no">
          No
        </div>
        <div className="country-question-legend-answer country-question-legend-answer--partial">
          Partial
        </div>
        <div className="country-question-legend-answer country-question-legend-answer--yes">
          Yes
        </div>
        <div className="country-question-legend-answer country-question-legend-answer--no-data">
          No data
        </div>
        <div className="country-question-legend-answer country-question-legend-answer--not-applicable">
          Not applicable
        </div>
        <div className="country-question-legend-answer country-question-legend-answer--no-disclosure">
          No disclosure
        </div>
        <div className="country-question-legend-answer country-question-legend-answer--excempt">
          Exempt
        </div>
      </div>
    </div>
  );
};

AscorQuestionLegend.propTypes = {};

export default AscorQuestionLegend;
