import Turbolinks from "turbolinks";
import Slick from "slick-carousel";
import Chartkick from "chartkick";
import HighCharts from "highcharts";
import Rails from "rails-ujs";

Chartkick.use(HighCharts);

window.Rails = Rails;
window.$ = $;

Rails.start();
/* Turbolinks.start(); */
