# Persistencia de Datos - App Fuerza de Ventas

## Arquitectura Implementada

### 1. **SolicitudRepository** (`solicitud_repository.dart`)
Responsable de guardar solicitudes de crédito en Supabase o SQLite.

**Métodos:**
- `guardarSolicitud()` → Inserta en Supabase + fallback SQLite
- `actualizarEstado()` → Cambia estado de solicitud
- `asignarExpediente()` → Asigna número de expediente único

**Flujo:**
```
Con red          →  Guardar en Supabase
Sin red          →  Guardar en SQLite con pendiente_sync=true
Reconectar       →  Sincronizar tabla solicitudes_pendientes
```

### 2. **ExpedienteService** (`expediente_service.dart`)
Genera números de expediente únicos por fecha y secuencia.

**Formato:** `EXP-YYYYMMDD-0001`
**Ejemplo:** `EXP-20260602-0001`

**Fallback:** Si falla BD, usa timestamp

### 3. **DocumentosDataSource** (`documentos_datasource.dart`)
Sube documentos a Supabase Storage y registra en BD.

**Métodos:**
- `subirDocumento()` → Carga archivo a Storage
- `guardarRegistroDocumento()` → Inserta en tabla `solicitudes_documentos`

**Ubicación en Storage:** `documentos-solicitudes/{solicitud_id}/{tipo_documento}.jpg`

### 4. **TransmisionScreen** (flujo integrado)
Ejecuta 5 pasos de persistencia:

```
Paso 1: Validar datos          → Verifica completitud
Paso 2: Subir documentos        → Carga a Storage
Paso 3: Registrar en BD         → SolicitudRepository.guardarSolicitud()
Paso 4: Asignar expediente      → ExpedienteService.generarNumero()
Paso 5: Completar              → Retorna { expediente: "EXP-..." }
```

## Garantías

✅ **Datos guardados en Supabase** (tabla `solicitudes_credito`)
- `id`, `numero_expediente`, `estado`, `monto_solicitado`, `plazo_meses`, etc.

✅ **Documentos guardados en Storage**
- URL públicas registradas en `solicitudes_documentos`

✅ **Expedientes únicos**
- Generados por fecha + secuencia autoincremental

✅ **Modo offline**
- Si falla la conexión, guarda localmente con `pendiente_sync=true`
- Se sincroniza automáticamente al reconectar

## Tablas Supabase Utilizadas

| Tabla | Uso |
|-------|-----|
| `solicitudes_credito` | Datos principales de la solicitud |
| `solicitudes_documentos` | Registro de archivos adjuntos |
| `asesores_negocio` | Asesor responsable |
| `clientes` | Cliente solicitante |
| `agencias` | Agencia de origen |

## Storage Supabase

**Bucket:** `documentos-solicitudes`
**Ruta:** `/solicitud_id/tipo_documento.jpg`

Ejemplos:
- `/sol_abc123/dni_anverso.jpg`
- `/sol_abc123/ruc.jpg`
- `/sol_abc123/foto_negocio.jpg`

## Próximas Mejoras

- [ ] Sincronización en background con WorkManager
- [ ] Encriptación de documentos en Storage
- [ ] Webhook para notificar cuando se recibe solicitud
- [ ] Retento automático de fallos de red
