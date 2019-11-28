import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['links']

  connect() {
    this.wrapperClass = this.data.get('wrapperClass') || 'nested-fields';
  }

  addRecord(event) {
    const templateName = event.target.dataset['template'];
    const content = this._getTemplateElement(templateName)
                        .innerHTML
                        .replace(/NEW_RECORD/g, new Date().getTime());

    this._manipulateDOM(content);
  }

  addNestedRecord(event) {
    const templateName = event.target.dataset['template'];
    const content = this._getTemplateElement(templateName)
                        .innerHTML
                        .replace(/NEW_IMAGE_RECORD/g, new Date().getTime());

    this._manipulateDOM(content);
  }

  removeRecord(event) {
    event.preventDefault();

    const wrapper = event.target.closest('.' + this.wrapperClass);

    // New records are simply removed from the page
    if (wrapper.dataset.newRecord == 'true') {
      wrapper.remove();

      // Existing records are hidden and flagged for deletion
    } else {
      wrapper.querySelector('input[name*="_destroy"]').value = 1;
      wrapper.style.display = 'none';
    }
  }

  _getTemplateElement(name) {
    if (!name) return this.element.querySelector('template');

    return this.element.querySelector(`template[name*=${name}]`);
  }

  _manipulateDOM(content) {
    this.linksTarget.insertAdjacentHTML('beforebegin', content);

    // very nasty trick, using dynamic list instead of AA has_many forms
    // many plugins listen to this event to reinitialize, for example select2 from activeadmin addons
    document.dispatchEvent(new Event('has_many_add:after'));
  }
}
