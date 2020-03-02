import React, { useMemo, useState } from 'react';
import PropTypes from 'prop-types';

import CheckList from 'components/CheckList';

function CompanySelector({ companies, selected, onChange, onClose }) {
  const options = useMemo(
    () => companies.map(c => ({ value: c, label: c })),
    [companies]
  );
  const [selectedCompanies, setSelectedCompanies] = useState(selected);

  const handleApplyChangesClick = () => {
    onChange(selectedCompanies);
    onClose();
  };

  return (
    <div className="chart-company-selector">
      <p>
        Add <strong>up to 10</strong> companies simultaneously
      </p>

      <CheckList
        maxSelectedCount={10}
        options={options}
        selected={selectedCompanies}
        onChange={setSelectedCompanies}
      />

      <div>
        <button type="button" className="button is-primary apply-changes-button" onClick={handleApplyChangesClick}>
          Apply Changes
        </button>
      </div>
    </div>
  );
}

CompanySelector.defaultProps = {
  companies: [],
  selected: [],
  onClose: () => {},
  onChange: () => {}
};

CompanySelector.propTypes = {
  companies: PropTypes.arrayOf(PropTypes.string),
  selected: PropTypes.arrayOf(PropTypes.string),
  onChange: PropTypes.func,
  onClose: PropTypes.func
};

export default CompanySelector;
