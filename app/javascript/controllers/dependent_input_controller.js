import { Controller } from "stimulus";

export default class extends Controller {
  connect() {
    this.dependsOnElement.addEventListener('change', this.refreshVisiblity.bind(this));
    this.refreshVisiblity();
  }

  refreshVisiblity() {
    this.element.classList.toggle('hidden', !this.dependsOnElement.checked);
  }

  get dependsOnElement() {
    const dependsOnId = this.element.getAttribute('data-depends-on');
    return document.getElementById(dependsOnId);
  }
}
