import React, { useState, useRef, useEffect, useMemo } from 'react';

import PropTypes from 'prop-types';
import { getNames } from 'country-list';
import { Modal } from './Modal';
import { OverlayProvider } from '@react-aria/overlays';
import Select from './Select';
import classNames from 'classnames';
import downloadIcon from 'images/icons/download.svg';

const Field = ({ label, name, value, onChange, type, required, error, placeholder, children }) => {
  const ref = useRef(null);

  useEffect(() => {
    if (error) {
      ref.current.focus();
    }
  }, [error]);

  return (
    <div className="content__input">
      <label ref={ref} className="content__input__label" htmlFor={name}>
        {label}
      </label>
      {children || (
      <input
        required={required}
        type={type || 'text'}
        onChange={onChange}
        name={name}
        id={name}
        value={value}
        placeholder={placeholder}
      />
      )}
      {error && <span className="error">{error}</span>}
    </div>
  );
};

Field.propTypes = {
  label: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  type: PropTypes.string,
  value: PropTypes.string,
  onChange: PropTypes.func,
  error: PropTypes.string,
  required: PropTypes.bool,
  placeholder: PropTypes.string,
  children: PropTypes.node
};

Field.defaultProps = {
  error: null,
  type: 'text',
  onChange: () => {},
  value: undefined,
  required: false,
  placeholder: '',
  children: null
};

const checkboxInputs = [
  'diligence_research',
  'engagement',
  'voting',
  'academic_research',
  'content_creation_commercial',
  'content_creation_noncommercial',
  'investment',
  'financial_decision_making',
  'client_reporting',
  'other_purpose_checkbox'
];

const initialFormValues = {
  accept_terms: false,
  email: '',
  job_title: '',
  forename: '',
  surname: '',
  location: '',
  organisation: '',
  purposes: [],
  other_purpose: ''
};

function DownloadFormModal({ downloadUrl }) {
  const [showModal, setShowModal] = useState(false);
  const [error, setError] = useState(null);
  const [formValues, setFormValues] = useState(initialFormValues);

  const downloadLinkRef = useRef(null);
  const countryOptions = useMemo(() => getNames()?.map((name) => ({label: name, value: name})), []);

  const handleSubmit = (e) => {
    e.preventDefault();

    if (formValues.purposes.length === 0) {
      setError('Please select at least one purpose');
      return;
    }
    if (formValues.purposes.includes('other_purpose_checkbox') && !formValues.other_purpose) {
      setError('Please specify other purposes');
      return;
    }

    fetch('/sectors/send_download_file_info_email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify(formValues)
    }).then(() => {
      downloadLinkRef.current.click();
      setShowModal(false);
      setFormValues(initialFormValues);
    }, () => {
      setError('Something went wrong. Please try again later.');
    });
  };

  const handleChange = (e) => {
    setFormValues({ ...formValues, [e.target.name]: e.target.value });
    if (checkboxInputs.includes(e.target.name)) {
      if (e.target.checked) {
        setFormValues({
          ...formValues,
          purposes: [...formValues.purposes, e.target.name]
        });
        setError(null);
      } else {
        setFormValues({
          ...formValues,
          other_purpose: e.target.name === 'other_purpose_checkbox' ? '' : formValues.other_purpose,
          purposes: formValues.purposes.filter((item) => item !== e.target.name)
        });
      }
    }
  };

  return (
    <div>
      <button type="button" onClick={() => setShowModal(true)} className="button is-primary with-icon with-border">
        <img src={downloadIcon} alt="download icon" />
        CP & MQ Data
      </button>

      <OverlayProvider>
        <Modal
          title="Data Disclaimer"
          open={showModal}
          onClose={() => setShowModal(false)}
        >
          <div className="download-form">
            <h2>Data Disclaimer</h2>
            <p>
              I have read the Use of TPI Centre Data and will not use the data for
              commercial purposes unless I have sought prior permission.
            </p>
            <div className="content">
              <form onSubmit={handleSubmit}>
                <div className="checkbox-inputs">
                  <Field
                    value={formValues.accept_terms}
                    onChange={handleChange}
                    required
                    label="Accept terms and conditions"
                    type="checkbox"
                    name="accept_terms"
                  />
                </div>
                <p className="--mandatory">All
                  fields below are mandatory.
                </p>
                <div className="text-inputs">
                  <Field
                    value={formValues.email}
                    onChange={handleChange}
                    required
                    label="Email"
                    name="email"
                  />
                  <Field
                    value={formValues.job_title}
                    onChange={handleChange}
                    required
                    label="Job title"
                    name="job_title"
                  />
                  <Field
                    value={formValues.forename}
                    onChange={handleChange}
                    required
                    label="Forename"
                    name="forename"
                  />
                  <Field
                    value={formValues.surname}
                    onChange={handleChange}
                    required
                    label="Surname"
                    name="surname"
                  />
                  <Field
                    value={formValues.location}
                    onChange={handleChange}
                    required
                    label="Location"
                    name="location"
                  >
                    <Select
                      name="location"
                      placeholder="Select country"
                      onSelect={(e) => handleChange({ target: e })}
                      value={formValues.location}
                      label="Select country"
                      allowSearch
                      required
                      options={countryOptions}
                    />
                  </Field>
                  <Field
                    value={formValues.organisation}
                    onChange={handleChange}
                    required
                    label="Organisation"
                    name="organisation"
                  />
                </div>
                <p>
                  To help us understand how our data is used, please select your
                  purpose(s) from the choices below:
                </p>
                <div className="checkbox-inputs">
                  <Field
                    onChange={handleChange}
                    label="Due diligence research"
                    type="checkbox"
                    name="diligence_research"
                  />
                  <Field
                    onChange={handleChange}
                    label="Engagement"
                    type="checkbox"
                    name="engagement"
                  />
                  <Field
                    onChange={handleChange}
                    label="Proxy voting"
                    type="checkbox"
                    name="voting"
                  />
                  <Field
                    onChange={handleChange}
                    label="Academic research"
                    type="checkbox"
                    name="academic_research"
                  />
                  <Field
                    onChange={handleChange}
                    label="Product/Service creation (commercial)"
                    type="checkbox"
                    name="content_creation_commercial"
                  />
                  <Field
                    onChange={handleChange}
                    label="Product/Service creation (non-commercial)"
                    type="checkbox"
                    name="content_creation_noncommercial"
                  />
                  <Field
                    label="Input to portfolio construction"
                    type="checkbox"
                    onChange={handleChange}
                    name="investment"
                  />
                  <Field
                    label="Financial decision making"
                    type="checkbox"
                    onChange={handleChange}
                    name="financial_decision_making"
                  />
                  <Field
                    label="Client reporting"
                    type="checkbox"
                    onChange={handleChange}
                    name="client_reporting"
                  />
                  <Field
                    onChange={handleChange}
                    label="Other (please specify)"
                    name="other_purpose_checkbox"
                    type="checkbox"
                  />
                </div>
                <div className={classNames('other-purposes-text', { hidden: !formValues.purposes.includes('other_purpose_checkbox') })}>
                  <Field
                    label=""
                    name="other_purpose"
                    placeholder="Please, write here other purposes"
                    value={formValues.other_purpose}
                    onChange={handleChange}
                  />
                </div>
                <a hidden ref={downloadLinkRef} href={downloadUrl} rel="noreferrer">
                  <button type="button">Click</button>
                </a>
                <input required type="hidden" name="purposes" value={formValues.purposes} />
                {error && <span className="error">{error}</span>}
                <div className="form-buttons">
                  <button className="button is-primary" type="submit">Submit</button>
                  <button className="button is-secondary" type="button" onClick={() => setShowModal(false)}>
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </Modal>
      </OverlayProvider>
    </div>
  );
}

DownloadFormModal.propTypes = {
  downloadUrl: PropTypes.string.isRequired
};

export default DownloadFormModal;
