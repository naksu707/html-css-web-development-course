-- Script de generación masiva de datos estructurados para PostgreSQL

DO $$
DECLARE
    
    v_user_id INT;
    v_agencia_id INT;
    v_viaje_id INT;
    v_reserva_id INT;
    
    v_nombres TEXT[] := ARRAY['Carlos', 'Lucia', 'Andres', 'Mariana', 'Esteban', 'Sofia', 'Mateo', 'Valentina', 'Santiago', 'Camila', 'Alejandro', 'Daniela', 'Gabriel', 'Isabella', 'Felipe', 'Natalia', 'Javier', 'Elena', 'Diego', 'Paula'];
    v_apellidos TEXT[] := ARRAY['Mendoza', 'Gomez', 'Restrepo', 'Perez', 'Silva', 'Londono', 'Rojas', 'Cruz', 'Torres', 'Ramirez', 'Vargas', 'Morales', 'Castillo', 'Gutierrez', 'Ortiz', 'Chavez', 'Ruiz', 'Alvarez', 'Suarez', 'Romero'];
    v_ciudades TEXT[] := ARRAY['Cali', 'Bogota', 'Medellin', 'Cartagena', 'Santa Marta', 'Manizales', 'Pereira', 'Bucaramanga', 'Pastos', 'San Andres', 'Leticia', 'Popayan'];
    v_agencias_nombres TEXT[] := ARRAY['Andes Tours', 'Pacific Viajes', 'Caribe Express', 'Cafetero Adventures', 'Amazonas Discovery'];
    
BEGIN

    TRUNCATE TABLE 
        estadisticas_mensuales,
        pqrs,
        resenas,
        reservas,
        viajes,
        agencias,
        usuarios
    RESTART IDENTITY CASCADE;

    FOR i IN 1..100 LOOP
        INSERT INTO usuarios (
            nombre, apellidos, email, password_hash, rol, tipo_doc, numero_doc, pais, departamento_provincia, telefono
        ) VALUES (
            v_nombres[1 + floor(random() * array_length(v_nombres, 1))::int],
            v_apellidos[1 + floor(random() * array_length(v_apellidos, 1))::int],
            'usuario_' || i || '@correo.com',
            'hash_secure_password_' || i,
            CASE WHEN i <= 5 THEN 'AGENCIA'::rol_usuario ELSE 'CLIENTE'::rol_usuario END,
            (ARRAY['CC', 'CE', 'PASAPORTE'])[1 + floor(random() * 3)::int]::tipo_documento,
            (1000000000 + i)::text,
            'Colombia',
            'Valle del Cauca',
            '300' || lpad(i::text, 7, '0')
        );
    END LOOP;

    FOR i IN 1..5 LOOP
        INSERT INTO agencias (
            usuario_id, nombre_agencia, nit, contacto_principal
        ) VALUES (
            i,
            v_agencias_nombres[i],
            '900' || lpad(i::text, 6, '0') || '-' || i,
            (SELECT nombre || ' ' || apellidos FROM usuarios WHERE id = i)
        );
    END LOOP;

    FOR i IN 1..200 LOOP
        v_agencia_id := 1 + floor(random() * 5)::int;
        INSERT INTO viajes (
            agencia_id, titulo, subtitulo, descripcion, origen, destino, tipo_cobertura,
            duracion, categoria, fecha_salida, fecha_llegada, cupos_totales, cupos_disponibles, precio_base, imagen_url
        ) VALUES (
            v_agencia_id,
            'Tour Especial ' || i,
            'Increíble experiencia turística número ' || i,
            'Disfruta de una experiencia inolvidable explorando los mejores paisajes.',
            v_ciudades[1 + floor(random() * array_length(v_ciudades, 1))::int],
            v_ciudades[1 + floor(random() * array_length(v_ciudades, 1))::int],
            (ARRAY['LOCAL', 'NACIONAL', 'INTERNACIONAL'])[1 + floor(random() * 3)::int],
            (ARRAY['PASADIA', 'FIN_DE_SEMANA', 'SEMANA_COMPLETA'])[1 + floor(random() * 3)::int]::duracion_categoria,
            (ARRAY['PLAYA', 'MONTANA', 'CIUDAD', 'NIEVE'])[1 + floor(random() * 4)::int]::ambiente_categoria,
            NOW() + (i || ' days')::interval,
            NOW() + (i || ' days')::interval + '3 days'::interval,
            50,
            floor(random() * 50)::int,
            (150000 + (random() * 1850000))::numeric(12,2),
            'imagen_' || i || '.jpg'
        );
    END LOOP;

    FOR i IN 1..1500 LOOP
        v_user_id := 6 + floor(random() * 95)::int; -- Solo clientes (IDs 6 al 100)
        v_viaje_id := 1 + floor(random() * 200)::int;
        INSERT INTO reservas (
            usuario_id, viaje_id, cantidad_pasajeros, precio_total, aplico_descuento_50, estado, fecha_reserva
        ) VALUES (
            v_user_id,
            v_viaje_id,
            1 + floor(random() * 4)::int,
            (200000 + (random() * 2000000))::numeric(12,2),
            (random() > 0.85),
            (ARRAY['PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'COMPLETADA'])[1 + floor(random() * 4)::int]::estado_reserva,
            NOW() - ((floor(random() * 180)) || ' days')::interval
        );
    END LOOP;

    FOR i IN 1..2000 LOOP
        v_reserva_id := 1 + floor(random() * 1500)::int;
        
        SELECT usuario_id, viaje_id INTO v_user_id, v_viaje_id 
        FROM reservas WHERE id = v_reserva_id;

        INSERT INTO resenas (
            usuario_id, viaje_id, reserva_id, calificacion, comentario, fecha_publicacion
        ) VALUES (
            v_user_id,
            v_viaje_id,
            v_reserva_id,
            1 + floor(random() * 5)::int,
            'Comentario de la reseña número ' || i || '. La experiencia cumplió con mis expectativas.',
            NOW() - ((floor(random() * 90)) || ' days')::interval
        )
        ON CONFLICT (reserva_id) DO NOTHING; -
    END LOOP;

    FOR i IN 1..500 LOOP
        v_user_id := 6 + floor(random() * 95)::int;
        v_reserva_id := 1 + floor(random() * 1500)::int;
        v_agencia_id := 1 + floor(random() * 5)::int;

        INSERT INTO pqrs (
            codigo_radicado, usuario_id, reserva_id, tipo, asunto, descripcion,
            estado, prioridad, respuesta_oficial, agencia_responde_id, fecha_creacion
        ) VALUES (
            'PQR-2026-' || lpad(i::text, 5, '0'),
            v_user_id,
            v_reserva_id,
            (ARRAY['PETICION', 'QUEJA', 'RECLAMO', 'SUGERENCIA'])[1 + floor(random() * 4)::int]::tipo_pqr,
            'Asunto PQR ' || i,
            'Descripción detallada del motivo de la PQR número ' || i,
            (ARRAY['PENDIENTE', 'EN_PROCESO', 'RESUELTO', 'CERRADO'])[1 + floor(random() * 4)::int]::estado_pqr,
            (ARRAY['BAJA', 'MEDIA', 'ALTA'])[1 + floor(random() * 3)::int]::prioridad_pqr,
            'Respuesta oficial emitida para la PQR número ' || i,
            v_agencia_id,
            NOW() - ((floor(random() * 60)) || ' days')::interval
        );
    END LOOP;

    FOR i IN 1..2000 LOOP
        v_agencia_id := 1 + (i % 5);
        INSERT INTO estadisticas_mensuales (
            agencia_id, anio, mes, total_reservas, tasa_conversion, pqrs_pendientes,
            ingresos_totales, metricas_json
        ) VALUES (
            v_agencia_id,
            2010 + (i / 60)::int, 
            1 + (i % 12),
            floor(random() * 100)::int,
            (random() * 30)::numeric(5,2),
            floor(random() * 10)::int,
            (5000000 + (random() * 45000000))::numeric(15,2),
            jsonb_build_object('satisfaccion', (3 + (random() * 2))::numeric(3,1), 'visitas_web', floor(random() * 5000))
        )
        ON CONFLICT (agencia_id, anio, mes) DO NOTHING; -- Mantiene la restricción UNIQUE (agencia_id, anio, mes)
    END LOOP;

END $$;