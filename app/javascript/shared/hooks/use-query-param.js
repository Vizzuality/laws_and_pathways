import { useState, useCallback } from 'react';

function getQueryStringValue(key) {
  const params = new URLSearchParams(window.location.search);
  return params.get(key);
}

function setQueryStringValue(key, value) {
  const params = new URLSearchParams(window.location.search);
  params.set(key, value);
  const url = `${window.location.pathname}?${params}`;
  window.history.replaceState({}, null, url);
}

export default function useQueryParam(key, initialValue) {
  const [value, setValue] = useState(getQueryStringValue(key) || initialValue);
  const onSetValue = useCallback(
    newValue => {
      setValue(newValue);
      setQueryStringValue(key, newValue);
    },
    [key]
  );

  return [value, onSetValue];
}
