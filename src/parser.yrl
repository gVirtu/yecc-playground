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
  array
  array_items
  map
  field_set
  field_key
  accessor
  accessor_items
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
  ':'
  ';'
  '('
  ')'
  '['
  ']'
  '{'
  '}'
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
statement -> expression accessor : {access, '$1', '$2'}.
statement -> expression : '$1'.

% An assignment binds a variable name to an expression.
assignment -> name '=' expression : {assign, '$1', '$3'}.

% An expression can be a literal.
expression -> integer : unwrap('$1').
expression -> string : '$1'.
expression -> boolean : '$1'.
expression -> array : '$1'.
expression -> map : '$1'.

% An expression can return the value of a variable.
expression -> name : {var, '$1'}.

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

% An array is a list of items, enclosed in brackets.
array -> '[' array_items ']' : {array, '$2'}.

% Array items are expressions separated by commas.
array_items -> expression : ['$1'].
array_items -> expression ',' array_items : ['$1'|'$3'].

% A map is a set of fields, enclosed in curly braces.
map -> '{' field_set '}' : {map, '$2'}.

% Field set entries are composed of the key name, then a colon, then the key value.
% Entries are separated by commas.
field_set -> field_key ':' expression : [{'$1', '$3'}].
field_set -> field_key ':' expression ',' field_set : [{'$1', '$3'} | '$5'].

% Key names can be either a name or a string literal.
field_key -> name : '$1'.
field_key -> string : '$1'.

% Accessors are a list of items enclosed by brackets.
accessor -> '[' accessor_items ']' : '$2'.

% Accessor items are expressions separated by commas.
accessor_items -> expression : ['$1'].
accessor_items -> expression ',' accessor_items : ['$1'|'$3'].

% Helper functions
Erlang code.

type_of(Token) -> element(1, Token).
value_of(Token) -> element(3, Token).
unwrap({integer, Line, Value}) -> {integer, Line, list_to_integer(Value)}.
