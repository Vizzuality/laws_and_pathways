import React, {useState, useEffect, useRef} from 'react';
import PropTypes from 'prop-types';

const ESCAPE_KEY = 27;
const ENTER_KEY = 13;

const SearchComponent = ({placeholder, action, closeSearchMode}) => {
  const input = useRef(null);
  const container = useRef(null);

  useEffect(() => (input.current.focus()));

  const handlePressEscape = event => {
    if (event.keyCode === ESCAPE_KEY) {
      closeSearchMode();
    }
  };

  const handlePressEnter = event => {
    const {origin} = window.location;
    const {value} = event.target;
    const path = origin + action;

    if (event.keyCode === ENTER_KEY && value && value.length > 0) {
      window.location.href = `${path}?query=${encodeURIComponent(value)}`;
    }
  }

  const handleClickOutside = event => {
    if (!container.current.contains(event.target)) closeSearchMode();
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('keydown', handlePressEscape);
    document.addEventListener('keydown', handlePressEnter);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handlePressEscape);
      document.removeEventListener('keydown', handlePressEnter);
    };
  }, []);

  return (
    <div className="navbar__search">
      <div ref={container} className="container">
        <input ref={input} type="text" className="navbar__search-input" placeholder={placeholder} />
        <a onClick={closeSearchMode} className="navbar__search--close">
          <span className="icon icon__close"></span>
        </a>
      </div>
    </div>
  );
};

const NavbarComponent = ({items, openSearchMode}) => {
  const [tpi, publications, about, newsletter, login, search] = items;

  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="navbar" role="navigation" aria-label="main navigation">
      <div className="container">
        <div className="navbar-brand is-hidden-desktop">
          <a className="navbar-item" href="#">MENU</a>
          <a role="button"
            className={`navbar-burger ${isOpen ? 'is-active' : ''}`}
            onClick={() => setIsOpen(!isOpen)}
            aria-label="menu"
            aria-expanded="false"
            data-target="HeaderMenu"
          >
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
          </a>
        </div>
        <div id="HeaderMenu" className={`navbar-menu ${isOpen ? 'is-active' : ''}`}>
          <div className="navbar-start">
            <div className="navbar-item has-dropdown is-hoverable">
              <a className="navbar-link is-arrowless">
                {tpi.entry}
                <span className="icon icon__chevron-down"></span>
              </a>

              <div className="navbar-dropdown">
                {tpi.path && (
                  <a className="navbar-item" href={tpi.path}>{tpi.entry}</a>
                )}
                {tpi.content && tpi.content.map(({slug, title}) => (
                  <a href={slug} className="navbar-item">
                    {title}
                  </a>
                ))}
              </div>
            </div>

            <a className="navbar-item" href={publications.path}>{publications.entry}</a>

            <div className="navbar-item has-dropdown is-hoverable">
              <a className="navbar-link is-arrowless">
                {about.entry}
                <span className="icon icon__chevron-down"></span>
              </a>

              <div className="navbar-dropdown">
                {about.content && about.content.map(({slug, title}) => (
                  <a href={slug} className="navbar-item">
                    {title}
                  </a>
                ))}
              </div>
            </div>
          </div>

          <div className="navbar-end">
            <a className="navbar-item" href={newsletter.path}>{newsletter.entry}</a>
            <a className="navbar-item" href={login.path}>{login.entry}</a>
            <a className="navbar-item" aria-label={search.entry} onClick={openSearchMode}>
              {search.hasIcon && (
                <span className="icon icon__search"></span>
              )}
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

const Navbar = ({items, controls}) => {
  const [searchMode, setSearchMode] = useState(false);
  const {search} = controls;

  const openSearchMode = () => (setSearchMode(true));
  const closeSearchMode = () => (setSearchMode(false));

  if (searchMode === true) return (
    <header className="header">
      <SearchComponent {...search} closeSearchMode={closeSearchMode} />
    </header>
  );

  return (
    <header className="header">
      <NavbarComponent items={items} openSearchMode={openSearchMode} />
    </header>
  );
}

Navbar.propTypes = {
  items: PropTypes.arrayOf(PropTypes.shape({
    entry: PropTypes.string.isRequired,
    path: PropTypes.string,
    content: PropTypes.arrayOf(PropTypes.shape({
      title: PropTypes.string.isRequired,
      slug: PropTypes.string.isRequired,
    })),
    hasIcon: PropTypes.bool,
    className: PropTypes.string,
  })).isRequired,
  controls: PropTypes.shape({
    search: PropTypes.shape({
      placeholder: PropTypes.string.isRequired,
      action: PropTypes.string.isRequired,
    }),
  }),
};

export default Navbar;
