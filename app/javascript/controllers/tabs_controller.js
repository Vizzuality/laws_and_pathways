import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['activeTab']

  connect() {
    $(this.element).tabs();

    $(this.element.querySelectorAll('.nav-tabs a')).on('click', (event) => {
      event.preventDefault();
      this._changeActiveTabTo(event.target.hash);
    });

    const activeTab = this.activeTabTarget.value;
    if (activeTab) {
      $(this.element).find(`.nav-tabs a[href="${activeTab}"]`).click();
    }
  }

  _changeActiveTabTo(hash) {
    window.location.hash = hash;
    this.activeTabTarget.value = hash;
  }
}
