let datos = {};
let productos = [];
let usuarios = [];
let calificaciones = [];
let intervaloCarrusel = null;

fetch("data/data.json")
    .then(response => {
        if (!response.ok) throw new Error("No se pudo cargar el JSON");
        return response.json();
    })
    .then(data => {
        datos = data;
        productos = data.productos || [];
        usuarios = data.usuarios || [];
        calificaciones = data.calificaciones || [];

        mostrarProductos();
        iniciarCarruselAuto();
    })
    .catch(error => console.error("Error al cargar datos:", error));

function mostrarProductos() {
    const contenedor = document.getElementById("contenedor-productos");
    if (!contenedor) return;

    contenedor.innerHTML = "";

    productos.forEach(producto => {
        const tarjeta = document.createElement("article");
        tarjeta.classList.add("tarjeta-producto");

        tarjeta.innerHTML = `
            <div class="tarjeta-imagen-container">
                <img src="${producto.foto}" alt="${producto.nombre}">
                <span class="insignia-estrellas">★★★★★</span>
            </div>
            <div class="informacion-producto">
                <h3>${producto.nombre}</h3>
                <button class="btn-comentarios" onclick="verComentarios(${producto.id})">
                    Comentarios
                </button>
            </div>
        `;

        contenedor.appendChild(tarjeta);
    });
}

// Mover el carrusel
function moverCarruselSiguiente() {
    const contenedor = document.getElementById("contenedor-productos");
    if (!contenedor) return;

    const maxScroll = contenedor.scrollWidth - contenedor.clientWidth;
    
    if (contenedor.scrollLeft >= maxScroll - 5) {
        contenedor.scrollLeft = 0;
    } else {
        contenedor.scrollLeft += 280;
    }
}

function iniciarCarruselAuto() {
    if (!intervaloCarrusel) {
        intervaloCarrusel = setInterval(moverCarruselSiguiente, 2000);
    }
}

function detenerCarruselAuto() {
    clearInterval(intervaloCarrusel);
    intervaloCarrusel = null;
}

function verComentarios(idProducto) {
    detenerCarruselAuto();

    const producto = productos.find(p => p.id === idProducto);
    const opinionesFiltradas = calificaciones.filter(c => c.id_producto === idProducto);

    const modal = document.getElementById("modal-comentarios");
    const titulo = document.getElementById("modal-titulo-producto");
    const contenedorLista = document.getElementById("modal-lista-comentarios");

    if (!modal || !producto) return;

    titulo.textContent = `Comentarios: ${producto.nombre}`;
    contenedorLista.innerHTML = "";

    if (opinionesFiltradas.length === 0) {
        contenedorLista.innerHTML = "<p>Aún no hay comentarios para este producto.</p>";
    } else {
        opinionesFiltradas.forEach(calificacion => {
            const usuario = usuarios.find(u => u.id === calificacion.id_usuario);
            const nombreUsuario = usuario ? usuario.nombre : "Usuario";
            const fotoUsuario = usuario ? usuario.foto : "img/iconos/usuario.png";

            const div = document.createElement("div");
            div.classList.add("comentario-item");
            div.innerHTML = `
                <div class="comentario-header">
                    <img src="${fotoUsuario}" alt="${nombreUsuario}">
                    <div>
                        <strong>${nombreUsuario}</strong>
                        <div class="comentario-estrellas">${"★".repeat(calificacion.calificacion)}${"☆".repeat(5 - calificacion.calificacion)}</div>
                    </div>
                </div>
                <p>"${calificacion.comentario}"</p>
            `;
            contenedorLista.appendChild(div);
        });
    }

    modal.classList.add("activo");
}

function cerrarModal() {
    const modal = document.getElementById("modal-comentarios");
    if (modal) {
        modal.classList.remove("activo");
        iniciarCarruselAuto();
    }
}

document.getElementById("btn-cerrar-modal")?.addEventListener("click", cerrarModal);

window.addEventListener("click", (e) => {
    const modal = document.getElementById("modal-comentarios");
    if (e.target === modal) {
        cerrarModal();
    }
});

// Controles manuales
document.getElementById("siguiente")?.addEventListener("click", () => {
    moverCarruselSiguiente();
});

document.getElementById("anterior")?.addEventListener("click", () => {
    const contenedor = document.getElementById("contenedor-productos");
    if (contenedor) contenedor.scrollLeft -= 280;
});