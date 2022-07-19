import React, { useState, useEffect } from 'react';
import cx from 'classnames';

const BankingQuestionLegend = () => {
  const [isVisible, setVisible] = useState(false);

  const isChecked = () => {
    let anyChecked = false;

    document.querySelectorAll('.bank-assessment > input.toggle').forEach((input) => {
      anyChecked = anyChecked || input.checked;
    });

    setVisible(anyChecked);
  };

  useEffect(() => {
    const eventListeners = [];
    document.querySelectorAll('.bank-assessment > input.toggle').forEach((input) => {
      const listener = input.addEventListener('click', isChecked);
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
      <div className="banking-question-legend__header">
        Legend
      </div>
      <div className="banking-question-legend__content">
        <div className="banking-question-legend-answer banking-question-legend-answer--yes">
          Yes
        </div>
        <div className="banking-question-legend-answer banking-question-legend-answer--no">
          No
        </div>
        <div className="banking-question-legend-answer banking-question-legend-answer--not-applicable">
          Not applicable
        </div>
      </div>
    </div>
  );
};

BankingQuestionLegend.propTypes = {
};

export default BankingQuestionLegend;
