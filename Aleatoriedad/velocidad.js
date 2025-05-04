// Nativo
function nativeRandom(min, max) {
    return Math.floor(min + Math.random() * (max - min + 1));
}

// Xorshift
function xorshift(min, max, seed) {
    seed ^= seed << 13;
    seed ^= seed >> 17;
    seed ^= seed << 5;
    const normalized = (seed >>> 0) / 2 ** 32;
    return Math.floor(min + normalized * (max - min + 1));
}

// Mulberry32
function mulberry32(min, max, seed) {
    let t = seed += 0x6D2B79F5;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    const result = ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    return Math.floor(min + result * (max - min + 1));
}

function measureTime(algorithm, min, max, iterations, seed) {
    const start = performance.now();
    let currentSeed = seed;
    for (let i = 0; i < iterations; i++) {
        algorithm(min, max, currentSeed);  
        currentSeed = (currentSeed + 1) % 2**32;  
    }
    const end = performance.now();
    return end - start;  
}

const iterations = 1_000_000_000;  // de iteraciones
const min = 1;
const max = 1000;
const seed = 12345;  

console.log("Comparando tiempos de ejecución para 1000 millones de números aleatorios...");

const nativeTime = measureTime(nativeRandom, min, max, iterations, seed);
console.log(`Tiempo para el random nativo: ${nativeTime.toFixed(2)} ms`);

const xorshiftTime = measureTime(xorshift, min, max, iterations, seed);
console.log(`Tiempo para xorshift: ${xorshiftTime.toFixed(2)} ms`);

const mulberryTime = measureTime(mulberry32, min, max, iterations, seed);
console.log(`Tiempo para mulberry32: ${mulberryTime.toFixed(2)} ms`);