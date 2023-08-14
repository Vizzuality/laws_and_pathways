import React, { useState } from 'react';
import PropTypes from 'prop-types';
import CustomModal from './Modal';
import { OverlayProvider } from '@react-aria/overlays';

const TPI_MODAL_DISMISSED = 'TPI_MODAL_DISMISSED';

const MqBetaModal = ({ enabled }) => {
  const [displayed, setDisplayed] = useState(false);

  const isDismissed = localStorage.getItem(TPI_MODAL_DISMISSED);
  const [popupDismissed, setPopupDismissed] = useState(
    JSON.parse(isDismissed) || false
  );

  if (popupDismissed) {
    return null;
  }

  const handleOnRequestClose = () => {
    setDisplayed(true);
    setPopupDismissed(true);
    localStorage.setItem(TPI_MODAL_DISMISSED, true);
  };

  return (
    <OverlayProvider>
      <CustomModal
        open={enabled && !displayed}
        onClose={handleOnRequestClose}
        title="Management Quality (MQ) methodology"
      >
        <div>
          <div className="close-btn" data-action="click->cookies-consent#close">
            <div className="icon__close" />
          </div>
          <div className="modal-title">Management Quality (MQ) methodology</div>
          <div className="content">
            <p>
              The TPI Centre&apos;s is in the process of developing an update
              its Management Quality (MQ) methodology, which will be version
              5.0.
            </p>
            <p>
              By clicking &quot;Proceed&quot; you are now accessing a preview of
              this data. Please note, this is an additional data service and
              will not replace the current methodology until further notice.
            </p>
            <p>
              Data from the current framework will remain available on the
              website at least until 2024.
            </p>
            <p>
              The detailed methodology note behind MQ methodology version 5.0,
              including a section discussing methodological differences between
              version 5.0 and 4.0, can be found here.
            </p>
            <p>
              Carbon Performance assessments are not affected by using this
              toggle.
            </p>
          </div>
          <button
            type="button"
            className="button is-primary"
            onClick={handleOnRequestClose}
          >
            Proceed
          </button>
        </div>
      </CustomModal>
    </OverlayProvider>
  );
};

MqBetaModal.propTypes = {
  enabled: PropTypes.bool.isRequired
};

export default MqBetaModal;
