import { Controller } from 'stimulus';

export default class extends Controller {
  close() {
    document.cookie = `cookies_consented=true; path=/;
                       expires=${new Date(Date.now() + 86400e3 * 365)}
                       ${window.location.protocol === 'https:' && ' secure'}`;

    this.element.remove();
  }
}
