import { useEffect, useState } from 'react';

const SCROLL_POSITIONS = {
  notScrolled: 0,
  partiallyScrolled: 1,
  fullyScrolled: 2
};
export const useScrollClasses = () => {
  const [scrollPosition, setScrollPosition] = useState(
    SCROLL_POSITIONS.notScrolled
  );

  useScrollPosition(setScrollPosition);
  useAddScrollClass(scrollPosition);
};

export const useScrollPosition = (setScrollPosition) => {
  useEffect(() => {
    const handleTableScroll = () => {
      const tableContent = document.querySelector('.rc-table-body');
      if (!tableContent) return;
      const isScrolled = tableContent.scrollLeft > 0;
      const isNotFullyScrolled = tableContent.scrollLeft
      < tableContent.scrollWidth - tableContent.clientWidth - 1;

      let scroll = SCROLL_POSITIONS.notScrolled;
      if (isScrolled) {
        scroll = isNotFullyScrolled
          ? SCROLL_POSITIONS.partiallyScrolled
          : SCROLL_POSITIONS.fullyScrolled;
      }

      setScrollPosition(scroll);
    };

    const addTableScrollListener = () => {
      const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.addedNodes.length > 0) {
            const tableContent = document.querySelector('.rc-table-body');
            if (tableContent) {
              tableContent.addEventListener('scroll', handleTableScroll);
              observer.disconnect();
            }
          }
        });
      });
      observer.observe(document.body, { childList: true, subtree: true });
    };

    const removeTableScrollListener = () => {
      const tableContent = document.querySelector('.rc-table-body');
      if (tableContent) {
        tableContent.removeEventListener('scroll', handleTableScroll);
      }
    };

    addTableScrollListener();
    return () => {
      removeTableScrollListener();
    };
  }, [setScrollPosition]);
};

export const useAddScrollClass = (scrollPosition) => {
  // Add classes depending on the scroll
  useEffect(() => {
    const tableContent = document.querySelector('.rc-table-body');
    const tableHead = document.querySelector('.rc-table-header');
    const addClass = (element, className) => {
      const removedClass = className === 'fully-scrolled' ? 'partially-scrolled' : 'fully-scrolled';
      if (element) {
        element.classList.add(className);
        element.classList.remove(removedClass);
      }
    };
    const updateClasses = () => {
      if (tableContent) {
        if (scrollPosition === SCROLL_POSITIONS.partiallyScrolled) {
          addClass(tableContent, 'partially-scrolled');
          addClass(tableHead, 'partially-scrolled');
          return;
        }
        if (
          scrollPosition === SCROLL_POSITIONS.fullyScrolled
        ) {
          addClass(tableContent, 'fully-scrolled');
          addClass(tableHead, 'fully-scrolled');
          return;
        }

        tableContent.classList.remove('fully-scrolled');
        tableHead.classList.remove('fully-scrolled');
        tableContent.classList.remove('partially-scrolled');
        tableHead.classList.remove('partially-scrolled');
      }
    };
    updateClasses();
  }, [scrollPosition]);
};
