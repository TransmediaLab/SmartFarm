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
 * @fileoverview Weather blocks for Blockly.
 * @author nhbean@k-state.edu (Nathan H. Bean)
 * This file defines a set of Blockly blocks for manipulating a simulation's weather
 * The weather-related data used by the simulation is:
 * VARIABLE 			UNIT
 * -------------- 		-----
 * rainfall 			mm
 * snowfall 			mm
 * solar_radiation 		J/m*m
 * day_length 			?
 * average_temperature 		degrees C
 * low_temperature 		degrees C
 * high_temperature 		degrees C
 * wind_speed m/s
 * wind_direction  		compass degrees
 * dew_point 			degrees C
 * relative_humidity 		% saturation
 */
'use strict';

goog.require('Blockly.Blocks');

//
// Precipitation Blocks
// precipitation blocks are stored in mm; the blocks convert
// other values.
//-------------------------------------------------------------
Blockly.Blocks['weather_set_precipitation'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Set");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["rain", "RAIN"], ["snow", "SNOW"]]), "FORM");
    this.appendDummyInput()
        .appendField("to");
    this.appendValueInput("PRECIPITATION")
        .setCheck("Number");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["mm", "MM"], ["inches", "INCHES"]]), "MEASURE");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['weather_get_precipitation'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["rain", "RAIN"], ["snow", "SNOW"]]), "FORM");
    this.appendDummyInput()
        .appendField("in");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["mm", "MM"], ["inches", "INCHES"]]), "MEASURE");
    this.setInputsInline(true);
    this.setOutput(true);
    this.setTooltip('');
  }
};

//
// Solar Radiation Blocks
// solar radiation is stored in Joules per square meter
// the blocks convert other values
//-------------------------------------------------------------
Blockly.Blocks['weather_set_solar_radiation'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Set solar radiation to");
    this.appendValueInput("RADIATION")
        .setCheck("Number");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["Joules/m²", "JOULES_PER_SQUARE_METER"], ["Langleys", "LANGLEY"]]), "UNIT");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['weather_get_solar_radiation'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Solar radiation in");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["Joules/m²", "JOULES_PER_SQUARE_METER"], ["Langleys", "LANGLEY"]]), "UNIT");
    this.setInputsInline(true);
    this.setOutput(true, "Number");
    this.setTooltip('');
  }
};

//
// Temperature Blocks
// temperatures are stored in degrees Celsius; the blocks 
// convert other values.
//-------------------------------------------------------------
Blockly.Blocks['weather_set_temperature'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Set");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["average", "AVERAGE"], ["high", "HIGH"], ["low", "LOW"]]), "CATEGORY");
    this.appendDummyInput()
        .appendField("temperature to degrees");
    this.appendValueInput("TEMP")
        .setCheck("Number");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["Celsius", "DEGREES_C"],["Fahrenheit", "DEGREES_F"]]), "MEASURE");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Set the air temperature');
  }
};
Blockly.Blocks['weather_get_temperature'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["average", "AVERAGE"], ["high", "HIGH"], ["low", "LOW"]]), "CATEGORY");
    this.appendDummyInput()
        .appendField("temperature in degrees");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["Fahrenheit", "DEGREES_F"], ["Celsius", "DEGREES_C"]]), "MEASURE");
    this.setInputsInline(true);
    this.setOutput(true);
    this.setTooltip('Get the air temperature');
  }
};

//
// Wind Blocks
// wind speed is stored in m/s and wind direction in compass degrees;
// blocks convert other values.
//-------------------------------------------------------------
Blockly.Blocks['weather_set_wind_speed'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Set wind speed");
    this.appendValueInput("SPEED")
        .setCheck("Number");
    this.appendDummyInput()
        .appendField("in");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["m/s", "METERS_PER_SECOND"], ["miles/hr", "MILES_PER_HOUR"]]), "MEASURE");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['weather_get_wind_speed'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Wind speed in");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["m/s", "METERS_PER_SECOND"], ["miles/hr", "MILES_PER_HOUR"]]), "MEASURE");
    this.setInputsInline(true);
    this.setOutput(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['weather_set_wind_direction'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Set wind direction to");
    this.appendValueInput("DIRECTION")
        .setCheck("Number");
    this.appendDummyInput()
        .appendField("degrees");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['weather_get_wind_direction'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Wind direction in degrees");
    this.setInputsInline(true);
    this.setOutput(true);
    this.setTooltip('');
  }
};

//
//Dew Point Blocks
//dew point is stored as degrees C
//------------------------------------------------------------
Blockly.Blocks['weather_set_dew_point'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Set dew point to");
    this.appendValueInput("TEMP")
        .setCheck("Number");
    this.appendDummyInput()
        .appendField("degrees");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["Celsius", "DEGREES_C"], ["Fahrenheight", "DEGREES_F"]]), "UNIT");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['weather_get_dew_point'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Dew point in degrees");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["Celsius", "DEGREES_C"], ["Fahrenheight", "DEGREES_F"]]), "UNIT");
    this.setInputsInline(true);
    this.setOutput(true);
    this.setTooltip('');
  }
};

//
// Humidity Blocks
// humidity is stored as a %
//-------------------------------------------------------------
Blockly.Blocks['weather_set_relative_humidity'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Set % relative humidity to");
    this.appendValueInput("RELATIVE_HUMIDITY")
        .setCheck("Number");
    this.appendDummyInput()
        .appendField("%");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['weather_get_relative_humidity'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("% relative humidity");
    this.setInputsInline(true);
    this.setOutput(true);
    this.setTooltip('');
  }
};




