jQuery(function() {

  /* Set up the blockly editor */
  Blockly.inject(document.getElementById('blocklyDiv'),{
    toolbox: document.getElementById('toolbox'),
    workspace: document.getElementById('workspace')
  });

  /* Set up the websocket communication layer */
  var ws = new WebSocket('ws://gameken.com/simulation_ws', 'simulation-protocol');

  document.ws = ws;

  ws.onopen = function() {
    var weather_id = $('#weather-id').val()
    if(weather_id) {
      ws.send('{"type":"load-weather","data":{"id":' + weather_id + '}}');
    }
    var plant_id = $('#plant-id').val()
    if(plant_id) {
      ws.send('{"type":"load-plants","data":{"id":' + plant_id + '}}');
    }
    Blockly.addChangeListener(function(){
      var xml = Blockly.Xml.workspaceToDom(Blockly.getMainWorkspace()),
          xmlText, 
          code,
          msg = {data:{}};
      msg.type = "change-" + document.location.pathname.split("/")[1]
      xml.id = "workspace";
      xml.setAttribute("style", "display: none");
      msg.data.workspace = Blockly.Xml.domToText(xml);
      msg.data.code = Blockly.JavaScript.workspaceToCode();
      ws.send(JSON.stringify(msg));    
console.log(msg);
    });
  };

  $('#run').prop('disabled', false)
  $('#pause').prop('disabled', true)
  $('#step').prop('disabled', false)

  /* Server interaction commands */
  $('#run').on('click', function(){
    ws.send('{"type":"run"}');
    $('#run').prop('disabled', true)
    $('#pause').prop('disabled', false)
    $('#step').prop('disabled', true)
  });

  $('#pause').on('click', function(){
    ws.send('{"type":"pause"}');
    $('#run').prop('disabled', false)
    $('#pause').prop('disabled', true)
    $('#step').prop('disabled', false)
  });

  $('#step').on('click', function(){
    ws.send('{"type":"step"}');
    $('#run').prop('disabled', false)
    $('#pause').prop('disabled', true)
    $('#step').prop('disabled', false)
  });

  $('#reset').on('click', function(){
    ws.send('{"type":"reset"}');
    $('#run').prop('disabled', false)
    $('#pause').prop('disabled', true)
    $('#step').prop('disabled', false)
  });

  $('#save').on('click', function(){
console.log('saving');
    var msg = {}
    msg.type = "save-" + document.location.pathname.split("/")[1]
    ws.send(JSON.stringify(msg));
console.log(msg);
/*
    var xml = Blockly.Xml.workspaceToDom(Blockly.getMainWorkspace()),
        xmlText, 
        code,
        msg = {data:{}};
    msg.type = "update-" + document.location.pathname.split("/")[1]
    xml.id = "workspace";
    xml.setAttribute("style", "display: none");
    msg.data.workspace = Blockly.Xml.domToText(xml);
    msg.data.code = Blockly.JavaScript.workspaceToCode();
    ws.send(JSON.stringify(msg));
*/
  });

  /* Server response handling */
  ws.onmessage = function(msg) {
console.log(msg);
    
    var state = JSON.parse(msg.data);
    console.log(state.type);
    switch(state.type) {
      case "workspace":
        var xml = Blockly.Xml.textToDom(state.data);
        Blockly.Xml.domToWorkspace(Blockly.mainWorkspace, xml);
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
      case 0:
        $('#calendar-month').html("Jan");
        break;
      case 1:
        $('#calendar-month').html("Feb");
        break;
      case 2: 
        $('#calendar-month').html("March");
        break;
      case 3:
        $('#calendar-month').html("April");
        break;
      case 4:
        $('#calendar-month').html("May");
        break;
      case 5:
        $('#calendar-month').html("June");
        break;
      case 6:
        $('#calendar-month').html("July");
        break;
      case 7:
        $('#calendar-month').html("Aug");
        break;
      case 8: 
        $('#calendar-month').html("Sept");
        break;
      case 9:
        $('#calendar-month').html("Oct");
        break;
      case 10:
        $('#calendar-month').html("Nov");
        break;
      case 11:
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
