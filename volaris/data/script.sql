-- 1. TIPOS ENUMERADOS
CREATE TYPE rol_usuario AS ENUM ('CLIENTE', 'AGENCIA');
CREATE TYPE tipo_documento AS ENUM ('CC', 'CE', 'PASAPORTE', 'NIT');
CREATE TYPE duracion_categoria AS ENUM ('PASADIA', 'FIN_DE_SEMANA', 'SEMANA_COMPLETA');
CREATE TYPE ambiente_categoria AS ENUM ('PLAYA', 'MONTANA', 'CIUDAD', 'NIEVE');
CREATE TYPE estado_reserva AS ENUM ('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'COMPLETADA');
CREATE TYPE tipo_pqr AS ENUM ('PETICION', 'QUEJA', 'RECLAMO', 'SUGERENCIA');
CREATE TYPE estado_pqr AS ENUM ('PENDIENTE', 'EN_PROCESO', 'RESUELTO', 'CERRADO');
CREATE TYPE prioridad_pqr AS ENUM ('BAJA', 'MEDIA', 'ALTA');

-- 2. TABLA DE USUARIOS Y PERFILES
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100),
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol rol_usuario NOT NULL DEFAULT 'CLIENTE',
    tipo_doc tipo_documento,
    numero_doc VARCHAR(20) UNIQUE,
    pais VARCHAR(80),
    departamento_provincia VARCHAR(80),
    telefono VARCHAR(20),
    foto_perfil VARCHAR(255),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABLA DE AGENCIAS
CREATE TABLE agencias (
    id SERIAL PRIMARY KEY,
    usuario_id INT UNIQUE NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre_agencia VARCHAR(150) NOT NULL,
    nit VARCHAR(30) UNIQUE NOT NULL,
    contacto_principal VARCHAR(100)
);

-- 4. TABLA DE VIAJES Y TOURS
CREATE TABLE viajes (
    id SERIAL PRIMARY KEY,
    agencia_id INT NOT NULL REFERENCES agencias(id) ON DELETE CASCADE,
    titulo VARCHAR(150) NOT NULL,
    subtitulo VARCHAR(255),
    descripcion TEXT,
    origen VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    tipo_cobertura VARCHAR(20) CHECK (tipo_cobertura IN ('LOCAL', 'NACIONAL', 'INTERNACIONAL')),
    duracion duracion_categoria NOT NULL,
    categoria ambiente_categoria NOT NULL,
    fecha_salida TIMESTAMP NOT NULL,
    fecha_llegada TIMESTAMP NOT NULL,
    cupos_totales INT NOT NULL CHECK (cupos_totales > 0),
    cupos_disponibles INT NOT NULL CHECK (cupos_disponibles >= 0),
    precio_base DECIMAL(12, 2) NOT NULL CHECK (precio_base > 0),
    imagen_url VARCHAR(255),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. TABLA DE RESERVAS
CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    viaje_id INT NOT NULL REFERENCES viajes(id) ON DELETE RESTRICT,
    cantidad_pasajeros INT NOT NULL DEFAULT 1 CHECK (cantidad_pasajeros > 0),
    precio_total DECIMAL(12, 2) NOT NULL,
    aplico_descuento_50 BOOLEAN DEFAULT FALSE,
    estado estado_reserva DEFAULT 'CONFIRMADA',
    fecha_reserva TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. TABLA DE RESEÑAS Y COMENTARIOS
CREATE TABLE resenas (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    viaje_id INT NOT NULL REFERENCES viajes(id) ON DELETE CASCADE,
    reserva_id INT UNIQUE NOT NULL REFERENCES reservas(id) ON DELETE CASCADE,
    calificacion INT CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT NOT NULL,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. TABLA DE PQRs
CREATE TABLE pqrs (
    id SERIAL PRIMARY KEY,
    codigo_radicado VARCHAR(20) UNIQUE NOT NULL,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    reserva_id INT REFERENCES reservas(id) ON DELETE SET NULL,
    tipo tipo_pqr NOT NULL,
    asunto VARCHAR(150) NOT NULL,
    descripcion TEXT NOT NULL,
    estado estado_pqr DEFAULT 'PENDIENTE',
    prioridad prioridad_pqr DEFAULT 'MEDIA',
    respuesta_oficial TEXT,
    agencia_responde_id INT REFERENCES agencias(id),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta TIMESTAMP
);

-- 8. TABLA DE ESTADÍSTICAS Y ANALÍTICA
CREATE TABLE estadisticas_mensuales (
    id SERIAL PRIMARY KEY,
    agencia_id INT NOT NULL REFERENCES agencias(id) ON DELETE CASCADE,
    anio INT NOT NULL,
    mes INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    total_reservas INT DEFAULT 0,
    tasa_conversion DECIMAL(5,2) DEFAULT 0.00,
    pqrs_pendientes INT DEFAULT 0,
    ingresos_totales DECIMAL(15,2) DEFAULT 0.00,
    metricas_json JSONB,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_agencia_anio_mes UNIQUE (agencia_id, anio, mes)
);

-- 9. ÍNDICES DE RENDIMIENTO
CREATE INDEX idx_viajes_origen_destino ON viajes(origen, destino);
CREATE INDEX idx_viajes_descuento ON viajes(fecha_salida, cupos_disponibles);
CREATE INDEX idx_pqrs_codigo ON pqrs(codigo_radicado);
CREATE INDEX idx_reservas_usuario ON reservas(usuario_id);