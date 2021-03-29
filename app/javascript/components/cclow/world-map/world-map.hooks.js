import { useMemo } from 'react';
import { scaleLinear, scaleThreshold } from 'd3-scale';
import { ckmeans } from 'simple-statistics';
import centroids from './centroids';

import { BUBBLE_MIN_RADIUS, BUBBLE_MAX_RADIUS, COLOR_RAMPS, EU_COUNTRIES, EU_ISO } from './constants';

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

export function useCombinedLayer(selectedContext, selectedContent, isEUAggregated = false) {
  return useMemo(() => {
    if (!selectedContext || !selectedContent) return null;

    const features = [];

    selectedContext.values.forEach(cx => {
      const contentValue = selectedContent.values.find(cxv => cxv.geography_iso === cx.geography_iso);

      if (!contentValue) return;
      if (features.find(f => f.iso === cx.geography_iso)) return;

      features.push({
        iso: cx.geography_iso,
        contentValue: contentValue.value,
        contextValue: cx.value
      });
    });

    return {
      ramp: selectedContext.ramp,
      features
    };
  }, [selectedContext, selectedContent, isEUAggregated]);
}

export function useMarkers(activeLayer, scales, isEUAggregated = false) {
  return useMemo(() => {
    if (!activeLayer) return null;

    const { sizeScale, colorScale } = scales;

    const features = activeLayer
      .features
      .map(feature => {
        if ((isEUAggregated && EU_COUNTRIES.includes(feature.iso)) || (!isEUAggregated && feature.iso === EU_ISO)) return null;
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

    return features;
  }, [activeLayer, scales, isEUAggregated]);
}
