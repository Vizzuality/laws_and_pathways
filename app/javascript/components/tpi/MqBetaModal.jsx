/* eslint-disable operator-linebreak */
import React, { useState, useRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import CustomModal from './Modal';
import { OverlayProvider } from '@react-aria/overlays';

const TPI_MODAL_DISMISSED = 'TPI_MODAL_DISMISSED';
const TPI_MODAL_PAGES_SHOWN = 'TPI_MODAL_PAGES_SHOWN';
const MQ_REPORT_PUBLICATION_LINK = '/static_files/Raising the Bar. TPI\'s new Management Quality framework.pdf';

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
          <div className="modal-title">Management Quality methodology</div>
          <div className="content">
            <p>
              TPI Centre has developed an update to its Management Quality
              (MQ) methodology, which is displayed here as a BETA methodology.
            </p>
            <p>
              By clicking &quot;Proceed&quot; you are now accessing this data.
              Please note, this is an additional data service and will not
              replace the existing MQ methodology until further notice.
            </p>
            <p>
              Data from the current framework will remain available on the
              website until at least September 2024.
            </p>
            <p>
              A report detailing what’s new in the BETA MQ methodology,
              and a review of its impact on company scoring, can be found
              <a href={MQ_REPORT_PUBLICATION_LINK} rel="noreferrer" target="_blank"> here</a>.
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
