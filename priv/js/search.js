jQuery(function() {
  var search = "",
      user_ids = [];

  $('#search-button').on('click', function() {
    search = $('#search').val();
    retrieveResults();
  });

  $('.user-filter').on('change', function(event) {
    target = $(event.target)
    if(target.prop('checked'))
      user_ids.push(target.val());
    else {
      var i = user_ids.indexOf(target.val());
      user_ids.splice(i, 1);
    }
    retrieveResults();
  });

  function retrieveResults() {
    var qs = "";
    if(search != "") qs += "search=" + search;
    user_ids.forEach(function(user_id) {
      qs += "&user_id=" + user_id;
    });

    $.ajax( window.location.pathname, {
      data: qs,
      success: function(data) {
        $('#search-results').html(data);
      }
    });
  }

  $('.delete-button').on('click', function() {
    target = $(this);
    $.ajax( target.data('path'), {
      method: 'DELETE',
      success: function(data) {
        target.parent().remove();
      }
    });
  });

});
