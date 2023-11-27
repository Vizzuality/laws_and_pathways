import React, { useEffect } from 'react';

const AscorQuestionLegend = () => {
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

    return () => {
      eventListeners.forEach(([input, listener]) => {
        input.removeEventListener('click', listener);
      });
    };
  });

  return (
    <div className="banking-question-legend banking-question-legend--active">
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
        <div className="country-question-legend-answer country-question-legend-answer--exempt">
          Exempt
        </div>
      </div>
    </div>
  );
};

AscorQuestionLegend.propTypes = {};

export default AscorQuestionLegend;
