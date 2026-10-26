/*Questão 1: View de Resumo de Vendas (V_VENDAS_RESUMO)
Crie uma view operacional chamada `V_VENDAS_RESUMO` que centralize os 
JOINs entre as tabelas de vendas, clientes e vendedores. A view deve 
retornar o `id_venda`, a `dt_venda`, o `status`, o `canal`, o nome do 
cliente, o nome do vendedor e o `valor_liquido` consolidado.*/
CREATE OR REPLACE VIEW V_VENDAS_RESUMO AS
SELECT V.ID_VENDA, V.DT_VENDA, V.STATUS, V.CANAL, CL.NOME NOME_CLIENTE, VR.NOME NOME_VENDEDOR, V.VALOR_LIQUIDO
FROM TB_VENDA V
INNER JOIN TB_CLIENTE CL USING(ID_CLIENTE)
INNER JOIN TB_VENDEDOR VR USING(ID_VENDEDOR);

SELECT * FROM V_VENDAS_RESUMO;

/*Questão 2: View de Cliente Público (V_CLIENTE_PUBLICO)
Desenvolva uma view voltada para a equipe de marketing chamada 
`V_CLIENTE_PUBLICO`. Esta view deve ocultar colunas sensíveis de dados 
pessoais (como CPF e Telefone) e filtrar apenas os clientes que estão 
com o status ativo (`ativo = 'S'`).*/
CREATE OR REPLACE VIEW V_CLIENTE_PUBLICO AS
SELECT ID_CLIENTE, NOME, EMAIL, DT_CADASTRO
FROM TB_CLIENTE
WHERE ATIVO='S';

SELECT * FROM V_CLIENTE_PUBLICO;

/*Questão 3: View de Receita por Categoria (V_VENDAS_POR_CATEGORIA)
Crie uma view analítica chamada `V_VENDAS_POR_CATEGORIA` que unifique e 
agrupe o faturamento acumulado por mês e por categoria de produto 
(considerando apenas vendas com status `'FECHADA'`).*/
CREATE OR REPLACE VIEW V_VENDAS_POR_CATEGORIA AS
SELECT SUM(VI.VALOR_TOTAL) FATURAMENTO, TO_CHAR(V.DT_VENDA, 'MM') MES, CT.NOME NOME_CATEGORIA
FROM TB_VENDA V 
JOIN TB_VENDA_ITEM VI USING(ID_VENDA)
JOIN TB_PRODUTO P USING(ID_PRODUTO)
JOIN TB_CATEGORIA CT USING(ID_CATEGORIA)
WHERE V.STATUS='FECHADA'
GROUP BY MES, NOME_CATEGORIA;

SELECT * FROM V_VENDAS_POR_CATEGORIA;

/*Questão 4: Consumindo a View Analítica
Escreva uma consulta SQL simples diretamente sobre a view
`V_VENDAS_POR_CATEGORIA` que filtre apenas as categorias de produto que
registraram um faturamento acumulado estritamente superior a R$ 5.000,00 
para o mês corrente.*/
SELECT NOME_CATEGORIA, FATURAMENTO
FROM V_VENDAS_POR_CATEGORIA
WHERE FATURAMENTO>5000 AND MES=TO_CHAR(SYSDATE, 'MM')
ORDER BY FATURAMENTO DESC;