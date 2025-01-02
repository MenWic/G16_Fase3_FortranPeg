s "sentence"
  = e* eof

e "expression"
  = _ (int / str) _

int "integer"
  = [0-9]+

str "string"
  = [a-zA-Z]+

_ "whitespace"
  = [ \t\n\r]*

eof "end of file"
  = !.
