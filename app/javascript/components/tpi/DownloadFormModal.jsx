import React, { useState, useRef, useEffect, useMemo } from 'react';

import PropTypes from 'prop-types';
import { getNames } from 'country-list';
import { Modal } from './Modal';
import { OverlayProvider } from '@react-aria/overlays';
import Select from './Select';
import classNames from 'classnames';
import downloadIcon from 'images/icons/download.svg';
import BaseTooltip from './BaseTooltip';

const Field = ({ label, name, value, onChange, type, required, error, placeholder, minLength, children }) => {
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
        minLength={minLength}
      />
      )}
      {error && <span className="error">{error}</span>}
    </div>
  );
};

const isValidInput = (value) => /[a-zA-Z0-9]/.test(value.trim());

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim());
}

Field.propTypes = {
  label: PropTypes.any.isRequired,
  name: PropTypes.string.isRequired,
  type: PropTypes.string,
  value: PropTypes.string,
  onChange: PropTypes.func,
  error: PropTypes.string,
  required: PropTypes.bool,
  placeholder: PropTypes.string,
  minLength: PropTypes.number,
  children: PropTypes.node
};

Field.defaultProps = {
  error: null,
  type: 'text',
  onChange: () => {},
  value: undefined,
  required: false,
  placeholder: '',
  minLength: 3,
  children: null
};

const checkboxInputs = [
  'diligence_research',
  'engagement',
  'voting',
  'academic_research',
  'content_creation',
  'investment',
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

function DownloadFormModal({ downloadUrl, title, buttonClass, source }) {
  const [showModal, setShowModal] = useState(false);
  const [error, setError] = useState(null);
  const [formValues, setFormValues] = useState(initialFormValues);

  const minLength = 3;

  const getSourceName = () => {
    switch (source) {
      case 'sectors':
      case 'companies':
        return 'Carbon Performance';
      case 'banks':
        return 'Banking';
      case 'ascor':
        return 'ASCOR';
      default:
        return 'TPI';
    }
  };

  const isValidLength = (value) => value && value.trim().length >= minLength;

  const downloadLinkRef = useRef(null);
  const countryOptions = useMemo(() => getNames()?.map((name) => ({label: name, value: name})), []);

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!isValidEmail(formValues.email)) {
      setError('Email is not valid');
      return;
    }

    if (!isValidInput(formValues.job_title) || !isValidLength(formValues.job_title)) {
      setError('Please add your Job title');
      return;
    }

    if (!isValidInput(formValues.forename) || !isValidLength(formValues.forename)) {
      setError('Please add your Forename');
      return;
    }

    if (!isValidInput(formValues.surname) || !isValidLength(formValues.surname)) {
      setError('Please add your Surname');
      return;
    }

    if (!isValidInput(formValues.organisation) || !isValidLength(formValues.organisation)) {
      setError('Please add your Organisation');
      return;
    }

    if (formValues.purposes.length === 0) {
      setError('Please select at least one purpose');
      return;
    }
    if (formValues.purposes.includes('other_purpose_checkbox') && !formValues.other_purpose) {
      setError('Please specify other purposes');
      return;
    }

    fetch(`/${source}/send_download_file_info_email`, {
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
      <button type="button" onClick={() => setShowModal(true)} className={buttonClass || 'button is-primary with-icon with-border'}>
        <img src={downloadIcon} alt="download icon" />
        { title || 'Download Data'}
      </button>

      <OverlayProvider>
        <Modal
          title="Data Disclaimer"
          open={showModal}
          onClose={() => setShowModal(false)}
        >
          <div className="download-form">
            <h2>Data Disclaimer</h2>
            <div className="content">
              <form onSubmit={handleSubmit}>
                <div className="disclaimer-text">
                  <p>
                    {getSourceName()} data are viewable on the website and can be downloaded without Authorisation or License only for the Permitted Uses listed in the{' '}
                    <a href="https://www.lse.ac.uk/lse-information/terms-of-use" target="_blank" rel="noopener noreferrer">
                      Terms of Use
                    </a>
                    . You should read the Terms of Use to ensure that you are complying with their requirements.
                  </p>
                </div>
                <div className="checkbox-inputs">
                  <Field
                    value={formValues.accept_terms}
                    onChange={handleChange}
                    required
                    label={
                      <>
                        By checking this box, I attest that I have read and understood the{' '}
                        <a href="https://www.transitionpathwayinitiative.org/use-of-the-centre-s-data" target="_blank" rel="noopener noreferrer">
                          Terms of Use of TPI Centre Data
                        </a>
                        .
                      </>
                    }
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
                    minLength={minLength}
                    label={
                      <>
                        Email{' '}
                        <BaseTooltip
                          content="If you do not have access to a professional email address, please reach out to tpi@lse.ac.uk."
                        />
                      </>
                    }
                    name="email"
                    placeholder="Professional email addresses only"
                  />
                  <Field
                    value={formValues.job_title}
                    onChange={handleChange}
                    required
                    minLength={minLength}
                    label="Job title"
                    name="job_title"
                  />
                  <Field
                    value={formValues.forename}
                    onChange={handleChange}
                    required
                    minLength={minLength}
                    label="Forename"
                    name="forename"
                  />
                  <Field
                    value={formValues.surname}
                    onChange={handleChange}
                    required
                    minLength={minLength}
                    label="Surname"
                    name="surname"
                  />
                  <Field
                    value={formValues.location}
                    onChange={handleChange}
                    required
                    minLength={minLength}
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
                    minLength={minLength}
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
                    label="Product and service creation"
                    type="checkbox"
                    name="content_creation"
                  />
                  <Field
                    label="Investment universe selection/portfolio construction"
                    type="checkbox"
                    onChange={handleChange}
                    name="investment"
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
  buttonClass: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  downloadUrl: PropTypes.string.isRequired,
  source: PropTypes.string.isRequired
};

export default DownloadFormModal;
