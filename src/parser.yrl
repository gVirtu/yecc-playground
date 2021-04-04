% List of valid non-terminal symbols (or rules)
Nonterminals
  root
  statements
  statement
  expression
  assignment
.

% List of valid terminal symbols
Terminals
  integer
  string
  name
  '+'
  '-'
  '*'
  '/'
  '='
  ';'
  '('
  ')'
.

% List of valid root symbols
Rootsymbol
   root
.

% Operator precendence and associativeness. (higher number means highers precedence)
Right 100 '='.
Left 300 '+'.
Left 300 '-'.
Left 400 '*'.
Left 400 '/'.

%% ------------------------------------------------------------------------------------------------
%% PARSER RULES
%% ------------------------------------------------------------------------------------------------

% A program is a list of statements.
root -> statements : '$1'.

% A list of statements is one or more statement, separated by a semicolon.
% The last semicolon is optional.
statements -> statement : ['$1'].
statements -> statement ';' : ['$1'].
statements -> statement ';' statements : ['$1'|'$3'].

% A statement can be an expression or an assignment.
statement -> assignment : '$1'.
statement -> expression : '$1'.

% An assignment binds a variable name to an expression.
assignment -> name '=' expression : {assign, '$1', '$3'}.

% An expression can be a constant integer.
expression -> integer : unwrap('$1').

% An expression can be a literal string.
expression -> string : '$1'.

% An expression can return the value of a variable.
expression -> name : '$1'.

% An expression can be parenthesized.
expression -> '(' expression ')' : '$2'.

% An expression can be an arithmetic operation.
expression -> expression '+' expression : {op_add, '$1', '$3'}.
expression -> expression '-' expression : {op_sub, '$1', '$3'}.
expression -> expression '*' expression : {op_mul, '$1', '$3'}.
expression -> expression '/' expression : {op_div, '$1', '$3'}.

% Helper functions
Erlang code.

unwrap({integer, Line, Value}) -> {integer, Line, list_to_integer(Value)}.
