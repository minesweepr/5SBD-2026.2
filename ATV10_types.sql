/*1. Exercício 1 (Métodos Construtores Personalizados)
Crie um tipo de objeto chamado `t_retangulo` com os atributos `largura` (NUMBER) e `altura` (NUMBER). 
Adicione duas funções ao tipo: `MEMBER FUNCTION calcular_area RETURN NUMBER` e `MEMBER FUNCTION 
calcular_perimetro RETURN NUMBER`. Escreva a especificação, o corpo (`BODY`) e execute um bloco anônimo 
PL/SQL ou comando `SELECT` para testar a instanciação e o cálculo das funções.*/
CREATE OR REPLACE TYPE T_RETANGULO AS OBJECT(
    LARGURA NUMBER,
    ALTURA NUMBER,
    MEMBER FUNCTION CALCULAR_AREA RETURN NUMBER,
    MEMBER FUNCTION CALCULAR_PERIMETRO RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY T_RETANGULO AS
    MEMBER FUNCTION CALCULAR_AREA RETURN NUMBER IS
    BEGIN
        RETURN LARGURA*ALTURA;
    END;

    MEMBER FUNCTION CALCULAR_PERIMETRO RETURN NUMBER IS
    BEGIN
        RETURN (LARGURA*2)+(ALTURA* 2);
    END;
END;

SELECT T_RETANGULO(5, 10).CALCULAR_AREA() AREA, T_RETANGULO(5, 10).CALCULAR_PERIMETRO() PERIMETRO
FROM DUAL;

/*2. Exercício 2 (Método MAP para Ordenação)  
Modifique a especificação e o corpo do tipo `t_retangulo` criado no Exercício 1 para incluir um método 
`MAP MEMBER FUNCTION ordenar RETURN NUMBER`. A função deve retornar a área total do retângulo. Teste a 
ordenação criando uma tabela simples de retângulos e executando uma consulta com a cláusula `ORDER BY` 
diretamente sobre a coluna do tipo objeto.*/
CREATE OR REPLACE TYPE T_RETANGULO AS OBJECT(
    LARGURA NUMBER,
    ALTURA NUMBER,
    MEMBER FUNCTION CALCULAR_AREA RETURN NUMBER,
    MEMBER FUNCTION CALCULAR_PERIMETRO RETURN NUMBER,
    MAP MEMBER FUNCTION ORDENAR RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY T_RETANGULO AS
    MEMBER FUNCTION CALCULAR_AREA RETURN NUMBER IS
    BEGIN
        RETURN LARGURA*ALTURA;
    END;

    MEMBER FUNCTION CALCULAR_PERIMETRO RETURN NUMBER IS
    BEGIN
        RETURN (LARGURA*2)+(ALTURA* 2);
    END;

    MAP MEMBER FUNCTION ORDENAR RETURN NUMBER IS
    BEGIN
        RETURN LARGURA*ALTURA;
    END;
END;

CREATE TABLE TB_RETANGULOS (
    ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RETANGULO T_RETANGULO
);

INSERT INTO TB_RETANGULOS(RETANGULO) VALUES(T_RETANGULO(5, 10));
INSERT INTO TB_RETANGULOS(RETANGULO) VALUES(T_RETANGULO(2, 2));
INSERT INTO TB_RETANGULOS(RETANGULO) VALUES(T_RETANGULO(6, 9));

SELECT ID, T.RETANGULO.LARGURA LARGURA, T.RETANGULO.ALTURA ALTURA, T.RETANGULO.CALCULAR_AREA() AREA
FROM TB_RETANGULOS T
ORDER BY T.RETANGULO;

/*3. Exercício 3 (Análise Crítica de Engenharia)
Considere o cenário de modelagem de dados para um sistema corporativo. Elabore um texto comparativo analisando 
o uso de `Nested Tables` como colunas versus a modelagem relacional tradicional (duas tabelas distintas vinculadas 
por Foreign Key de 1:N). Enderece em sua resposta:
   * Flexibilidade de consulta SQL.
   * Manutenção de integridade referencial.
   * Suporte por ferramentas de integração/ORM.
   * Performance em cargas massivas (ETL).*/
/*RESPOSTA: As Nested Tables permitem armazenar coleções diretamente em uma tabela, que facilita a representação de 
estruturas complexas, mas podem gerar maior complexidade e overhead de armazenamento. Enquanto isso, a modelagem relacional 
tradicional oferece consultas mais flexíveis, melhor controle de integridade referencial, maior compatibilidade com ferramentas 
ORM e maior facilidade de processamento em cargas massivas de ETL. Por isso o modelo relacional é geralmente mais adequado 
para sistemas corporativos.*/