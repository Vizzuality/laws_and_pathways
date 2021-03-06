import React, {useState, useEffect, useRef} from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';

const SLIDE_DELAY = 8000;

// from https://overreacted.io/making-setinterval-declarative-with-react-hooks/
function useInterval(callback, delay) {
  const savedCallback = useRef();

  // Remember the latest callback.
  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  // Set up the interval.
  useEffect(() => {
    function tick() {
      savedCallback.current();
    }

    if (delay !== null) {
      const timer = setInterval(tick, delay);
      return () => clearInterval(timer);
    }

    return () => {};
  }, [delay]);
}

const nextPage = (current, total) => (current === total ? 0 : current + 1);
const previousPage = (current, total) => (current === 0 ? total : current - 1);

const Controls = ({changePage}) => (
  <>
    <a
      onClick={() => changePage(previousPage)}
      className="is-hidden-touch testimonials__control left"
    >&#8592;
    </a>
    <a
      onClick={() => changePage(nextPage)}
      className="is-hidden-touch testimonials__control right"
    >&#8594;
    </a>
  </>
);

Controls.propTypes = {
  changePage: PropTypes.func.isRequired
};

const Quote = ({message, author, role, handleClick}) => (
  <div className="column is-8" onClick={handleClick}>
    <div className="testimonials__content">
      {message.map((p, i) => (
        <p key={`paragraph-${i}`}>{p}</p>
      ))}
    </div>

    <div className="testimonials__author">
      <p>{author}</p>
      {role && <p>{role}</p>}
    </div>
  </div>
);

Quote.propTypes = {
  message: PropTypes.arrayOf(PropTypes.string).isRequired,
  author: PropTypes.string.isRequired,
  role: PropTypes.string.isRequired,
  handleClick: PropTypes.func.isRequired
};

const Pagination = ({page, quotes, changePage}) => (
  <div className="testimonials__pagination">
    {quotes.map((_, i) => (
      <a
        key={`page-${i}`}
        className={classnames('page', {active: i === page})}
        onClick={() => changePage(() => i)}
      />
    ))}
  </div>
);

Pagination.propTypes = {
  page: PropTypes.number.isRequired,
  quotes: PropTypes.array.isRequired,
  changePage: PropTypes.func.isRequired
};

const Testimonials = ({testimonials, quote_path}) => {
  const [state, setState] = useState({
    current: 0,
    isRunning: true
  });
  const {current, isRunning} = state;
  const {message, author, role} = testimonials[current];
  const totalQuotes = testimonials.length - 1;

  const changePage = (callback) => {
    setState({
      ...state,
      current: callback(current, totalQuotes)
    });
  };

  const stopChangePage = () => {
    setState({...state, isRunning: !isRunning});
  };

  useInterval(() => {
    setState({
      ...state,
      current: nextPage(current, totalQuotes)
    });
  }, isRunning ? SLIDE_DELAY : null);

  return (
    <div className="testimonials__container">
      <Controls changePage={changePage} />
      <div className="columns">
        <div className="column is-2 testimonials__quote">
          <img src={quote_path} alt="quote" />
        </div>

        <Quote
          author={author}
          role={role}
          message={message}
          handleClick={stopChangePage}
        />

        <Pagination
          page={current}
          quotes={testimonials}
          changePage={changePage}
        />
      </div>
    </div>
  );
};

Testimonials.defaultProps = {
  testimonials: []
};

Testimonials.propTypes = {
  testimonials: PropTypes.array,
  quote_path: PropTypes.string.isRequired
};

export default Testimonials;
