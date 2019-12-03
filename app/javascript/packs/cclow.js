/* import Turbolinks from "turbolinks"; */
/* import Slick from "slick-carousel"; */
import Chartkick from "chartkick";
import HighCharts from "highcharts";
import Rails from "@rails/ujs";
import ReactRailsUJS from "react_ujs";
import $ from "jquery";

import 'shared';

Chartkick.use(HighCharts);

window.Rails = Rails;
window.$ = $;

Rails.start();
/* Turbolinks.start(); */

// setup react-rails
const componentRequireContext = require.context("components", true);
ReactRailsUJS.useContext(componentRequireContext);
