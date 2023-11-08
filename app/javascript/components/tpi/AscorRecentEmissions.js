import PropTypes from 'prop-types';
import Select from './Select';
import React, {useState} from 'react';

const AscorRecentEmissions = ({
  emissions_metric_filter,
  default_emissions_metric_filter,
  emissions_boundary_filter,
  default_emissions_boundary_filter,
  trend_filters,
  default_trend_filter,
  data
}) => {
  const [filters, setFilters] = useState({
    emissions_metric: default_emissions_metric_filter,
    emissions_boundary: default_emissions_boundary_filter,
    trends: default_trend_filter
  });
  const recentEmissions = data.filter((d) => d.emissions_metric === filters.emissions_metric && d.emissions_boundary === filters.emissions_boundary)[0] || {};
  const trend = recentEmissions.trend || {};
  const trendValue = trend.values?.filter((t) => t.filter === filters.trends)[0] || {};

  const handleSelect = (opt) => {
    setFilters({ ...filters, [opt.name]: opt.value });
  };

  return (
    <>
      <div className="country-assessment__metric">
        <div className="country-assessment__metric__title">
          i. What is the country&apos;s most recent emissions level?
        </div>
        { recentEmissions.source && (
          <div className="country-assessment__metric__source">
            <a target="_blank" rel="noreferrer" href={recentEmissions.source}>Source ({recentEmissions.year})</a>
          </div>
        )}
        <div className="country-assessment__break" />
        <div className="emissions__filters assessments">
          <div className="emissions__filters__emissions">
            <Select
              options={emissions_metric_filter}
              onSelect={handleSelect}
              value={filters.emissions_metric}
              name="emissions_metric"
              placeholder="Emissions Metric"
              label="Emissions Metric"
            />
            <Select
              options={emissions_boundary_filter}
              onSelect={handleSelect}
              value={filters.emissions_boundary}
              name="emissions_boundary"
              placeholder="Emissions Boundary"
              label="Emissions Boundary"
            />
          </div>
        </div>
        { recentEmissions.value !== null && (
          <>
            <div className="country-assessment__break" />
            <div className="country-assessment__metric__text">
              <span>{recentEmissions.value} </span>
              { recentEmissions.value.toLowerCase() !== 'no data' && (
                <span>{recentEmissions.unit}</span>
              )}
            </div>
          </>
        )}
      </div>
      <div className="country-assessment__metric">
        <div className="country-assessment__metric__title">
          ii. What is the country&apos;s most recent emissions trend?
        </div>
        { trend.source && (
          <div className="country-assessment__metric__source">
            <a target="_blank" rel="noreferrer" href={trend.source}>Source ({trend.year})</a>
          </div>
        )}
        <div className="country-assessment__break" />
        <div className="emissions__filters assessments">
          <div className="emissions__filters__emissions">
            <Select
              options={trend_filters}
              onSelect={handleSelect}
              value={filters.trends}
              name="trends"
              placeholder="Trends"
              label="Trends"
            />
          </div>
        </div>
        { trendValue.value && (
          <>
            <div className="country-assessment__break" />
            <div className="country-assessment__metric__text">
              {trendValue.value}
            </div>
          </>
        )}
      </div>
    </>
  );
};

AscorRecentEmissions.propTypes = {
  emissions_metric_filter: PropTypes.arrayOf(PropTypes.string).isRequired,
  default_emissions_metric_filter: PropTypes.string.isRequired,
  emissions_boundary_filter: PropTypes.arrayOf(PropTypes.string).isRequired,
  default_emissions_boundary_filter: PropTypes.string.isRequired,
  trend_filters: PropTypes.arrayOf(PropTypes.string).isRequired,
  default_trend_filter: PropTypes.string.isRequired,
  data: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.number,
      source: PropTypes.string,
      year: PropTypes.number,
      unit: PropTypes.string.isRequired,
      emissions_metric: PropTypes.string.isRequired,
      emissions_boundary: PropTypes.string.isRequired,
      trend: PropTypes.shape({
        source: PropTypes.string,
        year: PropTypes.number,
        values: PropTypes.arrayOf(
          PropTypes.shape({
            filter: PropTypes.string.isRequired,
            value: PropTypes.string
          })
        ).isRequired
      }).isRequired
    })
  ).isRequired
};

export default AscorRecentEmissions;
