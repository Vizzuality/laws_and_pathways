import { useEffect } from 'react';

export default function useOutsideClick(element, action) {
  if (typeof action !== 'function') throw new Error('useOutsideClick expects action to be function');

  const handleClickOutside = event => {
    if (!element.current) return;
    if (!element.current.contains(event.target)) action();
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);
}
