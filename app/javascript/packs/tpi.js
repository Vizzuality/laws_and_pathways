/* import Turbolinks from "turbolinks"; */
import Rails from '@rails/ujs';
import ReactRailsUJS from 'react_ujs';
import $ from 'jquery';

import 'tpi';

window.Rails = Rails;
window.$ = $;

Rails.start();
/* Turbolinks.start(); */

// setup react-rails
const componentRequireContext = require.context('components', true);
ReactRailsUJS.useContext(componentRequireContext);
