import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    $('.close-btn', this.element).on('click', this.setCookie.bind(this));
  }

  setCookie() {
    document.cookie = `cookies_consented=true; path=/; 
                       expires=${new Date(Date.now() + 86400e3 * 365)}
                       ${window.location.protocol === 'https:' && ' secure'}`;

    this.element.remove();
  }
}
