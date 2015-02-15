Blockly.JavaScript['lsystem_start'] = function(block) {
  var axiom = Blockly.JavaScript.statementToCode(block, 'Axiom');
  var prods = Blockly.JavaScript.statementToCode(block, 'Productions');
  return axiom; 
};
Blockly.JavaScript['lsystem_production'] = function(block) {
  var head = Blockly.JavaScript.statementToCode(block, 'Head');
  var body = Blockly.JavaScript.statementToCode(block, 'Body');
  var code = '[' + head + ',' + body + '];' ;
  return code;
};
Blockly.JavaScript['lsystem_terminal'] = function(block) {
  var term = block.getFieldValue('TERMINALS');
  var code;
  if (term == 'DRAW') code = 'draw();';
  else if (term == 'LEFT') code = 'turn(true);';
  else if (term == 'PUSH') code = 'push();';
  else if (term == 'POP') code = 'pop();';
  else if (term == 'RIGHT') code = 'turn(false);';
  else alert('Something went wrong!\n');
  return code;  
};
