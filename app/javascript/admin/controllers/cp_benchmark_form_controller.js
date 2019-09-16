import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['emissionTable', 'emissionRowTemplate', 'emissionRowAdd']

  connect() {
    $(this.element).on('submit', () => {
      // serialize emissions
      this.element.querySelector('#input_emissions').value = this.serializeTableData();
    });

    $(this.emissionTableTarget).find('tbody').sortable({
      handle: '.sortable-handle',
      items: 'tr.emission'
    });
  }

  serializeTableData() {
    const result = {};

    $(this.element).find('table tr.emission').each((el) => {
      const year = $(el).find('input[name=emission_year]').val();
      const value = $(el).find('input[name=emission_value]').val();

      result[year] = value;
    });

    return result;
  }

  //actions
  addEmission() {
    const content = this.emissionRowTemplateTarget.innerHTML;
    this.emissionRowAddTarget.insertAdjacentHTML('beforebegin', content);
  }

  removeEmission() {
    const element = event.target.closest('tr');
    element.remove();
  }
}
