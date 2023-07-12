import { Controller } from '@hotwired/stimulus';
import { tns } from 'tiny-slider/src/tiny-slider';

export default class extends Controller {
  static targets = ['items'];

  connect() {
    this.slider = tns({
      container: this.itemsTarget,
      controls: false,
      controlsText: [
        '<i class="fa fa-1x fa-arrow-left"></i>',
        '<i class="fa fa-1x fa-arrow-right"></i>'
      ],
      gutter: 20,
      items: 1,
      loop: false,
      mouseDrag: true,
      nav: false,
      slideBy: 'page',
      swipeAngle: 30,
      responsive: {
        768: {
          items: 3,
          controls: true
        }
      },
      onInit(slider) {
        slider.nextButton.setAttribute('aria-label', 'Next');
        slider.prevButton.setAttribute('aria-label', 'Previous');
      }
    });
  }

  disconnect() {
    if (this.slider) this.slider.destroy();
  }
}
