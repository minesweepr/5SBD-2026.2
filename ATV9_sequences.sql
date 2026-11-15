/*Exercício 1: Sequence com Reinício (CYCLE)
Crie uma sequência chamada seq_ticket_diario com START WITH 1, INCREMENT BY 1, MINVALUE 1, MAXVALUE 5, CYCLE e CACHE 2. 
Execute chamadas sucessivas a NEXTVAL e documente o comportamento do sistema ao ultrapassar o valor 5.*/
CREATE SEQUENCE SEQ_TICKET_DIARIO
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 5
    CYCLE
    CACHE 2;

SELECT seq_ticket_diario.NEXTVAL FROM DUAL;
/*RESPOSTA: ao atingir o valor máximo 5, a sequência reinicia automaticamente por causa da opção CYCLE e os valores
começam a se repetir*/


/*Exercício 2: Migração Trigger vs DEFAULT
Escreva um código demonstrando a atribuição clássica de uma sequência via Trigger BEFORE INSERT (padrão pré-Oracle 12c) e 
compare-o com a sintaxe moderna DEFAULT seq.NEXTVAL. Destaque as melhorias em termos de legibilidade, manutenção e 
performance de execução.*/
/*migraçao trigger*/
CREATE SEQUENCE SEQ_FUNCIONARIO_ID START WITH 1 INCREMENT BY 1;

CREATE TABLE TB_FUNCIONARIOS_TRIGGER(
    ID_FUNCIONARIO NUMBER PRIMARY KEY, 
    NOME VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER TRG_FUNCIONARIO_ID 
BEFORE INSERT ON TB_FUNCIONARIOS_TRIGGER
FOR EACH ROW
BEGIN
    IF :NEW.ID_FUNCIONARIO IS NULL THEN
        :NEW.ID_FUNCIONARIO:=SEQ_FUNCIONARIO_ID.NEXTVAL;
    END IF;
END;

/*default*/
CREATE SEQUENCE SEQ_FUNCIONARIO_DEFAULT START WITH 1 INCREMENT BY 1;

CREATE TABLE SEQ_FUNCIONARIOS_DEFAULT(
    ID_FUNCIONARIO NUMBER DEFAULT SEQ_FUNCIONARIO_DEFAULT.NEXTVAL PRIMARY KEY, 
    NOME VARCHAR2(100)
);
/*RESPOSTA: Em comparação à migração trigger, o default é melhor na simplificação da estrutura (legibilidade), redução da 
quantidade de objetos e códigos a serem administrados (manutenção) e reduz a necessidade de processamento adiciona ao
evitar a execução de um trigger para cada inserção.*/


/*Exercício 3: Análise de Concorrência e CACHE
Explique os impactos arquiteturais da opção NOCACHE em um sistema de alta concorrência (OLTP), abordando a contenção na 
área de memória compartilhada (row cache lock na SGA) e os gargalos de I/O na atualização do dicionário de dados.*/
/*RESPOSTA: Na contenção na SGA com NOCACHE, os valores não são pré-alocados em memória. Em sistemas com muitas sessões 
simultâneas, isso aumenta a necessidade de acessar e atualizar informações da sequência, podendo gerar contenção de row cache lock.
Já nos gargalos de I/O, a ausência de cache aumenta as operações de atualização do dicionário de dados, gerando mais acessos de 
leitura e escrita. Isso pode aumentar a latência e reduzir o desempenho em sistemas OLTP com alto volume de transações.