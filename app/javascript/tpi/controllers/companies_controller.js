import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['assessmentDateSelect', 'assessmentContent']

  connect() {
    console.log('Connected');
  }

  assessmentDateChange(event) {
    const newUrl = new URL(window.location.href);
    newUrl.searchParams.set('mq_assessment_id', event.target.value);

    fetch(`${newUrl.pathname}/mq_assessment?mq_assessment=${event.target.value}`)
      .then(response => response.text())
      .then(html => {
        this.assessmentContentTarget.innerHTML = html;
      });

    /* window.history.pushState({}, 'Title aa', newUrl.href); */
    /* window.location.href = newUrl.href; */
    /* Turbolinks.scroll['cache'] = window.scrollY; */
    /* Turbolinks.visit(newUrl.href); */
  }
}
