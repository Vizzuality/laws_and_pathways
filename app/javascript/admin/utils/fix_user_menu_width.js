const fixUserMenuWidth = () => {
  const menuElements = document.querySelectorAll('#utility_nav > li');

  if (menuElements && menuElements.length) {
    let maxWidth = 0;

    menuElements.forEach((el) => {
      if (el.clientWidth > maxWidth) maxWidth = el.clientWidth;
    });
    menuElements.forEach((el) => {
      el.style.width = `${maxWidth}px`; /* eslint-disable-line no-param-reassign */
    });
  }
};

document.addEventListener('DOMContentLoaded', fixUserMenuWidth);
document.addEventListener('turbolinks:load', fixUserMenuWidth);
