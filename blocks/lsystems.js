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
 * @fileoverview L-System blocks for Blockly.
 * @author nhbean@ksu.edu (Nathan Bean)
 */
'use strict';

goog.provide('Blockly.Blocks.lsystems');

goog.require('Blockly.Blocks');


Blockly.Blocks.lsystems.HUE = 298;


Blockly.Blocks['lsystems_draw'] = {
  /**
   * Block for drawing an L-System.
   * @this Blockly.Block
   */
  init: function() {
    this.setHelpUrl(Blockly.Msg.LSYSTEMS_GET_HELPURL);
    this.setColour(Blockly.Blocks.lsystems.HUE);
    this.appendValueInput("LSYSTEM")
        .setCheck("LSystem")
        .setAlign(Blockly.ALIGN_RIGHT)
        .appendField(Blockly.Msg.LSYSTEMS_DRAW_TITLE);
    this.appendDummyInput()
	.setAlign(Blockly.ALIGN_RIGHT)
	.appendField(Blockly.Msg.LSYSTEMS_DRAW_WITH);
    this.appendValueInput("TIMES")
        .setCheck("Number")
        .setAlign(Blockly.ALIGN_RIGHT)
        .appendField(Blockly.Msg.LSYSTEMS_DRAW_RECURSIONS);
    this.appendValueInput("ANGLE")
        .setCheck("Number")
        .setAlign(Blockly.ALIGN_RIGHT)
        .appendField(Blockly.Msg.LSYSTEMS_DRAW_ANGLE);
    this.appendValueInput("DISTANCE")
        .setCheck("Number")
        .setAlign(Blockly.ALIGN_RIGHT)
        .appendField(Blockly.Msg.LSYSTEMS_DRAW_DISTANCE);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip(Blockly.Msg.LSYSTEMS_DRAW_TOOLTIP);
  }
};

Blockly.Blocks['lsystems_create'] = {
  /**
   * Block for creating an L-System with any number of Productions.
   * @this Blockly.Block
   */
  init: function() {
    this.setHelpUrl(Blockly.Msg.LSYSTEMS_CREATE_HELPURL);
    this.setColour(Blockly.Blocks.lsystems.HUE);
    this.appendDummyInput()
      .appendField(Blockly.Msg.LSYSTEMS_CREATE_TITLE);
    this.appendDummyInput()
      .appendField(Blockly.Msg.LSYSTEMS_CREATE_AXIOM)
      .appendField(new Blockly.FieldTextInput("A"), "AXIOM")
      .setAlign(Blockly.ALIGN_RIGHT);
    this.itemCount_ = 3;
    this.updateShape_();
    this.setOutput(true, 'LSystem');
    this.setMutator(new Blockly.Mutator(['lsystems_create_item']));
    this.setTooltip(Blockly.Msg.LSYSTEMS_CREATE_TOOLTIP);
  },
  /**
   * Create XML to represent Production inputs.
   * @return {Element} XML storage element.
   * @this Blockly.Block
   */
  mutationToDom: function() {
    var container = document.createElement('mutation');
    container.setAttribute('items', this.itemCount_);
    return container;
  },
  /**
   * Parse XML to restore the Production inputs.
   * @param {!Element} xmlElement XML storage element.
   * @this Blockly.Block
   */
  domToMutation: function(xmlElement) {
    this.itemCount_ = parseInt(xmlElement.getAttribute('items'), 10);
    this.updateShape_();
  },
  /**
   * Populate the mutator's dialog with this block's components.
   * @param {!Blockly.Workspace} workspace Mutator's workspace.
   * @return {!Blockly.Block} Root block in mutator.
   * @this Blockly.Block
   */
  decompose: function(workspace) {
    var containerBlock =
        Blockly.Block.obtain(workspace, 'lsystems_create_container');
    containerBlock.initSvg();
    var connection = containerBlock.getInput('STACK').connection;
    for (var i = 0; i < this.itemCount_; i++) {
      var itemBlock = Blockly.Block.obtain(workspace, 'lsystems_create_item');
      itemBlock.initSvg();
      connection.connect(itemBlock.previousConnection);
      connection = itemBlock.nextConnection;
    }
    return containerBlock;
  },
  /**
   * Reconfigure this block based on the mutator dialog's components.
   * @param {!Blockly.Block} containerBlock Root block in mutator.
   * @this Blockly.Block
   */
  compose: function(containerBlock) {
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    // Count number of inputs.
    var connections = [];
    var i = 0;
    while (itemBlock) {
      connections[i] = itemBlock.valueConnection_;
      itemBlock = itemBlock.nextConnection &&
          itemBlock.nextConnection.targetBlock();
      i++;
    }
    this.itemCount_ = i;
    this.updateShape_();
    // Reconnect any child blocks.
    for (var i = 0; i < this.itemCount_; i++) {
      if (connections[i]) {
        this.getInput('ADD' + i).connection.connect(connections[i]);
      }
    }
  },
  /**
   * Store pointers to any connected child blocks.
   * @param {!Blockly.Block} containerBlock Root block in mutator.
   * @this Blockly.Block
   */
  saveConnections: function(containerBlock) {
    var itemBlock = containerBlock.getInputTargetBlock('STACK');
    var i = 0;
    while (itemBlock) {
      var input = this.getInput('ADD' + i);
      itemBlock.valueConnection_ = input && input.connection.targetConnection;
      i++;
      itemBlock = itemBlock.nextConnection &&
          itemBlock.nextConnection.targetBlock();
    }
  },
  /**
   * Modify this block to have the correct number of Production inputs.
   * @private
   * @this Blockly.Block
   */
  updateShape_: function() {
    // Delete everything.
    if (this.getInput('EMPTY')) {
      this.removeInput('EMPTY');
    } else {
      var i = 0;
      while (this.getInput('ADD' + i)) {
        this.removeInput('ADD' + i);
        i++;
      }
    }
    // Rebuild block.
    if (this.itemCount_ == 0) {
      this.appendDummyInput('EMPTY')
          .appendField(Blockly.Msg.LSYSTEMS_CREATE_EMPTY_TITLE);
    } else {
      for (var i = 0; i < this.itemCount_; i++) {
        var input = this.appendValueInput('ADD' + i)
          .setAlign(Blockly.ALIGN_RIGHT)
          .setCheck('Production');
        if (i == 0) {
          input.appendField(Blockly.Msg.LSYSTEMS_CREATE_INPUT_WITH);
        }
      }
    }
  }
};

Blockly.Blocks['lsystems_create_container'] = {
  /**
   * Mutator block for Productions container.
   * @this Blockly.Block
   */
  init: function() {
    this.setColour(Blockly.Blocks.lsystems.HUE);
    this.appendDummyInput()
        .appendField(Blockly.Msg.LSYSTEMS_CREATE_CONTAINER_TITLE_ADD);
    this.appendStatementInput('STACK');
    this.setTooltip(Blockly.Msg.LSYSTEMS_CREATE_CONTAINER_TOOLTIP);
    this.contextMenu = false;
  }
};

Blockly.Blocks['lsystems_create_item'] = {
  /**
   * Mutator block for adding productions.
   * @this Blockly.Block
   */
  init: function() {
    this.setColour(Blockly.Blocks.lsystems.HUE);
    this.appendDummyInput()
        .appendField(Blockly.Msg.LSYSTEMS_CREATE_ITEM_TITLE);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip(Blockly.Msg.LSYSTEMS_CREATE_ITEM_TOOLTIP);
    this.contextMenu = false;
  }
};

Blockly.Blocks['lsystems_rule'] = {
  /**
   * Block representing an L-System production
   * @this Blockly.Block
   */
  init: function() {
    this.setHelpUrl(Blockly.Msg.LSYSTEM_GET_HELPURL);
    this.setColour(Blockly.Blocks.lsystems.HUE);
    this.appendDummyInput()
        .appendField(Blockly.Msg.LSYSTEMS_RULE_TITLE)
        .appendField(new Blockly.FieldTextInput("A"), "MATCH")
        .appendField(new Blockly.FieldImage("../../media/arrow.png", 15, 15, "=>"))
        .appendField(new Blockly.FieldTextInput("B"), "YIELD");
    this.setInputsInline(true);
    this.setOutput(true, "Production");
    this.setTooltip('');
  }
};

