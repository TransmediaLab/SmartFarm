jQuery(function() {
  Blockly.inject(document.getElementById('blocklyDiv'),{
    toolbox: document.getElementById('toolbox'),
    workspace: document.getElementById('workspace')
  });

  document.ws = new WebSocket('ws://gameken.com/_ws', 'weather-protocol');

  document.ws.onopen = function() {
    document.ws.send('{"type":"load-weather","data":{"id":' + 1 + '}}');
  };

  /* Server interaction commands */
  $('#pause').on('click', function(){
    console.log("pause");
    document.ws.send('{"type":"pause"}');
  });

  $('#step').on('click', function(){
    console.log("step");
    document.ws.send('{"type":"step"}');
  });

  $('#run').on('click', function(){
    console.log("resume");
    document.ws.send('{"type":"run"}');
  });

  $('#reset').on('click', function(){
    document.ws.send('{"type":"reset"}');
    console.log("reset");
  });

  $('#save').on('click', function(){
    var xml = Blockly.Xml.workspaceToDom(Blockly.getMainWorkspace()),
        xmlText, 
        code,
        msg = {type:"update",data:{}};
    xml.id = "workspace";
    xml.setAttribute("style", "display: none");
    msg.data.workspace = Blockly.Xml.domToText(xml);
    msg.data.code = Blockly.JavaScript.workspaceToCode();
    document.ws.send(JSON.stringify(msg));
  });

  /* Server response handling */

  document.ws.onmessage = function(msg) {
console.log(msg);
    
    var state = JSON.parse(msg.data);
    console.log(state.type);
    switch(state.type) {
      case "time":
        updateTime(state.data);
        break;
      case "weather":
        updateWeather(state.data);
        break;
    }
  }


  function updateTime(state) {

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

  function updateWeather(state) {
    var info = ""

    if(state.snowfall > 0 && state.rainfall > 0) 
      info += '<i class="wi wi-rain-mix"></i> ';
    else if(state.snowfall > 0) 
      info += '<i class="wi wi-snow"></i>';
    else if(state.rainfall > 0) 
      info += '<i class="wi wi-rain"></i>';
    else 
      info += '<i class="wi wi-day-sunny"></i>';
    
    
    info += state.average_temperature;
    info += '<i class="wi wi-fahrenheit"></i>';
    
    $('#weather-info').html(info);

    $('#weather-precipitation').html("Precipitation: " + (state.snowfall + state.rainfall) + " inches");
    
  }

});
