Blockly.Blocks['lsystem_terminal'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(20);
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([['Forward', 'DRAW'], ['Turn Right', 'RIGHT'], ['Turn Left', 'LEFT'], ['Save', 'PUSH'], ['Load', 'POP']]), 'TERMINALS');
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['lsystem_production'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.setColour(20);
    this.appendStatementInput("Head")
        .setCheck("String");
    this.appendDummyInput()
        .appendField("-->");
    this.appendStatementInput("Body")
        .setCheck("String");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
Blockly.Blocks['lsystem_start'] = {
  init: function() {
    this.setHelpUrl('http://www.example.com/');
    this.appendDummyInput()
        .setAlign(Blockly.ALIGN_CENTRE)
        .appendField("LSystemFactory");
    this.appendStatementInput("Axiom")
        .setAlign(Blockly.ALIGN_RIGHT)
        .appendField("Axiom");
    this.appendStatementInput("Productions")
        .setAlign(Blockly.ALIGN_RIGHT)
        .appendField("Productions");
    this.setTooltip('');
  }
};
