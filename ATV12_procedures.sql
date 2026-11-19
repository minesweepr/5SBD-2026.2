/*Exercício 1 (Procedure de Reajuste Salarial)
Crie uma procedure chamada prc_reajustar_saldo_em_massa que receba como parâmetro de 
entrada o percentual de reajuste (p_percentual IN NUMBER) e retorne, em um parâmetro 
de saída (p_total_atualizado OUT NUMBER), a quantidade exata de contas com status 
'ATIVA' que sofreram reajuste.*/
CREATE OR REPLACE PROCEDURE PRC_REAJUSTAR_SALDO_EM_MASSA(P_PERCENTUAL IN  NUMBER, P_TOTAL_ATUALIZADO OUT NUMBER) IS
BEGIN
    UPDATE TB_CONTAS SET SALDO=SALDO+(SALDO*P_PERCENTUAL/100) WHERE STATUS='ATIVA';
    P_TOTAL_ATUALIZADO:=SQL%ROWCOUNT;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_TOTAL_ATUALIZADO:=0;
        RAISE;
END PRC_REAJUSTAR_SALDO_EM_MASSA;

DECLARE
    V_TOTAL NUMBER;
BEGIN
    PRC_REAJUSTAR_SALDO_EM_MASSA(10, V_TOTAL);
    DBMS_OUTPUT.PUT_LINE('contas atualizadas: '||V_TOTAL);
END;

/*Exercício 2 (Bloqueio Concorrente com FOR UPDATE)
Explique tecnicamente a importância da cláusula FOR UPDATE utilizada na consulta de 
saldo da procedure prc_transferir_fundos. O que aconteceria em um ambiente corporativo 
com dezenas de transações simultâneas se essa cláusula fosse omitida?*/
/*RESPOSTA: A cláusula FOR UPDATE bloqueia temporariamente a linha da conta durante a
transação, impedindo alterações simultâneas. Sem ela, poderiam ocorrer race conditions, 
comprometendo a consistência dos saldos das contas*/

/*Exercício 3 (Manipulação de Parâmetros IN OUT)
Escreva uma procedure denominada prc_sanitizar_texto que utilize um único parâmetro 
bidirecional p_texto IN OUT VARCHAR2. A procedure deve remover espaços em branco 
sobressalentes nas extremidades (TRIM) e converter todos os caracteres para maiúsculas (UPPER).*/
CREATE OR REPLACE PROCEDURE PRC_SANITIZAR_TEXTO(P_TEXTO IN OUT VARCHAR2) IS
BEGIN
    P_TEXTO:=UPPER(TRIM(P_TEXTO));
END PRC_SANITIZAR_TEXTO;

DECLARE
    V_TEXTO VARCHAR2(100):='exemplo';
BEGIN
    PRC_SANITIZAR_TEXTO(V_TEXTO);
    DBMS_OUTPUT.PUT_LINE('texto sanitizado: '||V_TEXTO);
END;