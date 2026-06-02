-- ============================================================
-- FASE 1-C: Row Level Security (RLS)
-- Proyecto: App Fuerza de Ventas — Caja Cusco
-- Pegar en: Supabase Dashboard → SQL Editor → New query
-- (Ejecutar DESPUÉS de 01 y 02)
-- ============================================================
-- IMPORTANTE: Sin estas políticas, nadie puede leer ni escribir
-- aunque tenga token válido. Actívalas SIEMPRE antes de probar.
-- ============================================================


-- ──────────────────────────────────────────────────────────────
-- FUNCIÓN HELPER: obtiene el UUID del asesor autenticado
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_asesor_id()
RETURNS UUID
LANGUAGE SQL STABLE
AS $$
  SELECT id
  FROM asesores_negocio
  WHERE user_id = auth.uid()
  LIMIT 1;
$$;

-- FUNCIÓN HELPER: obtiene el agencia_id del asesor autenticado
CREATE OR REPLACE FUNCTION get_asesor_agencia_id()
RETURNS UUID
LANGUAGE SQL STABLE
AS $$
  SELECT agencia_id
  FROM asesores_negocio
  WHERE user_id = auth.uid()
  LIMIT 1;
$$;

-- FUNCIÓN HELPER: obtiene el perfil del asesor autenticado
CREATE OR REPLACE FUNCTION get_asesor_perfil()
RETURNS TEXT
LANGUAGE SQL STABLE
AS $$
  SELECT perfil
  FROM asesores_negocio
  WHERE user_id = auth.uid()
  LIMIT 1;
$$;


-- ──────────────────────────────────────────────────────────────
-- AGENCIAS — lectura libre para autenticados
-- ──────────────────────────────────────────────────────────────
ALTER TABLE agencias ENABLE ROW LEVEL SECURITY;

CREATE POLICY "agencias_select_auth"
  ON agencias FOR SELECT
  TO authenticated
  USING (true);


-- ──────────────────────────────────────────────────────────────
-- ASESORES_NEGOCIO
-- ──────────────────────────────────────────────────────────────
ALTER TABLE asesores_negocio ENABLE ROW LEVEL SECURITY;

-- Cada asesor ve solo su propia fila
CREATE POLICY "asesores_select_own"
  ON asesores_negocio FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Supervisor/Admin ven todos los de su agencia
CREATE POLICY "asesores_select_supervisor"
  ON asesores_negocio FOR SELECT
  TO authenticated
  USING (
    agencia_id = get_asesor_agencia_id()
    AND get_asesor_perfil() IN ('supervisor','administrador')
  );

-- Solo el propio asesor actualiza su token_fcm
CREATE POLICY "asesores_update_own_fcm"
  ON asesores_negocio FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());


-- ──────────────────────────────────────────────────────────────
-- CLIENTES
-- ──────────────────────────────────────────────────────────────
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- Operador: solo clientes que están en su cartera de hoy
CREATE POLICY "clientes_select_en_cartera"
  ON clientes FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT cliente_id
      FROM cartera_diaria
      WHERE asesor_id = get_asesor_id()
    )
  );

-- Supervisor/Admin: todos los clientes de su agencia
CREATE POLICY "clientes_select_supervisor"
  ON clientes FOR SELECT
  TO authenticated
  USING (
    get_asesor_perfil() IN ('supervisor','administrador')
  );


-- ──────────────────────────────────────────────────────────────
-- CARTERA DIARIA
-- ──────────────────────────────────────────────────────────────
ALTER TABLE cartera_diaria ENABLE ROW LEVEL SECURITY;

-- Operador: solo su cartera
CREATE POLICY "cartera_select_own"
  ON cartera_diaria FOR SELECT
  TO authenticated
  USING (asesor_id = get_asesor_id());

-- Supervisor/Admin: toda la agencia
CREATE POLICY "cartera_select_supervisor"
  ON cartera_diaria FOR SELECT
  TO authenticated
  USING (
    agencia_id = get_asesor_agencia_id()
    AND get_asesor_perfil() IN ('supervisor','administrador')
  );

-- El asesor actualiza el estado de visita de su cartera
CREATE POLICY "cartera_update_own"
  ON cartera_diaria FOR UPDATE
  TO authenticated
  USING (asesor_id = get_asesor_id())
  WITH CHECK (asesor_id = get_asesor_id());


-- ──────────────────────────────────────────────────────────────
-- CRÉDITOS
-- ──────────────────────────────────────────────────────────────
ALTER TABLE creditos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "creditos_select_own"
  ON creditos FOR SELECT
  TO authenticated
  USING (asesor_id = get_asesor_id());

CREATE POLICY "creditos_select_supervisor"
  ON creditos FOR SELECT
  TO authenticated
  USING (
    agencia_id = get_asesor_agencia_id()
    AND get_asesor_perfil() IN ('supervisor','administrador')
  );


-- ──────────────────────────────────────────────────────────────
-- CRÉDITOS PREAPROBADOS
-- ──────────────────────────────────────────────────────────────
ALTER TABLE creditos_preaprobados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "preaprobados_select_own"
  ON creditos_preaprobados FOR SELECT
  TO authenticated
  USING (asesor_id = get_asesor_id());


-- ──────────────────────────────────────────────────────────────
-- CAMPAÑAS ACTIVAS
-- ──────────────────────────────────────────────────────────────
ALTER TABLE campanas_activas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "campanas_select_own"
  ON campanas_activas FOR SELECT
  TO authenticated
  USING (asesor_id = get_asesor_id());


-- ──────────────────────────────────────────────────────────────
-- SOLICITUDES DE CRÉDITO
-- ──────────────────────────────────────────────────────────────
ALTER TABLE solicitudes_credito ENABLE ROW LEVEL SECURITY;

CREATE POLICY "solicitudes_select_own"
  ON solicitudes_credito FOR SELECT
  TO authenticated
  USING (asesor_id = get_asesor_id());

CREATE POLICY "solicitudes_select_supervisor"
  ON solicitudes_credito FOR SELECT
  TO authenticated
  USING (
    agencia_id = get_asesor_agencia_id()
    AND get_asesor_perfil() IN ('supervisor','administrador')
  );

CREATE POLICY "solicitudes_insert_own"
  ON solicitudes_credito FOR INSERT
  TO authenticated
  WITH CHECK (asesor_id = get_asesor_id());

CREATE POLICY "solicitudes_update_own"
  ON solicitudes_credito FOR UPDATE
  TO authenticated
  USING (asesor_id = get_asesor_id())
  WITH CHECK (asesor_id = get_asesor_id());


-- ──────────────────────────────────────────────────────────────
-- DOCUMENTOS DE SOLICITUD
-- ──────────────────────────────────────────────────────────────
ALTER TABLE solicitudes_documentos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "docs_select_own"
  ON solicitudes_documentos FOR SELECT
  TO authenticated
  USING (
    solicitud_id IN (
      SELECT id FROM solicitudes_credito
      WHERE asesor_id = get_asesor_id()
    )
  );

CREATE POLICY "docs_insert_own"
  ON solicitudes_documentos FOR INSERT
  TO authenticated
  WITH CHECK (
    solicitud_id IN (
      SELECT id FROM solicitudes_credito
      WHERE asesor_id = get_asesor_id()
    )
  );

CREATE POLICY "docs_delete_own"
  ON solicitudes_documentos FOR DELETE
  TO authenticated
  USING (
    solicitud_id IN (
      SELECT id FROM solicitudes_credito
      WHERE asesor_id = get_asesor_id()
    )
  );


-- ──────────────────────────────────────────────────────────────
-- CONSULTAS DE BURÓ
-- ──────────────────────────────────────────────────────────────
ALTER TABLE consultas_buro ENABLE ROW LEVEL SECURITY;

CREATE POLICY "buro_select_own"
  ON consultas_buro FOR SELECT
  TO authenticated
  USING (asesor_id = get_asesor_id());

CREATE POLICY "buro_insert_own"
  ON consultas_buro FOR INSERT
  TO authenticated
  WITH CHECK (asesor_id = get_asesor_id());


-- ──────────────────────────────────────────────────────────────
-- ACCIONES DE COBRANZA
-- ──────────────────────────────────────────────────────────────
ALTER TABLE acciones_cobranza ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cobranza_select_own"
  ON acciones_cobranza FOR SELECT
  TO authenticated
  USING (asesor_id = get_asesor_id());

CREATE POLICY "cobranza_insert_own"
  ON acciones_cobranza FOR INSERT
  TO authenticated
  WITH CHECK (asesor_id = get_asesor_id());


-- ──────────────────────────────────────────────────────────────
-- ALERTAS DE CARTERA
-- ──────────────────────────────────────────────────────────────
ALTER TABLE alertas_cartera ENABLE ROW LEVEL SECURITY;

CREATE POLICY "alertas_select_own"
  ON alertas_cartera FOR SELECT
  TO authenticated
  USING (asesor_id = get_asesor_id());

CREATE POLICY "alertas_update_own"
  ON alertas_cartera FOR UPDATE
  TO authenticated
  USING (asesor_id = get_asesor_id())
  WITH CHECK (asesor_id = get_asesor_id());


-- ──────────────────────────────────────────────────────────────
-- NOTAS INTERNAS
-- ──────────────────────────────────────────────────────────────
ALTER TABLE solicitudes_notas_internas ENABLE ROW LEVEL SECURITY;

-- Autor de la nota o supervisor de la agencia
CREATE POLICY "notas_select_autor_o_supervisor"
  ON solicitudes_notas_internas FOR SELECT
  TO authenticated
  USING (
    asesor_id = get_asesor_id()
    OR get_asesor_perfil() IN ('supervisor','administrador')
  );

CREATE POLICY "notas_insert_own"
  ON solicitudes_notas_internas FOR INSERT
  TO authenticated
  WITH CHECK (asesor_id = get_asesor_id());


-- ──────────────────────────────────────────────────────────────
-- STORAGE — Bucket documentos-solicitudes
-- ──────────────────────────────────────────────────────────────
-- Ejecutar esto en: Storage → Policies (o con el SQL Editor)

INSERT INTO storage.buckets (id, name, public)
VALUES ('documentos-solicitudes', 'documentos-solicitudes', false)
ON CONFLICT (id) DO NOTHING;

-- El asesor puede subir archivos a su carpeta
CREATE POLICY "storage_upload_own"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'documentos-solicitudes'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM solicitudes_credito
      WHERE asesor_id = get_asesor_id()
    )
  );

-- El asesor puede leer archivos de sus solicitudes
CREATE POLICY "storage_select_own"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'documentos-solicitudes'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM solicitudes_credito
      WHERE asesor_id = get_asesor_id()
    )
  );

-- El asesor puede eliminar sus archivos
CREATE POLICY "storage_delete_own"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'documentos-solicitudes'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM solicitudes_credito
      WHERE asesor_id = get_asesor_id()
    )
  );
