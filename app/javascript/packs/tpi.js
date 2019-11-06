import Turbolinks from "turbolinks";
import Chartkick from "chartkick";
import HighCharts from "highcharts";
import Rails from "rails-ujs";

import "tpi";

Chartkick.use(HighCharts);

window.Rails = Rails;
window.$ = $;

Rails.start();
Turbolinks.start();
