/**
 * @license
 * SmartFarm
 *
 * Copyright 2015 Department of Computing and Information Sciences
 * Kansas State University
 * https://cis.ksu.edu
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @fileoverview Plant Editor conrols for SmartFarm.
 * @author nhbean@ksu.edu (Nathan H. Bean)
 */
jQuery(function() {

  /* Set up the websocket communication layer */
  var id = window.location.pathname.split('/')[2],
      ws = new WebSocket("ws://" + window.location.host + "/plants/" + id + "/ws"),
      months = [],
      tempMeasure = 'C';

  /* Set up the blockly editor once the websocket opens*/
  ws.onopen = function() {
    Blockly.inject(document.getElementById('blocklyDiv'),{
      toolbox: document.getElementById('toolbox')
    });
    Blockly.addChangeListener(function() {
      var xml = Blockly.Xml.workspaceToDom(Blockly.getMainWorkspace()),
          xmlText, 
          code,
          msg = {data:{}};
      xml.id = "workspace";
      xml.setAttribute("style", "display: none");
      msg.type = "change-code"
      msg.data.workspace = Blockly.Xml.domToText(xml);
      msg.data.code = Blockly.Elixir.workspaceToCode();
      msg.data.variables = Blockly.Variables.allVariables(Blockly.mainWorkspace);
      ws.send(JSON.stringify(msg));
    });
  };

  ws.onclose = function() {
    alert("Connection to the server lost. Please refresh the page to re-establish it.");
  }

  $(document).on('logged-in', function(event, user_id, token){
    ws.send(JSON.stringify({type: 'logged-in', data: {user_id: user_id, token: token}}));
  });

  $(document).on('logged-out', function(event){
    ws.send(JSON.stringify({type: 'logged-out'}));
  });


  /* Server response handling */
  ws.onmessage = function(event) {
    var msg = JSON.parse(event.data);
    switch(msg.type) {
      case "not-logged-in":
        $(document).trigger('log-in-to-save');
        break;
      case "new-id":
        window.history.pushState("", "", "/plants/" + msg["data"]);
        break;
      case "workspace":
        var xml = Blockly.Xml.textToDom(msg.data);
        Blockly.Xml.domToWorkspace(Blockly.mainWorkspace, xml);
      case "plant":
        var xml = Blockly.Xml.textToDom(msg.data.workspace);
        Blockly.Xml.domToWorkspace(Blockly.mainWorkspace, xml);
        $('#plant-name').val(msg.data.name);
        $('#plant-description').val(msg.data.description);
        break;
      case "state":
        updateTime(msg.data.simulation_time);
        updateWeather(msg.data);
        updatePlants(msg.data.plants);
        break;
    }
  }



  $('#run').prop('disabled', false)
  $('#pause').prop('disabled', true)
  $('#step').prop('disabled', false)

  /* Server interaction commands */
  $('#run').on('click', function(){
    ws.send('{"type":"run"}');
    $('#run').prop('disabled', true);
    $('#pause').prop('disabled', false);
    $('#step').prop('disabled', true);
  });

  $('#pause').on('click', function(){
    ws.send('{"type":"pause"}');
    $('#run').prop('disabled', false);
    $('#pause').prop('disabled', true);
    $('#step').prop('disabled', false);
  });

  $('#step').on('click', function(){
    ws.send('{"type":"step"}');
    $('#run').prop('disabled', false);
    $('#pause').prop('disabled', true);
    $('#step').prop('disabled', false);
  });

  $('#reset').on('click', function(){
    ws.send('{"type":"reset"}');
    $('#run').prop('disabled', false);
    $('#pause').prop('disabled', true);
    $('#step').prop('disabled', false);
    $('#weather-history').empty();
  });

  $('#save').on('click', function(){
    var msg = {};
    msg.type = "save";
    ws.send(JSON.stringify(msg));
  });

  $('#plant-name').on('change', function(){
    var msg = {};
    msg.type = "name";
    msg.data = $('#plant-name').val();
    ws.send(JSON.stringify(msg));
  });

  $('#plant-description').on('change', function(){
    var msg = {};
    msg.type = "description";
    msg.data = $('#plant-description').val();
    ws.send(JSON.stringify(msg));
  });

  /* Set calendar values */
  function updateTime(time) {
    var simTime = new Date(time);
    $('#calendar-day').html(simTime.getDate());
    $('#calendar-month').html(months[simTime.getMonth()][1]);
  }

  months[0] = ["Januaray", "Jan"];
  months[1] = ["February", "Feb"];
  months[2] = ["March", "March"];
  months[3] = ["April", "April"];
  months[4] = ["May", "May"];
  months[5] = ["June", "June"];
  months[6] = ["July", "July"];
  months[7] = ["August", "Aug"];
  months[8] = ["September", "Sept"];
  months[9] = ["October", "Oct"];
  months[10] = ["November", "Nov"];
  months[11] = ["December", "Dec"];


  /* Set weather values */
  function updateWeather(state) {

    var simTime = new Date(state.simulation_time),
        html = "";
    html += months[simTime.getMonth()][0] + " " + simTime.getDate() + " " + simTime.getFullYear();
    html += formatForecast(state);
    html += ' <i class="wi wi-thermometer"></i>' + formatTemperature(state.weather_average_temperature);
    html += ' <i class="wi wi-up"></i>' + formatTemperature(state.weather_high_temperature);
    html += ' <i class="wi wi-down"></i>' + formatTemperature(state.weather_low_temperature);
    if(tempMeasure == "C")
      html += ' <i class="wi wi-celsius"></i>';
    else
      html += ' <i class="wi wi-fahrenheit"></i>';
    html += ' <i class="wi wi-sprinkles"></i>' + ((state.weather_rainfall ? state.weather_rainfall : 0) + (state.weather_snowfall ? state.weather_snowfall : 0)) + ' inches'; 
    $('#weather-status').html(html);
  }

  function formatForecast(state) {
    var snow = (state.weather_snowfall && state.weather_snowfall > 0),
        rain = (state.weather_rainfall && state.weather_rainfall > 0) 
    if(rain && snow) 
      return ' <i class="wi wi-rain-mix"></i> ';
    else if(snow) 
      return ' <i class="wi wi-snow"></i>';
    else if(rain) 
      return ' <i class="wi wi-rain"></i>';
    else 
      return ' <i class="wi wi-day-sunny"></i>';
  }

  function formatValue(value) {
    if(value) return value;
    else return "?";
  }

  function formatTemperature(temperature) {
    if(temperature) {
      if(tempMeasure == 'C') return temperature;
      else return (temperature *(9.0/5.0) + 32);
    } else return "?";
  }

  /* Set Plant values */
  var draw = SVG('plant-rendering').size(480, 480).viewbox(-210, -400, 420, 420);
  var ground = draw.rect(420, 20).x(-210).fill('#996633');
  var seed = draw.circle(2).fill('green');
  var plants = draw.group();
  function updatePlants(populationState) {
    plants.clear();
    populationState.forEach( function(state) {
      if(state.svg_path) state.svg_path.forEach( function(path) {
        plants.path(path).stroke('green').fill('none');
      });
    });
  }

});
