$(function(){

  $('body').on('click', '.login-link', function(event) {
    event.preventDefault();
    $('#login-dialog').modal();
    $('#login-username').focus();
    return false;
  });

  $('body').on('click', '.signup-link', function(event) {
    event.preventDefault();
    $('#login-dialog').modal('hide');
    $('#signup-dialog').modal();
    $('#signup-username').focus();
    return false;
  });

  $('body').on('click', '.logout-link', function(event) {
    event.preventDefault();
    $.ajax('/logout', {
      method: "GET",
      success: function(data) {
        alert("Logged out!");
        $('#session-message').html(data);
        $('.logged-in').hide();
        $('.logged-out').show();
      }
    });
    return false;
  });

  $('#login-button').on('click', function(event) {
    var username = $('#login-username').val(),
        password = $('#login-password').val();
    $.ajax('/login', {
      method: "POST",
      data: {username: username, password: password},
      success: function(data) {
        $('#login-dialog').modal('hide');
        $('#session-message').html(data);
        $('.logged-in').show();
        $('.logged-out').hide();
      },
      error: function(xhr) {
        $('#login-message').html(xhr.responseText);
      }
    });    
  });

  $('#signup-button').on('click', function(event) {
    $.ajax('/signup', {
      method: "POST",
      data: {
        username: $('#signup-username').val(), 
        password: $('#signup-password').val(), 
        password_confirmation: $('#signup-password-confirmation').val(),
        teacher: $('#signup-teacher').prop('checked')
      },
      success: function(data) {
        $('#signup-dialog').modal('hide');
        $('#signed-in-message').html(data);
        $('.logged-in').show();
        $('.logged-out').hide();
      },
      error: function(xhr) {
        $('#signup-message').html(xhr.responseText);
      }
    });    
  });

});
