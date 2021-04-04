Definitions.

INTEGER    = [0-9]+
NAME       = [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE = [\s\t\n\r]

Rules.

\+            : {token, {'+',  TokenLine}}.
\-            : {token, {'-',  TokenLine}}.
\*            : {token, {'*',  TokenLine}}.
\/            : {token, {'/',  TokenLine}}.
\=            : {token, {'=',  TokenLine}}.
\;            : {token, {';',  TokenLine}}.
\(            : {token, {'(',  TokenLine}}.
\)            : {token, {')',  TokenLine}}.
{NAME}        : {token, {name, TokenLine, list_to_atom(TokenChars)}}.
{INTEGER}     : {token, {integer,  TokenLine, TokenChars}}.
{WHITESPACE}+ : skip_token.

Erlang code.