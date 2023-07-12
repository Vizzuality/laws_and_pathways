import { useEffect, useRef } from 'react';

// from https://overreacted.io/making-setinterval-declarative-with-react-hooks/
export default function useInterval(callback, delay) {
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
