import get from 'lodash/get';
import { useMemo } from 'react';
import cloneDeep from 'lodash/cloneDeep';
import { COLORS } from './options';

// get last emission also looking at targeted
// const getLastEmission = (d) => d.data && d.data.length && d.data.slice(-1)[0][1];
function getLastEmission(d) {
  const lastEmissionYear = get(d, 'data.zones[0].value');
  let lastEmission;
  if (!lastEmissionYear) {
    // get last emission
    lastEmission = d.data && d.data.length && d.data.slice(-1)[0][1];
  } else {
    lastEmission = d.data && d.data.length && d.data.find(x => x[0] === lastEmissionYear)[1];
  }
  return parseFloat(lastEmission, 10);
}

export function ensure10sorted(companyData) {
  return [...companyData]
    .sort((a, b) => getLastEmission(b) - getLastEmission(a))
    .slice(0, 10);
}

function applyColors(items) {
  return items.map((d, idx) => ({...d, color: COLORS[idx % 10]}));
}

export const useParsedChartData = (data, companySelector, selectedCompanies, selectedShowBy) => useMemo(
  () => {
    const benchmarks = data.filter(d => {
      const typeMatch = d.type === 'area';
      if (selectedShowBy?.value.includes('by_subsector')) {
        return typeMatch && d.subsector === selectedShowBy.value.replace('by_subsector_', '');
      }

      return typeMatch;
    });
    const restData = applyColors(
      companySelector
        ? selectedCompanies.map(c => data.find(d => get(d, 'company.name') === c))
        : data.filter(d => d.type !== 'area')
    );

    // do not why cloneDeep is needed, but highchart seems to mutate the data
    return cloneDeep([...benchmarks, ...restData]);
  },
  [data, companySelector, selectedCompanies, selectedShowBy]
);
