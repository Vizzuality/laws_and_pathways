import PropTypes from 'prop-types';

// eslint-disable-next-line no-empty-pattern
const AscorRecentEmissions = ({ }) => {

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
      trends: PropTypes.shape({
        source: PropTypes.string,
        year: PropTypes.number,
        values: PropTypes.arrayOf(
          PropTypes.shape({
            filter: PropTypes.string.isRequired,
            value: PropTypes.string.isRequired
          })
        ).isRequired
      }).isRequired
    })
  ).isRequired
};

export default AscorRecentEmissions;
