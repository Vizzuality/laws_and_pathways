module ChartHelper
  # defaults chart options (Highcharts)
  def default_chart_options
    {
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

  def mq_company_no_of_assessments_chart_options
    {
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
          year: '%Y'
        }
      },
      yAxis: {
        tickInterval: 1,
        title: {
          text: 'Level'
        }
      }
    }
  end
end
