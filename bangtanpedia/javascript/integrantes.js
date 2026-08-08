const tarjetas = document.querySelectorAll('.tarjeta-integrante');

const informacion = {
    rm: {
        nombre: 'RM',
        nombreReal: 'Kim Namjoon',
        descripcion: 'Líder de BTS, rapero, compositor y productor. Es reconocido por su participación en la creación musical del grupo y por su interés en el arte y la literatura.'
    },
    jin: {
        nombre: 'Jin',
        nombreReal: 'Kim Seokjin',
        descripcion: 'Vocalista de BTS. Es conocido por su personalidad alegre, su sentido del humor y su participación en diferentes proyectos musicales del grupo.'
    },
    suga: {
        nombre: 'SUGA',
        nombreReal: 'Min Yoongi',
        descripcion: 'Rapero, compositor y productor de BTS. También desarrolla trabajos musicales como solista bajo el nombre de Agust D.'
    },
    jhope: {
        nombre: 'j-hope',
        nombreReal: 'Jung Hoseok',
        descripcion: 'Rapero, bailarín y compositor. Es reconocido especialmente por sus habilidades de baile y por su energía en las presentaciones.'
    },
    jimin: {
        nombre: 'Jimin',
        nombreReal: 'Park Jimin',
        descripcion: 'Vocalista y bailarín de BTS. Es reconocido por su estilo de baile, su voz y sus interpretaciones en el escenario.'
    },
    v: {
        nombre: 'V',
        nombreReal: 'Kim Taehyung',
        descripcion: 'Vocalista de BTS. Es conocido por su voz profunda, su interés por la fotografía, el arte y diferentes disciplinas creativas.'
    },
    jungkook: {
        nombre: 'Jung Kook',
        nombreReal: 'Jeon Jungkook',
        descripcion: 'Vocalista y bailarín de BTS. Es conocido por sus habilidades en diferentes áreas artísticas y por su participación en numerosos proyectos musicales.'
    }
};

tarjetas.forEach(function(tarjeta) {
    tarjeta.addEventListener('click', function() {
        const integrante = tarjeta.dataset.integrante;
        mostrarInformacion(integrante);
    });
});

function mostrarInformacion(integrante) {
    const datos = informacion[integrante];

    document.getElementById('nombre-integrante').textContent = datos.nombre;
    document.getElementById('nombre-real').textContent = datos.nombreReal;
    document.getElementById('descripcion-integrante').textContent = datos.descripcion;

    document.getElementById('informacion-integrante').classList.add('mostrar');
}

const cerrar = document.getElementById('cerrar-info');

cerrar.addEventListener('click', function() {
    document.getElementById('informacion-integrante').classList.remove('mostrar');
});