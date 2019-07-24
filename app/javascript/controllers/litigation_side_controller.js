import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    $(this.systemTypeSelect).on('change', this._changeInputsVisibility.bind(this));

    this._changeInputsVisibility();
  }

  _changeInputsVisibility() {
    const selected = this.systemTypeSelect.value;

    $(this.companyField).toggle(selected === 'company');
    $(this.locationField).toggle(selected === 'location');
    $(this.nameField).toggle(selected === 'other');
  }

  get systemTypeSelect () {
    return this.element.querySelector('select[id*="_system_type"');
  }

  get companyField() {
    return this.element.querySelector('li[id*="_company_id"');
  }

  get locationField() {
    return this.element.querySelector('li[id*="_location_id"');
  }

  get nameField() {
    return this.element.querySelector('li[id*="_name"');
  }
}
