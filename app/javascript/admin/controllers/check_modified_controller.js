/* eslint-disable consistent-return */

import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.unsaved = false;

    $(window).bind('beforeunload', () => {
      if (this.unsaved) return 'Changes you made may not be saved.';
    });

    $('input, select', this.element).on('input change', this._trackChanges.bind(this));
    $('trix-editor', this.element).on('trix-change', this._trackChanges.bind(this));

    $(this.element).on('submit', () => {
      this.unsaved = false;
    });
  }

  _trackChanges() {
    this.unsaved = true;
  }
}
