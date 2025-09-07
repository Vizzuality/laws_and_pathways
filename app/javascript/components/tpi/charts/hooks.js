import { isEmpty } from 'lodash';
import { useEffect, useState } from 'react';

export function useChartData(dataUrl, params = {}) {
  const [data, setData] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  const paramSeparator = containsParams(dataUrl) ? '&' : '?';
  const url = isEmpty(params)
    ? dataUrl
    : `${dataUrl}${paramSeparator}${new URLSearchParams(params)}`;

  useEffect(() => {
    if (!dataUrl) {
      setLoading(false);
      setError('No data URL provided');
      return;
    }

    fetch(url)
      .then((r) => r.json())
      .then((chartData) => {
        setLoading(false);
        setData(chartData);
      })
      .catch(() => {
        setLoading(false);
        setError('Error while loading the data');
      });
  }, [url, dataUrl]);

  return {
    data,
    error,
    loading
  };
}

function containsParams(dataUrl) {
  return dataUrl && dataUrl.includes('?');
}
