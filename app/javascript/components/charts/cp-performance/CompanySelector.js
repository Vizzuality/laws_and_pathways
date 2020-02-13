import React, { useMemo } from 'react';
import PropTypes from 'prop-types';

import CheckList from 'components/CheckList';

function CompanySelector({ companies, selected, onChange }) {
  const options = useMemo(
    () => companies.map(c => ({ value: c, label: c })),
    [companies]
  );

  return (
    <div className="chart-company-selector">
      <p>
        Add up to 10 companies simultaneously
      </p>

      <CheckList
        maxSelectedCount={10}
        options={options}
        selected={selected}
        onChange={onChange}
      />
    </div>
  );
}

CompanySelector.defaultProps = {
  companies: [],
  selected: [],
  onChange: () => {}
};

CompanySelector.propTypes = {
  companies: PropTypes.arrayOf(PropTypes.string),
  selected: PropTypes.arrayOf(PropTypes.string),
  onChange: PropTypes.func
};

export default CompanySelector;
