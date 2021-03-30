/* eslint-disable react-hooks/rules-of-hooks */
/* import Turbolinks from "turbolinks"; */
import Rails from '@rails/ujs';
import ReactRailsUJS from 'react_ujs';

import 'shared';

window.Rails = Rails;

Rails.start();
/* Turbolinks.start(); */

// setup react-rails
ReactRailsUJS.useContext(require.context('components/cclow', true));
