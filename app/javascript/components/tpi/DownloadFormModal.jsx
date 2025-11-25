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

const FREE_EMAIL_DOMAINS = [
  'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'aol.com',
  'icloud.com', 'mail.com', 'protonmail.com', 'zoho.com', 'yandex.com',
  'gmx.com', 'inbox.com', 'live.com', 'msn.com', 'yahoo.co.uk',
  'yahoo.fr', 'yahoo.de', 'yahoo.es', 'yahoo.it', 'yahoo.ca',
  'hotmail.co.uk', 'hotmail.fr', 'hotmail.de', 'hotmail.es', 'hotmail.it',
  'outlook.co.uk', 'outlook.fr', 'outlook.de', 'outlook.es', 'outlook.it',
  'googlemail.com', 'me.com', 'mac.com', 'fastmail.com', 'hushmail.com',
  'tutanota.com', 'proton.me', 'pm.me', 'cock.li', 'mailfence.com',
  'posteo.de', 'runbox.com', 'safe-mail.net', 'mail.ru', 'rambler.ru'
];

function isPersonalEmail(email) {
  const domain = email.trim().toLowerCase().split('@')[1];
  return FREE_EMAIL_DOMAINS.includes(domain);
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

const organisationTypeOptions = [
  { label: 'Academia', value: 'Academia' },
  { label: 'Asset management & investment & advisory', value: 'Asset management & investment & advisory' },
  { label: 'Asset owner', value: 'Asset owner' },
  { label: 'Corporate', value: 'Corporate' },
  { label: 'Consultant & advisory', value: 'Consultant & advisory' },
  { label: 'Commercial & retail bank', value: 'Commercial & retail bank' },
  { label: 'Credit reference agency', value: 'Credit reference agency' },
  { label: 'Financial technology', value: 'Financial technology' },
  { label: 'Government', value: 'Government' },
  { label: 'Hedge fund', value: 'Hedge fund' },
  { label: 'Investment bank', value: 'Investment bank' },
  { label: 'Media', value: 'Media' },
  { label: 'NGO', value: 'NGO' },
  { label: 'Private equity', value: 'Private equity' },
  { label: 'Wealth management', value: 'Wealth management' },
  { label: 'Other (please specify)', value: 'Other' }
];

const assetOwnerSubOptions = [
  { label: 'Endowments & foundations', value: 'Endowments & foundations' },
  { label: 'Family offices', value: 'Family offices' },
  { label: 'Insurance companies', value: 'Insurance companies' },
  { label: 'Pension funds', value: 'Pension funds' },
  { label: 'Sovereign wealth funds', value: 'Sovereign wealth funds' }
];

const useCaseOptions = [
  { label: 'Academic use', value: 'Academic use' },
  { label: 'Internal research use (see Terms of Use)', value: 'Internal research use (see Terms of Use)' },
  { label: 'Engagement with investee companies', value: 'Engagement with investee companies' },
  { label: 'Media purposes', value: 'Media purposes' },
  { label: 'Proxy voting', value: 'Proxy voting' },
  { label: 'Product & service creation', value: 'Product & service creation' },
  { label: 'Other', value: 'Other' }
];

const initialFormValues = {
  accept_terms: false,
  email: '',
  job_title: '',
  forename: '',
  surname: '',
  location: '',
  organisation: '',
  organisation_type: '',
  asset_owner_type: '',
  organisation_type_other: '',
  use_case: '',
  use_case_description: '',
  self_attestation: ''
};

function DownloadFormModal({ downloadUrl, title, buttonClass, source, showIcon = false }) {
  const [showModal, setShowModal] = useState(false);
  const [error, setError] = useState(null);
  const [formValues, setFormValues] = useState(initialFormValues);

  const minLength = 3;

  const getSourceName = () => {
    switch (source) {
      case 'sectors':
      case 'companies':
      case 'cp':
        return 'Carbon Performance';
      case 'mq':
        return 'Management Quality';
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
  const countryOptions = useMemo(() => getNames()?.sort().map((name) => ({label: name, value: name})), []);

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!isValidEmail(formValues.email)) {
      setError('Email is not valid');
      return;
    }

    if (isPersonalEmail(formValues.email)) {
      setError('Please use a professional/organizational email address. If you do not have access to one, please contact tpi@lse.ac.uk');
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

    if (!formValues.organisation_type) {
      setError('Please select an Organisation type');
      return;
    }

    if (formValues.organisation_type === 'Asset owner' && !formValues.asset_owner_type) {
      setError('Please select an Asset owner type');
      return;
    }

    if (formValues.organisation_type === 'Other' && !formValues.organisation_type_other) {
      setError('Please specify your organisation type');
      return;
    }

    if (!formValues.use_case) {
      setError('Please select a Use case');
      return;
    }

    if (!formValues.use_case_description || formValues.use_case_description.trim().length === 0) {
      setError('Please provide a description of your use case');
      return;
    }

    if (formValues.use_case_description.length > 500) {
      setError('Use case description must not exceed 500 characters');
      return;
    }

    if (!formValues.self_attestation) {
      setError('Please select one of the self-attestation options');
      return;
    }

    const getEmailEndpoint = () => {
      if (source === 'cp') {
        return '/sectors/send_download_cp_info_email';
      } else if (source === 'mq') {
        return '/sectors/send_download_mq_info_email';
      } else {
        return `/${source}/send_download_file_info_email`;
      }
    };

    fetch(getEmailEndpoint(), {
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
    const { name, value } = e.target;
    const updatedValues = { ...formValues, [name]: value };
    
    if (name === 'organisation_type' && value !== 'Asset owner') {
      updatedValues.asset_owner_type = '';
    }
    
    if (name === 'organisation_type' && value !== 'Other') {
      updatedValues.organisation_type_other = '';
    }
    
    setFormValues(updatedValues);
    setError(null);
  };

  return (
    <div>
      <button type="button" onClick={() => setShowModal(true)} className={buttonClass || 'button is-primary with-icon with-border'}>
        {showIcon && <img src={downloadIcon} alt="download icon" />}
        { title || 'Download Data'}
      </button>

      <OverlayProvider>
        <Modal
          title="Data disclaimer"
          open={showModal}
          onClose={() => setShowModal(false)}
        >
          <div className="download-form">
            <h2>Data disclaimer</h2>
            <div className="content">
              <form onSubmit={handleSubmit}>
                <div className="disclaimer-text">
                  <p>
                    {getSourceName()} data are viewable on the website and can be downloaded without Authorisation or License only for the Permitted Uses listed in the{' '}
                    <a href="https://www.transitionpathwayinitiative.org/use-of-the-centre-s-data" target="_blank" rel="noopener noreferrer">
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
                <div className="form-section">
                  <h3 className="form-section__title">Personal details</h3>
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
                      value={formValues.organisation}
                      onChange={handleChange}
                      required
                      minLength={minLength}
                      label="Organisation name"
                      name="organisation"
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
                  </div>
                </div>
                <div className="form-section">
                  <h3 className="form-section__title">Use case details</h3>
                  <div className="text-inputs">
                    <Field
                      value={formValues.organisation_type}
                      onChange={handleChange}
                      required
                      label="Organisation type"
                      name="organisation_type"
                    >
                      <Select
                        name="organisation_type"
                        placeholder="Select organisation type"
                        onSelect={(e) => handleChange({ target: e })}
                        value={formValues.organisation_type}
                        label="Select organisation type"
                        required
                        options={organisationTypeOptions}
                      />
                    </Field>
                    {formValues.organisation_type === 'Asset owner' && (
                      <Field
                        value={formValues.asset_owner_type}
                        onChange={handleChange}
                        required
                        label="Asset owner type"
                        name="asset_owner_type"
                      >
                        <Select
                          name="asset_owner_type"
                          placeholder="Select asset owner type"
                          onSelect={(e) => handleChange({ target: e })}
                          value={formValues.asset_owner_type}
                          label="Select asset owner type"
                          required
                          options={assetOwnerSubOptions}
                        />
                      </Field>
                    )}
                    {formValues.organisation_type === 'Other' && (
                      <Field
                        value={formValues.organisation_type_other}
                        onChange={handleChange}
                        required
                        label="Please specify"
                        name="organisation_type_other"
                        placeholder="Specify your organisation type"
                      />
                    )}
                    <Field
                      value={formValues.use_case}
                      onChange={handleChange}
                      required
                      label="Use case"
                      name="use_case"
                    >
                      <Select
                        name="use_case"
                        placeholder="Select use case"
                        onSelect={(e) => handleChange({ target: e })}
                        value={formValues.use_case}
                        label="Select use case"
                        required
                        options={useCaseOptions}
                      />
                    </Field>
                  </div>
                  <div className="full-width-field">
                    <Field
                      value={formValues.use_case_description}
                      onChange={handleChange}
                      required
                      label="Description of use case"
                      name="use_case_description"
                    >
                      <textarea
                        name="use_case_description"
                        id="use_case_description"
                        value={formValues.use_case_description}
                        onChange={handleChange}
                        placeholder="To help us understand how our data are used, please provide more detail on your intended use case, including whether it's directly related to the generation of revenue or commercial compensation."
                        maxLength={500}
                        required
                        rows={4}
                      />
                    </Field>
                    <div className="character-count">
                      {formValues.use_case_description.length}/500 characters
                    </div>
                  </div>
                </div>
                <div className="form-section">
                  <h3 className="form-section__title">Self-attestation of use case</h3>
                  <p>
                    After reading the{' '}
                    <a href="https://www.transitionpathwayinitiative.org/use-of-the-centre-s-data" target="_blank" rel="noopener noreferrer">
                      Terms of Use
                    </a>
                    , please select one of the boxes below to self-attest your use case.
                  </p>
                  <p>
                    LSE reserves the right to review requests and in the event of a suspected breach of these terms of use may conduct an investigation and take subsequent action to ensure compliance, or authorise its data partners and/or other third parties to do so on its behalf.
                  </p>
                  {source === 'mq' && (
                    <p>
                      All Management Quality assessments are produced by LSEG, TPI's data partner, using the TPI Centre's methodology. For queries related to Management Quality scores or to discuss licensing for additional use cases, please reach out to tpi_access@lseg.com.
                    </p>
                  )}
                  <div className="radio-inputs">
                    <Field
                      value={formValues.self_attestation}
                      onChange={handleChange}
                      required
                      label="Uses subject to Authorisation and License"
                      type="radio"
                      name="self_attestation"
                    >
                      <input
                        type="radio"
                        name="self_attestation"
                        id="self_attestation_authorised"
                        value="Uses subject to Authorisation and License"
                        checked={formValues.self_attestation === 'Uses subject to Authorisation and License'}
                        onChange={handleChange}
                        required
                      />
                    </Field>
                    <Field
                      value={formValues.self_attestation}
                      onChange={handleChange}
                      required
                      label="Permitted uses without Authorisation or License"
                      type="radio"
                      name="self_attestation"
                    >
                      <input
                        type="radio"
                        name="self_attestation"
                        id="self_attestation_permitted"
                        value="Permitted uses without Authorisation or License"
                        checked={formValues.self_attestation === 'Permitted uses without Authorisation or License'}
                        onChange={handleChange}
                        required
                      />
                    </Field>
                  </div>
                </div>
                <a hidden ref={downloadLinkRef} href={downloadUrl} rel="noreferrer">
                  <button type="button">Click</button>
                </a>
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
  source: PropTypes.string.isRequired,
  showIcon: PropTypes.bool
};

export default DownloadFormModal;
