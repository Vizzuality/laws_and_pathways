import React, {
  Children, cloneElement, isValidElement, useRef
} from 'react';
import cx from 'classnames';
import PropTypes from 'prop-types';
import {
  useOverlay, usePreventScroll, useModal, OverlayContainer
} from '@react-aria/overlays';

import { useDialog } from '@react-aria/dialog';
import { FocusScope } from '@react-aria/focus';

export const Modal = ({
  title,
  open,
  dismissable = true,
  children,
  className,
  onClose
}) => {
  const containerRef = useRef();
  const { overlayProps } = useOverlay(
    {
      isKeyboardDismissDisabled: !dismissable,
      isDismissable: dismissable,
      isOpen: open,
      onClose
    },
    containerRef,
  );
  const { modalProps } = useModal();
  const { dialogProps } = useDialog({ 'aria-label': title }, containerRef);

  usePreventScroll({ isDisabled: !open });

  return (
    open && (
    <OverlayContainer>
      <div className="modal-overlay">
        <FocusScope contain restoreFocus autoFocus>
          <div {...overlayProps} {...dialogProps} {...modalProps} ref={containerRef}>
            <div
              className={cx('modal-content', {[className]: !!className })}
              style={{
                maxHeight: '90%'
              }}
            >
              {/* Children */}
              {Children.map(children, (child) => {
                if (isValidElement(child)) {
                  return cloneElement(child, {
                    onClose
                  });
                }
                return null;
              })}
            </div>
          </div>
        </FocusScope>
      </div>
    </OverlayContainer>
    )
  );
};

Modal.defaultProps = {
  dismissable: true,
  className: ''
};

Modal.propTypes = {
  title: PropTypes.string.isRequired,
  open: PropTypes.bool.isRequired,
  dismissable: PropTypes.bool,
  children: PropTypes.node.isRequired,
  className: PropTypes.string,
  onClose: PropTypes.func.isRequired
};

export default Modal;
