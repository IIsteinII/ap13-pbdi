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