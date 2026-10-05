-- Parte 1: Testando a Resiliência (O Princípio de "Falhar Cedo")
--- **Questão 1: Violação de Chave Estrangeira (FK)**
------Escreva uma instrução de inserção (`INSERT`) que tente registrar uma venda amarrada a um ID de cliente inexistente (ex: `9999`).
------Execute o comando e analise qual constraint impediu o registro e qual regra comercial ela garante.
INSERT INTO TB_VENDA (ID_VENDA,ID_CLIENTE,ID_VENDEDOR,STATUS,CANAL)
VALUES (200, 9999, 5, 'ABERTA', 'SITE')
/*
ERRO: ORA-02291: integrity constraint (WKSP_GABS5SBD.FK_TB_VENDA_CLIENTE) violated - parent key not found
ANÁLISE: A CONSTRAINT DA FK IMPEDE A INSERÇÃO PORQUE O ID DO CLIENTE NÃO EXISTE NA TABELA TB_CLIENTE
         ISSO GARANTE A INTEGRIDADE REFERENCIAL E EVITA VENDAS SEM CLIENTE CADASTRADO.
*/

--- **Questão 2: Violação de Domínio (CHECK Constraint)**
------Escreva um comando de atualização (`UPDATE`) que tente alterar o status de uma venda para o valor inválido `'PENDENTE'`.
------Analise qual erro o banco retorna e por que essa validação deve residir no banco de dados e não apenas no aplicativo.
UPDATE TB_VENDA
SET STATUS='PENDENTE'
WHERE ID_VENDA=1
/*
ERRO: ORA-02290: check constraint (WKSP_GABS5SBD.CK_TB_VENDA_STATUS) violated
ANÁLISE: A CONSTRAINT DE CHECK DO TATUS IMPEDE O VALOR INVÁLIDO, POIS ESPECIFICA TRÊS TIPOS DE STATUS (ABERTA, FECHADA OU CANCELADA)
         ESSA VALIDAÇÃO GARANTE A INTEGRIDADE DOS DADOS MESMO SE TENTAREM INSERIR UM VALOR INVALIDO, PROPOSITALMENTE OU NÃO.
*/

--- **Questão 3: Impedindo Preços Absurdos**
------Escreva uma instrução para inserir um novo produto na tabela `tb_produto` informando um preço unitário negativo (ex: `-15.00`).
------Teste e identifique qual constraint do modelo físico foi acionada para blindar o sistema.
INSERT INTO TB_PRODUTO (ID_PRODUTO,ID_CATEGORIA,SKU,NOME,PRECO_UNIT)
VALUES (230, 3, 'PROD-MOUSE-01', 'MOUSE', -15.00)
/*
ERRO: ORA-02290: check constraint (WKSP_GABS5SBD.CK_TB_PRODUTO_PRECO) violated
ANÁLISE: A CONSTRAINT DE CHECK DO PREÇO IMPEDE A INSERÇÃO POR NÃO PERMITIR PREÇO UNITÁRIO NEGATIVO, EVITANDO
         ERROS DE CADASTRO E VALORES INVÁLIDOS.
*/

-- Parte 2: Evoluindo a Modelagem Física (DDL)
--- **Questão 4: Limite de Desconto de Itens (CHECK)**
------Escreva um comando DDL (`ALTER TABLE`) para adicionar uma nova constraint `CHECK` na tabela `tb_venda_item` que garanta,
------no nível do banco de dados, que nenhum desconto unitário (`desconto_item`) concedido em uma venda possa ultrapassar 50%
------do preço unitário cadastrado para o respectivo produto.
ALTER TABLE TB_VENDA_ITEM
ADD CONSTRAINT CHECK_DESCONTO_ITEM CHECK (DESCONTO_ITEM<=(PRECO_UNIT*0.5)) NOVALIDATE

--- **Questão 5: Garantia de Unicidade de Contato (UNIQUE)**
------Escreva um comando DDL para adicionar uma restrição de unicidade (`UNIQUE`) na coluna `telefone` da tabela `tb_cliente`,
------impedindo que dois clientes distintos compartilhem acidentalmente o mesmo canal de contato no CRM.
ALTER TABLE TB_CLIENTE
ADD UNIQUE(TELEFONE)


-- Parte 3: Comportamento de Exclusão (CASCADE vs. Soft Delete)
--- **Questão 6: Exclusão em Cascata (ON DELETE CASCADE)**
------Delete um registro de venda pai (`tb_venda`) que possua registros filhos em `tb_venda_item`. Analise o comportamento automático
------do banco de dados ao limpar os registros associados e discuta o perigo do uso indiscriminado dessa cláusula.
DELETE FROM TB_VENDA
WHERE ID_VENDA=(SELECT ID_VENDA FROM TB_VENDA_ITEM FETCH FIRST 1 ROWS ONLY)
/*
ANÁLISE: JÁ QUE A FK DA TB_VENDA_ITEM TEM ON DELETE CASCADE, AO EXCLUIR A VENDA, TODOS OS ITENS ASSOCIADOS SERÃO EXCLUIDOS AUTOMATICAMENTE.
         O USO INDISCRIMINADO DESSA CLÁUSULA PODE CAUSAR A EXCLUSÃO DE DIVERSOS REGISTROS.
*/

--- **Questão 7: Exclusão Lógica (Soft Delete)**
------Escreva um comando SQL para desativar logicamente um vendedor que se desligou da empresa (atualizando a coluna `ativo` para `'N'`).
------Justifique por que essa técnica de exclusão lógica é preferível em relação à remoção física (`DELETE`) em bancos corporativos com
------histórico de faturamento.
UPDATE TB_VENDEDOR
SET ATIVO='N'
WHERE ID_VENDEDOR=1
/*
JUSTIFICATIVA: PARA PRESERVAR O HISTÓRICO DE VENDAS, ALÉM DE SEUS RESPECTIVOS VENDEDORES.
*/