/*Exercício 1: Simulação de Ambiente Multi-Schema e Privilégios
Cenário: Explique e elabore o fluxo completo de comandos SQL e DCL necessários para que o usuário ANALISTA_BI 
consiga consultar a tabela EMPLOYEES pertencente ao schema HR, utilizando simplesmente a instrução SELECT * FROM func;*/
GRANT SELECT ON HR.EMPLOYEES TO ANALISTA_BI; --o usuario HR concede permissão de leitura pro usuario ANALISTA_BI
CREATE SYNONYM FUNC FOR HR.EMPLOYEES; --no schema de ANALISTA_BI é criado o sinônimo privado
SELECT * FROM FUNC; --e o usuario pode consultar a tabela*

/*Exercício 2: Ordem de Resolução de Nomes
Cenário: Considere que o usuário conectado possui em seu ambiente:
    Uma tabela física própria chamada PEDIDOS.
    Um sinônimo privado chamado PEDIDOS (apontando para FATURAMENTO.TB_PEDIDOS).
    Um sinônimo público chamado PEDIDOS (apontando para GLOBAL.TB_PEDIDOS).
Ao executar a consulta SELECT * FROM pedidos;, qual objeto será retornado pelo Oracle Database? 
Justifique com base nas regras de parsing.*/
/*RESPOSTA: A tabela física PEDIDOS do schema vai ser consultada, pois objetos locais 
têm prioridade sobre sinônimos privados e públicos na resolução de nomes do Oracle.*/

/*Exercício 3: Sinônimos Inválidos / Órfãos
Cenário: O que acontece com um sinônimo se o objeto subjacente para o qual ele aponta (ex: tabela base) 
for excluído com a instrução DROP TABLE? O sinônimo é removido automaticamente? 
O que ocorre ao tentar consultá-lo?*/
/*RESPOSTA: O sinônimo não é removido automaticamente quando a tabela de destino é removida. 
Ele permanece no dicionário de dados como sinônimo órfão e, ao tentar consultá-lo, o oracle retorna 
o erro ORA-00942: table or view does not exist.*/