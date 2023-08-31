SET SERVEROUTPUT ON

DECLARE -- declaração de variáveis
    v_id NUMBER(5) := 1;
BEGIN -- início do bloco
    v_id := 2;
    dbms_output.put_line(v_id); -- imprime a variável v-id na tela
END;
-- final do bloco.

-- ---------------------------------------------------------------------------

-- Insert
DECLARE
    v_id NUMBER(5) := 1;
    v_descricao VARCHAR2(100) := 'varejo';
BEGIN
    INSERT INTO segmercado (id, descricao)
        VALUES (v_id, v_descricao);
    COMMIT;
END;

-- ---------------------------------------------------------------------------
-- seguindo as melhores práticas
DECLARE
    v_id segmercado.id%type := 2;
    v_descricao segmercado.descricao%type := 'atacado';
BEGIN
    INSERT INTO segmercado (id, descricao)
        VALUES (v_id, upper(v_descricao));
    COMMIT;
END;
-- ---------------------------------------------------------------------------
-- Comando Update
DECLARE
    v_id segmercado.id%type := 1;
    v_descricao segmercado.descricao%type := 'varejista';
BEGIN
    UPDATE segmercado SET descricao = upper(v_descricao)
        WHERE id = v_id;
        
    v_id := 2;
    v_descricao:= 'atacadista';
        
    UPDATE segmercado SET descricao = upper(v_descricao)
        WHERE id = v_id;
    
    COMMIT;
END;
-- ---------------------------------------------------------------------------
-- Apagando registros
DECLARE
    v_id segmercado.id%type := 2;    
BEGIN
    DELETE FROM segmercado WHERE id = v_id;
    COMMIT;
END;
-- ---------------------------------------------------------------------------

-- criando uma procedure
CREATE PROCEDURE incluir_segmento 
    (p_id in segmercado.id%type,
     p_descricao in segmercado.descricao%type)
IS
BEGIN
    INSERT INTO segmercado (id, descricao) 
        VALUES (p_id, upper(p_descricao));
    COMMIT;
END;

-- testando a procedure
EXECUTE incluir_segmento(3, 'Farmeceutico');
-- -----------------------
BEGIN
    incluir_segmento(4, 'Industrial');
END;

-- ---------------------------------------------------------------------------
-- função
CREATE OR REPLACE FUNCTION obter_descricao_segmercado
    (p_id IN segmercado.id%type)
    RETURN segmercado.descricao%type
IS  
    v_descricao segmercado.descricao%type;
BEGIN
    SELECT descricao INTO v_descricao
        FROM segmercado WHERE id = p_id;
    
    RETURN v_descricao;
END;

-- Teste
VARIABLE g_descricao varchar2(100)
EXECUTE :g_descricao := obter_descricao_segmercado(1)
PRINT g_descricao

-- teste 2
SET SERVEROUTPUT ON
DECLARE
    v_descricao segmercado.descricao%type;
BEGIN
    v_descricao := obter_descricao_segmercado(1);
    dbms_output.put_line('Descrição: ' || v_descricao || ' XALABILONGO');
END;
-- --------------------------------------------------------------------------
-- condicional

CREATE OR REPLACE PROCEDURE INCLUIR_CLIENTE
    (p_id cliente.id%type,
     p_razao_social cliente.razao_social%type,
     p_CNPJ cliente.cnpj%type,
     p_segmercado_id cliente.segmercado_id%type,
     p_faturamento_previsto cliente.faturamento_previsto%type)
IS
    v_categoria cliente.categoria%type;
BEGIN    
    -- Defininco categoria com base no faturamento, usando o condicional.
    IF p_faturamento_previsto < 10000 THEN
        v_categoria := 'PEQUENO';
    ELSIF p_faturamento_previsto < 50000 THEN
        v_categoria := 'MÉDIO';
    ELSIF p_faturamento_previsto < 100000 THEN
        v_categoria := 'MÉDIO GRANDE';
    ELSE
        v_categoria := 'GRANDE';
    END IF;    
    
    INSERT INTO cliente (id, razao_social, CNPJ, segmercado_id, data_inclusao,
                         faturamento_previsto, categoria)
        VALUES (p_id, UPPER(p_razao_social), p_CNPJ, p_segmercado_id, SYSDATE,
                p_faturamento_previsto, v_categoria);
    COMMIT;
END;

-- testando 
EXECUTE INCLUIR_CLIENTE(1, 'SUPERMERCADO XYZ', '1234567890ABCD', NULL, 150000);

-- criando uma função para a cliassificação de categoria
CREATE OR REPLACE FUNCTION categoria_cliente
    (p_faturamento IN cliente.faturamento_previsto%type)
    RETURN cliente.categoria%type
IS
BEGIN
    IF p_faturamento < 10000 THEN
        RETURN 'PEQUENO';
    ELSIF p_faturamento < 50000 THEN
       RETURN 'MÉDIO';
    ELSIF p_faturamento < 100000 THEN
       RETURN 'MÉDIO GRANDE';
    ELSE
        RETURN 'GRANDE';
    END IF;   
END;

-- testando a função
VARIABLE teste_func varchar2(100)
EXECUTE :teste_func := categoria_cliente(100000) -- lembrar dos dois pontos
PRINT teste_func

-- aplicando a função dentro da procedure
CREATE OR REPLACE PROCEDURE INCLUIR_CLIENTE
    (p_id cliente.id%type,
     p_razao_social cliente.razao_social%type,
     p_CNPJ cliente.cnpj%type,
     p_segmercado_id cliente.segmercado_id%type,
     p_faturamento_previsto cliente.faturamento_previsto%type)
IS
BEGIN    
    -- Defininco categoria com base no faturamento, usando o condicional.
       
    INSERT INTO cliente (id, razao_social, CNPJ, segmercado_id, data_inclusao,
                         faturamento_previsto, categoria)
        VALUES (p_id, UPPER(p_razao_social), p_CNPJ, p_segmercado_id, SYSDATE,
                p_faturamento_previsto, 
                categoria_cliente(p_faturamento_previsto));
    COMMIT;
END;

-- testando procedure atualizada
EXECUTE INCLUIR_CLIENTE(2, 'casa do xapéu', '0987654321ABCD', NULL, 51000);

-- --------------------------------------------------------------------------
-- Usando IN OUT
CREATE OR REPLACE PROCEDURE FORMAT_CNPJ
    (p_cnpj IN OUT cliente.CNPJ%type)
-- Usa se IN OUT quando queremos retornar o valor da procedure na mesma
-- variável de entrada.
IS
BEGIN
    p_cnpj := substr(p_cnpj,1,2) || '/' || substr(p_cnpj,3);
END;

-- testando a procedure
VARIABLE g_cnpj varchar2(10)
EXECUTE :g_cnpj := '12345'
PRINT g_cnpj
EXECUTE FORMAT_CNPJ(:g_cnpj) -- usa-se o : no parâmetro!!!!
PRINT g_cnpj
-- --------------------------------------------------------------------------
-- Estruturas de repetição
-- Criando uma Procedure para atualizar o segmento de mercado.
CREATE OR REPLACE PROCEDURE atualizar_cli_seg_mercado
    (p_id cliente.id%type,
     p_segmercado_id IN cliente.segmercado_id%type)
IS
BEGIN
    UPDATE cliente
        SET segmercado_id = p_segmercado_id
        WHERE id = p_id;
    COMMIT;
END;

-- Loop Básico 
DECLARE 
    v_segmercado_id segmercado.id%type := 1;
    v_i number(3);
BEGIN
    v_i := 1;
    
    LOOP
        atualizar_cli_seg_mercado(v_i, v_segmercado_id);
        v_i := v_i + 1;
        EXIT WHEN v_i > 3;
    END LOOP;
END;

-- Loop For
DECLARE
    v_segmercado_id segmercado.id%type := 2;
BEGIN
    FOR i IN 1..3 LOOP
        atualizar_cli_seg_mercado (i, v_segmercado_id);
    END LOOP;
    COMMIT;
END;

-- Cursores

DECLARE 
    v_id cliente.id%type;
    v_segmercado_id segmercado.id%type :=3;
    -- declaração do cursor pegando a coluna ID da tabela CLIENTE.
    CURSOR cur_cliente IS
        SELECT id FROM cliente;
BEGIN
    -- Antes de cada operação com o cursos, ele deve ser aberto com o comando
    -- OPEN.
    OPEN cur_cliente;
    LOOP
        FETCH cur_cliente INTO v_id;
        -- FETCH: A cada iteração lê uma linha nova do cursor.
        EXIT WHEN cur_cliente%NOTFOUND;
        -- Testa se o cursor chegou ao fim, caso o atributo do cursor
        -- seja diferente de NOTFOUND, ele continuará iterando.
        ATUALIZAR_CLI_SEG_MERCADO(v_id, v_segmercado_id);
    END LOOP;
    -- Quando as operações com o cursor forem concluídas, devemos finalizar o
    -- cursor usando o comando CLOSE.
    CLOSE cur_cliente;
    COMMIT;
END;

-- Refatorando o comando acima de forma mais sucinta.
DECLARE
    v_segmercado_id segmercado.id%type := 4;
    CURSOR cur_clien IS
        SELECT id FROM cliente;
BEGIN
    -- Abrindo o open, fetch, close e a verificação do conteúdo implicitamente com o for.
    FOR cur_rec IN cur_clien LOOP
        atualizar_cli_seg_mercado(cur_rec.id, v_segmercado_id);
    END LOOP;
    COMMIT;
END;

-- --------------------------------------------------------------------------
-- Tratamento de Erros
