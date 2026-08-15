document.addEventListener("DOMContentLoaded", () => {
    
    const COSTO_DOMICILIO = 8500; 

    const bannerLogin = document.getElementById("banner-login");
    const radiosEntrega = document.querySelectorAll('input[name="tipoEntrega"]');
    const campoDireccion = document.getElementById("campo-direccion");
    const inputDireccion = document.getElementById("direccion");
    
    const inputNombre = document.getElementById("nombre");
    const inputEmail = document.getElementById("email");
    const inputTelefono = document.getElementById("telefono");
    
    const subtotalArepasElem = document.getElementById("subtotal-arepas");
    const costoDomicilioElem = document.getElementById("costo-domicilio");
    const totalPagarElem = document.getElementById("total-pagar");
    
    const formCheckout = document.getElementById("form-checkout");

    const radiosPago = document.querySelectorAll('input[name="metodoPago"]');
    const detallesNequi = document.getElementById("detalles-nequi");
    const detallesTarjeta = document.getElementById("detalles-tarjeta");

    const inputNequiNum = document.getElementById("numero-nequi");
    const inputNequiComp = document.getElementById("comprobante-nequi");
    const inputTarjNum = document.getElementById("numero-tarjeta");
    const inputTarjExp = document.getElementById("expiracion-tarjeta");
    const inputTarjCvv = document.getElementById("cvv-tarjeta");
    const inputTarjNom = document.getElementById("nombre-tarjeta");

    const carrito = JSON.parse(localStorage.getItem("carrito_arepas")) || [];
    const subtotalProductos = carrito.reduce((acc, p) => acc + (p.precio * p.cantidad), 0);

    function actualizarTotal() {
        const tipoEntrega = document.querySelector('input[name="tipoEntrega"]:checked').value;
        const valorDomicilio = (tipoEntrega === "llevar") ? COSTO_DOMICILIO : 0;
        const totalFinal = subtotalProductos + valorDomicilio;

        if (subtotalArepasElem) {
            subtotalArepasElem.textContent = `$${subtotalProductos.toLocaleString()}`;
        }

        if (costoDomicilioElem) {
            if (tipoEntrega === "recoger") {
                costoDomicilioElem.textContent = "Gratis";
            } else {
                costoDomicilioElem.textContent = `$${valorDomicilio.toLocaleString()}`;
            }
        }

        if (totalPagarElem) {
            totalPagarElem.textContent = `$${totalFinal.toLocaleString()}`;
        }

        return {
            subtotal: subtotalProductos,
            domicilio: valorDomicilio,
            total: totalFinal
        };
    }

    const usuarioActivo = JSON.parse(localStorage.getItem("usuario_activo"));

    if (usuarioActivo) {
        if (bannerLogin) bannerLogin.style.display = "none";

        inputNombre.value = usuarioActivo.nombre || "";
        inputEmail.value = usuarioActivo.email || "";
        inputTelefono.value = usuarioActivo.telefono || "";
        
        if (usuarioActivo.direccion && inputDireccion) {
            inputDireccion.value = usuarioActivo.direccion;
        }
    }

    function gestionarCampoDireccion() {
        const opcionSeleccionada = document.querySelector('input[name="tipoEntrega"]:checked').value;

        if (opcionSeleccionada === "recoger") {
            campoDireccion.style.display = "none";
            inputDireccion.removeAttribute("required"); 
            inputDireccion.value = ""; 
        } else {
            campoDireccion.style.display = "block";
            inputDireccion.setAttribute("required", "true"); 
            
            if (usuarioActivo && usuarioActivo.direccion) {
                inputDireccion.value = usuarioActivo.direccion;
            }
        }

        actualizarTotal();
    }

    radiosEntrega.forEach(radio => {
        radio.addEventListener("change", gestionarCampoDireccion);
    });

    function gestionarCamposPago() {
        const metodo = document.querySelector('input[name="metodoPago"]:checked').value;

        if (detallesNequi) detallesNequi.style.display = "none";
        if (detallesTarjeta) detallesTarjeta.style.display = "none";

        [inputNequiNum, inputNequiComp, inputTarjNum, inputTarjExp, inputTarjCvv, inputTarjNom].forEach(input => {
            if (input) input.removeAttribute("required");
        });

        if (metodo === "nequi" && detallesNequi) {
            detallesNequi.style.display = "block";
            if (inputNequiNum) inputNequiNum.setAttribute("required", "true");
            if (inputNequiComp) inputNequiComp.setAttribute("required", "true");
        } else if (metodo === "tarjeta" && detallesTarjeta) {
            detallesTarjeta.style.display = "block";
            if (inputTarjNum) inputTarjNum.setAttribute("required", "true");
            if (inputTarjExp) inputTarjExp.setAttribute("required", "true");
            if (inputTarjCvv) inputTarjCvv.setAttribute("required", "true");
            if (inputTarjNom) inputTarjNom.setAttribute("required", "true");
        }
    }

    radiosPago.forEach(radio => {
        radio.addEventListener("change", gestionarCamposPago);
    });

    gestionarCampoDireccion();
    gestionarCamposPago();

    formCheckout.addEventListener("submit", (e) => {
        e.preventDefault();

        if (carrito.length === 0) {
            Swal.fire('Error', 'Tu carrito está vacío', 'error');
            return;
        }

        const totales = actualizarTotal();
        const tipoEntregaVal = document.querySelector('input[name="tipoEntrega"]:checked').value;

        const pedido = {
            cliente: {
                nombre: inputNombre.value,
                email: inputEmail.value,
                telefono: inputTelefono.value,
                direccion: tipoEntregaVal === "llevar" ? inputDireccion.value : "Recoge en tienda"
            },
            tipoEntrega: tipoEntregaVal,
            metodoPago: document.querySelector('input[name="metodoPago"]:checked').value,
            productos: carrito,
            subtotal: totales.subtotal,
            envio: totales.domicilio,
            total: totales.total,
            fecha: new Date().toLocaleString()
        };

        console.log("Pedido realizado con éxito:", pedido);

        Swal.fire({
            title: '¡Pedido Confirmado!',
            text: `Gracias por tu compra. Total abonado: $${totales.total.toLocaleString()}`,
            icon: 'success',
            confirmButtonText: 'Volver al Inicio',
            confirmButtonColor: '#27ae60'
        }).then(() => {
            localStorage.removeItem("carrito_arepas");
            window.location.href = "index.html";
        });
    });
});