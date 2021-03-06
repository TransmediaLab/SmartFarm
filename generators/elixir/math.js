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
 * @fileoverview Generating Elixir for math blocks.
 * @author nhbean@ksu.edu (Nathan Bean)
 */
'use strict';

goog.provide('Blockly.Elixir.math');

goog.require('Blockly.Elixir');


Blockly.Elixir['math_number'] = function(block) {
  // Numeric value.
  var code = parseFloat(block.getFieldValue('NUM'));
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['math_arithmetic'] = function(block) {
  // Basic arithmetic operators, and power.
  var OPERATORS = {
    'ADD': [' + ', Blockly.Elixir.ORDER_ADDITION],
    'MINUS': [' - ', Blockly.Elixir.ORDER_SUBTRACTION],
    'MULTIPLY': [' * ', Blockly.Elixir.ORDER_MULTIPLICATION],
    'DIVIDE': [' / ', Blockly.Elixir.ORDER_DIVISION],
    'POWER': [null, Blockly.Elixir.ORDER_COMMA]  // Handle power separately.
  };
  var tuple = OPERATORS[block.getFieldValue('OP')];
  var operator = tuple[0];
  var order = tuple[1];
  var argument0 = Blockly.Elixir.valueToCode(block, 'A', order) || '0';
  var argument1 = Blockly.Elixir.valueToCode(block, 'B', order) || '0';
  var code;
  // Power in Elixir requires a special case since it has no operator.
  if (!operator) {
    code = ':math.pow(' + argument0 + ', ' + argument1 + ')';
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  }
  code = argument0 + operator + argument1;
  return [code, order];
};

Blockly.Elixir['math_single'] = function(block) {
  // Math operators with single operand.
  var operator = block.getFieldValue('OP');
  var code;
  var arg;
  if (operator == 'NEG') {
    // Negation is a special case given its different operator precedence.
    arg = Blockly.Elixir.valueToCode(block, 'NUM',
        Blockly.Elixir.ORDER_UNARY_NEGATION) || '0';
    if (arg[0] == '-') {
      // --3 is not legal in JS.
      arg = ' ' + arg;
    }
    code = '-' + arg;
    return [code, Blockly.Elixir.ORDER_UNARY_NEGATION];
  }
  if (operator == 'SIN' || operator == 'COS' || operator == 'TAN') {
    arg = Blockly.Elixir.valueToCode(block, 'NUM',
        Blockly.Elixir.ORDER_DIVISION) || '0';
  } else {
    arg = Blockly.Elixir.valueToCode(block, 'NUM',
        Blockly.Elixir.ORDER_NONE) || '0';
  }
  // First, handle cases which generate values that don't need parentheses
  // wrapping the code.
  switch (operator) {
    case 'ABS':
      code = 'abs(' + arg + ')';
      break;
    case 'ROOT':
      code = ':math.sqrt(' + arg + ')';
      break;
    case 'LN':
      code = ':math.log(' + arg + ')';
      break;
    case 'LOG10':
      code = ':math.log10(' + arg + ')';
      break;
    case 'EXP':
      code = ':math.exp(' + arg + ')';
      break;
    case 'POW10':
      code = ':math.pow(10,' + arg + ')';
      break;
    case 'ROUND':
      code = 'round(' + arg + ')';
      break;
    case 'ROUNDUP':
      code = 'round((' + arg + ' + 0.5))';
      break;
    case 'ROUNDDOWN':
      code = 'round((' + arg + ' - 0.5))';
      break;
    case 'SIN':
      code = 'Float.round(:math.sin(' + arg + ' / 180.0 * :math.pi),15)';
      break;
    case 'COS':
      code = 'Float.round(:math.cos(' + arg + ' / 180.0 * :math.pi),15)';
      break;
    case 'TAN':
      code = ':math.tan(' + arg + ' / 180.0 * :math.pi)';
      break;
  }
  if (code) {
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  }
  // Second, handle cases which generate values that may need parentheses
  // wrapping the code.
  switch (operator) {
    case 'ASIN':
      code = ':math.asin(' + arg + ') / :math.PI * 180.0';
      break;
    case 'ACOS':
      code = ':math.acos(' + arg + ') / :math.pi * 180.0';
      break;
    case 'ATAN':
      code = ':math.atan(' + arg + ') / :math.pi * 180.0';
      break;
    default:
      throw 'Unknown math operator: ' + operator;
  }
  return [code, Blockly.Elixir.ORDER_DIVISION];
};

Blockly.Elixir['math_constant'] = function(block) {
  // Constants: PI, E, the Golden Ratio, sqrt(2), 1/sqrt(2), INFINITY.
  var CONSTANTS = {
    'PI': [':math.pi', Blockly.Elixir.ORDER_MEMBER],
    'E': ['2.718281828459045', Blockly.Elixir.ORDER_MEMBER],
    'GOLDEN_RATIO':
        ['(1 + :math.sqrt(5)) / 2', Blockly.Elixir.ORDER_DIVISION],
    'SQRT2': ['1.4142135623730951', Blockly.Elixir.ORDER_MEMBER],
    'SQRT1_2': ['0.7071067811865476', Blockly.Elixir.ORDER_MEMBER]
  };
  return CONSTANTS[block.getFieldValue('CONSTANT')];
};

Blockly.Elixir['math_number_property'] = function(block) {
  // Check if a number is even, odd, prime, whole, positive, or negative
  // or if it is divisible by certain number. Returns true or false.
  var number_to_check = Blockly.Elixir.valueToCode(block, 'NUMBER_TO_CHECK',
      Blockly.Elixir.ORDER_MODULUS) || '0';
  var dropdown_property = block.getFieldValue('PROPERTY');
  var code;
  if (dropdown_property == 'PRIME') {
    // Prime is a special case as it is not a one-liner test.
    var functionName = Blockly.Elixir.provideFunction_(
        'math_isPrime',
        [ 'function ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ + '(n) {',
          '  // https://en.wikipedia.org/wiki/Primality_test#Naive_methods',
          '  if (n == 2 || n == 3) {',
          '    return true;',
          '  }',
          '  // False if n is NaN, negative, is 1, or not whole.',
          '  // And false if n is divisible by 2 or 3.',
          '  if (isNaN(n) || n <= 1 || n % 1 != 0 || n % 2 == 0 ||' +
            ' n % 3 == 0) {',
          '    return false;',
          '  }',
          '  // Check all the numbers of form 6k +/- 1, up to sqrt(n).',
          '  for (var x = 6; x <= Math.sqrt(n) + 1; x += 6) {',
          '    if (n % (x - 1) == 0 || n % (x + 1) == 0) {',
          '      return false;',
          '    }',
          '  }',
          '  return true;',
          '}']);
    code = functionName + '(' + number_to_check + ')';
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  }
  switch (dropdown_property) {
    case 'EVEN':
      code = number_to_check + ' % 2 == 0';
      break;
    case 'ODD':
      code = number_to_check + ' % 2 == 1';
      break;
    case 'WHOLE':
      code = number_to_check + ' % 1 == 0';
      break;
    case 'POSITIVE':
      code = number_to_check + ' > 0';
      break;
    case 'NEGATIVE':
      code = number_to_check + ' < 0';
      break;
    case 'DIVISIBLE_BY':
      var divisor = Blockly.Elixir.valueToCode(block, 'DIVISOR',
          Blockly.Elixir.ORDER_MODULUS) || '0';
      code = number_to_check + ' % ' + divisor + ' == 0';
      break;
  }
  return [code, Blockly.Elixir.ORDER_EQUALITY];
};

Blockly.Elixir['math_change'] = function(block) {
  // Add to a variable in place.
  var argument0 = Blockly.Elixir.valueToCode(block, 'DELTA',
      Blockly.Elixir.ORDER_ADDITION) || '0';
  var varName = Blockly.Elixir.variableDB_.getName(
      block.getFieldValue('VAR'), Blockly.Variables.NAME_TYPE);
  return varName + ' = (typeof ' + varName + ' == \'number\' ? ' + varName +
      ' : 0) + ' + argument0 + ';\n';
};

// Rounding functions have a single operand.
Blockly.Elixir['math_round'] = Blockly.Elixir['math_single'];
// Trigonometry functions have a single operand.
Blockly.Elixir['math_trig'] = Blockly.Elixir['math_single'];

Blockly.Elixir['math_on_list'] = function(block) {
  // Math functions for lists.
  var func = block.getFieldValue('OP');
  var list, code;
  switch (func) {
    case 'SUM':
      list = Blockly.Elixir.valueToCode(block, 'LIST',
          Blockly.Elixir.ORDER_MEMBER) || '[]';
      code = list + '.reduce(function(x, y) {return x + y;})';
      break;
    case 'MIN':
      list = Blockly.Elixir.valueToCode(block, 'LIST',
          Blockly.Elixir.ORDER_COMMA) || '[]';
      code = 'Math.min.apply(null, ' + list + ')';
      break;
    case 'MAX':
      list = Blockly.Elixir.valueToCode(block, 'LIST',
          Blockly.Elixir.ORDER_COMMA) || '[]';
      code = 'Math.max.apply(null, ' + list + ')';
      break;
    case 'AVERAGE':
      // math_median([null,null,1,3]) == 2.0.
      var functionName = Blockly.Elixir.provideFunction_(
          'math_mean',
          [ 'function ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ +
              '(myList) {',
            '  return myList.reduce(function(x, y) {return x + y;}) / ' +
                  'myList.length;',
            '}']);
      list = Blockly.Elixir.valueToCode(block, 'LIST',
          Blockly.Elixir.ORDER_NONE) || '[]';
      code = functionName + '(' + list + ')';
      break;
    case 'MEDIAN':
      // math_median([null,null,1,3]) == 2.0.
      var functionName = Blockly.Elixir.provideFunction_(
          'math_median',
          [ 'function ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ +
              '(myList) {',
            '  var localList = myList.filter(function (x) ' +
              '{return typeof x == \'number\';});',
            '  if (!localList.length) return null;',
            '  localList.sort(function(a, b) {return b - a;});',
            '  if (localList.length % 2 == 0) {',
            '    return (localList[localList.length / 2 - 1] + ' +
              'localList[localList.length / 2]) / 2;',
            '  } else {',
            '    return localList[(localList.length - 1) / 2];',
            '  }',
            '}']);
      list = Blockly.Elixir.valueToCode(block, 'LIST',
          Blockly.Elixir.ORDER_NONE) || '[]';
      code = functionName + '(' + list + ')';
      break;
    case 'MODE':
      // As a list of numbers can contain more than one mode,
      // the returned result is provided as an array.
      // Mode of [3, 'x', 'x', 1, 1, 2, '3'] -> ['x', 1].
      var functionName = Blockly.Elixir.provideFunction_(
          'math_modes',
          [ 'function ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ +
              '(values) {',
            '  var modes = [];',
            '  var counts = [];',
            '  var maxCount = 0;',
            '  for (var i = 0; i < values.length; i++) {',
            '    var value = values[i];',
            '    var found = false;',
            '    var thisCount;',
            '    for (var j = 0; j < counts.length; j++) {',
            '      if (counts[j][0] === value) {',
            '        thisCount = ++counts[j][1];',
            '        found = true;',
            '        break;',
            '      }',
            '    }',
            '    if (!found) {',
            '      counts.push([value, 1]);',
            '      thisCount = 1;',
            '    }',
            '    maxCount = Math.max(thisCount, maxCount);',
            '  }',
            '  for (var j = 0; j < counts.length; j++) {',
            '    if (counts[j][1] == maxCount) {',
            '        modes.push(counts[j][0]);',
            '    }',
            '  }',
            '  return modes;',
            '}']);
      list = Blockly.Elixir.valueToCode(block, 'LIST',
          Blockly.Elixir.ORDER_NONE) || '[]';
      code = functionName + '(' + list + ')';
      break;
    case 'STD_DEV':
      var functionName = Blockly.Elixir.provideFunction_(
          'math_standard_deviation',
          [ 'function ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ +
              '(numbers) {',
            '  var n = numbers.length;',
            '  if (!n) return null;',
            '  var mean = numbers.reduce(function(x, y) {return x + y;}) / n;',
            '  var variance = 0;',
            '  for (var j = 0; j < n; j++) {',
            '    variance += Math.pow(numbers[j] - mean, 2);',
            '  }',
            '  variance = variance / n;',
            '  return Math.sqrt(variance);',
            '}']);
      list = Blockly.Elixir.valueToCode(block, 'LIST',
          Blockly.Elixir.ORDER_NONE) || '[]';
      code = functionName + '(' + list + ')';
      break;
    case 'RANDOM':
      var functionName = Blockly.Elixir.provideFunction_(
          'math_random_list',
          [ 'function ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ +
              '(list) {',
            '  var x = Math.floor(Math.random() * list.length);',
            '  return list[x];',
            '}']);
      list = Blockly.Elixir.valueToCode(block, 'LIST',
          Blockly.Elixir.ORDER_NONE) || '[]';
      code = functionName + '(' + list + ')';
      break;
    default:
      throw 'Unknown operator: ' + func;
  }
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['math_modulo'] = function(block) {
  // Remainder computation.
  var argument0 = Blockly.Elixir.valueToCode(block, 'DIVIDEND',
      Blockly.Elixir.ORDER_MODULUS) || '0';
  var argument1 = Blockly.Elixir.valueToCode(block, 'DIVISOR',
      Blockly.Elixir.ORDER_MODULUS) || '0';
  var code = argument0 + ' % ' + argument1;
  return [code, Blockly.Elixir.ORDER_MODULUS];
};

Blockly.Elixir['math_constrain'] = function(block) {
  // Constrain a number between two limits.
  var argument0 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_COMMA) || '0';
  var argument1 = Blockly.Elixir.valueToCode(block, 'LOW',
      Blockly.Elixir.ORDER_COMMA) || '0';
  var argument2 = Blockly.Elixir.valueToCode(block, 'HIGH',
      Blockly.Elixir.ORDER_COMMA) || '0';
  var code = 'Enum.min([Enum.max([' + argument0 + ', ' + argument1 +']),' +
      arguement2 + '])';
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['math_random_int'] = function(block) {
  // Random integer between [X] and [Y].
  var argument0 = Blockly.Elixir.valueToCode(block, 'FROM',
      Blockly.Elixir.ORDER_COMMA) || '0';
  var argument1 = Blockly.Elixir.valueToCode(block, 'TO',
      Blockly.Elixir.ORDER_COMMA) || '0';
  var code = argument0 + ' + :random.uniform(' + argument1 + ' - ' + argument0 + ')';
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['math_random_float'] = function(block) {
  // Random fraction between 0 and 1.
  return [':random.uniform()', Blockly.Elixir.ORDER_FUNCTION_CALL];
};
