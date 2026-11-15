/*Exercício 1 (Seletividade e Leading Column)
Enunciado: Execute a consulta abaixo no Oracle APEX e inspecione o plano de execução gerado via botão Explain Plan:
    SELECT nome, salario
    FROM tb_funcionarios
    WHERE cargo = 'ANALISTA';
Pergunta: Explique detalhadamente por que o índice composto idx_func_dep_cargo_sal (criado na Etapa 5) não gerou um 
INDEX RANGE SCAN direto e eficiente nesta instrução, e como a regra da Leading Column (coluna líder) fundamenta esse 
comportamento do otimizador Oracle.*/
/*RESPOSTA: O índice idx_func_dep_cargo_sal foi criado na ordem departamento, depois cargo e, por fim, salario. Como 
a consulta filtra apenas por cargo, ela não usa a primeira coluna do índice (departamento). Pela regra da Leading Column, 
o Oracle precisa considerar a primeira coluna para realizar uma busca eficiente pelo índice, por isso pode optar por 
TABLE ACCESS FULL em vez de INDEX RANGE SCAN.*/


/*Exercício 2 (Indexação Temporal)
Enunciado: Suponha uma demanda em que o relatório de auditoria fiscal realiza consultas frequentes buscando funcionários 
admitidos em um determinado ano, utilizando a sintaxe:
    SELECT * 
    FROM tb_funcionarios 
    WHERE EXTRACT(YEAR FROM data_admissao) = 2022;
Tarefa: Escreva a instrução SQL completa DDL para criar um Function-Based Index apropriado para essa consulta e apresente 
a sintaxe SQL de validação utilizando o Dicionário de Dados do Oracle (USER_INDEXES).*/
CREATE INDEX IDX_FUNC_ANO_ADMISSAO ON TB_FUNCIONARIOS(EXTRACT(YEAR FROM DATA_ADMISSAO));
SELECT INDEX_NAME, INDEX_TYPE, STATUS FROM USER_INDEXES WHERE INDEX_NAME='IDX_FUNC_ANO_ADMISSAO';


/*Exercício 3 (Análise Crítica de Trade-offs)
Enunciado: Um desenvolvedor júnior propôs a criação de índices individuais para todas as colunas da tabela tb_funcionarios 
com o objetivo de "garantir que nenhuma consulta do sistema fique lenta".

Tarefa: Elabore uma justificativa técnica (mínimo de 2 parágrafos) desconstruindo essa abordagem para a equipe de arquitetura. 
Aborde os impactos físicos e de infraestrutura nos seguintes tópicos:
    1- Desempenho e overhead em operações transacionais de escrita (INSERT, UPDATE, DELETE).
    2- Consumo de espaço em disco e comportamento do Buffer Cache em memória.
    3- Decisões do Otimizador Baseado em Custo (CBO - Cost-Based Optimizer).*/
/*RESPOSTA: A criação de índices para todas as colunas não garante melhor desempenho já que cada índice adicional gera overhead nas 
operações INSERT, UPDATE e DELETE, pois precisa ser atualizado junto com os dados da tabela. Isso aumenta o tempo das transações
e o volume de operações de leitura e escrita. 
Além disso, os índices ocupam espaço em disco e utilizam o Buffer Cache em memória, podendo consumir recursos que seriam utilizados 
por outras operações. O CBO também não utiliza obrigatoriamente todos os índices disponíveis, optando pelo plano de execução que 
considera mais eficiente. Portanto, os índices devem ser criados conforme as consultas e necessidades reais do sistema.*/