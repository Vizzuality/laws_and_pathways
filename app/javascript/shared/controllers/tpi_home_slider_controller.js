import { Controller } from '@hotwired/stimulus';
import { tns } from 'tiny-slider/src/tiny-slider';

export default class extends Controller {
  static targets = ['items'];

  static values = {
    tabletItems: { type: Number, default: 3 },
    desktopItems: { type: Number, default: 3 }
  };

  connect() {
    this.slider = tns({
      container: this.itemsTarget,
      controls: true,
      controlsText: [
        '<i class="fa fa-1x fa-arrow-left"></i>',
        '<i class="fa fa-1x fa-arrow-right"></i>'
      ],
      edgePadding: 20,
      gutter: 20,
      items: 1,
      loop: false,
      mouseDrag: true,
      nav: false,
      slideBy: 'page',
      swipeAngle: 30,
      responsive: {
        768: {
          edgePadding: 0,
          items: this.tabletItemsValue
        },
        992: {
          edgePadding: 0,
          items: this.desktopItemsValue
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
