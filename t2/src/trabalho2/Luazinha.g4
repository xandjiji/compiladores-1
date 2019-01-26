grammar Luazinha;


@members{
static String grupo = "<551473, 511322, 726534>";
PilhaDeTabelas pilhaDeTabelas = new PilhaDeTabelas();
}

/**
 * Implementamos as verificações das regras
 * semânticas por meio de visitor. O código
 * está no arquivo LuazinhaBaseVisitor.java
 */

/*
 * As ações que já estavam implementadas aqui
 * foram transferidas para o código do visitor.
{ pilhaDeTabelas.empilhar(new TabelaDeSimbolos("global")); }
{ pilhaDeTabelas.desempilhar(); }
*/
programa :  trecho
         ;

trecho : (comando ';'?)* (ultimocomando ';'?)?
       ;

bloco : trecho
      ;

comando :  listavar '=' listaexp
        |  chamadadefuncao
        |  'do' bloco 'end'
        |  'while' exp 'do' bloco 'end'
        |  'repeat' bloco 'until' exp
        |  'if' exp 'then' bloco ('elseif' exp 'then' bloco)* ('else' bloco)? 'end'
        |  for1='for' n=NOME '=' exp ',' exp (',' exp)? 'do' bloco 'end'
        |  for2='for' ln1=listadenomes 'in' listaexp 'do' bl=bloco 'end'
        |  'function' ndf=nomedafuncao corpodafuncao
        |  'local' 'function' NOME corpodafuncao
        |  'local' ln2=listadenomes ('=' listaexp)?
        ;

ultimocomando : 'return' (listaexp)? | 'break'
              ;

nomedafuncao returns [ String nome, boolean metodo ]
@init { $metodo = false; }
    : n1=NOME { $nome = $n1.getText(); }
      ('.' n2=NOME { $nome += "." + $n2.getText(); })*
      (':' n3=NOME { $metodo = true; $nome += "." + $n3.getText(); })?
    ;

listavar returns [ List<String> nomes ]
@init { $nomes = new ArrayList<String>(); }
    : v1=var { $nomes.add($v1.nome); }
      (',' v2=var { $nomes.add($v2.nome); }
      )*
    ;

var returns [ String nome, int linha, int coluna ]
    :  NOME { $nome = $NOME.getText(); $linha = $NOME.line; $coluna = $NOME.pos; }
    |  expprefixo '[' exp ']'
    |  expprefixo '.' NOME
    ;

listadenomes returns [ List<String> nomes ]
@init{ $nomes = new ArrayList<String>(); }
    : n1=NOME { $nomes.add($n1.getText()); }
      (',' n2=NOME { $nomes.add($n2.getText()); } )*
    ;

listaexp : (exp ',')* exp
         ;

exp :  'nil' | 'false' | 'true' | NUMERO | CADEIA | '...' | funcao |
       expprefixo2 | construtortabela | exp opbin exp | opunaria exp
    ;


expprefixo : NOME ( '[' exp ']' | '.' NOME )*
           ;

expprefixo2 : var | chamadadefuncao | '(' exp ')'
           ;

chamadadefuncao :  expprefixo args |
                   expprefixo ':' NOME args
                ;

args :  '(' (listaexp)? ')' | construtortabela | CADEIA
     ;

funcao : 'function' corpodafuncao
       ;

corpodafuncao : '(' (listapar)? ')' bloco 'end'
              ;

listapar : listadenomes (',' '...')?
         | '...'
         ;

construtortabela : '{' (listadecampos)? '}'
                 ;

listadecampos : campo (separadordecampos campo)* (separadordecampos)?
              ;

campo : '[' exp ']' '=' exp | NOME '=' exp | exp
      ;

separadordecampos : ',' | ';'
                  ;

opbin : '+' | '-' | '*' | '/' | '^' | '%' | '..' | '<' |
        '<=' | '>' | '>=' | '==' | '~=' | 'and' | 'or'
      ;

opunaria : '-' | 'not' | '#'
         ;


NOME	:	('a'..'z' | 'A'..'Z' | '_') ('a'..'z' | 'A'..'Z' | '0'..'9' | '_')*;
CADEIA	:	'\'' ~('\n' | '\r' | '\'')* '\'' | '"' ~('\n' | '\r' | '"')* '"';
NUMERO	:	('0'..'9')+ EXPOENTE? | ('0'..'9')+ '.' ('0'..'9')* EXPOENTE?
		| '.' ('0'..'9')+ EXPOENTE?;
fragment
EXPOENTE	:	('e' | 'E') ( '+' | '-')? ('0'..'9')+;
COMENTARIO
	:	'--' ~('\n' | '\r')* '\r'? '\n' {skip();};
WS	:	(' ' | '\t' | '\r' | '\n') {skip();};
