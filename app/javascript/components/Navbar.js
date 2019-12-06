import React, { useState, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';

const ESCAPE_KEY = 27;
const ENTER_KEY = 13;

const SearchComponent = ({ placeholder, action, closeSearchMode }) => {
  const input = useRef(null);
  const container = useRef(null);

  useEffect(() => input.current.focus());

  const handlePressEscape = event => {
    if (event.keyCode === ESCAPE_KEY) closeSearchMode();
  };

  const handlePressEnter = event => {
    const { origin } = window.location;
    const { value } = event.target;
    const path = origin + action;

    if (event.keyCode === ENTER_KEY && value && value.length > 0) {
      window.location.href = `${path}?query=${encodeURIComponent(value)}`;
    }
  };

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
        <input
          ref={input}
          type="text"
          className="navbar__search-input"
          placeholder={placeholder}
        />
        <a onClick={closeSearchMode} className="navbar__search--close">
          <span className="icon icon__close" />
        </a>
      </div>
    </div>
  );
};

SearchComponent.propTypes = {
  action: PropTypes.shape({
    placeholder: PropTypes.string.isRequired,
    action: PropTypes.string.isRequired
  }).isRequired,
  placeholder: PropTypes.string.isRequired,
  closeSearchMode: PropTypes.func.isRequired
};

const splitter = (key = '') => {
  const chunks = key.split('/');
  return chunks.length === 1 ? chunks.shift() : chunks.pop();
};

const checkActivePage = (current = {}, active = {}) => Object.values(current).find(
  currentKey => Object.values(active).find(
    activeKey => splitter(currentKey) === splitter(activeKey)
  )
);

const NavbarComponent = ({ items, openSearchMode, active }) => {
  const [tpi, publications, about, newsletter, login, search] = items;
  const [isOpen, setIsOpen] = useState(false);

  const currentActive = items.find(item => checkActivePage({
    controller: item.controller,
    action: item.action
  }, active));
  const controller = splitter(currentActive.controller);

  return (
    <div className="navbar" role="navigation" aria-label="main navigation">
      <div className="container">
        <div className="navbar-brand is-hidden-desktop">
          <a className="navbar-item" href="#">
            MENU
          </a>
          <a
            role="button"
            className={classnames('navbar-burger', {'is-active': isOpen})}
            onClick={() => setIsOpen(!isOpen)}
            aria-label="menu"
            aria-expanded="false"
            data-target="HeaderMenu"
          >
            <span aria-hidden="true" />
            <span aria-hidden="true" />
            <span aria-hidden="true" />
          </a>
        </div>
        <div
          id="HeaderMenu"
          className={classnames('navbar-menu', {'is-active': isOpen})}
        >
          <div className="navbar-start">
            <div className="navbar-item has-dropdown is-hoverable">
              <a
                className={classnames('navbar-link', 'is-arrowless', {
                  'is-active': controller === tpi.controller
                })}
              >
                {tpi.entry}
                <span className="icon icon__chevron-down" />
              </a>

              <div className="navbar-dropdown">
                {tpi.path && (
                  <a className="navbar-item" href={tpi.path}>
                    {tpi.entry}
                  </a>
                )}
                {tpi.content && (
                  tpi.content.map(({ slug, title }) => (
                    <a href={slug} className="navbar-item">
                      {title}
                    </a>
                  )))}
              </div>
            </div>

            <a
              href={publications.path}
              className={classnames('navbar-item', {
                'is-active': controller === publications.controller
              })}
            >
              {publications.entry}
            </a>

            <div
              className={classnames('navbar-item', 'has-dropdown', 'is-hoverable', {
                'is-active': controller === about.controller
              })}
            >
              <a
                className={classnames('navbar-link', 'is-arrowless', {
                  'is-active': controller === about.controller
                })}
              >
                {about.entry}
                <span className="icon icon__chevron-down" />
              </a>

              <div className="navbar-dropdown">
                {about.content && (
                  about.content.map(({ slug, title }) => (
                    <a href={slug} className="navbar-item">
                      {title}
                    </a>
                  )))}
              </div>
            </div>
          </div>

          <div className="navbar-end">
            <a
              href={newsletter.path}
              className={classnames('navbar-item', {
                'is-active': controller === newsletter.controller
              })}
            >
              {newsletter.entry}
            </a>
            <a className="navbar-item" href={login.path}>
              {login.entry}
            </a>
            <a
              className="navbar-item"
              aria-label={search.entry}
              onClick={openSearchMode}
            >
              {search.hasIcon && <span className="icon icon__search" />}
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

NavbarComponent.propTypes = {
  items: PropTypes.arrayOf(
    PropTypes.shape({
      controller: PropTypes.string,
      action: PropTypes.string,
      entry: PropTypes.string.isRequired,
      path: PropTypes.string,
      content: PropTypes.arrayOf(
        PropTypes.shape({
          title: PropTypes.string.isRequired,
          slug: PropTypes.string.isRequired
        })
      ),
      hasIcon: PropTypes.bool,
      className: PropTypes.string
    })
  ).isRequired,
  openSearchMode: PropTypes.func.isRequired,
  active: PropTypes.shape({
    controller: PropTypes.string.isRequired,
    action: PropTypes.string.isRequired
  }).isRequired
};

const Navbar = ({ items, controls, active }) => {
  const [searchMode, setSearchMode] = useState(false);
  const { search } = controls;

  const openSearchMode = () => setSearchMode(true);
  const closeSearchMode = () => setSearchMode(false);

  if (searchMode === true) {
    return (
      <header className="header">
        <SearchComponent {...search} closeSearchMode={closeSearchMode} />
      </header>
    );
  }

  return (
    <header className="header">
      <NavbarComponent
        items={items}
        openSearchMode={openSearchMode}
        active={active}
      />
    </header>
  );
};

Navbar.propTypes = {
  items: PropTypes.arrayOf(PropTypes.object).isRequired,
  controls: PropTypes.shape({
    search: PropTypes.object.isRequired
  }).isRequired,
  active: PropTypes.object.isRequired
};

export default Navbar;
