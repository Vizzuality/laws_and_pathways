// Fix taken from here
// https://github.com/select2/select2/issues/4614#issuecomment-251277428

function fixPositioning(element) {
  this.dropdown._resizeDropdown();
  this.dropdown._positionDropdown();
}

// fix wrong positioning issue for ajax select2
function fixSelectedListPositioningForAllElements() {
  for (const element of document.querySelectorAll('select.selected-list-input')) {
    $(element).one('select2:opening', function() {
      $(element).data('select2').on('results:message', fixPositioning);
    });
  }
}

document.addEventListener("DOMContentLoaded", fixSelectedListPositioningForAllElements);
document.addEventListener("turbolinks:load", fixSelectedListPositioningForAllElements);
