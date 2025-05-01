const random =  require('./algoritmos.js')
const fs = require('fs');

function analyzeGenerator(fn, name, min, max, iterations = 10000) {
    const counts = Array(max - min + 1).fill(0);
    let last = null;
    let repeatCount = 0;
    let totalRepeats = 0;
    let sumProduct = 0;
    let sumPrev = 0;
    let sumCurr = 0;
    let sumPrevSq = 0;
    let sumCurrSq = 0;
    let pairs = 0;

    for (let i = 0; i < iterations; i++) {
        const val = fn(min, max);
        counts[val - min]++;

        if (val === last) {
            repeatCount++;
        } else {
            totalRepeats += repeatCount;
            repeatCount = 0;
        }

        if (last !== null) {
            sumProduct += last * val;
            sumPrev += last;
            sumCurr += val;
            sumPrevSq += last * last;
            sumCurrSq += val * val;
            pairs++;
        }

        last = val;
    }

    // coesficiente de pearson
    const numerator = pairs * sumProduct - sumPrev * sumCurr;
    const denominator = Math.sqrt((pairs * sumPrevSq - sumPrev ** 2) * (pairs * sumCurrSq - sumCurr ** 2));
    const correlation = denominator !== 0 ? numerator / denominator : 0;

    return {
        counts,
        totalRepeats,
        correlation
    };
}

function runAnalysis() {
    //const sizes = [5, 10, 15, 20, 38];
    //probamos con los tamños del 1 al 38
    const sizes = Array.from({ length: 38 - 2 + 1 }, (_, i) => i + 2);
    let iterations = 10000000
    //crear algoritmos
    lcg = random.createLCG(123456789)
    xs = random.createXorshift(123456789)
    mb32 = random.createMulberry32(123456789)
    const generators = [
        { name: 'nativeRandom', fn: random.nativeRandom },
        { name: 'lcg', fn: lcg },
        { name: 'xorshift', fn: xs},
        { name: 'mulberry32', fn: mb32}
    ];

    let csv = 'roulette_size,generator,number,repeats,correlation,counts\n';

    for (const size of sizes) {
        for (const gen of generators) {
            const res = analyzeGenerator(gen.fn, gen.name, 1, size, iterations);
            csv += `${size},${gen.name},,${res.totalRepeats},${res.correlation.toFixed(4)},\n`;
            res.counts.forEach((count, idx) => {
                csv += `${size},${gen.name},${idx + 1},,,${count}\n`;
            });
        }
    }
    let filename = 'results'+ iterations +'.csv'
    fs.writeFileSync(filename, csv, 'utf8');
    console.log('Resultados guardados en', filename);
}

runAnalysis();