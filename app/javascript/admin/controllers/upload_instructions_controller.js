import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['uploaderSelect', 'showLink']

  showInstructions(e) {
    e.preventDefault();
    const uploader = this.uploaderSelectTarget.value;
    fetch(`/admin/data_uploads/instruction?uploader=${uploader}`)
      .then((res) => {
        if (!res.ok) throw new Error('error');
        return res.text();
      }).then((html) => {
        let instructionModal = document.querySelector('#instruction_modal');
        if (!instructionModal) {
          instructionModal = document.createElement('div');
          instructionModal.id = 'instruction_modal';
          document.body.appendChild(instructionModal);
        }
        instructionModal.innerHTML = html;
        $(instructionModal).dialog({
          dialogClass: 'dialog-no-title',
          width: window.innerWidth * 0.9,
          modal: true,
          buttons: [
            {
              text: 'Close',
              click() {
                $(this).dialog('close');
              }
            }
          ],
          open() {
            $('.ui-widget-overlay').bind('click', () => {
              $(this).dialog('close');
            });
          }
        });
      })
      .catch(() => {
        alert('Error occured while showing instructions'); // eslint-disable-line
      });
  }
}
