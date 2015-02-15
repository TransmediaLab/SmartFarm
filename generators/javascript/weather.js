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
 * @fileoverview Generating JavaScript for weather blocks.
 * @author nhbean@k-state.edu (Nathan H. Bean)
 */
'use strict';

goog.require('Blockly.JavaScript');

Blockly.JavaScript['weather_set_precipitation'] = function(block) {
  var precipitation = Blockly.JavaScript.valueToCode(block, 'PRECIPITATION', Blockly.JavaScript.ORDER_ATOMIC);
  var measure = block.getFieldValue('MEASURE');
  var form = block.getFieldValue('FORM');  
  // Convert to mm, if needed
  if(measure == 'INCHES') {
    precipitation = '((' + precipitation + ') * 25.4)';
  }
  // Store in the appropriate variable
  switch(form) {
    case 'RAIN':
      return 'set_rainfall(' + precipitation + ');\n';
    case 'SNOW':
      return 'set_snowfall(' + precipitation + ');\n';
  }
  return '';
};

Blockly.JavaScript['weather_get_precipitation'] = function(block) {
  var measure = block.getFieldValue('MEASURE');
  var form = block.getFieldValue('FORM');
  var code = '0';
  // Retrieve from the appropriate variable
  switch(form) {
    case 'RAIN':
      code = 'get_rainfall()';
      break;
    case 'SNOW':
      code = 'get_snowfall()';
      break;
  }
  // Convert to mm, if needed
  if(measure == 'INCHES') {
    code = '((' + code + ') / 25.4)';
  }
  return [code, Blockly.JavaScript.ORDER_ATOMIC];
};

Blockly.JavaScript['weather_set_solar_radiation'] = function(block) {
  var radiation = Blockly.JavaScript.valueToCode(block, 'RADIATION', Blockly.JavaScript.ORDER_ATOMIC);
  var unit = block.getFieldValue('UNIT');
  // Convert if necessary
  if(unit == 'LANGLEY') {
    radiation = '((' + radiation + ') * 41840)';
  }
  return 'set_solar_radiation(' + radiation + ');\n';
};

Blockly.JavaScript['weather_get_solar_radiation'] = function(block) {
  var unit = block.getFieldValue('UNIT');
  var code = 'get_solar_radiation()';
  // Change units if necessary
  if(unit == 'LANGLEY') {
    code = '((' + code + ') / 41840)';
  }
  return [code, Blockly.JavaScript.ORDER_ATOMIC];
};

Blockly.JavaScript['weather_set_temperature'] = function(block) {
  var temperature = Blockly.JavaScript.valueToCode(block, 'TEMP', Blockly.JavaScript.ORDER_ATOMIC);
  var measure = block.getFieldValue('MEASURE');
  var category = block.getFieldValue('CATEGORY');
  // Convert to Degrees C, if needed
  if(measure == 'DEGREES_F') {
    temperature = '(((' + temperature + ') - 32) * (5/9))';
  }
  // Store in the appropriate variable
  switch(category) {
    case 'AVERAGE':
      return 'set_average_temperature(' + temperature + ');\n';
    case 'HIGH':
      return 'set_high_temperature(' + temperature + ');\n';
    case 'LOW': 
      return 'set_low_temperature(' + temperature + ');\n';
  }
  return '';
};

Blockly.JavaScript['weather_get_temperature'] = function(block) {
  var measure = block.getFieldValue('MEASURE');
  var category = block.getFieldValue('CATEGORY');
  var code = '0';
  // Retrieve from the appropriate variable
  switch(category) {
    case 'AVERAGE':
      code = 'get_average_temperature()';
      break;
    case 'HIGH':
      code = 'get_high_temperature()';
      break;
    case 'LOW':
      code = 'get_low_temperature()';
      break;
  }
  // Convert to degrees F, if needed
  if(measure == 'DEGREES_F') {
    code = '((' + code + ') * 9/5 + 32)';
  }
  return [code, Blockly.JavaScript.ORDER_ATOMIC];
};

Blockly.JavaScript['weather_set_wind_speed'] = function(block) {
  var speed = Blockly.JavaScript.valueToCode(block, 'SPEED', Blockly.JavaScript.ORDER_ATOMIC);
  var measure = block.getFieldValue('MEASURE');
  // convert to m/s, if neccessary
  if(measure == 'MILES_PER_HOUR') {
    speed = '((' + speed + ') * 0.44704)';
  }
  // store wind_speed
  return 'set_wind_speed(' + speed + ');\n';
};

Blockly.JavaScript['weather_get_wind_speed'] = function(block) {
  var measure = block.getFieldValue('MEASURE');
  var code = 'get_wind_speed()';
  // convert to miles/hour, if necessary
  if(measure == 'MILES_PER_HOUR') {
    code = '((' + code + ') / 0.44704)';
  }
  return [code, Blockly.JavaScript.ORDER_ATOMIC];
};

Blockly.JavaScript['weather_set_wind_direction'] = function(block) {
  var direction = Blockly.JavaScript.valueToCode(block, 'DIRECTION', Blockly.JavaScript.ORDER_ATOMIC);
  return 'set_wind_direction(' + direction + ');\n';
};

Blockly.JavaScript['weather_get_wind_direction'] = function(block) {
  return ['get_wind_direction()', Blockly.JavaScript.ORDER_ATOMIC];
};

Blockly.JavaScript['weather_get_dew_point'] = function(block) {
  var unit = block.getFieldValue('UNIT');
  code = 'get_dew_point()';

  // Convert to degrees F, if needed
  if(unit == 'DEGREES_F') {
    code = '(' + code + ' * 9/5 + 32)';
  }
  return [code, Blockly.JavaScript.ORDER_ATOMIC];
};

Blockly.JavaScript['weather_set_relative_humidity'] = function(block) {
  var humidity = Blockly.JavaScript.valueToCode(block, 'RELATIVE_HUMIDITY', Blockly.JavaScript.ORDER_ATOMIC);
  return 'set_relative_humidity(' + humidity + ');\n';
};

Blockly.JavaScript['weather_get_relative_humidity'] = function(block) {
  return ['get_relative_humidity()', Blockly.JavaScript.ORDER_ATOMIC];
};

