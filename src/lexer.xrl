Definitions.

INTEGER        = [0-9]+
NAME           = [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE     = [\s\t\r]
STRING         = "([^\"\\]|\\.)*"
CMP_OPERATOR   = \<|\>|\=\=|\!\=|\<\=|\>\=
OR_OPERATOR    = or|\|\|
AND_OPERATOR   = and|\&\&
NOT_OPERATOR   = not|\!
BOOLEAN        = true|false

Rules.

\+             : {token, {'+',  TokenLine}}.
\-             : {token, {'-',  TokenLine}}.
\*             : {token, {'*',  TokenLine}}.
\/             : {token, {'/',  TokenLine}}.
\=             : {token, {'=',  TokenLine}}.
\:             : {token, {':',  TokenLine}}.
\;             : {token, {';',  TokenLine}}.
\,             : {token, {',',  TokenLine}}.
\(             : {token, {'(',  TokenLine}}.
\)             : {token, {')',  TokenLine}}.
\[             : {token, {'[',  TokenLine}}.
\]             : {token, {']',  TokenLine}}.
\{             : {token, {'{',  TokenLine}}.
\}             : {token, {'}',  TokenLine}}.
\n+            : {token, {eol,  TokenLine}}.
{BOOLEAN}      : {token, {boolean, TokenLine, list_to_atom(TokenChars)}}.
{CMP_OPERATOR} : {token, {op_cmp, TokenLine, list_to_atom(TokenChars)}}.
{OR_OPERATOR}  : {token, {op_or, TokenLine}}.
{AND_OPERATOR} : {token, {op_and, TokenLine}}.
{NOT_OPERATOR} : {token, {op_not, TokenLine}}.
nil            : {token, {nil, TokenLine}}.
{NAME}         : {token, {name, TokenLine, TokenChars}}.
{INTEGER}      : {token, {integer,  TokenLine, TokenChars}}.
{STRING}       : {token, {string, TokenLine, trim_quotes(TokenChars)}}.
{WHITESPACE}+  : skip_token.

Erlang code.

trim_quotes(String) -> string:trim(String, both, "\"").
