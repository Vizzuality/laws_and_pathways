import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    $(this.element).slick({
      prevArrow: '<button type="button" class="slick-prev"><i class="fa fa-1x fa-arrow-left"></i></button>',
      nextArrow: '<button type="button" class="slick-next"><i class="fa fa-1x fa-arrow-right"></i></button>'
    });
  }

  disconnect() {
    $(this.element).unslick();
  }
}
