import PropTypes from 'prop-types';
import CustomModal from './Modal';
import { OverlayProvider } from '@react-aria/overlays';
import React, {useEffect, useState} from 'react';

const InfoModal = ({ title, text, element }) => {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const eventListeners = [];
    document.querySelectorAll(element).forEach((input) => {
      const listener = input.addEventListener('click', handleOnRequestOpen);
      eventListeners.push([input, listener]);
    });

    return () => {
      eventListeners.forEach(([input, listener]) => {
        input.removeEventListener('click', listener);
      });
    };
  });

  const handleOnRequestOpen = () => {
    setVisible(true);
  };

  const handleOnRequestClose = () => {
    setVisible(false);
  };

  return (
    <OverlayProvider>
      <CustomModal
        open={visible}
        onClose={handleOnRequestClose}
        title={title}
      >
        <div>
          <button
            type="button"
            className="close-btn"
            onClick={handleOnRequestClose}
            aria-label="Proceed with Management Quality (MQ) methodology preview"
          >
            <div className="icon__close" />
          </button>
          <div className="modal-title">{title}</div>
          <div className="content" dangerouslySetInnerHTML={{__html: text}} />
        </div>
      </CustomModal>
    </OverlayProvider>
  );
};

InfoModal.propTypes = {
  title: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  element: PropTypes.string.isRequired
};

export default InfoModal;
