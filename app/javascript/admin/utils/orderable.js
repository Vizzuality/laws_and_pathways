/* eslint-disable */

(function ($) {
  $(document).ready(function () {
    $('.handle').closest('tbody').activeAdminSortable();
  });

  $.fn.activeAdminSortable = function () {
    this.sortable({
      handle: '.handle',
      update(event, ui) {
        const item = ui.item.find('[data-sort-url]');
        const url = item.data('sort-url');
        let customParams = {};
        if (typeof item.data('sort-custom-params') === 'object') {
          customParams = item.data('sort-custom-params');
        }

        $.ajax({
          url,
          type: 'post',
          data: $.extend(customParams, { position: ui.item.index() + 1 }),
          error() { console.error('Saving sortable error'); },
          success() {
            $('tr', $('.handle').closest('tbody')).removeClass('even odd');
            $('tr', $('.handle').closest('tbody')).filter(':even').addClass('odd');
            $('tr', $('.handle').closest('tbody')).filter(':odd').addClass('even');
          }
        });
      }
    });

    this.disableSelection();
  };
}(jQuery));
