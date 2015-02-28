/**
 * @license
 * SmartFarm hackable glass simulation, built on Google's Blockly
 *
 * Copyright 2014 Computing and Information Sciences, Kansas State University.
 * http://smartfarm.cis.k-state.edu
 * 
 * Copyright 2012 Google Inc.
 * https://developers.google.com/blockly/
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
 * @fileoverview Generating Elixir for weather blocks.
 * @author nhbean@k-state.edu (Nathan H. Bean)
 */
'use strict';

goog.require('Blockly.Elixir');


/**
  * List of illegal vairable names, specific to the Weather module
  */
Blockly.Elixir.addReservedWords(
  "weather_rainfall", "weather_snowfall",
  "weather_solar_radiation", 
  "weather_average_temperature", "weather_high_temperature", "weather_low_temperature",
  "weather_wind_speed", "weather_wind_direction",
  "weather_dew_point", "weather_relative_humidity"
);


Blockly.Elixir['weather_set_precipitation'] = function(block) {
  var precipitation = Blockly.Elixir.valueToCode(block, 'PRECIPITATION', Blockly.Elixir.ORDER_ATOMIC);
  var measure = block.getFieldValue('MEASURE');
  var form = block.getFieldValue('FORM');  
  // Convert to mm, if needed
  if(measure == 'INCHES') {
    precipitation = '((' + precipitation + ') * 25.4)';
  }
  // Store in the appropriate variable
  switch(form) {
    case 'RAIN':
      return 'weather_rainfall = ' + precipitation + '\n';
    case 'SNOW':
      return 'weather_snowfall=' + precipitation + '\n';
  }
  return '';
};

Blockly.Elixir['weather_get_precipitation'] = function(block) {
  var measure = block.getFieldValue('MEASURE');
  var form = block.getFieldValue('FORM');
  var code = '0';
  // Retrieve from the appropriate variable
  switch(form) {
    case 'RAIN':
      code = 'weather_rainfall';
      break;
    case 'SNOW':
      code = 'weather_snowfall';
      break;
  }
  // Convert to mm, if needed
  if(measure == 'INCHES') {
    code = '((' + code + ') / 25.4)';
  }
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['weather_set_solar_radiation'] = function(block) {
  var radiation = Blockly.Elixir.valueToCode(block, 'RADIATION', Blockly.Elixir.ORDER_ATOMIC);
  var unit = block.getFieldValue('UNIT');
  // Convert if necessary
  if(unit == 'LANGLEY') {
    radiation = '((' + radiation + ') * 41840)';
  }
  return 'weather_solar_radiation = ' + radiation + '\n';
};

Blockly.Elixir['weather_get_solar_radiation'] = function(block) {
  var unit = block.getFieldValue('UNIT');
  var code = 'weather_solar_radiation';
  // Change units if necessary
  if(unit == 'LANGLEY') {
    code = '((' + code + ') / 41840)';
  }
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['weather_set_temperature'] = function(block) {
  var temperature = Blockly.Elixir.valueToCode(block, 'TEMP', Blockly.Elixir.ORDER_ATOMIC);
  var measure = block.getFieldValue('MEASURE');
  var category = block.getFieldValue('CATEGORY');
  // Convert to Degrees C, if needed
  if(measure == 'DEGREES_F') {
    temperature = '(((' + temperature + ') - 32) * (5/9))';
  }
  // Store in the appropriate variable
  switch(category) {
    case 'AVERAGE':
      return 'weather_average_temperature=' + temperature + '\n';
    case 'HIGH':
      return 'weather_high_temperature=' + temperature + '\n';
    case 'LOW': 
      return 'weather_low_temperature=' + temperature + '\n';
  }
  return '';
};

Blockly.Elixir['weather_get_temperature'] = function(block) {
  var measure = block.getFieldValue('MEASURE');
  var category = block.getFieldValue('CATEGORY');
  var code = '0';
  // Retrieve from the appropriate variable
  switch(category) {
    case 'AVERAGE':
      code = 'weather_average_temperature';
      break;
    case 'HIGH':
      code = 'weather_high_temperature';
      break;
    case 'LOW':
      code = 'weather_low_temperature';
      break;
  }
  // Convert to degrees F, if needed
  if(measure == 'DEGREES_F') {
    code = '(' + code + '*9/5+32)';
  }
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['weather_set_wind_speed'] = function(block) {
  var speed = Blockly.Elixir.valueToCode(block, 'SPEED', Blockly.Elixir.ORDER_ATOMIC);
  var measure = block.getFieldValue('MEASURE');
  // convert to m/s, if neccessary
  if(measure == 'MILES_PER_HOUR') {
    speed = '(' + speed + '*0.44704)';
  }
  // store wind_speed
  return 'weather_wind_speed=' + speed + '\n';
};

Blockly.Elixir['weather_get_wind_speed'] = function(block) {
  var measure = block.getFieldValue('MEASURE');
  var code = 'weather_wind_speed';
  // convert to miles/hour, if necessary
  if(measure == 'MILES_PER_HOUR') {
    code = '(' + code + '/0.44704)';
  }
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['weather_set_wind_direction'] = function(block) {
  var direction = Blockly.Elixir.valueToCode(block, 'DIRECTION', Blockly.Elixir.ORDER_ATOMIC);
  return 'weather_wind_direction=' + direction + '\n';
};

Blockly.Elixir['weather_get_wind_direction'] = function(block) {
  return ['weather_wind_direction', Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['weather_get_dew_point'] = function(block) {
  var unit = block.getFieldValue('UNIT');
  code = 'weather_dew_point';

  // Convert to degrees F, if needed
  if(unit == 'DEGREES_F') {
    code = '(' + code + '*9/5+32)';
  }
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['weather_set_relative_humidity'] = function(block) {
  var humidity = Blockly.Elixir.valueToCode(block, 'RELATIVE_HUMIDITY', Blockly.Elixir.ORDER_ATOMIC);
  return 'weather_relative_humidity=' + humidity + '\n';
};

Blockly.Elixir['weather_get_relative_humidity'] = function(block) {
  return ['weather_relative_humidity', Blockly.Elixir.ORDER_ATOMIC];
};

