import { Controller } from '@hotwired/stimulus';

const Trix = require('trix');

export default class extends Controller {
  connect() {
    const toolbar = this.element.toolbarElement;
    const embedButton = `
      <button type="button" class="trix-button trix-button--icon trix-button--icon-video"
        data-trix-attribute="video" title="Embed Video" tabindex="-1">Video</button>`;
    const videoDialog = `
      <div class="trix-dialog trix-dialog--video" data-trix-dialog="video" data-trix-dialog-attribute="video">
         <div class="trix-dialog__link-fields">
          <input type="url" name="video" class="trix-input trix-input--dialog"
            placeholder="Enter a Youtube URL…" aria-label="URL" required="" data-trix-input="" disabled="disabled">
          <div class="trix-button-group">
            <input type="button" class="trix-button trix-button--dialog" value="Insert"
              data-trix-method="setAttribute" data-trix-dialog-submit--video>
            <input type="button" class="trix-button trix-button--dialog" value="Cancel" data-trix-method="removeAttribute">
          </div>
        </div>
      </div>`;
    toolbar.querySelector('.trix-button-group--block-tools').insertAdjacentHTML('beforeend', embedButton);
    toolbar.querySelector('[data-trix-dialogs]').insertAdjacentHTML('beforeend', videoDialog);
    toolbar.querySelector('[data-trix-dialog-submit--video]').addEventListener('click', (event) => {
      // Expecting to have input[name=video] in this position. If dialog changes
      // make sure to update this reference!
      const videoElement = event.target.parentElement.previousElementSibling;
      if (videoElement.value) {
        const youtubeId = this.getYoutubeId(videoElement.value);
        const videoEmbed = `<iframe width="420" height="315" src="https://www.youtube.com/embed/${youtubeId}"
          frameborder="0" allowfullscreen></iframe>`;
        const attachmentVideo = new Trix.Attachment({
          contentType: 'application/youtube-video.html',
          content: videoEmbed
        });
        this.element.editor.insertAttachment(attachmentVideo);
      }
    });
  }

  getYoutubeId(url) {
    let youtubeId = '';
    const match = url.replace(/(>|<)/gi, '').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/);
    if (match[2] !== undefined) {
      youtubeId = match[2].split(/[^0-9a-z_]/i);
      youtubeId = youtubeId[0];
    } else {
      youtubeId = url;
    }
    return youtubeId;
  }
}
