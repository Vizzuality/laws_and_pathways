import { useMemo } from 'react';
import { scaleDivergingSqrt, scaleQuantize } from 'd3-scale';
import centroids from './centroids';

const COLOR_RAMPS = {
  risk: [
    '#FCDE9C',
    '#FCBC81',
    '#FC9764',
    '#FC6C42',
    '#F04129',
    '#D22228',
    '#B10226'
  ],
  emissions: [
    '#FCDE9C',
    '#BEC5A9',
    '#8DA8AD',
    '#668BA8',
    '#466A9F',
    '#2C4B93',
    '#062A89'
  ]
};

export function useMarkers(layers, activeLayerId) {
  const getScales = (items, ramp) => {
    const allSizeValues = [];
    const allColorValues = [];
    items.forEach(i => {
      allSizeValues.push(i.contentValue);
      allColorValues.push(i.contextValue);
    });
    const maxSize = Math.max(...allSizeValues) + 1;
    const minSize = Math.min(...allSizeValues);

    const maxColor = Math.max(...allColorValues) + 1;
    const minColor = Math.min(...allColorValues);

    const sizeScale = scaleDivergingSqrt()
      .domain([minSize, maxSize])
      .range([4, 24]);

    const colorScale = scaleQuantize()
      .domain([minColor, maxColor])
      .range(COLOR_RAMPS[ramp]);

    return { sizeScale, colorScale };
  };

  return useMemo(() => {
    const activeLayer = layers.find(l => l.id === activeLayerId);
    const { sizeScale, colorScale } = getScales(
      activeLayer.features,
      activeLayer.ramp
    );
    return activeLayer.features.map(feature => ({
      iso: feature.iso,
      weight: sizeScale(feature.contentValue),
      color: colorScale(feature.contextValue),
      coordinates: centroids[feature.iso]
    }));
  }, [activeLayerId, layers]);
}
