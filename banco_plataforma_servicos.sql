-- =====================================================================
-- Banco de dados gerado a partir do diagrama de classes
-- Compatível com MySQL 8 / MySQL Workbench
-- Herança: Profissional e Cliente apontam para Usuario (tabela por subclasse)
-- =====================================================================

DROP DATABASE IF EXISTS plataforma_servicos;
CREATE DATABASE plataforma_servicos
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE plataforma_servicos;

-- ---------------------------------------------------------------------
-- Usuario (superclasse)
-- ---------------------------------------------------------------------
CREATE TABLE Usuario (
  idUsuario     INT          NOT NULL AUTO_INCREMENT,
  nome          VARCHAR(150) NOT NULL,
  email         VARCHAR(150) NOT NULL,
  telefone      VARCHAR(20),
  senhaHash     VARCHAR(255) NOT NULL,
  cpf           CHAR(11)     NOT NULL,
  dataCadastro  DATE         NOT NULL DEFAULT (CURRENT_DATE),
  status        VARCHAR(30)  NOT NULL DEFAULT 'ativo',
  PRIMARY KEY (idUsuario),
  UNIQUE KEY uq_usuario_email (email),
  UNIQUE KEY uq_usuario_cpf (cpf)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Profissional (herda de Usuario)
-- ---------------------------------------------------------------------
CREATE TABLE Profissional (
  idProfissional      INT          NOT NULL AUTO_INCREMENT,
  idUsuario           INT          NOT NULL,
  descricaoPerfil     TEXT,
  cidadeAtuacao       VARCHAR(100),
  raioAtendimento     INT,
  statusVerificacao   VARCHAR(30)  NOT NULL DEFAULT 'pendente',
  notaMedia           DECIMAL(3,2) DEFAULT 0.00,
  PRIMARY KEY (idProfissional),
  UNIQUE KEY uq_profissional_usuario (idUsuario),
  CONSTRAINT fk_profissional_usuario
    FOREIGN KEY (idUsuario) REFERENCES Usuario (idUsuario)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Cliente (herda de Usuario)
-- ---------------------------------------------------------------------
CREATE TABLE Cliente (
  idCliente  INT          NOT NULL AUTO_INCREMENT,
  idUsuario  INT          NOT NULL,
  endereco   VARCHAR(255),
  cidade     VARCHAR(100),
  cep        CHAR(8),
  PRIMARY KEY (idCliente),
  UNIQUE KEY uq_cliente_usuario (idUsuario),
  CONSTRAINT fk_cliente_usuario
    FOREIGN KEY (idUsuario) REFERENCES Usuario (idUsuario)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Mensagem (Usuario 1 envia 0..* Mensagem)
-- ---------------------------------------------------------------------
CREATE TABLE Mensagem (
  idMensagem  INT        NOT NULL AUTO_INCREMENT,
  idUsuario   INT        NOT NULL,
  conteudo    TEXT       NOT NULL,
  dataEnvio   DATE       NOT NULL DEFAULT (CURRENT_DATE),
  lida        TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (idMensagem),
  CONSTRAINT fk_mensagem_usuario
    FOREIGN KEY (idUsuario) REFERENCES Usuario (idUsuario)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Categoria
-- ---------------------------------------------------------------------
CREATE TABLE Categoria (
  idCategoria  INT          NOT NULL AUTO_INCREMENT,
  nome         VARCHAR(100) NOT NULL,
  descricao    VARCHAR(255),
  PRIMARY KEY (idCategoria),
  UNIQUE KEY uq_categoria_nome (nome)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Especialidade
-- Profissional 1 oferece 0..* | Categoria 1 classifica 0..*
-- ---------------------------------------------------------------------
CREATE TABLE Especialidade (
  idEspecialidade  INT           NOT NULL AUTO_INCREMENT,
  idProfissional   INT           NOT NULL,
  idCategoria      INT           NOT NULL,
  descricao        VARCHAR(255),
  valorReferencia  DECIMAL(10,2),
  PRIMARY KEY (idEspecialidade),
  CONSTRAINT fk_especialidade_profissional
    FOREIGN KEY (idProfissional) REFERENCES Profissional (idProfissional)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_especialidade_categoria
    FOREIGN KEY (idCategoria) REFERENCES Categoria (idCategoria)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Verificacao (Profissional 1 submete-se 0..*)
-- ---------------------------------------------------------------------
CREATE TABLE Verificacao (
  idVerificacao  INT         NOT NULL AUTO_INCREMENT,
  idProfissional INT         NOT NULL,
  tipoDocumento  VARCHAR(50) NOT NULL,
  status         VARCHAR(30) NOT NULL DEFAULT 'pendente',
  dataAnalise    DATE,
  PRIMARY KEY (idVerificacao),
  CONSTRAINT fk_verificacao_profissional
    FOREIGN KEY (idProfissional) REFERENCES Profissional (idProfissional)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Certificacao (Profissional 1 possui 0..*)
-- ---------------------------------------------------------------------
CREATE TABLE Certificacao (
  idCertificacao  INT          NOT NULL AUTO_INCREMENT,
  idProfissional  INT          NOT NULL,
  tipo            VARCHAR(100) NOT NULL,
  numeroRegistro  VARCHAR(50),
  orgaoEmissor    VARCHAR(100),
  validade        DATE,
  status          VARCHAR(30)  NOT NULL DEFAULT 'pendente',
  PRIMARY KEY (idCertificacao),
  CONSTRAINT fk_certificacao_profissional
    FOREIGN KEY (idProfissional) REFERENCES Profissional (idProfissional)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Pedido (Cliente 1 realiza 0..* | Categoria 1 classifica 0..*)
-- ---------------------------------------------------------------------
CREATE TABLE Pedido (
  idPedido         INT          NOT NULL AUTO_INCREMENT,
  idCliente        INT          NOT NULL,
  idCategoria      INT          NOT NULL,
  descricao        TEXT         NOT NULL,
  cep              CHAR(8),
  cidade           VARCHAR(100),
  periodo          VARCHAR(50),
  frequencia       VARCHAR(50),
  dataSolicitacao  DATE         NOT NULL DEFAULT (CURRENT_DATE),
  status           VARCHAR(30)  NOT NULL DEFAULT 'aberto',
  PRIMARY KEY (idPedido),
  CONSTRAINT fk_pedido_cliente
    FOREIGN KEY (idCliente) REFERENCES Cliente (idCliente)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pedido_categoria
    FOREIGN KEY (idCategoria) REFERENCES Categoria (idCategoria)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Oportunidade (Pedido 1 gera 0..* | Profissional 1 recebe 0..*)
-- ---------------------------------------------------------------------
CREATE TABLE Oportunidade (
  idOportunidade         INT         NOT NULL AUTO_INCREMENT,
  idPedido               INT         NOT NULL,
  idProfissional         INT         NOT NULL,
  dataDisponibilizacao   DATE        NOT NULL DEFAULT (CURRENT_DATE),
  status                 VARCHAR(30) NOT NULL DEFAULT 'disponivel',
  PRIMARY KEY (idOportunidade),
  CONSTRAINT fk_oportunidade_pedido
    FOREIGN KEY (idPedido) REFERENCES Pedido (idPedido)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_oportunidade_profissional
    FOREIGN KEY (idProfissional) REFERENCES Profissional (idProfissional)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- CompraOportunidade (Oportunidade 1 -> 0..1)
-- ---------------------------------------------------------------------
CREATE TABLE CompraOportunidade (
  idCompra        INT           NOT NULL AUTO_INCREMENT,
  idOportunidade  INT           NOT NULL,
  valor           DECIMAL(10,2) NOT NULL,
  meioPagamento   VARCHAR(30)   NOT NULL,
  dataCompra      DATE          NOT NULL DEFAULT (CURRENT_DATE),
  status          VARCHAR(30)   NOT NULL DEFAULT 'pendente',
  PRIMARY KEY (idCompra),
  UNIQUE KEY uq_compra_oportunidade (idOportunidade),
  CONSTRAINT fk_compra_oportunidade
    FOREIGN KEY (idOportunidade) REFERENCES Oportunidade (idOportunidade)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Contratacao (Pedido 1 -> 0..1 | Profissional 1 executa 0..*)
-- ---------------------------------------------------------------------
CREATE TABLE Contratacao (
  idContratacao   INT           NOT NULL AUTO_INCREMENT,
  idPedido        INT           NOT NULL,
  idProfissional  INT           NOT NULL,
  dataInicio      DATE          NOT NULL,
  horario         TIME,
  recorrencia     VARCHAR(50),
  valorAcordado   DECIMAL(10,2) NOT NULL,
  status          VARCHAR(30)   NOT NULL DEFAULT 'pendente',
  PRIMARY KEY (idContratacao),
  UNIQUE KEY uq_contratacao_pedido (idPedido),
  CONSTRAINT fk_contratacao_pedido
    FOREIGN KEY (idPedido) REFERENCES Pedido (idPedido)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_contratacao_profissional
    FOREIGN KEY (idProfissional) REFERENCES Profissional (idProfissional)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Avaliacao (Contratacao 1 origina 0..1)
-- ---------------------------------------------------------------------
CREATE TABLE Avaliacao (
  idAvaliacao    INT     NOT NULL AUTO_INCREMENT,
  idContratacao  INT     NOT NULL,
  nota           TINYINT NOT NULL,
  comentario     TEXT,
  dataAvaliacao  DATE    NOT NULL DEFAULT (CURRENT_DATE),
  PRIMARY KEY (idAvaliacao),
  UNIQUE KEY uq_avaliacao_contratacao (idContratacao),
  CONSTRAINT chk_avaliacao_nota CHECK (nota BETWEEN 1 AND 5),
  CONSTRAINT fk_avaliacao_contratacao
    FOREIGN KEY (idContratacao) REFERENCES Contratacao (idContratacao)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
