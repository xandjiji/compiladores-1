// T1 (Construcao de Compiladores 1)
// Alexandre Regali Seleghim e Jessica Simoes Gama

grammar Lua;

@members {
   public static String grupo="<<551473, 511323>>";
}


// <---------- DEFININDO OS LEXEMAS DA NOSSA LINGUAGEM ---------->


// definindo nossos operadores

    Op1 : 'or';

    Op2: 'and';
    
    Op3Rel: '=='    | 
            '~='    |  
            '<'     | 
            '>'     | 
            '<='    | 
            '>='    ;
    
    Op4: '..'       ;
    
    OpAritSoma: '+';
    OpAritSub: '-' ;
  
    OpArit6: '*'    | 
             '/'    | 
             '%'    ;
    
    Op7: 'not'      | 
         '#'        ;
    
    OpArit8: '^'    ;
    
    OpAtrib: '='    ;
     
    OpSobrando: 
                '(' | 
                ')' | 
                '{' | 
                '}' | 
                '[' | 
                ']' | 
                ';' | 
                ':' |
                ',' | 
                '.' | 
                '...';
    



// definindo NOMES na nossa linguagem (cadeias de cadeias contendo LETRAS [a-z][A-Z], DIGITOS [0-9] e underlines [_] que NAO comecam com DIGITOS)
// exemplos validos: _gato38, c4ch0rr0_azul, papagaio
//exemplos invalidos: 182blink, ***teste***
    
    Nome: (Letra | '_')(Letra | DIG | '_')*;
    

// definindo CADEIAS na nossa linguagem (cadeias de caracteres que iniciam e terminam com " ou ')
    
    Cadeia : ('\'' | '"') ( ~('\''| '"') )* ('\'' | '"');
    

// definindo nosso alfabeto de LETRAS [a-z][A-Z]

    fragment Letra : 'a'..'z'   | 
                     'A'..'Z'   ;

    
// definindo o simbolo utilizado para notacao exponencial de um DIGITO

    fragment EXP: 'e'|
                  'E';


// definindo nosso alfabeto de DIGITOS [0-9]
	
    fragment DIG: '0'..'9';


// definindo os simbolos para indicar o sinal que acompanha a notacao exponencial (opcional)

    fragment SIN: '+'|
                  '-';


// definindo o alfabeto de DIGITOS alfabeticos utilizados na base hexadecimal [a-f][A-F]
	
    fragment Alfhexa: 'A' ..  'F'   |
                      'a' .. 'f'    ;


// finalmente, definindo uma cadeia de numeros
	
    CadeiaNum : DIG* '.'? DIG+ (EXP SIN? DIG+)? | 
                     '0x' (DIG | Alfhexa )*     ;
    

    


// definindo um dicionario de palavras reservadas

    PalavrasReservadas: 'end'           |
                        'in'            |
                        'break'         |
                        'false'         |
                        'local'         |
                        'do'            |
                        'for'           |
                        'nil'           |
                        'else'          |
                        'elseif'        |
                        'function if'   |
                        'repeat'        |
                        'return'        |
                        'then'          |
                        'true'          |
                        'until'         |
                        'while'         ;


// definindo caracteres que serao IGNORADOS conforme a especificacao do trabalho

    Ignorados: (('--' (~('\n'|'\r'))* ('\r')? '\n')      |
               (' '                                      |
               '\t'                                     |
               '\r'                                     |
               '\n'                                     ))-> skip ;
    





// <---------- DEFININDO A GRAMATICA DA NOSSA LINGUAGEM ---------->


// regra PROGRAMA, utilizada para o comeco de cada programa

    programa : trecho;
    

// regras COMANDO e ULTIMOCOMANDO, utilizadas para derivar um comando na nossa linguagem

    comando : listaVar OpAtrib listaExp                                                 | 
              chamadaFuncao                                                             | 
              'do' bloco 'end'                                                          |
              'while' exp 'do' bloco 'end'                                              | 
              'repeat' bloco 'until' exp                                                |
              'if' exp 'then' bloco ('elseif' exp 'then' bloco)* ('else' bloco)? 'end'  |
              'for' Nome  { TabelaDeSimbolos.adicionarSimbolo($Nome.text,Tipo.VARIAVEL); } OpAtrib exp ',' exp (',' exp)? 'do' bloco 'end'                    |
              'for' listaNomes 'in' listaExp 'do' bloco 'end'                           |
              'function' nomeFuncao { TabelaDeSimbolos.adicionarSimbolo($nomeFuncao.text,Tipo.FUNCAO); } corpoFuncao                                          |
              'local' ('function' Nome  { TabelaDeSimbolos.adicionarSimbolo($Nome.text,Tipo.FUNCAO); } corpoFuncao) |
              'local' listaNomes (OpAtrib listaExp)?      ;
    
    ultimoComando : 'return' (listaExp)?    | 
                    'break'                 ;
    

// regras TRECHO (que seria comandos em cadeia separados por [;]) e BLOCO (que seria uma cadeia de TRECHOS)
       
    trecho : (comando ';'?)* (ultimoComando ';'?)?; 

    bloco : trecho;
    

// regra NOMEFUNCAO que define o nome de uma funcao na nossa linguagem
    
    nomeFuncao : Nome ('.' Nome)* (':' Nome)? ;
    

// regra LISTANOMES que definira variaveis (separadas por [,])
    
    listaNomes : Nome { TabelaDeSimbolos.adicionarSimbolo($Nome.text,Tipo.VARIAVEL); } 
               (',' Nome { TabelaDeSimbolos.adicionarSimbolo($Nome.text,Tipo.VARIAVEL); } )* ;






// a seguir definiremos regras que serao utilizadas pela regra EXP que definira uma expressao aritmetica


// regra OPERADOR ARITMETICO define nossos operadores ([+] e [-])
    
    operadorAritmetico : OpAritSoma |
                         OpAritSub  ;                        

    
// regra ELEMENTO define os termos da nossa expressao (pondendo ser uma cadeia de numeros ou caracteres)

    elemento : CadeiaNum | 
               Cadeia  ;


// definindo os simbolos terminais na nossa expressao
    
    expfinal : 'nil'            |
               'false'          |
               'true'           | 
               elemento         | 
               '...'            |    
               'funcao'         |
                expprefixo      | 
                construtorTabela;


// e finalmente definindo nossas possiveis derivacoes de expressoes

    exp : exp1 ('or' exp1)*;

    exp1: exp2 ('and' exp2)*;

    exp2: exp3 (Op3Rel exp3)*;

    exp3: exp4 (Op4 exp4)*;

    exp4: exp5 (operadorAritmetico exp5)*;

    exp5: exp6 (OpArit6 exp6)*;

    exp6: (Op7 | OpAritSub)* exp7;

    exp7 : expfinal (OpArit8 expfinal)*;
    
    
// LISTAEXP serao varias expressoes em cadeia, separadas por virgula [,]

    listaExp : (exp ',')* exp ;


// LISTAVAR serao varias variaveis em cadeia separadas por virgula [,]

    listaVar : var         { TabelaDeSimbolos.adicionarSimbolo($var.text,Tipo.VARIAVEL); } 
               (',' var   { TabelaDeSimbolos.adicionarSimbolo($var.text,Tipo.VARIAVEL); })* ;
               

// EXPPREFIXO serao possiveis tokens que acompanharao nossas expressoes (chamada de funcoes)
    
    expprefixo : var | chamadaFuncao | '(' exp ')';

    expprefixo1 :   Nome ( '[' exp ']' | '.' Nome )*;

      
// definindo VAR para identificar uma variavel

    var : Nome
    { TabelaDeSimbolos.adicionarSimbolo($Nome.text,Tipo.VARIAVEL); }    | 
          expprefixo1 '[' exp ']'                                       | 
          expprefixo1 '.' Nome                                          ; 


// definindo uma chamada de funcao    
    
    chamadaFuncao : expprefixo1 (args | (':' Nome args))  { TabelaDeSimbolos.adicionarSimbolo($expprefixo1.text,Tipo.FUNCAO); }   ;


// definindo possiveis argumentos (ARGS) para nossa chamada de funcao
  
    args : '(' (listaExp)? ')'      | 
           construtorTabela         | 
           Cadeia                   ;


// regra FUNCAO para definir uma funcao
    
    funcao : 'function' corpoFuncao ;
    

// define o que vira depois de uma funcao (lista de parametros entre parentesis [(] [)] seguido de um BLOCO e terminado por [end])

    corpoFuncao : '(' (listapar)? ')' bloco 'end';
    

// definindo LISTAPAR que serao nossos parametros separados por virgula [,] no corpo da funcao

    listapar : listaNomes (',' '...')?    | 
               '...'                        ;


// definindo algumas estruturas utilizadas na nossa linguagem

    construtorTabela : '{' (listaCampos)? '}';

    listaCampos : campo (separadorCampos campo)* (separadorCampos)?;

    campo : '[' exp ']' OpAtrib exp | 
            Nome OpAtrib exp        | 
            exp                 ;

    separadorCampos : ','       | 
                      ';'       ;
