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
 * @fileoverview Helper functions for generating Elxir for blocks.
 * @author nhbean@k-state.edu (Nathan H. Bean)
 */
'use strict';

goog.provide('Blockly.Elixir');

goog.require('Blockly.Generator');


/**
 * Elixir code generator.
 * @type !Blockly.Generator
 */
Blockly.Elixir = new Blockly.Generator('Elixir');

/**
 * List of illegal variable names.
 * This is not intended to be a security feature.  Blockly is 100% client-side,
 * so bypassing this list is trivial.  This is intended to prevent users from
 * accidentally clobbering a built-in object or function.
 * @private
 */
// TODO: Add Elixir's reserved and key words
//Blockly.Elixir.addReservedWords(
//);

/**
 * Order of operation ENUMs.
 * https://developer.mozilla.org/en/Elixir/Reference/Operators/Operator_Precedence
 */
Blockly.Elixir.ORDER_ATOMIC = 0;         // 0 "" ...
Blockly.Elixir.ORDER_MEMBER = 1;         // . []
Blockly.Elixir.ORDER_NEW = 1;            // new
Blockly.Elixir.ORDER_FUNCTION_CALL = 2;  // ()
Blockly.Elixir.ORDER_INCREMENT = 3;      // ++
Blockly.Elixir.ORDER_DECREMENT = 3;      // --
Blockly.Elixir.ORDER_LOGICAL_NOT = 4;    // !
Blockly.Elixir.ORDER_BITWISE_NOT = 4;    // ~
Blockly.Elixir.ORDER_UNARY_PLUS = 4;     // +
Blockly.Elixir.ORDER_UNARY_NEGATION = 4; // -
Blockly.Elixir.ORDER_TYPEOF = 4;         // typeof
Blockly.Elixir.ORDER_VOID = 4;           // void
Blockly.Elixir.ORDER_DELETE = 4;         // delete
Blockly.Elixir.ORDER_MULTIPLICATION = 5; // *
Blockly.Elixir.ORDER_DIVISION = 5;       // /
Blockly.Elixir.ORDER_MODULUS = 5;        // %
Blockly.Elixir.ORDER_ADDITION = 6;       // +
Blockly.Elixir.ORDER_SUBTRACTION = 6;    // -
Blockly.Elixir.ORDER_BITWISE_SHIFT = 7;  // << >> >>>
Blockly.Elixir.ORDER_RELATIONAL = 8;     // < <= > >=
Blockly.Elixir.ORDER_IN = 8;             // in
Blockly.Elixir.ORDER_INSTANCEOF = 8;     // instanceof
Blockly.Elixir.ORDER_EQUALITY = 9;       // == != === !==
Blockly.Elixir.ORDER_BITWISE_AND = 10;   // &
Blockly.Elixir.ORDER_BITWISE_XOR = 11;   // ^
Blockly.Elixir.ORDER_BITWISE_OR = 12;    // |
Blockly.Elixir.ORDER_LOGICAL_AND = 13;   // &&
Blockly.Elixir.ORDER_LOGICAL_OR = 14;    // ||
Blockly.Elixir.ORDER_CONDITIONAL = 15;   // ?:
Blockly.Elixir.ORDER_ASSIGNMENT = 16;    // = += -= *= /= %= <<= >>= ...
Blockly.Elixir.ORDER_COMMA = 17;         // ,
Blockly.Elixir.ORDER_NONE = 99;          // (...)

/**
 * Initialise the database of variable names.
 * @param {!Blockly.Workspace} workspace Workspace to generate code from.
 */
Blockly.Elixir.init = function(workspace) {
  // Create a dictionary of definitions to be printed before the code.
  Blockly.Elixir.definitions_ = Object.create(null);
  // Create a dictionary mapping desired function names in definitions_
  // to actual function names (to avoid collisions with user functions).
  Blockly.Elixir.functionNames_ = Object.create(null);

  if (!Blockly.Elixir.variableDB_) {
    Blockly.Elixir.variableDB_ =
        new Blockly.Names(Blockly.Elixir.RESERVED_WORDS_);
  } else {
    Blockly.Elixir.variableDB_.reset();
  }

  var defvars = [];
  var variables = Blockly.Variables.allVariables(workspace);
  for (var x = 0; x < variables.length; x++) {
    defvars[x] = 'var ' +
        Blockly.Elixir.variableDB_.getName(variables[x],
        Blockly.Variables.NAME_TYPE) + ';';
  }
  Blockly.Elixir.definitions_['variables'] = defvars.join('\n');
};

/**
 * Prepend the generated code with the variable definitions.
 * @param {string} code Generated code.
 * @return {string} Completed code.
 */
Blockly.Elixir.finish = function(code) {
  // Convert the definitions dictionary into a list.
  var definitions = [];
  for (var name in Blockly.Elixir.definitions_) {
    definitions.push(Blockly.Elixir.definitions_[name]);
  }
  return definitions.join('\n\n') + '\n\n\n' + code;
};

/**
 * Naked values are top-level blocks with outputs that aren't plugged into
 * anything.  A trailing semicolon is needed to make this legal.
 * @param {string} line Line of generated code.
 * @return {string} Legal line of code.
 */
Blockly.Elixir.scrubNakedValue = function(line) {
  return line + ';\n';
};

/**
 * Encode a string as a properly escaped Elixir string, complete with
 * quotes.
 * @param {string} string Text to encode.
 * @return {string} Elixir string.
 * @private
 */
Blockly.Elixir.quote_ = function(string) {
  // TODO: This is a quick hack.  Replace with goog.string.quote
  string = string.replace(/\\/g, '\\\\')
                 .replace(/\n/g, '\\\n')
                 .replace(/'/g, '\\\'');
  return '\'' + string + '\'';
};

/**
 * Common tasks for generating Elixir from blocks.
 * Handles comments for the specified block and any connected value blocks.
 * Calls any statements following this block.
 * @param {!Blockly.Block} block The current block.
 * @param {string} code The Elixir code created for this block.
 * @return {string} Elixir code with comments and subsequent blocks added.
 * @private
 */
Blockly.Elixir.scrub_ = function(block, code) {
  var commentCode = '';
  // Only collect comments for blocks that aren't inline.
  if (!block.outputConnection || !block.outputConnection.targetConnection) {
    // Collect comment for this block.
    var comment = block.getCommentText();
    if (comment) {
      commentCode += Blockly.Elixir.prefixLines(comment, '# ') + '\n';
    }
    // Collect comments for all value arguments.
    // Don't collect comments for nested statements.
    for (var x = 0; x < block.inputList.length; x++) {
      if (block.inputList[x].type == Blockly.INPUT_VALUE) {
        var childBlock = block.inputList[x].connection.targetBlock();
        if (childBlock) {
          var comment = Blockly.Elixir.allNestedComments(childBlock);
          if (comment) {
            commentCode += Blockly.Elixir.prefixLines(comment, '# ');
          }
        }
      }
    }
  }
  var nextBlock = block.nextConnection && block.nextConnection.targetBlock();
  var nextCode = Blockly.Elixir.blockToCode(nextBlock);
  return commentCode + code + nextCode;
};
