import { useEffect, useState } from 'react';

export function useChartData(dataUrl) {
  const [data, setData] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(dataUrl)
      .then((r) => r.json())
      .then((chartData) => {
        setLoading(false);
        setData(chartData);
      })
      .catch(() => {
        setLoading(false);
        setError('Error while loading the data');
      });
  }, [dataUrl]);

  return {
    data,
    error,
    loading
  };
}
