jQuery(function() {
  Blockly.inject(document.getElementById('blocklyDiv'),
    {toolbox: document.getElementById('toolbox')});

  document.ws = new WebSocket('ws://gameken.com/_ws', 'weather-protocol');

  document.ws.onmessage = function(msg) {
console.log(msg);
    
    var state = JSON.parse(msg.data);
    console.log(state.type);
    switch(state.type) {
      case "time":
        updateTime(state.data);
        break;
    }
  }


  function updateTime(state) {
console.log(state);
    /* Set calendar values */
    clock = new Date(state.clock);

    $('#calendar-day').html(clock.getDate());

    switch(clock.getMonth()) {
      case 1:
        $('#calendar-month').html("Jan");
        break;
      case 2:
        $('#calendar-month').html("Feb");
        break;
      case 3: 
        $('#calendar-month').html("March");
        break;
      case 4:
        $('#calendar-month').html("April");
        break;
      case 5:
        $('#calendar-month').html("May");
        break;
      case 6:
        $('#calendar-month').html("June");
        break;
      case 7:
        $('#calendar-month').html("July");
        break;
      case 8:
        $('#calendar-month').html("Aug");
        break;
      case 9: 
        $('#calendar-month').html("Sept");
        break;
      case 10:
        $('#calendar-month').html("Oct");
        break;
      case 11:
        $('#calendar-month').html("Nov");
        break;
      case 12:
        $('#calendar-month').html("Dec");
        break;
    }
  }

  $('#pause').on('click', function(){
    console.log("pause");
    document.ws.send('pause\n');
  });

  $('#step').on('click', function(){
    console.log("step");
    document.ws.send('step\n');
  });

  $('#run').on('click', function(){
    console.log("resume");
    document.ws.send('resume\n');
  });

  $('#reset').on('click', function(){
    document.ws.send('reset\n');
    console.log("reset");
  });

});
