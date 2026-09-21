CREATE SCHEMA oficina;


-- ============================================================
-- 1. CLIENTE
-- ============================================================

CREATE TABLE oficina.cliente (
    id_cliente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(150) NOT NULL
);


-- ============================================================
-- 2. EQUIPE
-- ============================================================

CREATE TABLE oficina.equipe (
    id_equipe INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);


-- ============================================================
-- 3. VEÍCULO
-- ============================================================

CREATE TABLE oficina.veiculo (
    id_veiculo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ano INTEGER,
    id_cliente INTEGER NOT NULL,
    id_equipe INTEGER NOT NULL,

    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES oficina.cliente (id_cliente),

    CONSTRAINT fk_veiculo_equipe
        FOREIGN KEY (id_equipe)
        REFERENCES oficina.equipe (id_equipe)
);


-- ============================================================
-- 4. MECÂNICO
-- ============================================================

CREATE TABLE oficina.mecanico (
    id_mecanico INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    id_equipe INTEGER NOT NULL,

    CONSTRAINT fk_mecanico_equipe
        FOREIGN KEY (id_equipe)
        REFERENCES oficina.equipe (id_equipe)
);


-- ============================================================
-- 5. ORDEM DE SERVIÇO
-- ============================================================

CREATE TABLE oficina.ordem_servico (
    id_os INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_os INTEGER NOT NULL UNIQUE,
    id_veiculo INTEGER NOT NULL,
    id_equipe INTEGER NOT NULL,

    data_emissao DATE NOT NULL DEFAULT CURRENT_DATE,
    data_prevista_conclusao DATE,

    valor_total NUMERIC(10,2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL,

    autorizado_em TIMESTAMP,

    CONSTRAINT fk_os_veiculo
        FOREIGN KEY (id_veiculo)
        REFERENCES oficina.veiculo (id_veiculo),

    CONSTRAINT fk_os_equipe
        FOREIGN KEY (id_equipe)
        REFERENCES oficina.equipe (id_equipe),

    CONSTRAINT ck_os_valor
        CHECK (valor_total >= 0),

    CONSTRAINT ck_os_status
        CHECK (
            status IN (
                'ABERTA',
                'EM_EXECUCAO',
                'AGUARDANDO_PECAS',
                'CONCLUIDA',
                'CANCELADA'
            )
        )
);


-- ============================================================
-- 6. TABELA DE REFERÊNCIA DE SERVIÇOS / MÃO DE OBRA
-- ============================================================

CREATE TABLE oficina.servico (
    id_servico INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL,
    valor_mao_obra NUMERIC(10,2) NOT NULL,

    CONSTRAINT ck_servico_valor
        CHECK (valor_mao_obra >= 0)
);


-- ============================================================
-- 7. SERVIÇOS EXECUTADOS EM CADA OS
-- ============================================================

CREATE TABLE oficina.os_servico (
    id_os_servico INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_os INTEGER NOT NULL,
    id_servico INTEGER NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 1,
    valor_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_os_servico_os
        FOREIGN KEY (id_os)
        REFERENCES oficina.ordem_servico (id_os),

    CONSTRAINT fk_os_servico_servico
        FOREIGN KEY (id_servico)
        REFERENCES oficina.servico (id_servico),

    CONSTRAINT ck_os_servico_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT ck_os_servico_valor
        CHECK (valor_unitario >= 0)
);


-- ============================================================
-- 8. PEÇAS
-- ============================================================

CREATE TABLE oficina.peca (
    id_peca INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    descricao VARCHAR(250),
    valor_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT ck_peca_valor
        CHECK (valor_unitario >= 0)
);


-- ============================================================
-- 9. PEÇAS UTILIZADAS EM CADA OS
-- ============================================================

CREATE TABLE oficina.os_peca (
    id_os_peca INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_os INTEGER NOT NULL,
    id_peca INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,

    valor_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_os_peca_os
        FOREIGN KEY (id_os)
        REFERENCES oficina.ordem_servico (id_os),

    CONSTRAINT fk_os_peca_peca
        FOREIGN KEY (id_peca)
        REFERENCES oficina.peca (id_peca),

    CONSTRAINT ck_os_peca_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT ck_os_peca_valor
        CHECK (valor_unitario >= 0)
);
