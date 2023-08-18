/* eslint-disable operator-linebreak */
import React, { useState, useRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import CustomModal from './Modal';
import { OverlayProvider } from '@react-aria/overlays';

const TPI_MODAL_DISMISSED = 'TPI_MODAL_DISMISSED';
const TPI_MODAL_PAGES_SHOWN = 'TPI_MODAL_PAGES_SHOWN';

const MqBetaModal = ({ enabled, page }) => {
  const [displayed, setDisplayed] = useState(false);

  const isDismissed = localStorage.getItem(TPI_MODAL_DISMISSED);
  const pagesShown = localStorage.getItem(TPI_MODAL_PAGES_SHOWN);
  const hasBeenShownInPage =
    pagesShown?.includes(page) ||
    (page === 'company' && pagesShown?.includes('companies'));
  const [popupDismissed, setPopupDismissed] = useState(
    JSON.parse(isDismissed) || false
  );

  const mainButtonRef = useRef();

  // Put focus on the Proceed button on render
  useEffect(() => {
    if (mainButtonRef.current) {
      mainButtonRef.current.focus();
    }
  }, [mainButtonRef]);

  if (popupDismissed || hasBeenShownInPage) {
    return null;
  }

  const handleOnRequestClose = () => {
    setDisplayed(true);
    localStorage.setItem(
      TPI_MODAL_PAGES_SHOWN,
      pagesShown ? `${pagesShown},${page}` : page
    );
  };

  const handleDoNotShowAgain = () => {
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
          <button
            type="button"
            className="close-btn"
            onClick={handleOnRequestClose}
            aria-label="Proceed with Management Quality (MQ) methodology preview"
          >
            <div className="icon__close" />
          </button>
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
          <div className="actions">
            <button
              type="button"
              className="button is-primary"
              onClick={handleOnRequestClose}
              ref={mainButtonRef}
            >
              Proceed
            </button>
            <button
              type="button"
              className="button is-secondary margin-left"
              onClick={handleDoNotShowAgain}
            >
              Don&apos;t show this again
            </button>
          </div>
        </div>
      </CustomModal>
    </OverlayProvider>
  );
};

MqBetaModal.propTypes = {
  enabled: PropTypes.bool.isRequired,
  page: PropTypes.oneOf(['sector', 'company', 'companies']).isRequired
};

export default MqBetaModal;
