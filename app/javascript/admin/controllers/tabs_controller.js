import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['activeTab']

  connect() {
    $(this.element).tabs();

    $(this.element.querySelectorAll('.nav-tabs a')).on('click', (event) => {
      event.preventDefault();
      this._selectTab(event.target.hash);
    });

    if (this.hasActiveTabTarget) {
      const activeTab = this.activeTabTarget.value;
      this._clickTab(activeTab);
    }
  }

  _clickTab(tabName) {
    $(this.element).find(`.nav-tabs a[href="${tabName}"]`).click();
  }

  _selectTab(tabName) {
    window.history.replaceState({}, '', tabName);

    if (this.hasActiveTabTarget) {
      this.activeTabTarget.value = tabName;
    }
  }
}
