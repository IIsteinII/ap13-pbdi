-- 1.2 Crie uma tabela apropriada para o armazenamento dos itens. 
--Não se preocupe com a normalização. Uma tabela basta.

CREATE TABLE tb_students(
	cod_students SERIAL PRIMARY KEY,
	age INT,
	gender INT,
	salary INT,
	prep_exam INT,
	notes INT,
	grade INT
);

SELECT * FROM tb_students
LIMIT 200;

-- 1.4.1 Exibe o número de estudantes maiores de idade.

CREATE OR REPLACE PROCEDURE sp_maior_idade(OUT resultado INT)
LANGUAGE plpgsql
AS $$ 
BEGIN
    SELECT COUNT(age) FROM tb_students
    WHERE age >= 1
    INTO resultado;
END;
$$

DO $$
DECLARE 
    resultado INT;
BEGIN
    CALL sp_maior_idade(resultado);
    RAISE NOTICE 'Total de pessoas maiores de idade: %', resultado;
END;
$$

-- 1.4.2 Exibe o percentual de estudantes de cada sexo.

CREATE OR REPLACE PROCEDURE sp_percentual_sexo(OUT resultado_F NUMERIC(10,2), OUT resultado_M NUMERIC(10,2))
LANGUAGE plpgsql
AS $$ 
BEGIN
    SELECT (COUNT(gender) * 100.0) / (SELECT COUNT(gender) FROM tb_students) AS porcentagem_F
    FROM tb_students 
    WHERE gender = 1
    INTO resultado_F;

    SELECT (COUNT(gender) * 100.0) / (SELECT COUNT(gender) FROM tb_students) AS percentagem_M
    FROM tb_students 
    WHERE gender = 2
    INTO resultado_M;

END;
$$

DO $$
DECLARE 
    resultado_F NUMERIC(10,2);
    resultado_M NUMERIC(10,2);
BEGIN
    CALL sp_percentual_sexo(resultado_F, resultado_M);
    RAISE NOTICE 'Total percentual de pessoas do sexo feminino: %, e do sexo masculino: %', 
    resultado_F, resultado_M;
END;
$$