import './controllers';
import Turbolinks from 'turbolinks';

Turbolinks.scroll = {};

document.addEventListener("turbolinks:load", ()=> {
  if (Turbolinks.scroll['cache']) {
    document.scrollingElement.scrollTo(0, Turbolinks.scroll['cache']);
  }

  Turbolinks.scroll = {};
});
