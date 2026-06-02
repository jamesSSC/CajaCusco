-- ============================================================
-- FASE 1-D: Datos semilla — Demo realista para Caja Cusco
-- Proyecto: App Fuerza de Ventas
-- Pegar en: Supabase Dashboard → SQL Editor → New query
-- (Ejecutar DESPUÉS de 01, 02 y 03)
-- ============================================================
-- PASO PREVIO OBLIGATORIO:
-- Antes de ejecutar este script, crea los 4 usuarios en
-- Authentication → Users → Invite User:
--
--   Email                     Contraseña    Perfil
--   ─────────────────────     ───────────   ───────────────
--   10001@cajacusco.app       Caja2026!     operador
--   10002@cajacusco.app       Caja2026!     super_operador
--   10003@cajacusco.app       Caja2026!     supervisor
--   10004@cajacusco.app       Caja2026!     administrador
--
-- Luego copia los UUID que Supabase asignó a cada uno y
-- reemplaza los valores en las variables de abajo.
-- ============================================================

DO $$
DECLARE
  -- ── Reemplaza estos UUIDs con los de tus usuarios de Auth ──
  uid_operador       UUID := '273ad65c-82b3-4259-8a77-98a86db82109';
  uid_super_op       UUID := 'f05f6652-0e56-4e24-8637-fce291b6de7c';
  uid_supervisor     UUID := 'cb958711-1e7b-4abf-b542-3da0013ac56e';
  uid_admin          UUID := '9bf46d55-c7ae-4d00-9631-3fda26cbf542';

  -- IDs internos (generados aquí para referenciarlos abajo)
  id_agencia         UUID := uuid_generate_v4();
  id_asesor_op       UUID := uuid_generate_v4();
  id_asesor_super    UUID := uuid_generate_v4();
  id_asesor_sup      UUID := uuid_generate_v4();
  id_asesor_adm      UUID := uuid_generate_v4();

  -- Clientes
  id_c1  UUID := uuid_generate_v4();
  id_c2  UUID := uuid_generate_v4();
  id_c3  UUID := uuid_generate_v4();
  id_c4  UUID := uuid_generate_v4();
  id_c5  UUID := uuid_generate_v4();
  id_c6  UUID := uuid_generate_v4();
  id_c7  UUID := uuid_generate_v4();
  id_c8  UUID := uuid_generate_v4();
  id_c9  UUID := uuid_generate_v4();
  id_c10 UUID := uuid_generate_v4();

  -- Créditos
  id_cr1 UUID := uuid_generate_v4();
  id_cr2 UUID := uuid_generate_v4();
  id_cr3 UUID := uuid_generate_v4();
  id_cr4 UUID := uuid_generate_v4();
  id_cr5 UUID := uuid_generate_v4();

BEGIN

  -- ── 1. AGENCIA ─────────────────────────────────────────────
  INSERT INTO agencias (id, nombre, region, lat, lng)
  VALUES (
    id_agencia,
    'Agencia Cusco Centro',
    'Cusco',
    -13.5319,
    -71.9675
  );

  -- ── 2. ASESORES ────────────────────────────────────────────
  INSERT INTO asesores_negocio
    (id, user_id, codigo_empleado, nombres, apellidos, agencia_id, perfil)
  VALUES
    (id_asesor_op,    uid_operador,   '10001', 'Carlos',  'Quispe Mamani',    id_agencia, 'operador'),
    (id_asesor_super, uid_super_op,   '10002', 'Ana',     'Flores Ccahuana',  id_agencia, 'super_operador'),
    (id_asesor_sup,   uid_supervisor, '10003', 'Roberto', 'Huanca Torres',    id_agencia, 'supervisor'),
    (id_asesor_adm,   uid_admin,      '10004', 'María',   'Condori Pumayalli', id_agencia, 'administrador');

  -- ── 3. CLIENTES (coordenadas alrededor de Cusco) ──────────
  INSERT INTO clientes
    (id, numero_documento, nombres, apellidos, telefono, direccion,
     tipo_negocio, nombre_negocio, antiguedad_negocio_meses,
     ingresos_estimados, lat, lng, calificacion_sbs)
  VALUES
    (id_c1,  '12345678', 'Pedro',    'Avendaño Rios',
     '984111222', 'Av. El Sol 345, Cusco',
     'Comercio', 'Ferretería Los Andes', 48, 3500, -13.5180, -71.9780, 'Normal'),

    (id_c2,  '23456789', 'Lucía',    'Ttito Ccoa',
     '985222333', 'Jr. Ayacucho 120, Cusco',
     'Servicios', 'Salón de Belleza Lucía', 24, 2200, -13.5220, -71.9710, 'Normal'),

    (id_c3,  '34567890', 'Juan',     'Mamani Condori',
     '986333444', 'Urb. Ttio Mz D Lt 5, Cusco',
     'Comercio', 'Abarrotes Don Juan', 72, 4800, -13.5350, -71.9520, 'CPP'),

    (id_c4,  '45678901', 'Rosa',     'Quispe Huanca',
     '987444555', 'Calle Saphi 88, Cusco',
     'Producción', 'Textilería Qori Manta', 60, 5200, -13.5140, -71.9800, 'Normal'),

    (id_c5,  '56789012', 'Miguel',   'Ccallo Huillca',
     '988555666', 'Av. Cusco 456, San Sebastián',
     'Agropecuario', 'Granja Los Pinos', 36, 3100, -13.5450, -71.9400, 'Deficiente'),

    (id_c6,  '67890123', 'Carmen',   'Vargas Béjar',
     '989666777', 'Av. La Cultura 789, Cusco',
     'Comercio', 'Librería Carmen', 18, 1800, -13.5200, -71.9600, 'Normal'),

    (id_c7,  '78901234', 'José',     'Medina Quispe',
     '981777888', 'Psje. Los Rosales 12, Wanchaq',
     'Servicios', 'Taller Mecánico Medina', 84, 6500, -13.5280, -71.9650, 'Normal'),

    (id_c8,  '89012345', 'Elena',    'Soto Pumayalli',
     '982888999', 'Jr. Tullumayo 234, Cusco',
     'Comercio', 'Bazar Elena', 12, 1500, -13.5160, -71.9740, 'Dudoso'),

    (id_c9,  '90123456', 'Raúl',     'Ccori Huallpa',
     '983999000', 'Av. Regional 560, San Jerónimo',
     'Agropecuario', 'Biohuerto Ccori', 96, 7200, -13.5500, -71.9300, 'Normal'),

    (id_c10, '01234567', 'Patricia', 'Lazo Gutiérrez',
     '984000111', 'Calle Plateros 45, Cusco',
     'Servicios', 'Restaurante Doña Pati', 30, 4100, -13.5120, -71.9770, 'Normal');

  -- ── 4. CRÉDITOS VIGENTES / VENCIDOS ──────────────────────
  INSERT INTO creditos
    (id, cliente_id, asesor_id, agencia_id, producto,
     monto_desembolsado, plazo_meses, tea, estado,
     fecha_desembolso, fecha_vencimiento,
     saldo_actual, cuotas_total, cuotas_pagadas, dias_mora)
  VALUES
    (id_cr1, id_c1, id_asesor_op, id_agencia, 'microcredito',
     8000, 12, 36.50, 'vigente',
     CURRENT_DATE - INTERVAL '8 months',
     CURRENT_DATE + INTERVAL '4 months',
     3200, 12, 8, 0),

    (id_cr2, id_c2, id_asesor_op, id_agencia, 'microcredito',
     5000, 6, 32.00, 'vigente',
     CURRENT_DATE - INTERVAL '4 months',
     CURRENT_DATE + INTERVAL '2 months',
     2100, 6, 4, 0),

    (id_cr3, id_c3, id_asesor_op, id_agencia, 'microcredito',
     12000, 18, 38.00, 'vencido',
     CURRENT_DATE - INTERVAL '14 months',
     CURRENT_DATE - INTERVAL '2 months',
     4800, 18, 14, 45),

    (id_cr4, id_c5, id_asesor_op, id_agencia, 'microcredito',
     6000, 12, 34.00, 'vencido',
     CURRENT_DATE - INTERVAL '10 months',
     CURRENT_DATE - INTERVAL '1 month',
     1800, 12, 9, 32),

    (id_cr5, id_c8, id_asesor_op, id_agencia, 'microcredito',
     3000, 6, 30.00, 'vencido',
     CURRENT_DATE - INTERVAL '9 months',
     CURRENT_DATE - INTERVAL '3 months',
     900, 6, 3, 90);

  -- ── 5. CRÉDITOS PREAPROBADOS ──────────────────────────────
  INSERT INTO creditos_preaprobados
    (cliente_id, asesor_id, monto_maximo, plazo_sugerido_meses,
     tea_referencial, score_confianza, vigente, fecha_vencimiento)
  VALUES
    (id_c1, id_asesor_op, 12000, 18, 36.50, 85, true, CURRENT_DATE + INTERVAL '30 days'),
    (id_c4, id_asesor_op, 15000, 24, 35.00, 92, true, CURRENT_DATE + INTERVAL '30 days'),
    (id_c7, id_asesor_op, 20000, 24, 34.00, 88, true, CURRENT_DATE + INTERVAL '15 days'),
    (id_c9, id_asesor_op, 25000, 36, 33.50, 95, true, CURRENT_DATE + INTERVAL '20 days');

  -- ── 6. CARTERA DEL DÍA (para el asesor operador) ─────────
  INSERT INTO cartera_diaria
    (asesor_id, cliente_id, agencia_id, fecha_asignacion,
     tipo_gestion, prioridad, score_prioridad, estado_visita)
  VALUES
    -- Mora vencida primero (mayor urgencia)
    (id_asesor_op, id_c3,  id_agencia, CURRENT_DATE,
     'RECUPERACION_MORA', 'alta',   100, 'pendiente'),
    (id_asesor_op, id_c8,  id_agencia, CURRENT_DATE,
     'RECUPERACION_MORA', 'alta',    95, 'pendiente'),
    (id_asesor_op, id_c5,  id_agencia, CURRENT_DATE,
     'RECUPERACION_MORA', 'alta',    90, 'pendiente'),
    -- Renovaciones de alto monto
    (id_asesor_op, id_c1,  id_agencia, CURRENT_DATE,
     'RENOVACION',        'alta',    85, 'pendiente'),
    (id_asesor_op, id_c7,  id_agencia, CURRENT_DATE,
     'RENOVACION',        'alta',    80, 'pendiente'),
    (id_asesor_op, id_c9,  id_agencia, CURRENT_DATE,
     'RENOVACION',        'media',   75, 'pendiente'),
    -- Ampliaciones
    (id_asesor_op, id_c4,  id_agencia, CURRENT_DATE,
     'AMPLIACION',        'media',   60, 'pendiente'),
    -- Seguimiento
    (id_asesor_op, id_c2,  id_agencia, CURRENT_DATE,
     'SEGUIMIENTO',       'normal',  30, 'pendiente'),
    (id_asesor_op, id_c6,  id_agencia, CURRENT_DATE,
     'SEGUIMIENTO',       'normal',  25, 'pendiente'),
    -- Nueva solicitud
    (id_asesor_op, id_c10, id_agencia, CURRENT_DATE,
     'NUEVA_SOLICITUD',   'normal',  15, 'pendiente');

  -- ── 7. ALERTAS DE CARTERA ─────────────────────────────────
  INSERT INTO alertas_cartera
    (asesor_id, cliente_id, tipo_alerta, mensaje, leida)
  VALUES
    (id_asesor_op, id_c3,  'mora_30d',
     'Juan Mamani Condori lleva 45 días de mora. Monto vencido: S/4,800.',
     false),
    (id_asesor_op, id_c8,  'mora_60d',
     'Elena Soto Pumayalli lleva 90 días de mora. Monto vencido: S/900.',
     false),
    (id_asesor_op, id_c5,  'primer_dia_mora',
     'Miguel Ccallo Huillca: 32 días de mora. Gestionar hoy.',
     false);

  -- ── 8. CAMPAÑAS ACTIVAS ───────────────────────────────────
  INSERT INTO campanas_activas
    (asesor_id, cliente_id, tipo, monto_ofertado, activa, fecha_vencimiento)
  VALUES
    (id_asesor_op, id_c1, 'renovacion',  12000, true, CURRENT_DATE + INTERVAL '7 days'),
    (id_asesor_op, id_c7, 'renovacion',  20000, true, CURRENT_DATE + INTERVAL '10 days'),
    (id_asesor_op, id_c4, 'ampliacion',  15000, true, CURRENT_DATE + INTERVAL '5 days'),
    (id_asesor_op, id_c9, 'renovacion',  25000, true, CURRENT_DATE + INTERVAL '20 days');

END $$;
