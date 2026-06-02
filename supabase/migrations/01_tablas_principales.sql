-- ============================================================
-- FASE 1-A: Tablas de identidad y clientes
-- Proyecto: App Fuerza de Ventas — Caja Cusco
-- Pegar en: Supabase Dashboard → SQL Editor → New query
-- ============================================================

-- Habilitar extensión para UUIDs (ya activa por defecto en Supabase)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ──────────────────────────────────────────────────────────────
-- 1. AGENCIAS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS agencias (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre      VARCHAR(100) NOT NULL,
  region      VARCHAR(50),
  lat         DECIMAL(10,7),
  lng         DECIMAL(10,7),
  activa      BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ──────────────────────────────────────────────────────────────
-- 2. ASESORES DE NEGOCIO
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS asesores_negocio (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  codigo_empleado  VARCHAR(10) NOT NULL UNIQUE,
  nombres          VARCHAR(100) NOT NULL,
  apellidos        VARCHAR(100) NOT NULL,
  agencia_id       UUID NOT NULL REFERENCES agencias(id),
  perfil           VARCHAR(20) NOT NULL DEFAULT 'operador'
                   CHECK (perfil IN ('operador','super_operador','supervisor','administrador')),
  token_fcm        TEXT,
  activo           BOOLEAN NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_asesores_user_id ON asesores_negocio(user_id);
CREATE INDEX IF NOT EXISTS idx_asesores_agencia ON asesores_negocio(agencia_id);


-- ──────────────────────────────────────────────────────────────
-- 3. CLIENTES
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clientes (
  id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_documento          VARCHAR(15) NOT NULL UNIQUE,
  tipo_documento            VARCHAR(5)  NOT NULL DEFAULT 'DNI'
                            CHECK (tipo_documento IN ('DNI','RUC','CE')),
  nombres                   VARCHAR(100) NOT NULL,
  apellidos                 VARCHAR(100) NOT NULL,
  fecha_nacimiento          DATE,
  estado_civil              VARCHAR(15)
                            CHECK (estado_civil IN ('Soltero','Casado','Conviviente','Divorciado','Viudo')),
  telefono                  VARCHAR(15),
  email                     VARCHAR(100),
  direccion                 TEXT,
  tipo_negocio              VARCHAR(30),
  nombre_negocio            VARCHAR(100),
  antiguedad_negocio_meses  INTEGER DEFAULT 0,
  ingresos_estimados        DECIMAL(12,2) DEFAULT 0,
  lat                       DECIMAL(10,7),
  lng                       DECIMAL(10,7),
  calificacion_sbs          VARCHAR(15) DEFAULT 'Normal'
                            CHECK (calificacion_sbs IN ('Normal','CPP','Deficiente','Dudoso','Perdida')),
  en_lista_negra            BOOLEAN NOT NULL DEFAULT false,
  motivo_lista_negra        TEXT,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_clientes_documento ON clientes(numero_documento);


-- ──────────────────────────────────────────────────────────────
-- 4. CRÉDITOS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS creditos (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id          UUID NOT NULL REFERENCES clientes(id),
  asesor_id           UUID NOT NULL REFERENCES asesores_negocio(id),
  agencia_id          UUID NOT NULL REFERENCES agencias(id),
  producto            VARCHAR(30) NOT NULL DEFAULT 'microcredito',
  monto_desembolsado  DECIMAL(12,2) NOT NULL,
  plazo_meses         INTEGER NOT NULL,
  tea                 DECIMAL(5,2) NOT NULL,
  estado              VARCHAR(20) NOT NULL DEFAULT 'vigente'
                      CHECK (estado IN ('vigente','pagado','vencido','castigado')),
  fecha_desembolso    DATE NOT NULL,
  fecha_vencimiento   DATE NOT NULL,
  saldo_actual        DECIMAL(12,2) NOT NULL,
  cuotas_total        INTEGER NOT NULL,
  cuotas_pagadas      INTEGER NOT NULL DEFAULT 0,
  dias_mora           INTEGER NOT NULL DEFAULT 0,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_creditos_cliente ON creditos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_creditos_asesor  ON creditos(asesor_id);


-- ──────────────────────────────────────────────────────────────
-- 5. CRÉDITOS PREAPROBADOS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS creditos_preaprobados (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id            UUID NOT NULL REFERENCES clientes(id),
  asesor_id             UUID NOT NULL REFERENCES asesores_negocio(id),
  monto_maximo          DECIMAL(12,2) NOT NULL,
  plazo_sugerido_meses  INTEGER NOT NULL,
  tea_referencial       DECIMAL(5,2) NOT NULL,
  score_confianza       INTEGER NOT NULL DEFAULT 50
                        CHECK (score_confianza BETWEEN 0 AND 100),
  vigente               BOOLEAN NOT NULL DEFAULT true,
  fecha_calculo         DATE NOT NULL DEFAULT CURRENT_DATE,
  fecha_vencimiento     DATE NOT NULL,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_preaprobados_cliente ON creditos_preaprobados(cliente_id);


-- ──────────────────────────────────────────────────────────────
-- 6. CAMPAÑAS ACTIVAS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS campanas_activas (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asesor_id        UUID NOT NULL REFERENCES asesores_negocio(id),
  cliente_id       UUID NOT NULL REFERENCES clientes(id),
  tipo             VARCHAR(30) NOT NULL
                   CHECK (tipo IN ('renovacion','ampliacion','producto_paralelo')),
  monto_ofertado   DECIMAL(12,2) NOT NULL,
  activa           BOOLEAN NOT NULL DEFAULT true,
  fecha_vencimiento DATE NOT NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_campanas_asesor ON campanas_activas(asesor_id);
