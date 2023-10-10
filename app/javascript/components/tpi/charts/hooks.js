import { isEmpty } from 'lodash';
import { useEffect, useState } from 'react';

export function useChartData(dataUrl, params = {}) {
  const [data, setData] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  const url = isEmpty(params)
    ? dataUrl
    : `${dataUrl}?${new URLSearchParams(params)}`;

  useEffect(() => {
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
  }, [url]);

  return {
    data,
    error,
    loading
  };
}
