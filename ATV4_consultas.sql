--1. Jornada de Compras do Cliente: A equipe de CRM quer entender o comportamento de recompra 
--dos clientes. Escreva uma consulta que liste o nome do cliente, a data da venda (dt_venda) 
--e o valor líquido. Adicione uma coluna calculada chamada numero_compra utilizando a função 
--ROW_NUMBER(). Essa coluna deve numerar cronologicamente as compras de cada cliente 
--(a primeira compra do cliente recebe 1, a segunda 2, e assim por diante). 
--Considere apenas vendas com status 'FECHADA'.
SELECT C.NOME, V.DT_VENDA, V.VALOR_LIQUIDO, ROW_NUMBER() OVER(
    PARTITION BY ID_CLIENTE
    ORDER BY V.DT_VENDA
) numero_compra
FROM TB_VENDA V
JOIN TB_CLIENTE C USING(ID_CLIENTE)
WHERE V.STATUS='FECHADA'
GROUP BY C.NOME, V.DT_VENDA, V.VALOR_LIQUIDO
ORDER BY C.NOME, V.DT_VENDA

--2. Ranking Mensal de Vendedores: O RH precisa do pódio mensal de vendas. Crie uma consulta 
--(você pode usar uma CTE antes para facilitar) que calcule o total vendido por cada vendedor em 
--cada mês. Em seguida, adicione uma coluna chamada posicao_ranking utilizando a função DENSE_RANK().
--O ranking deve ser reiniciado a cada mês (use PARTITION BY) e ordenado do maior para o menor faturamento.
WITH MENSAL_VENDAS AS(
    SELECT VEND.NOME, TO_CHAR(VEN.DT_VENDA, 'MM/YYYY') MES_ANO_VENDA, SUM(VEN.VALOR_LIQUIDO) TOTAL
    FROM TB_VENDA VEN
    JOIN TB_VENDEDOR VEND USING(ID_VENDEDOR)
    GROUP BY VEND.NOME, MES_ANO_VENDA
)
SELECT NOME, MES_ANO_VENDA, TOTAL, DENSE_RANK() OVER(
    PARTITION BY MES_ANO_VENDA
    ORDER BY TOTAL DESC
) posicao_ranking
FROM MENSAL_VENDAS

--3. Os 2 Produtos Mais Vendidos por Categoria: Descubra quais são os "carros-chefes" de cada categoria. 
--Crie uma consulta que calcule a quantidade total vendida de cada produto. Usando DENSE_RANK() particionado 
--por categoria, gere um ranking. Na consulta final, filtre para exibir apenas os 2 primeiros colocados de 
--cada categoria. (Lembre-se: não é possível usar funções analíticas direto na cláusula WHERE, 
--você precisará de uma subquery ou CTE).
WITH RANKING_PRODUTOS AS(
    SELECT P.NOME NOME_PRODUTO, C.NOME NOME_CATEGORIA, SUM(I.QUANTIDADE) QUANT_TOTAL, DENSE_RANK() OVER(
        PARTITION BY C.NOME
        ORDER BY SUM(I.QUANTIDADE) DESC
    ) COLOCACAO
    FROM TB_VENDA_ITEM I
    JOIN TB_PRODUTO P USING(ID_PRODUTO)
    JOIN TB_CATEGORIA C USING(ID_CATEGORIA)
    GROUP BY P.NOME, C.NOME
)
SELECT NOME_PRODUTO, NOME_CATEGORIA, QUANT_TOTAL, COLOCACAO
FROM RANKING_PRODUTOS
WHERE COLOCACAO<=2

--4. Participação no Faturamento (Market Share Interno): A diretoria quer saber a fatia do bolo de cada vendedor. 
--Calcule o faturamento total de cada vendedor (apenas vendas fechadas). Em uma coluna ao lado, mostre o percentual 
--que esse valor representa em relação ao faturamento total da empresa. (Dica: Divida a receita do vendedor pela 
--soma total usando SUM(receita) OVER() e multiplique por 100).
SELECT NOME, TO_CHAR(FATURAMENTO, 'L999G999G990D00') FATURAMENTO, ROUND(FATURAMENTO/SUM(FATURAMENTO) OVER()*100,2)||'%' PERCENTUAL
FROM(
    SELECT VEND.NOME, SUM(VEN.VALOR_LIQUIDO) FATURAMENTO
    FROM TB_VENDA VEN
    JOIN TB_VENDEDOR VEND USING(ID_VENDEDOR)
    WHERE VEN.STATUS='FECHADA'
    GROUP BY VEND.NOME
)

--5. Termômetro de Vendas (Acima ou Abaixo da Média?): Liste o id_venda, o valor_liquido e crie duas colunas analíticas extras:
--           media_geral: A média de valor de todas as vendas da empresa.
--           diferenca_media: O valor líquido da venda menos a média geral (para sabermos rapidamente se aquela venda foi 
--           acima ou abaixo do padrão da empresa).
SELECT ID_VENDA, VALOR_LIQUIDO, media_geral, ROUND(VALOR_LIQUIDO-media_geral,2) diferenca_media
FROM(
    SELECT ID_VENDA, VALOR_LIQUIDO, ROUND(AVG(VALOR_LIQUIDO) OVER(),2) media_geral
    FROM TB_VENDA
)