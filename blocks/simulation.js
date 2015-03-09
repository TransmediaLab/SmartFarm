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
 * @fileoverview Simulation blocks for Blockly.
 * @author nhbean@k-state.edu (Nathan H. Bean)
 * This file defines a set of Blockly blocks for accessing a simulation's state
 * The simulation-related data used by the simulation is:
 * VARIABLE 			UNIT
 * -------------- 		-----
 * time 			milliseconds since 1/1/1970
 */
'use strict';

goog.require('Blockly.Blocks');

/*
Blockly.Blocks['simulation_get_day_of_year'] = {
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
*/

//
// Location
// location is stored in degrees latitude and longitude
//-------------------------------------------------------------
Blockly.Blocks['simulation_get_latitude'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Latitude in Degrees");
    this.setInputsInline(true);
    this.setOutput(true, "Number");
    this.setTooltip('');
  }
};
Blockly.Blocks['simulation_get_longitude'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(330);
    this.appendDummyInput()
        .appendField("Longitude in Degrees");
    this.setInputsInline(true);
    this.setOutput(true, "Number");
    this.setTooltip('');
  }
};
