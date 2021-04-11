% List of valid non-terminal symbols (or rules)
Nonterminals
  root
  statements
  statement
  expression
  assignment
  function_call
  arguments
  array
  array_items
  map
  field_set
  field_key
  accessor
  accessor_items
  semicolon_eol
  colon_eol
  equals_eol
  open_paren_eol
  open_bracket_eol
  open_curly_eol
  close_paren_eol
  close_bracket_eol
  close_curly_eol
  plus_eol
  minus_eol
  sign_eol
  asterisk_eol
  slash_eol
  or_eol
  and_eol
  not_eol
  cmp_eol
  comma_eol
.

% List of valid terminal symbols
Terminals
  eol
  nil
  integer
  boolean
  string
  name
  op_or
  op_and
  op_not
  op_cmp
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
Left 110 op_or.
Left 120 op_and.
Left 150 op_cmp.
Left 210 '+'.
Left 210 '-'.
Left 220 '*'.
Left 220 '/'.
Unary 300 op_not.
Unary 310 sign_eol.

%% ------------------------------------------------------------------------------------------------
%% PARSER RULES
%% ------------------------------------------------------------------------------------------------

% A program is a list of statements.
root -> statements : '$1'.
root -> eol statements : '$2'.
root -> '$empty' : [].

% A list of statements is one or more statement, separated by a semicolon, end-of-line or both.
statements -> statement : ['$1'].
statements -> statement eol : ['$1'].
statements -> statement semicolon_eol : ['$1'].
statements -> statement eol statements : ['$1'|'$3'].
statements -> statement semicolon_eol statements : ['$1'|'$3'].

% A statement can be an expression or an assignment.
statement -> assignment : '$1'.
statement -> expression accessor : {access, '$1', '$2'}.
statement -> expression : '$1'.

% An assignment binds a variable name to an expression.
assignment -> name equals_eol expression : {assign, '$1', '$3'}.

% An expression can be a literal.
expression -> nil : nil.
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
expression -> open_paren_eol expression close_paren_eol : '$2'.

% An expression can be an unary operation.
expression -> sign_eol expression : {op_krn, type_of('$1'), '$2'}.
expression -> not_eol expression  : {op_krn, 'not', '$2'}.

% An expression can be an arithmetic operation.
expression -> expression plus_eol expression     : {op_krn, '+', '$1', '$3'}.
expression -> expression minus_eol expression    : {op_krn, '-', '$1', '$3'}.
expression -> expression asterisk_eol expression : {op_krn, '*', '$1', '$3'}.
expression -> expression slash_eol expression    : {op_krn, '/', '$1', '$3'}.

% An expression can be a boolean operation.
expression -> expression or_eol expression : {op_krn, 'or', '$1', '$3'}.
expression -> expression and_eol expression : {op_krn, 'and', '$1', '$3'}.

% An expression can be a comparison operation.
expression -> expression cmp_eol expression : {op_krn, value_of('$2'), '$1', '$3'}.

% A function call is comprised of a function name and a parenthesized list of arguments.
function_call -> name open_paren_eol arguments close_paren_eol : {call, '$1', '$3'}.

% A list of arguments is one or more expression, separated by a comma.
arguments -> expression : ['$1'].
arguments -> expression comma_eol arguments : ['$1'|'$3'].

% A sign_operator is a plus or minus.
sign_eol -> plus_eol : '$1'.
sign_eol -> minus_eol : '$1'.

% An array is a list of items, enclosed in brackets.
array -> open_bracket_eol array_items close_bracket_eol : {array, '$2'}.

% Array items are expressions separated by commas.
array_items -> expression : ['$1'].
array_items -> expression comma_eol array_items : ['$1'|'$3'].

% A map is a set of fields, enclosed in curly braces.
map -> open_curly_eol field_set close_curly_eol : {map, '$2'}.

% Field set entries are composed of the key name, then a colon, then the key value.
% Entries are separated by commas.
field_set -> field_key colon_eol expression : [{'$1', '$3'}].
field_set -> field_key colon_eol expression comma_eol field_set : [{'$1', '$3'} | '$5'].

% Key names can be either a name or a string literal.
field_key -> name : '$1'.
field_key -> string : '$1'.

% Accessors are a list of items enclosed by brackets.
accessor -> open_bracket_eol accessor_items close_bracket_eol : '$2'.

% Accessor items are expressions separated by commas.
accessor_items -> expression : ['$1'].
accessor_items -> expression comma_eol accessor_items : ['$1'|'$3'].

% Line break points.
semicolon_eol -> ';' : '$1'.
semicolon_eol -> ';' eol : '$1'.

colon_eol -> ':' : '$1'.
colon_eol -> ':' eol : '$1'.

equals_eol -> '=' : '$1'.
equals_eol -> '=' eol : '$1'.

open_paren_eol -> '(' : '$1'.
open_paren_eol -> '(' eol : '$1'.

open_bracket_eol -> '[' : '$1'.
open_bracket_eol -> '[' eol : '$1'.

open_curly_eol -> '{' : '$1'.
open_curly_eol -> '{' eol : '$1'.

close_paren_eol -> ')' : '$1'.
close_paren_eol -> eol ')' : '$1'.

close_bracket_eol -> ']' : '$1'.
close_bracket_eol -> eol ']' : '$1'.

close_curly_eol -> '}' : '$1'.
close_curly_eol -> eol '}' : '$1'.

plus_eol -> '+' : '$1'.
plus_eol -> '+' eol : '$1'.

minus_eol -> '-' : '$1'.
minus_eol -> '-' eol : '$1'.

asterisk_eol -> '*' : '$1'.
asterisk_eol -> '*' eol : '$1'.

slash_eol -> '/' : '$1'.
slash_eol -> '/' eol : '$1'.

or_eol -> op_or : '$1'.
or_eol -> op_or eol : '$1'.

and_eol -> op_and : '$1'.
and_eol -> op_and eol : '$1'.

not_eol -> op_not : '$1'.
not_eol -> op_not eol : '$1'.

cmp_eol -> op_cmp : '$1'.
cmp_eol -> op_cmp eol : '$1'.

comma_eol -> ',' : '$1'.
comma_eol -> ',' eol : '$1'.

% Helper functions
Erlang code.

type_of(Token) -> element(1, Token).
value_of(Token) -> element(3, Token).
unwrap({integer, Line, Value}) -> {integer, Line, list_to_integer(Value)}.
