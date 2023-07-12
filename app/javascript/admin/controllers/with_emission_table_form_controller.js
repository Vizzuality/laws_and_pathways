import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['emissionTable', 'emissionRowTemplate', 'emissionRowAdd']

  connect() {
    $(this.element).on('submit', () => {
      // serialize emissions
      this.element.querySelector('#input_emissions').value = JSON.stringify(this.serializeTableData());
    });

    $(this.emissionTableTarget).find('tbody').sortable({
      handle: '.sortable-handle',
      items: 'tr.emission'
    });
  }

  serializeTableData() {
    const result = {};

    $(this.emissionTableTarget).find('tr.emission').each((idx, el) => {
      const year = $(el).find('input[name=emission_year]').val();
      const value = parseFloat($(el).find('input[name=emission_value]').val());

      if (!year || Number.isNaN(value)) return;

      result[year] = value;
    });

    return result;
  }

  // actions
  addEmission() {
    const content = this.emissionRowTemplateTarget.innerHTML;
    this.emissionRowAddTarget.insertAdjacentHTML('beforebegin', content);
  }

  removeEmission(event) {
    const element = event.target.closest('tr');
    element.remove();
  }
}
