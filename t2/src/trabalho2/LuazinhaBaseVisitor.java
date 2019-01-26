// Generated from Luazinha.g4 by ANTLR 4.5.3 
package trabalho2;
import org.antlr.v4.runtime.tree.AbstractParseTreeVisitor;

/**
 * This class provides an empty implementation of {@link LuazinhaVisitor},
 * which can be extended to create a visitor which only needs to handle a subset
 * of the available methods.
 *
 * @param <T> The return type of the visit operation. Use {@link Void} for
 * operations with no return type.
 */
public class LuazinhaBaseVisitor<T> extends AbstractParseTreeVisitor<T> implements LuazinhaVisitor<T> {
	PilhaDeTabelas pilhaDeTabelas = new PilhaDeTabelas();

     	@Override public T visitPrograma(LuazinhaParser.ProgramaContext ctx) {
            /**
            * Empilha a tabela referente ao escopo global
            * no início do programa, e desempilha ao fim.
            * (Código transferido do arquivo .g4 para este)
            */
            pilhaDeTabelas.empilhar(new TabelaDeSimbolos("global"));
            T t = visitChildren(ctx);
            pilhaDeTabelas.desempilhar();
            return t;
        }

	@Override public T visitTrecho(LuazinhaParser.TrechoContext ctx) { return visitChildren(ctx); }

	@Override public T visitBloco(LuazinhaParser.BlocoContext ctx) { return visitChildren(ctx); }

	@Override public T visitComando(LuazinhaParser.ComandoContext ctx) {
            if (ctx.for1 != null) {
                /**
                 * Se entrou aqui, está na regra
                 * comando : 'for' NOME '=' exp ',' exp (',' exp)? 'do' bloco 'end'
                 * .
                 * Então, empilha-se uma nova tabela, referente ao
                 * escopo do comando "for", e amarra-se a variável
                 * de controle do laço a este escopo. Desempilha-se
                 * a tabela no fim do escopo.
                 */
                pilhaDeTabelas.empilhar(new TabelaDeSimbolos("for"));
                pilhaDeTabelas.topo().adicionarSimbolo(ctx.n.getText(), "variavel");
                T t = visitChildren(ctx);
                pilhaDeTabelas.desempilhar();
                return t;
            } else if (ctx.for2 != null) {
                /**
                 * Se entrou aqui, está na regra
                 * comando : 'for' listadenomes 'in' listaexp 'do' bloco 'end'
                 * .
                 * Então, empilha-se uma nova tabela, referente ao
                 * escopo do comando "for", e amarram-se as variáveis
                 * de controle do laço a este escopo. Desempilha-se
                 * a tabela no fim do escopo.
                 *
                 * Para garantir que as variáveis usadas em listaexp já
                 * estejam amarradas a algum escopo, visita-se listaexp
                 * antes de fazer a amarração das variáveis de listadenomes.
                 */
                pilhaDeTabelas.empilhar(new TabelaDeSimbolos("for"));
                visitListaexp(ctx.listaexp());
                pilhaDeTabelas.topo().adicionarSimbolos(ctx.ln1.nomes, "variavel");
                visitListadenomes(ctx.ln1);
                T t = visitBloco(ctx.bl);
                pilhaDeTabelas.desempilhar();
                return t;
            } else if (ctx.ndf != null) {
                /**
                 * Se entrou aqui, está na regra
                 * comando : 'function' nomedafuncao corpodafuncao
                 * .
                 * Então, empilha-se uma nova tabela, referente ao
                 * escopo da função, e a desempilha no fim do escopo.
                 */
                pilhaDeTabelas.empilhar(new TabelaDeSimbolos(ctx.ndf.nome));
                T t = visitChildren(ctx);
                pilhaDeTabelas.desempilhar();
                return t;
            } else if (ctx.listavar() != null) {
                /**
                 * Se entrou aqui, está na regra
                 * comando : listavar '=' listaexp
                 * .
                 * Então, amarram-se as variáveis do lado esquerdo
                 * da atribuição (listavar) ao escopo mais interno
                 * SE elas não estiverem amarradas a escopo algum.
                 */
                visitListaexp(ctx.listaexp());
                for (String nome : ctx.listavar().nomes) {
                    if (!pilhaDeTabelas.existeSimbolo(nome)) {
                        pilhaDeTabelas.topo().adicionarSimbolo(nome, "variavel");
                    }
                }
                T t = visitListavar(ctx.listavar());
                return t;
            } else if (ctx.ln2 != null) {
                /**
                 * Se entrou aqui, está na regra
                 * comando : 'local' listadenomes ('=' listaexp)?
                 * .
                 * Então, deve-se amarrar as variáveis de listanome
                 * ao escopo mais interno, sem verificar se elas já
                 * estão amarradas a algum outro escopo.
                 *
                 * Uma alternativa é fazer a amarração das
                 * variáveis de listanome ao escopo mais
                 * interno, sem fazer qualquer verificação.
                 *
                 * Nossa implementação, no entanto, verifica
                 * se já existe variável local com o mesmo
                 * nome no escopo mais interno. Se houver,
                 * apresenta erro. Porém, é possível que haja
                 * um parâmetro de mesmo nome, então deve-se
                 * checar apenas pela existência de VARIÁVEIS
                 * já amarradas (e não parâmetros). Para isso,
                 * criamos a função "existeSimboloTipo", que
                 * verifica se um símbolo de nome E tipo
                 * determinados fora amarrado a algum escopo.
                 */
                for (String nome : ctx.ln2.nomes) {
                    if (!pilhaDeTabelas.topo().existeSimboloTipo(nome, "variavel")) {
                        pilhaDeTabelas.topo().adicionarSimbolo(nome, "variavel");
                    } else {
                        Saida.println("Erro semantico: variavel local " + nome + " ja declarada");
                    }
                }
            }
            return visitChildren(ctx);
        }

        @Override public T visitUltimocomando(LuazinhaParser.UltimocomandoContext ctx) { return visitChildren(ctx); }

      	@Override public T visitNomedafuncao(LuazinhaParser.NomedafuncaoContext ctx) {
            /**
             * Se a função for definida como método,
             * através do caractere ":", amarra-se o
             * parâmetro "self" a seu escopo. Neste
             * caso, ctx.metodo tem valor true.
             *
             */
            if (ctx.metodo) {
                pilhaDeTabelas.topo().adicionarSimbolo("self", "parametro");
            }
            return visitChildren(ctx);
        }

	@Override public T visitListavar(LuazinhaParser.ListavarContext ctx) { return visitChildren(ctx); }

	@Override public T visitVar(LuazinhaParser.VarContext ctx) {
            /**
             * Sempre que uma variável for usada, ela
             * deve estar amarrada a algum escopo. Se
             * não estiver, apresenta o erro semântico.
             */
            if (!pilhaDeTabelas.existeSimbolo(ctx.nome)) {
                Saida.println(ctx.linha + "," + (ctx.coluna + 1) + ":Variavel " + ctx.nome + " nao amarrada");
            }
            return visitChildren(ctx);
        }

	@Override public T visitListadenomes(LuazinhaParser.ListadenomesContext ctx) { return visitChildren(ctx); }

	@Override public T visitListaexp(LuazinhaParser.ListaexpContext ctx) { return visitChildren(ctx); }

	@Override public T visitExp(LuazinhaParser.ExpContext ctx) { return visitChildren(ctx); }

	@Override public T visitExpprefixo(LuazinhaParser.ExpprefixoContext ctx) { return visitChildren(ctx); }

	@Override public T visitExpprefixo2(LuazinhaParser.Expprefixo2Context ctx) { return visitChildren(ctx); }

	@Override public T visitChamadadefuncao(LuazinhaParser.ChamadadefuncaoContext ctx) { return visitChildren(ctx); }

	@Override public T visitArgs(LuazinhaParser.ArgsContext ctx) { return visitChildren(ctx); }

        @Override public T visitFuncao(LuazinhaParser.FuncaoContext ctx) { return visitChildren(ctx); }

        @Override public T visitCorpodafuncao(LuazinhaParser.CorpodafuncaoContext ctx) { return visitChildren(ctx); }

        @Override public T visitListapar(LuazinhaParser.ListaparContext ctx) {
            /**
             * Definições de parâmetros em corpo de função,
             * ou seja, em "listapar", deve acarretar na
             * amarração dos mesmos ao escopo da funçnao.
             */
            if (ctx.listadenomes() != null) {
                pilhaDeTabelas.topo().adicionarSimbolos(ctx.listadenomes().nomes, "parametro");
            }
            return visitChildren(ctx);
        }

        @Override public T visitConstrutortabela(LuazinhaParser.ConstrutortabelaContext ctx) { return visitChildren(ctx); }

        @Override public T visitListadecampos(LuazinhaParser.ListadecamposContext ctx) { return visitChildren(ctx); }

        @Override public T visitCampo(LuazinhaParser.CampoContext ctx) { return visitChildren(ctx); }

        @Override public T visitSeparadordecampos(LuazinhaParser.SeparadordecamposContext ctx) { return visitChildren(ctx); }

        @Override public T visitOpbin(LuazinhaParser.OpbinContext ctx) { return visitChildren(ctx); }

        @Override public T visitOpunaria(LuazinhaParser.OpunariaContext ctx) { return visitChildren(ctx); }
}
