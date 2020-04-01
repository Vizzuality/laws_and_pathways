import qs from 'qs';

export function getQueryFilters() {
  return qs.parse(window.location.search.slice(1));
}

export function useInteger(element) {
  if (!element) return null;

  return parseInt(element, 10);
}

export function useIntegerArray(element) {
  return (element || []).map(x => parseInt(x, 10));
}

export function useStringArray(element) {
  return (element || []).map(String);
}
