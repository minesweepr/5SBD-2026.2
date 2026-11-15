/*Exercício 1: Crie uma Materialized View chamada mv_vendas_categoria agrupando o faturamento total e quantidade de vendas
por categoria de produto (requer JOIN entre tb_vendas e tb_produtos). Configure-a com REFRESH COMPLETE ON DEMAND.*/
CREATE MATERIALIZED VIEW MV_VENDAS_CATEGORIA
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND AS
SELECT P.CATEGORIA, SUM(V.VALOR_TOTAL) FATURAMENTO_TOTAL, SUM(V.QUANTIDADE) QUANTIDADE_DE_VENDAS
FROM TB_VENDAS V
JOIN TB_PRODUTOS P USING(ID_PRODUTO)
GROUP BY P.CATEGORIA;

SELECT * FROM MV_VENDAS_CATEGORIA ORDER BY FATURAMENTO_TOTAL;
/*Exercício 2: Altere o modo de atualização de uma visão materializada para ON COMMIT em um ambiente de desenvolvimento local. 
Teste a inserção de novos registros com COMMIT e analise as implicações em termos de retenção de locks transacionais e tempo de resposta.*/
CREATE MATERIALIZED VIEW MV_VENDAS_PRODUTO
BUILD IMMEDIATE REFRESH COMPLETE ON COMMIT AS
SELECT ID_PRODUTO, COUNT(*) TOTAL_TRANSACOES, SUM(QUANTIDADE) QUANTIDADE_TOTAL, SUM(VALOR_TOTAL) FATURAMENTO_TOTAL
FROM TB_VENDAS
GROUP BY ID_PRODUTO;

INSERT INTO TB_VENDAS(ID_PRODUTO, QUANTIDADE, DATA_VENDA, VALOR_TOTAL) VALUES(1, 2, SYSDATE, 9000);

SELECT * FROM MV_VENDAS_PRODUTO WHERE ID_PRODUTO=1;
/*ANÁLISE: a atualização ON COMMIT mantém a visão materializada atualizada automaticamente após cada confirmação, 
mas aumenta o tempo do COMMIT e pode prolongar a retenção de locks transacionais, pois a atualização precisa 
terminar antes da conclusão da operação.*/

/*Exercício 3: Inspecione o dicionário de dados do Oracle para verificar o status e metadados das MViews e Logs criados no seu schema:*/
SELECT OWNER, MVIEW_NAME, REFRESH_MODE, REFRESH_METHOD, LAST_REFRESH_DATE FROM USER_MVIEWS;
SELECT MASTER, LOG_TABLE, LOG_TRIGGER FROM USER_MVIEW_LOGS;