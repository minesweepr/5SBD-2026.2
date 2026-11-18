/*Exercício 1 (Função de Tempo de Casa em Anos): Crie uma função chamada fnc_calcular_tempo_casa que 
receba p_data_admissao IN DATE e retorne um NUMBER representando a quantidade de anos completos 
trabalhados pelo colaborador.
Dica: Utilize as funções nativas MONTHS_BETWEEN(SYSDATE, p_data_admissao) e FLOOR().*/
CREATE OR REPLACE FUNCTION FNC_CALCULAR_TEMPO_CASA(
    P_DATA_ADMISSAO IN DATE
)RETURN NUMBER
IS
BEGIN
    RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, P_DATA_ADMISSAO)/12);
END FNC_CALCULAR_TEMPO_CASA;

SELECT NOME, DATA_ADMISSAO, FNC_CALCULAR_TEMPO_CASA(DATA_ADMISSAO) ANOS_COMPLETOS_TRABALHADOS
FROM TB_COLABORADORES;

/*Exercício 2 (Violação de Pureza e Erro ORA-14551): Crie uma função experimental que tente executar 
um comando UPDATE na tabela tb_colaboradores antes de retornar um valor numérico. Tente executá-la 
através do comando SELECT fnc_teste_dml() FROM DUAL;. Documente a ocorrência da exceção 
ORA-14551: cannot perform a DML operation inside a query.*/
CREATE OR REPLACE FUNCTION FNC_TESTE_DML
RETURN NUMBER
IS
BEGIN
    UPDATE TB_COLABORADORES
    SET SALARIO_BASE=SALARIO_BASE+1
    WHERE ID_COLABORADOR=1;
    RETURN 1;
END FNC_TESTE_DML;

SELECT FNC_TESTE_DML() FROM DUAL;

/*RESPOSTA: A execução apresenta o erro ORA-14551: cannot perform a DML operation inside a query, 
pois o Oracle não permite que uma função chamada diretamente por uma consulta SQL execute operações 
DML nesse contexto.*/