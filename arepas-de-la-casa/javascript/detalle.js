document.addEventListener("DOMContentLoaded", () => {

    const urlParams = new URLSearchParams(window.location.search);
    const productoId = parseInt(urlParams.get("id"));

    if (!productoId) {
        console.error("No se especificó ningún ID de producto.");
        return;
    }

    fetch("data/data.json")
        .then(res => res.json())
        .then(data => {
            const producto = data.productos.find(p => p.id === productoId);

            if (producto) {
                document.getElementById("detalle-imagen").src = producto.foto;
                document.getElementById("detalle-nombre").textContent = producto.nombre;
                document.getElementById("detalle-precio").textContent = `$${producto.precio.toLocaleString()}`;
                document.getElementById("detalle-descripcion").textContent = producto.descripcion;
            } else {
                console.error("Producto no encontrado.");
            }
        })
        .catch(err => console.error("Error al cargar la información del producto:", err));
});