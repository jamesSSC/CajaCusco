-- ============================================================
-- FASE 1-B: Tablas operativas de campo
-- Proyecto: App Fuerza de Ventas — Caja Cusco
-- Pegar en: Supabase Dashboard → SQL Editor → New query
-- (Ejecutar DESPUÉS de 01_tablas_principales.sql)
-- ============================================================


-- ──────────────────────────────────────────────────────────────
-- 7. CARTERA DIARIA
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cartera_diaria (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asesor_id           UUID NOT NULL REFERENCES asesores_negocio(id),
  cliente_id          UUID NOT NULL REFERENCES clientes(id),
  agencia_id          UUID NOT NULL REFERENCES agencias(id),
  fecha_asignacion    DATE NOT NULL DEFAULT CURRENT_DATE,
  tipo_gestion        VARCHAR(30) NOT NULL
                      CHECK (tipo_gestion IN (
                        'RENOVACION','AMPLIACION','NUEVA_SOLICITUD',
                        'SEGUIMIENTO','RECUPERACION_MORA','DESERTOR'
                      )),
  prioridad           VARCHAR(10) NOT NULL DEFAULT 'normal'
                      CHECK (prioridad IN ('alta','media','normal')),
  score_prioridad     INTEGER NOT NULL DEFAULT 0
                      CHECK (score_prioridad BETWEEN 0 AND 100),
  estado_visita       VARCHAR(20) NOT NULL DEFAULT 'pendiente'
                      CHECK (estado_visita IN (
                        'pendiente','visitado','no_encontrado',
                        'reagendado','negocio_cerrado'
                      )),
  resultado_visita    VARCHAR(30),
  observacion_visita  TEXT,
  timestamp_visita    TIMESTAMPTZ,
  lat_visita          DECIMAL(10,7),
  lng_visita          DECIMAL(10,7),
  orden_manual        INTEGER,
  UNIQUE (asesor_id, cliente_id, fecha_asignacion)
);

CREATE INDEX IF NOT EXISTS idx_cartera_asesor_fecha
  ON cartera_diaria(asesor_id, fecha_asignacion);
CREATE INDEX IF NOT EXISTS idx_cartera_agencia_fecha
  ON cartera_diaria(agencia_id, fecha_asignacion);


-- ──────────────────────────────────────────────────────────────
-- 8. SOLICITUDES DE CRÉDITO
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS solicitudes_credito (
  id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_expediente         VARCHAR(20) UNIQUE,
  asesor_id                 UUID NOT NULL REFERENCES asesores_negocio(id),
  cliente_id                UUID NOT NULL REFERENCES clientes(id),
  agencia_id                UUID NOT NULL REFERENCES agencias(id),
  -- Datos del negocio
  tipo_negocio              VARCHAR(30),
  nombre_negocio            VARCHAR(100),
  actividad_economica       VARCHAR(10),
  antiguedad_negocio_meses  INTEGER,
  ingresos_estimados        DECIMAL(12,2),
  gastos_mensuales          DECIMAL(12,2),
  patrimonio_estimado       DECIMAL(12,2),
  destino_credito           TEXT,
  -- Cónyuge / garante (serializados en JSON)
  tiene_conyuge             BOOLEAN NOT NULL DEFAULT false,
  conyuge_json              JSONB,
  tiene_garante             BOOLEAN NOT NULL DEFAULT false,
  garante_json              JSONB,
  -- Condiciones del crédito
  monto_solicitado          DECIMAL(12,2) NOT NULL,
  plazo_meses               INTEGER NOT NULL,
  moneda                    VARCHAR(3) NOT NULL DEFAULT 'PEN'
                            CHECK (moneda IN ('PEN','USD')),
  tipo_cuota                VARCHAR(10) NOT NULL DEFAULT 'mensual'
                            CHECK (tipo_cuota IN ('mensual','quincenal','semanal')),
  garantia                  VARCHAR(20) DEFAULT 'sin_garantia'
                            CHECK (garantia IN (
                              'sin_garantia','aval','hipotecaria','prendaria'
                            )),
  cuota_estimada            DECIMAL(10,2),
  tea_referencial           DECIMAL(5,2),
  -- Estado del expediente
  estado                    VARCHAR(30) NOT NULL DEFAULT 'borrador'
                            CHECK (estado IN (
                              'borrador','enviado','recibido_comite',
                              'en_evaluacion','aprobado','condicionado',
                              'rechazado','desembolsado'
                            )),
  monto_aprobado            DECIMAL(12,2),
  motivo_rechazo            TEXT,
  condicion_adicional       TEXT,
  analista_asignado         VARCHAR(100),
  -- Firma y captura
  firma_cliente_base64      TEXT,
  lat_captura               DECIMAL(10,7),
  lng_captura               DECIMAL(10,7),
  -- Sync offline
  pendiente_sync            BOOLEAN NOT NULL DEFAULT false,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_solicitudes_asesor   ON solicitudes_credito(asesor_id);
CREATE INDEX IF NOT EXISTS idx_solicitudes_cliente  ON solicitudes_credito(cliente_id);
CREATE INDEX IF NOT EXISTS idx_solicitudes_estado   ON solicitudes_credito(estado);
CREATE INDEX IF NOT EXISTS idx_solicitudes_agencia  ON solicitudes_credito(agencia_id);


-- ──────────────────────────────────────────────────────────────
-- 9. DOCUMENTOS DE SOLICITUD
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS solicitudes_documentos (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  solicitud_id    UUID NOT NULL REFERENCES solicitudes_credito(id) ON DELETE CASCADE,
  tipo_documento  VARCHAR(40) NOT NULL
                  CHECK (tipo_documento IN (
                    'dni_anverso','dni_reverso','ruc','recibo_servicios',
                    'foto_negocio','foto_visita','contrato_arrendamiento'
                  )),
  storage_url     TEXT NOT NULL,
  tamanio_kb      INTEGER,
  nitidez_score   DECIMAL(5,2),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_docs_solicitud ON solicitudes_documentos(solicitud_id);


-- ──────────────────────────────────────────────────────────────
-- 10. CONSULTAS DE BURÓ
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS consultas_buro (
  id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asesor_id                   UUID NOT NULL REFERENCES asesores_negocio(id),
  cliente_id                  UUID NOT NULL REFERENCES clientes(id),
  solicitud_id                UUID REFERENCES solicitudes_credito(id),
  dni_consultado              VARCHAR(15) NOT NULL,
  calificacion_sbs            VARCHAR(20),
  entidades_con_deuda         INTEGER DEFAULT 0,
  deuda_total_pen             DECIMAL(12,2) DEFAULT 0,
  mayor_deuda                 DECIMAL(12,2) DEFAULT 0,
  dias_mayor_mora             INTEGER DEFAULT 0,
  resultado_json              JSONB,
  firma_consentimiento_base64 TEXT,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_buro_cliente ON consultas_buro(cliente_id);
CREATE INDEX IF NOT EXISTS idx_buro_asesor  ON consultas_buro(asesor_id);


-- ──────────────────────────────────────────────────────────────
-- 11. ACCIONES DE COBRANZA
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS acciones_cobranza (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asesor_id          UUID NOT NULL REFERENCES asesores_negocio(id),
  cliente_id         UUID NOT NULL REFERENCES clientes(id),
  credito_id         UUID NOT NULL REFERENCES creditos(id),
  tipo_gestion       VARCHAR(20) NOT NULL
                     CHECK (tipo_gestion IN ('visita','llamada','mensaje')),
  resultado          VARCHAR(30) NOT NULL
                     CHECK (resultado IN (
                       'compromiso_pago','pago_parcial',
                       'sin_contacto','se_niega'
                     )),
  monto_pagado       DECIMAL(12,2),
  fecha_compromiso   DATE,
  monto_compromiso   DECIMAL(12,2),
  observaciones      TEXT,
  lat                DECIMAL(10,7),
  lng                DECIMAL(10,7),
  timestamp_gestion  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cobranza_asesor  ON acciones_cobranza(asesor_id);
CREATE INDEX IF NOT EXISTS idx_cobranza_cliente ON acciones_cobranza(cliente_id);


-- ──────────────────────────────────────────────────────────────
-- 12. ALERTAS DE CARTERA
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS alertas_cartera (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asesor_id    UUID NOT NULL REFERENCES asesores_negocio(id),
  cliente_id   UUID NOT NULL REFERENCES clientes(id),
  tipo_alerta  VARCHAR(30) NOT NULL
               CHECK (tipo_alerta IN (
                 'primer_dia_mora','mora_30d','mora_60d',
                 'pago_parcial','pago_total'
               )),
  mensaje      TEXT,
  leida        BOOLEAN NOT NULL DEFAULT false,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alertas_asesor ON alertas_cartera(asesor_id);


-- ──────────────────────────────────────────────────────────────
-- 13. NOTAS INTERNAS DE SOLICITUD
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS solicitudes_notas_internas (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  solicitud_id UUID NOT NULL REFERENCES solicitudes_credito(id) ON DELETE CASCADE,
  asesor_id    UUID NOT NULL REFERENCES asesores_negocio(id),
  contenido    TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_contenido_longitud CHECK (LENGTH(contenido) <= 500)
);


-- ──────────────────────────────────────────────────────────────
-- VISTA AUXILIAR: cartera vencida (para M10)
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW cartera_vencida AS
SELECT
  cd.id,
  cd.asesor_id,
  cd.cliente_id,
  c.nombres || ' ' || c.apellidos AS cliente_nombre,
  c.numero_documento,
  c.telefono,
  cr.dias_mora,
  cr.saldo_actual AS monto_vencido,
  cr.id AS credito_id,
  (
    SELECT MAX(ac.timestamp_gestion)
    FROM acciones_cobranza ac
    WHERE ac.cliente_id = cd.cliente_id
      AND ac.asesor_id  = cd.asesor_id
  ) AS ultimo_contacto
FROM cartera_diaria cd
JOIN clientes c  ON c.id = cd.cliente_id
JOIN creditos cr ON cr.cliente_id = cd.cliente_id
              AND cr.estado = 'vencido'
WHERE cr.dias_mora > 0;


-- ──────────────────────────────────────────────────────────────
-- TRIGGER: actualiza updated_at en solicitudes_credito
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_solicitudes_updated_at ON solicitudes_credito;
CREATE TRIGGER trg_solicitudes_updated_at
  BEFORE UPDATE ON solicitudes_credito
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
