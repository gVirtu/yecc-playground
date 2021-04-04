% List of valid non-terminal symbols (or rules)
Nonterminals
  root
  statements
  statement
  expression
  assignment
  function_call
  arguments
  sign_operator
.

% List of valid terminal symbols
Terminals
  integer
  boolean
  string
  name
  or_operator
  and_operator
  not_operator
  cmp_operator
  '+'
  '-'
  '*'
  '/'
  '='
  ';'
  '('
  ')'
  ','
.

% List of valid root symbols
Rootsymbol
   root
.

% Operator precendence and associativeness. (higher number means highers precedence)
Right 100 '='.
Left 110 or_operator.
Left 120 and_operator.
Left 150 cmp_operator.
Left 210 '+'.
Left 210 '-'.
Left 220 '*'.
Left 220 '/'.
Unary 300 not_operator.
Unary 310 sign_operator.

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

% An expression can be a literal.
expression -> integer : unwrap('$1').
expression -> string : '$1'.
expression -> boolean : '$1'.

% An expression can return the value of a variable.
expression -> name : '$1'.

% An expression can be a function call.
expression -> function_call : '$1'.

% An expression can be parenthesized.
expression -> '(' expression ')' : '$2'.

% An expression can be an unary operation.
expression -> sign_operator expression : {op_krn, type_of('$1'), '$2'}.
expression -> not_operator expression  : {op_krn, 'not', '$2'}.

% An expression can be an arithmetic operation.
expression -> expression '+' expression : {op_krn, '+', '$1', '$3'}.
expression -> expression '-' expression : {op_krn, '-', '$1', '$3'}.
expression -> expression '*' expression : {op_krn, '*', '$1', '$3'}.
expression -> expression '/' expression : {op_krn, '/', '$1', '$3'}.

% An expression can be a boolean operation.
expression -> expression or_operator expression : {op_krn, 'or', '$1', '$3'}.
expression -> expression and_operator expression : {op_krn, 'and', '$1', '$3'}.

% An expression can be a comparison operation.
expression -> expression cmp_operator expression : {op_krn, value_of('$2'), '$1', '$3'}.

% A function call is comprised of a function name and a parenthesized list of arguments.
function_call -> name '(' arguments ')' : {call, '$1', '$3'}.

% A list of arguments is one or more expression, separated by a comma.
arguments -> expression : ['$1'].
arguments -> expression ',' arguments : ['$1'|'$3'].

% A sign_operator is a plus or minus.
sign_operator -> '+' : '$1'.
sign_operator -> '-' : '$1'.

% Helper functions
Erlang code.

type_of(Token) -> element(1, Token).
value_of(Token) -> element(3, Token).
unwrap({integer, Line, Value}) -> {integer, Line, list_to_integer(Value)}.
