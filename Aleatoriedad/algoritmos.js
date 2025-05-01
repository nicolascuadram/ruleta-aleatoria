/* Nativo
Es el generador pseudoaleatorio integrado en JS, ntrega un número entre [0 y 1[
Ventajas:
    Fácil de implementar.
Desventajas:
    No puedes controlar la semilla, no puedes reproducir resultados
    No es adecuado para criptografía ni simulaciones serias.
*/
function nativeRandom(min, max){
    return Math.floor(min + Math.random() * (max - min + 1));
}

//LCG
/*
Usa una fórmula simple:
Xₙ₊₁ = (a * Xₙ + c) mod m
a, c, m son constantes, y Xₙ es el número anterior. Necesita una semilla inicial para comenzar la recursión

Ventajas:
    Fácil de implementar.
    Permite reproducir secuencias si conoces la semilla.
Desventajas:
    Ciclos relativamente cortos, se repite antes de llegar a cubrir todos los posibles números.
    Puede mostrar patrones.
    No es adecuado para criptografía ni simulaciones serias.
*/
function createLCG(seed) {
    let m = 2 ** 31;
    let a = 1103515245;
    let c = 12345;

    return function(min, max) {
        seed = (a * seed + c) % m;
        let nseed = seed / m;
        return Math.floor(min + nseed * (max - min + 1));
    };
}


//XOR shift
/*
Aplica XOR y desplazamientos de bits sobre el valor actual.

Ventajas:
    Muy rápido, ideal para juegos y gráficos.
    Mejor calidad de aleatoriedad que LCG..
Desventajas:
    Necesita buen manejo de la semilla inicial.
    No es criptográficamente seguro.
*/
function createXorshift(seed) {
    return function(min, max) {
        seed ^= seed << 13;
        seed ^= seed >>> 17;
        seed ^= seed << 5;
        const normalized = (seed >>> 0) / 2 ** 32;
        return Math.floor(min + normalized * (max - min + 1));
    };
}
//Mulberry32
/*mezcla la semilla usando multiplicaciones, sumas y desplazamientos de bits

Ventajas:
    Muy rápido.
    Produce secuencias de alta calidad para simulaciones y juegos.
    Tiene un período largo antes de repetirse.

Desventajas:
    No es criptográficamente seguro.
*/
function createMulberry32(seed) {
    return function(min, max) {
        let t = seed += 0x6D2B79F5;
        t = Math.imul(t ^ (t >>> 15), t | 1);
        t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
        const result = ((t ^ (t >>> 14)) >>> 0) / 4294967296;
        return Math.floor(min + result * (max - min + 1));
    };
}



module.exports = {
    nativeRandom,
    createLCG,
    createXorshift,
    createMulberry32
}