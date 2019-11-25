# rubocop:disable Metrics/MethodLength
module ChartHelper
  # defaults chart options (Highcharts)
  def default_chart_options
    {
      colors: [
        '#00C170', '#ED3D4A', '#FFDD49', '#440388', '#FF9600', '#B75038', '#00A8FF', '#F78FB3', '#191919', '#F602B4'
      ],
      legend: {
        verticalAlign: 'top'
      },
      plotOptions: {
        area: {
          fillOpacity: 0.3,
          marker: {
            enabled: false
          }
        },
        column: {
          stacking: 'percent'
        }
      }
    }
  end

  def mq_sector_pie_chart_options
    {
      colors: ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB'],
      tooltip: {
        enabled: false
      },
      plotOptions: {
        pie: {
          dataLabels: {
            format: 'Level {point.name} <br> {point.y} companies <br> {point.percentage:.1f}%'
          }
        }
      }
    }
  end

  def cp_all_sectors_chart_options
    {
      colors: [
        '#00C170', '#ED3D4A', '#FFDD49', '#191919', '#FF9600', '#B75038', '#00A8FF', '#F78FB3', '#F602B4', '#440388'
      ],
      legend: {
        align: 'left',
        verticalAlign: 'top',
        margin: 50
      },
      plotOptions: {
        area: {
          fillOpacity: 0.3,
          marker: {
            enabled: false
          }
        },
        column: {
          stacking: 'percent'
        }
      },
      yAxis: {
        labels: {
          format: '{value}%' # does not work!
        }
      }
    }
  end

  def mq_company_no_of_assessments_chart_options
    {
      chart: {
        marginTop: 50
      },
      colors: ['#00C170'],
      legend: {
        enabled: false
      },
      tooltip: {
        dateTimeLabelFormats: {
          day: '%B %Y',
          hour: '%B %Y',
          minute: '%B %Y',
          month: '%B %Y',
          second: '%B %Y',
          year: '%Y'
        }
      },
      xAxis: {
        type: 'datetime',
        dateTimeLabelFormats: {
          month: '%Y',
          year: '%Y'
        },
        tickInterval: (Time.now - 1.year.ago).round * 1000
      },
      yAxis: {
        tickInterval: 1,
        title: {
          text: 'Level',
          textAlign: 'right',
          align: 'high',
          rotation: 0,
          x: 20,
          y: -20
        }
      }
    }
  end
end
# rubocop:enable Metrics/MethodLength
