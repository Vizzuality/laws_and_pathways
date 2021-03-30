import qs from 'qs';

export function getQueryFilters() {
  return qs.parse(window.location.search.slice(1));
}

export function paramInteger(element) {
  if (!element) return null;

  return parseInt(element, 10);
}

export function paramIntegerArray(element) {
  return (element || []).map(x => parseInt(x, 10));
}

export function paramStringArray(element) {
  return (element || []).map(String);
}
