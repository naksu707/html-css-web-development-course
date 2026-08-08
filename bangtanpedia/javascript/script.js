const ballena = document.querySelector('.ballena');

ballena.addEventListener('click', function () {
    document.querySelector('#sobre-bts').scrollIntoView({
        behavior: 'smooth'
    });
});