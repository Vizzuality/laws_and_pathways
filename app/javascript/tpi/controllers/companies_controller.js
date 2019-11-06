import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['mqAssessmentContent', 'cpAssessmentContent']

  connect() {
    console.log('Connected');
  }

  mqAssessmentDateChange(event) {
    const newUrl = new URL(window.location.href);
    newUrl.searchParams.set('mq_assessment_id', event.target.value);

    fetch(`${newUrl.pathname}/mq_assessment?mq_assessment_id=${event.target.value}`)
      .then(response => response.text())
      .then(html => {
        this.mqAssessmentContentTarget.innerHTML = html;
        window.history.pushState({}, '', newUrl.href);
      });

    /* window.history.pushState({}, 'Title aa', newUrl.href); */
    /* window.location.href = newUrl.href; */
    /* Turbolinks.scroll['cache'] = window.scrollY; */
    /* Turbolinks.visit(newUrl.href); */
  }

  cpAssessmentDateChange(event) {
    const newUrl = new URL(window.location.href);
    newUrl.searchParams.set('cp_assessment_id', event.target.value);

    fetch(`${newUrl.pathname}/cp_assessment?cp_assessment_id=${event.target.value}`)
      .then(response => response.text())
      .then(html => {
        this.cpAssessmentContentTarget.innerHTML = html;
        window.history.pushState({}, '', newUrl.href);
      });

    /* window.history.pushState({}, 'Title aa', newUrl.href); */
    /* window.location.href = newUrl.href; */
    /* Turbolinks.scroll['cache'] = window.scrollY; */
    /* Turbolinks.visit(newUrl.href); */
  }
}
