import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    $(this.connectedWithSelect).on('change', this._setDefaultName.bind(this));
  }

  _setDefaultName() {
    const selectedOptions = this.connectedWithSelect.selectedOptions;

    if (selectedOptions.length) {
      this.nameInput.value = selectedOptions[0].text;
    }
  }

  get connectedWithSelect () {
    return this.element.querySelector('select[id*="_connected_with"');
  }

  get nameInput() {
    return this.element.querySelector('input[id*="_name"');
  }
}
