import React from 'react';
import PropTypes from 'prop-types';
import editIcon from 'images/icons/edit-icon.svg';

const ManageDataButton = ({ link }) => (
  <a href={link} target="_blank" rel="noopener noreferrer" className="manage-data__button-container">
    <img className="manage-data__icon" src={editIcon} alt="edit data" />
    <span className="manage-data__text">Manage data</span>
  </a>
);

ManageDataButton.propTypes = {
  link: PropTypes.string.isRequired
};

export default ManageDataButton;
