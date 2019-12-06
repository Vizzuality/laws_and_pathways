import { Controller } from 'stimulus';

export default class extends Controller {
  showCount = 10;

  step = 10;

  items = [];

  buttonEl = null;

  connect() {
    this.buttonEl = this.element.getElementsByClassName('load-more-btn')[0];
    this.items = this.element.getElementsByClassName('content-item');
    this.checkButton();
    for (let i = this.showCount; i < this.items.length; i += 1) {
      this.items[i].style.display = 'none';
    }
    $(this.buttonEl).click(this.loadMore.bind(this));
  }

  loadMore() {
    this.showCount += this.step;

    for (let i = 0; i < this.items.length; i += 1) {
      this.items[i].style.display = this.showCount <= i ? 'none' : 'block';
    }
    this.checkButton();
  }

  checkButton() {
    if (this.items.length <= this.showCount) {
      this.buttonEl.style.display = 'none';
    }
  }

  disconnect() {
    $(this.buttonEl).off('click');
  }
}
