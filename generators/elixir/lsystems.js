/**
 * @license
 * SmartFarm hackable glass simulation, built on Google's Blockly
 *
 * Copyright 2015 Computing and Information Sciences, Kansas State University.
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
 * @fileoverview Generating Elixir for L-System blocks.
 * @author nhbean@ksu.edu (Nathan Bean)
 */
'use strict';

goog.provide('Blockly.Elixir.lsystems');

goog.require('Blockly.Elixir');


Blockly.Elixir['lsystems_draw'] = function(block) {
  // Draw an L-System using the supplied number of iterations,
  // angle, and distance
  var lsystem = Blockly.Elixir.valueToCode(block, 'LSYSTEM',
        Blockly.Elixir.ORDER_ATOMIC) || '';
  var count = Blockly.Elixir.valueToCode(block, 'TIMES', 
        Blockly.Elixir.ORDER_ATOMIC) || '0';
  var angle = Blockly.Elixir.valueToCode(block, 'ANGLE',
        Blockly.Elixir.ORDER_ATOMIC) || '0';
  var steps = Blockly.Elixir.valueToCode(block, 'DISTANCE',
        Blockly.Elixir.ORDER_ATOMIC) || '0';
  var code = 'svg_path = LSystem.render(' + lsystem + ', ' + count + ', ' + angle + ', ' + steps + ')';
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['lsystems_create'] = function(block) {
  // Create a L-System with any number of production rules.
  var axiom = block.getFieldValue('AXIOM') || '<<"">>';
  var code = new Array(block.itemCount_ + 1);
  for (var n = 0; n < block.itemCount_; n++) {
    code[n] = Blockly.Elixir.valueToCode(block, 'ADD' + n,
        Blockly.Elixir.ORDER_ATOMIC) || '';
  }
  // default case is to copy symbols with no change
  code[block.itemCount_] = '<<symbol,tail::binary>> -> {<<symbol>>,tail}'
  code = '{:lsystem, <<"' + axiom + '">>, fn ' + code.join('; ') + ' end}';
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['lsystems_rule'] = function(block) {
  var matchClause = block.getFieldValue('MATCH') || '<<0>>';
  var yieldClause = block.getFieldValue('YIELD') || match;
  var code = '<<"' + matchClause + '",tail::binary>> -> {<<"' + yieldClause + '">>,tail}';
  return [code, Blockly.Elixir.ORDER_COMMA];
};
