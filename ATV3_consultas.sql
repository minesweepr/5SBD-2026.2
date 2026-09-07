--Desempenho de Vendas por Vendedor: Escreva uma consulta que retorne o nome de cada vendedor e o valor total vendido por ele
--(soma do valor_liquido). Considere apenas as vendas com o status 'FECHADA' e ordene o resultado do maior para o menor faturamento.
SELECT VEND.NOME, SUM(VEN.valor_liquido) TOTAL
FROM TB_VENDEDOR VEND
JOIN TB_VENDA VEN ON VEN.id_vendedor=VEND.id_vendedor
WHERE VEN.status='FECHADA'
GROUP BY VEND.ID_VENDEDOR, VEND.NOME
ORDER BY TOTAL DESC

--Histórico de Compras do Cliente: Liste o nome dos clientes, a data da venda e o valor líquido de todas as compras que eles realizaram.
--Traga também os clientes que possuem vendas canceladas.
SELECT CLI.NOME, VEN.DT_VENDA, VEN.valor_liquido
FROM TB_CLIENTE CLI
JOIN TB_VENDA VEN ON CLI.ID_CLIENTE=VEN.ID_CLIENTE
ORDER BY VEN.valor_liquido DESC

--O Melhor Cliente: Identifique o nome do cliente que possui o maior valor total acumulado em compras fechadas.
SELECT CLI.NOME, SUM(VEN.VALOR_LIQUIDO) TOTAL
FROM TB_CLIENTE CLI
JOIN TB_VENDA VEN ON CLI.ID_CLIENTE=VEN.ID_CLIENTE
WHERE VEN.STATUS='FECHADA'
GROUP BY CLI.ID_CLIENTE, CLI.NOME
ORDER BY TOTAL DESC FETCH FIRST 1 ROW ONLY;

--Vendas Acima da Média (Subquery): Liste o id_venda, a data e o valor líquido de todas as vendas cujo valor seja
--superior à média geral de todas as vendas com status 'FECHADA'.
SELECT VEN.ID_VENDA, VEN.DT_VENDA, VEN.VALOR_LIQUIDO
FROM TB_VENDA VEN
WHERE VEN.STATUS='FECHADA'
AND VEN.VALOR_LIQUIDO > (
    SELECT AVG(VALOR_LIQUIDO)
    FROM TB_VENDA
    WHERE STATUS='FECHADA'
    )

--Estoque Encalhado (NOT EXISTS): A área de logística precisa saber quais produtos não estão girando.
--Liste o nome de todos os produtos ativos que nunca foram vendidos (ou seja, que não possuem nenhum
--registro na tabela TB_VENDA_ITEM). Utilize a cláusula NOT EXISTS.
SELECT P.NOME
FROM TB_PRODUTO P
WHERE P.ATIVO='S'
AND NOT EXISTS (
    SELECT 1
    FROM TB_VENDA_ITEM IT
    WHERE IT.ID_PRODUTO=P.ID_PRODUTO
)

--Classificação Comercial de Clientes (CASE WHEN): Crie um relatório que traga o nome do cliente,
--o seu faturamento total (vendas fechadas) e uma nova coluna chamada categoria_cliente.
--A classificação deve seguir a regra abaixo:
--Ouro: Faturamento acima de R$ 10.000,00.
--Prata: Faturamento entre R$ 2.000,00 e R$ 10.000,00.
--Bronze: Faturamento abaixo de R$ 2.000,00.
SELECT CLI.NOME, SUM(VEN.VALOR_LIQUIDO) FATURAMENTO,
    CASE
        WHEN SUM(VEN.VALOR_LIQUIDO)>10000 THEN 'OURO'
        WHEN SUM(VEN.VALOR_LIQUIDO)>=2000 THEN 'PRATA'
        ELSE 'BRONZE'
    END AS CATEGORIA_CLIENTE
FROM TB_CLIENTE CLI
JOIN TB_VENDA VEN ON CLI.ID_CLIENTE=VEN.ID_CLIENTE
WHERE VEN.STATUS='FECHADA'
GROUP BY CLI.ID_CLIENTE, CLI.NOME

--Receita Mensal da Empresa: Utilizando a cláusula WITH, crie uma CTE chamada receita_mensal que
--calcule o faturamento total das vendas fechadas por mês (você pode usar a função TRUNC(dt_venda, 'MM')
--para extrair o mês). Na consulta principal, exiba o mês e a receita ordenados cronologicamente.
WITH RECEITA_MENSAL AS(
    SELECT TRUNC(DT_VENDA, 'MM') AS MES_REF, SUM(VALOR_LIQUIDO) AS RECEITA
    FROM TB_VENDA
    WHERE STATUS='FECHADA'
    GROUP BY TRUNC(DT_VENDA, 'MM')
)
SELECT MES_REF, RECEITA
FROM RECEITA_MENSAL
ORDER BY MES_REF

--Top 5 Produtos Mais Vendidos: Construa uma CTE que calcule a quantidade total vendida de cada produto
--(somando a coluna quantidade da tabela de itens). Na consulta final, ordene do produto mais vendido para
--o menos vendido e limite o resultado para mostrar apenas os 5 primeiros colocados.
WITH QTD_PRODUTO AS(
    SELECT P.NOME AS PRODUTO, SUM(IT.QUANTIDADE) AS TOTAL_VENDIDO
    FROM TB_PRODUTO P
    JOIN TB_VENDA_ITEM IT ON P.ID_PRODUTO=IT.ID_PRODUTO
    GROUP BY P.ID_PRODUTO, P.NOME
)
SELECT PRODUTO, TOTAL_VENDIDO
FROM QTD_PRODUTO
ORDER BY TOTAL_VENDIDO DESC
FETCH FIRST 5 ROWS ONLY

--1.1 Listagem de Clientes Ativos: Escreva uma consulta que retorne o nome, o e-mail e o telefone de todos 
--os clientes que estão com o status ativo (ativo = 'S'). Ordene o resultado alfabeticamente pelo nome.
SELECT NOME, EMAIL, TELEFONE 
FROM TB_CLIENTE 
WHERE ATIVO='S' 
ORDER BY NOME

--1.2 Filtro de Vendas por Canal: A equipe de marketing precisa de uma lista das vendas. Retorne o id_venda, 
--a data da venda (dt_venda) e o valor_liquido de todas as vendas que foram realizadas pelo canal 'APP' e 
--que estão com o status 'FECHADA'.
SELECT ID_VENDA, DT_VENDA, VALOR_LIQUIDO 
FROM TB_VENDA 
WHERE CANAL='APP' 
AND STATUS='FECHADA'

--1.3 Catálogo de Produtos e Categorias (JOIN): Crie uma consulta que liste o nome do produto (tb_produto), 
--o seu sku e o nome da categoria à qual ele pertence (tb_categoria).
SELECT P.NOME AS NOME_PRODUTO, P.SKU, CA.NOME AS CATEGORIA
FROM TB_PRODUTO P
JOIN TB_CATEGORIA CA ON P.ID_CATEGORIA=CA.ID_CATEGORIA


--1.4 Contagem de Vendedores: Utilizando uma função de agregação simples, descubra qual é o número total de 
--vendedores cadastrados no sistema.
SELECT COUNT(*) AS TOTAL_DE_VENDEDORES
FROM TB_VENDEDOR

--1.5 Produtos Mais Caros: Liste o nome e o preço unitário (preco_unit) de todos os produtos ativos, ordenando 
--do produto mais caro para o mais barato.
SELECT NOME, PRECO_UNIT
FROM TB_PRODUTO
WHERE ATIVO='S'
ORDER BY PRECO_UNIT DESC

--2.1 Faturamento por Canal de Venda (GROUP BY): Calcule o faturamento total (soma do valor_liquido) gerado por cada 
--canal de venda ('APP', 'SITE', 'LOJA', 'TELEFONE'). Considere apenas as vendas 'FECHADA' e ordene do canal mais 
-- para o menos lucrativo.
SELECT CANAL, SUM(VALOR_LIQUIDO) AS TOTAL
FROM TB_VENDA
WHERE STATUS='FECHADA'
GROUP BY CANAL
ORDER BY TOTAL DESC

--2.2 Ticket Médio por Vendedor: Crie uma consulta que liste o nome de cada vendedor e o valor médio de suas vendas 
--(ticket médio). Retorne apenas as vendas com status 'FECHADA' e arredonde o valor para duas casas decimais.
SELECT VDR.NOME, ROUND(AVG(VD.VALOR_LIQUIDO), 2) AS TICKET_MEDIO 
FROM TB_VENDA VD
JOIN TB_VENDEDOR VDR ON VD.ID_VENDEDOR=VDR.ID_VENDEDOR
WHERE STATUS='FECHADA'
GROUP BY VDR.ID_VENDEDOR, VDR.NOME

--2.3 Clientes Inativos Comercialmente (NOT EXISTS): Identifique os clientes que se cadastraram no sistema, mas nunca 
--realizaram nenhuma compra. Retorne o nome e o e-mail desses clientes utilizando a cláusula NOT EXISTS (ou LEFT JOIN).
SELECT CL.NOME, CL.EMAIL
FROM TB_CLIENTE CL
WHERE NOT EXISTS(
    SELECT 1
    FROM TB_VENDA V
    WHERE CL.ID_CLIENTE=V.ID_CLIENTE
)

--2.4 Vendas Acima da Média (Subquery): Liste o id_venda, o nome do cliente e o valor_liquido das vendas (status 'FECHADA') 
--cujo valor seja estritamente maior que a média global de todas as vendas fechadas.
SELECT V.ID_VENDA, CL.NOME, V.VALOR_LIQUIDO
FROM TB_VENDA V
JOIN TB_CLIENTE CL ON V.ID_CLIENTE=CL.ID_CLIENTE
WHERE STATUS='FECHADA'
AND V.VALOR_LIQUIDO>(
    SELECT AVG(VALOR_LIQUIDO)
    FROM TB_VENDA
    WHERE STATUS='FECHADA'
)

--2.5 Classificação de Preço dos Produtos (CASE WHEN): A área de estoque pediu uma categorização visual. Retorne o nome do 
--produto, o preço unitário e uma nova coluna chamada faixa_preco utilizando a seguinte regra:
--Preço menor que R$ 50,00 -> 'BARATO'
--Preço entre R$ 50,00 e R$ 200,00 -> 'MÉDIO'
--Preço maior que R$ 200,00 -> 'CARO'
SELECT NOME, PRECO_UNIT,
    CASE
        WHEN PRECO_UNIT<50 THEN 'BARATO'
        WHEN PRECO_UNIT<=200 THEN 'MEDIO'
        ELSE 'CARO'
    END AS FAIZA_PRECO
FROM TB_PRODUTO 

--3.1 Numeração Cronológica de Compras (ROW_NUMBER): A equipe de CRM quer entender a jornada do cliente. Liste o nome do 
--cliente, a data da venda e o valor líquido, adicionando uma coluna chamada numero_compra que enumere as compras de cada 
--cliente em ordem cronológica (1 para a primeira compra, 2 para a segunda, etc.).
SELECT CL.NOME, V.DT_VENDA, V.VALOR_LIQUIDO,
    ROW_NUMBER() OVER(
        PARTITION BY V.ID_CLIENTE
        ORDER BY V.DT_VENDA, V.ID_VENDA
    ) AS NUMERO_COMPRA
FROM TB_CLIENTE CL
JOIN TB_VENDA V ON CL.ID_CLIENTE=V.ID_CLIENTE

--3.2 Participação Percentual no Faturamento (Matemática com OVER): Descubra qual é o peso de cada vendedor na empresa. 
--Calcule o faturamento total por vendedor e, em uma coluna ao lado, exiba o percentual que esse faturamento representa 
--em relação ao faturamento total da empresa, utilizando a cláusula OVER().
SELECT VR.NOME, SUM(VD.VALOR_LIQUIDO) AS FATURAMENTO_TOTAL, 
    ROUND(
        SUM(VD.VALOR_LIQUIDO)/SUM(SUM(VD.VALOR_LIQUIDO)) OVER() *100, 2
    ) AS PERCENTUAL
FROM TB_VENDEDOR VR
JOIN TB_VENDA VD ON VR.ID_VENDEDOR=VD.ID_VENDEDOR
GROUP BY VR.ID_VENDEDOR, VR.NOME

--3.3 Ranking Mensal de Vendedores (CTE + DENSE_RANK): Utilizando a cláusula WITH (CTE), crie uma consulta que mostre o 
--mês de referência (TRUNC(dt_venda, 'MM')), o nome do vendedor, sua receita total no mês e a posição dele no ranking 
--mensal de vendas (usando DENSE_RANK()). O ranking deve reiniciar a cada mês.
WITH MENSAL_DE_VENDA AS(
    SELECT TRUNC(VD.DT_VENDA, 'MM') AS MES_REFERENCIA, VR.NOME, SUM(VD.VALOR_LIQUIDO) AS RECEITA_TOTAL_MES
    FROM TB_VENDA VD
    JOIN TB_VENDEDOR VR ON VD.ID_VENDEDOR=VR.ID_VENDEDOR
    GROUP BY TRUNC(VD.DT_VENDA, 'MM'), VR.ID_VENDEDOR, VR.NOME
)
SELECT MES_REFERENCIA, NOME, RECEITA_TOTAL_MES, 
    DENSE_RANK() OVER(
        PARTITION BY MES_REFERENCIA
        ORDER BY RECEITA_TOTAL_MES DESC
    ) AS RANKING
FROM MENSAL_DE_VENDA
ORDER BY MES_REFERENCIA, RANKING

--3.4 Termômetro de Vendas (Comparação Analítica): Retorne o id_venda, o valor líquido da venda e crie uma coluna chamada 
--diferenca_para_media. Essa coluna deve calcular a diferença exata entre o valor da venda atual e a média geral de todas 
--as vendas da empresa.
SELECT ID_VENDA, VALOR_LIQUIDO, ROUND(VALOR_LIQUIDO - AVG(VALOR_LIQUIDO) OVER(), 2) AS DIFERENCA_PARA_MEDIA
FROM TB_VENDA

--3.5 Os 3 Produtos Mais Vendidos: Construa uma consulta utilizando CTE que some a quantidade vendida de cada produto 
--(tabela de itens). Em seguida, aplique um ranking e filtre a consulta principal para exibir apenas os 3 produtos mais 
--vendidos em toda a história do sistema.
WITH QUANT_VENDIDA AS(
    SELECT I.ID_PRODUTO, SUM(I.QUANTIDADE) AS QUANT_TOTAL
    FROM TB_VENDA_ITEM I
    GROUP BY I.ID_PRODUTO
),
RANKING AS(
    SELECT ID_PRODUTO, QUANT_TOTAL, ROW_NUMBER() OVER(ORDER BY QUANT_TOTAL DESC) AS COLOCACAO
    FROM QUANT_VENDIDA
)
SELECT R.COLOCACAO, P.NOME, R.QUANT_TOTAL
FROM RANKING R
JOIN TB_PRODUTO P ON R.ID_PRODUTO=P.ID_PRODUTO
WHERE R.COLOCACAO<=3
ORDER BY R.COLOCACAO