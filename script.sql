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