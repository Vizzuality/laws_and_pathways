import { Controller } from 'stimulus';

const ENTITY_TYPE_PARTY_TYPE_MAP = {
  'Company': 'corporation',
  'Location': 'government'
};

export default class extends Controller {
  connect() {
    $(this.connectedWithSelect).on('change', this._setDefaults.bind(this));
  }

  _setDefaults() {
    const selectedOption = this.connectedWithSelect.selectedOptions &&
          this.connectedWithSelect.selectedOptions.length &&
          this.connectedWithSelect.selectedOptions[0];

    if (selectedOption) {
      const entityType = selectedOption.value.split('-')[0];
      const partyType = ENTITY_TYPE_PARTY_TYPE_MAP[entityType];

      if (partyType) {
        $(this.partyTypeSelect).val(partyType);
        $(this.partyTypeSelect).trigger('change');
      }

      this.nameInput.value = selectedOption.text;
    }
  }

  get connectedWithSelect () {
    return this.element.querySelector('select[id*="_connected_with"');
  }

  get nameInput() {
    return this.element.querySelector('input[id*="_name"');
  }

  get partyTypeSelect() {
    return this.element.querySelector('select[id*="_party_type"');
  }
}
