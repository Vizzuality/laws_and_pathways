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

export function useScale(layer) {
  return useMemo(() => {
    if (!layer) return null;

    const allSizeValues = [];
    const allColorValues = [];
    layer.features.forEach(i => {
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
      .range(COLOR_RAMPS[layer.ramp]);

    return { sizeScale, colorScale };
  }, [layer]);
}

export function useCombinedLayer(selectedContext, selectedContent) {
  return useMemo(() => {
    if (!selectedContext || !selectedContent) return null;

    const features = selectedContext.values.map(cx => {
      const contentValue = selectedContent.values.find(cxv => cxv.geography_iso === cx.geography_iso);

      if (!contentValue) return null;

      return {
        iso: cx.geography_iso,
        contentValue: contentValue.value,
        contextValue: cx.value
      };
    }).filter(x => x);

    return {
      ramp: 'emissions',
      features
    };
  }, [selectedContext, selectedContent]);
}

export function useMarkers(activeLayer, scales) {
  return useMemo(() => {
    if (!activeLayer) return null;

    const { sizeScale, colorScale } = scales;

    return activeLayer
      .features
      .map(feature => {
        const coordinates = centroids[feature.iso];

        if (!coordinates) return null;

        return {
          iso: feature.iso,
          weight: sizeScale(feature.contentValue),
          color: colorScale(feature.contextValue),
          coordinates
        };
      })
      .filter(x => x);
  }, [activeLayer]);
}
