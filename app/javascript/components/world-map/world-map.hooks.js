import { useMemo } from 'react';
import { scaleLinear, scaleThreshold } from 'd3-scale';
import { ckmeans } from 'simple-statistics';
import centroids from './centroids';

import { BUBBLE_MIN_RADIUS, BUBBLE_MAX_RADIUS, COLOR_RAMPS } from './constants';

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

    const sizeScale = scaleLinear()
      .domain([minSize, maxSize])
      .range([BUBBLE_MIN_RADIUS, BUBBLE_MAX_RADIUS]);

    const byCkMeans = ckmeans(allColorValues, COLOR_RAMPS[layer.ramp].length);
    const ckMeansThresholds = byCkMeans.map(bucket => bucket[bucket.length - 1]);

    const colorScale = scaleThreshold()
      .domain(ckMeansThresholds)
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
      ramp: selectedContext.ramp,
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
