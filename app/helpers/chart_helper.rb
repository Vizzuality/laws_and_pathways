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
      chart: {
        styledMode: true
      },
      colors: ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB'],
      tooltip: {
        enabled: false
      },
      plotOptions: {
        pie: {
          dataLabels: {
            enabled: true,
            format: '<strong>Level {point.name}</strong> <br> {point.y} companies <br> {point.percentage:.1f}%',
            alignTo: 'connectors',
            connectorShape: 'crookedLine',
            crookDistance: '100%'
          }
        }
      }
    }
  end

  def cp_all_sectors_chart_options
    {
      # I couldn't make highcharts to use color directly from the chart data so sorting chart data
      # by cp alignment name and then we will use below colors in the right order
      colors: [
        '#00C170', '#FFDD49', '#FF9600', '#ED3D4A', '#595B5D'
      ],
      legend: {
        align: 'left',
        verticalAlign: 'top',
        margin: 50
      },
      plotOptions: {
        column: {
          stacking: 'percent'
          # below will show data labels for stacked bar but will also show 0 if no alignement in this category
          # to fix this we will have to initialize chart in javascript and use formatter function
          # dataLabels: {
          #   enabled: true
          # }
        }
      },
      yAxis: {
        labels: {
          format: '{value}%' # does not work!
        }
      }
    }
  end

  def cp_chart_options(unit)
    {
      colors: [
        '#00C170', '#ED3D4A', '#FFDD49', '#440388', '#FF9600', '#B75038', '#00A8FF', '#F78FB3', '#191919', '#F602B4'
      ],
      legend: {
        verticalAlign: 'top',
        margin: 50
      },
      plotOptions: {
        area: {
          # fillOpacity: 0.3,
          marker: {
            enabled: false
          }
        },
        line: {
          marker: {
            enabled: false
          }
        },
        column: {
          stacking: 'normal'
        },
        series: {
          lineWidth: 4
        }
      },
      yAxis: {
        title: {
          text: unit,
          reserveSpace: false,
          textAlign: 'left',
          align: 'high',
          rotation: 0,
          x: 0,
          y: -20
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
