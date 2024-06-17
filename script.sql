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

-- 1.4.3 Recebe um sexo como parâmetro em modo IN e utiliza oito parâmetros em modo OUT
-- para dizer qual o percentual de cada nota (variável grade) obtida por estudantes daquele sexo.

CREATE OR REPLACE PROCEDURE sp_calcula_grade_percent(
    IN input_gender INT,
    OUT percent_grade_0 NUMERIC,
    OUT percent_grade_1 NUMERIC,
    OUT percent_grade_2 NUMERIC,
    OUT percent_grade_3 NUMERIC,
    OUT percent_grade_4 NUMERIC,
    OUT percent_grade_5 NUMERIC,
    OUT percent_grade_6 NUMERIC,
    OUT percent_grade_7 NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_students INT;
BEGIN
    percent_grade_0 := 0;
    percent_grade_1 := 0;
    percent_grade_2 := 0;
    percent_grade_3 := 0;
    percent_grade_4 := 0;
    percent_grade_5 := 0;
    percent_grade_6 := 0;
    percent_grade_7 := 0;
    SELECT COUNT(*) INTO total_students FROM tb_students WHERE gender = input_gender;
    IF total_students = 0 THEN
        RETURN;
    END IF;
    SELECT
        (COUNT(*) FILTER (WHERE grade = 0)::NUMERIC / total_students) * 100,
        (COUNT(*) FILTER (WHERE grade = 1)::NUMERIC / total_students) * 100,
        (COUNT(*) FILTER (WHERE grade = 2)::NUMERIC / total_students) * 100,
        (COUNT(*) FILTER (WHERE grade = 3)::NUMERIC / total_students) * 100,
        (COUNT(*) FILTER (WHERE grade = 4)::NUMERIC / total_students) * 100,
        (COUNT(*) FILTER (WHERE grade = 5)::NUMERIC / total_students) * 100,
        (COUNT(*) FILTER (WHERE grade = 6)::NUMERIC / total_students) * 100,
        (COUNT(*) FILTER (WHERE grade = 7)::NUMERIC / total_students) * 100
    INTO
        percent_grade_0,
        percent_grade_1,
        percent_grade_2,
        percent_grade_3,
        percent_grade_4,
        percent_grade_5,
        percent_grade_6,
        percent_grade_7
    FROM tb_students
    WHERE gender = input_gender;
END;
$$;

DO $$
DECLARE
    percent_grade_0 NUMERIC;
    percent_grade_1 NUMERIC;
    percent_grade_2 NUMERIC;
    percent_grade_3 NUMERIC;
    percent_grade_4 NUMERIC;
    percent_grade_5 NUMERIC;
    percent_grade_6 NUMERIC;
    percent_grade_7 NUMERIC;
BEGIN
    CALL sp_calcula_grade_percent(1, percent_grade_0, percent_grade_1, percent_grade_2, percent_grade_3, percent_grade_4, percent_grade_5, percent_grade_6, percent_grade_7);

    RAISE NOTICE 'Percentual de notas para o sexo 1: 0: %, 1: %, 2: %, 3: %, 4: %, 5: %, 6: %, 7: %', 
        percent_grade_0, percent_grade_1, percent_grade_2, percent_grade_3, percent_grade_4, percent_grade_5, percent_grade_6, percent_grade_7;
END;
$$;


-- 1.5 Escreva as seguintes functions (incluindo um bloco anônimo de teste para cada uma):

-- 1.5.1 Responde (devolve boolean) se é verdade que todos os estudantes de renda acima de
-- 410 são aprovados (grade > 0).

CREATE OR REPLACE FUNCTION fn_aprovados() RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    resultado BOOLEAN;
BEGIN
    SELECT EXISTS (SELECT 1 FROM tb_students WHERE salary = 5 AND grade = 0) INTO resultado;
    IF resultado THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END;
$$;

DO $$
DECLARE
    resultado BOOLEAN;
BEGIN
    resultado := fn_aprovados();
    RAISE NOTICE 'Resultado: %', resultado;
END;
$$;


-- 1.5.2 Responde (devolve boolean) se é verdade que, entre os estudantes que fazem
-- anotações pelo menos algumas vezes durante as aulas, pelo menos 70% são aprovados
-- (grade > 0).

CREATE OR REPLACE FUNCTION fn_checa_aprovados_anot() RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    total_students INT;
    aprovados_students INT;
    percent_aprovados NUMERIC;
BEGIN
    SELECT COUNT(*) INTO total_students FROM tb_students WHERE notes > 0;
    SELECT COUNT(*) INTO aprovados_students FROM tb_students WHERE notes > 0 AND grade > 0;
    IF total_students = 0 THEN
        RETURN FALSE;
    END IF;
    percent_aprovados := (aprovados_students::NUMERIC / total_students) * 100;
    IF percent_aprovados >= 70 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;

DO $$
DECLARE
    resultado BOOLEAN;
BEGIN
    resultado := fn_checa_aprovados_anot();
    RAISE NOTICE 'Resultado: %', resultado;
END;
$$;
