CREATE TABLE segmercado (id NUMBER(5) PRIMARY KEY,
    descricao VARCHAR2(100));
    

CREATE TABLE cliente (
    id NUMBER(5) PRIMARY KEY,
    razao_social VARCHAR2(100) NOT NULL,
    segmercado_id NUMBER(5) REFERENCES segmercado (id),
    data_inclusao DATE NOT NULL,
    faturamento_previsto NUMBER(10,2),
    categoria VARCHAR2(20));
    
    
ALTER TABLE cliente 
    ADD CONSTRAINT cliente_segmercado_fk
    FOREIGN KEY (segmercado_id)
    REFERENCES segmercado(id)
    
