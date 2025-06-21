<script setup>
import { ref, computed, watch } from 'vue'
import QuitarItem from './QuitarItem.vue'

// Props
const props = defineProps({
    canSpin: {
        type: Boolean,
        required: true,
    },
    items: {
        type: Array,
        required: true,
        validator: (items) => items.length > 0
    }
})

// Emits
const emit = defineEmits(['result'])

// Reactive data
const rotation = ref(0)
const isSpinning = ref(false)
const result = ref(null)
const wheel = ref(null)
const actualContent = ref([]);
const allContent = ref([]);

const colors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4',
    '#FECA57', '#FF9FF3', '#54A0FF', '#5F27CD',
    '#00D2D3', '#FF9F43', '#10AC84', '#EE5A24'
]

// Computed
const segmentAngle = computed(() => {
    return 360 / actualContent.value.length
})

// Methods
const getSegmentPath = (index) => {
    const centerX = 150
    const centerY = 150
    const radius = 140
    const angle = segmentAngle.value
    const startAngle = (angle * index - 90) * Math.PI / 180
    const endAngle = (angle * (index + 1) - 90) * Math.PI / 180

    const x1 = centerX + radius * Math.cos(startAngle)
    const y1 = centerY + radius * Math.sin(startAngle)
    const x2 = centerX + radius * Math.cos(endAngle)
    const y2 = centerY + radius * Math.sin(endAngle)

    const largeArcFlag = angle > 180 ? 1 : 0

    return `M ${centerX} ${centerY} L ${x1} ${y1} A ${radius} ${radius} 0 ${largeArcFlag} 1 ${x2} ${y2} Z`
}

const getTextPosition = (index) => {
    const centerX = 150
    const centerY = 150
    const radius = 90 // Posición del texto más cerca del centro
    const angle = segmentAngle.value
    const midAngle = (angle * index + angle / 2 - 90) * Math.PI / 180

    return {
        x: centerX + radius * Math.cos(midAngle),
        y: centerY + radius * Math.sin(midAngle)
    }
}

const getTextTransform = (index) => {
    const angle = segmentAngle.value
    const midAngle = angle * index + angle / 2

    // Rotar el texto para que sea legible
    let rotation = midAngle
    if (rotation > 90 && rotation < 270) {
        rotation += 180 // Voltear el texto si está al revés
    }

    const pos = getTextPosition(index)
    return `rotate(${rotation} ${pos.x} ${pos.y})`
}

// Función para dividir texto en líneas
const wrapText = (text, maxCharsPerLine = 12) => {
    const words = text.split(' ')
    const lines = []
    let currentLine = ''

    for (const word of words) {
        if ((currentLine + word).length <= maxCharsPerLine) {
            currentLine += (currentLine ? ' ' : '') + word
        } else {
            if (currentLine) {
                lines.push(currentLine)
                currentLine = word
            } else {
                // Si una palabra es muy larga, la dividimos
                lines.push(word.substring(0, maxCharsPerLine))
                currentLine = word.substring(maxCharsPerLine)
            }
        }
    }

    if (currentLine) {
        lines.push(currentLine)
    }

    return lines.slice(0, 3) // Máximo 3 líneas
}

// Función para calcular el tamaño de fuente apropiado
const getFontSize = (text, segmentAngleValue) => {
    const baseSize = 14
    const textLength = text.length
    const angleRatio = segmentAngleValue / 60 // Normalizar basado en 60 grados como referencia

    let fontSize = baseSize * angleRatio

    // Ajustar basado en la longitud del texto
    if (textLength > 15) {
        fontSize *= 0.7
    } else if (textLength > 10) {
        fontSize *= 0.85
    }

    // Límites mínimos y máximos
    return Math.max(8, Math.min(fontSize, 16))
}

let xorshiftSeed = Date.now() >>> 0;

function xorshift(min = 0, max = 1) {
    let x = xorshiftSeed;
    x ^= x << 13;
    x ^= x >>> 17;
    x ^= x << 5;
    xorshiftSeed = x >>> 0;
    const normalized = xorshiftSeed / 2 ** 32;
    return min + normalized * (max - min);
}

const spin = () => {
    if (isSpinning.value) return

    isSpinning.value = true
    result.value = null

    // Generar rotación aleatoria (múltiples vueltas + ángulo final)
    const minSpins = 5
    const maxSpins = 8
    const spins = xorshift(minSpins, maxSpins)
    const finalAngle = xorshift(0, 360)
    const totalRotation = rotation.value + (spins * 360) + finalAngle

    rotation.value = totalRotation

    // Calcular el resultado basado en el ángulo final
    setTimeout(() => {
        const normalizedAngle = (360 - (totalRotation % 360)) % 360
        const segmentIndex = Math.floor(normalizedAngle / segmentAngle.value)
        const resultIndex = segmentIndex >= actualContent.value.length ? 0 : segmentIndex

        result.value = actualContent.value[resultIndex].name
        isSpinning.value = false

        // Emitir el resultado al componente padre
        emit('result', result.value)
    }, 5000)
}

const showModalRemove = ref(false);

const updateContent = (new_content) => {
    actualContent.value = new_content;
};

const toggleModalRemove = () => {
    showModalRemove.value = !showModalRemove.value;
};

watch(() => props.items, () => {
    actualContent.value = props.items.map(item => ({
        name: item,
        active: true
    }));
    allContent.value = props.items.map(item => ({
        name: item,
        active: true
    }));
});
</script>

<template>
    <div class="roulette-container">
        <div class="roulette-wrapper">
            <!-- Indicador/Flecha -->
            <div class="roulette-pointer"></div>

            <!-- Ruleta -->
            <svg class="roulette-wheel" :style="{ transform: `rotate(${rotation}deg)` }" ref="wheel" width="300"
                height="300" viewBox="0 0 300 300">
                <g v-for="(item, index) in actualContent" :key="index">
                    <path :d="getSegmentPath(index)" :fill="colors[index % colors.length]" stroke="#fff"
                        stroke-width="2" />

                    <!-- Texto con wrapping -->
                    <g :transform="getTextTransform(index)">
                        <text v-for="(line, lineIndex) in wrapText(item.name)" :key="lineIndex" :x="getTextPosition(index).x"
                            :y="getTextPosition(index).y + (lineIndex - (wrapText(item.name).length - 1) / 2) * (getFontSize(item.name, segmentAngle) * 1.2)"
                            fill="white" font-family="Arial, sans-serif" :font-size="getFontSize(item.name, segmentAngle)"
                            font-weight="bold" text-anchor="middle" dominant-baseline="middle"
                            style="text-shadow: 1px 1px 2px rgba(0,0,0,0.8);">
                            {{ line }}
                        </text>
                    </g>
                </g>
            </svg>
        </div>

        <!-- Controles -->
        <div class="controls">
            <button @click="spin" :disabled="isSpinning || !canSpin" class="spin-button">
                {{ isSpinning ? 'Girando...' : 'Girar Ruleta' }}
            </button>
            <button @click="toggleModalRemove" :disabled="isSpinning" class="spin-button remove-button">
                Quitar Items
            </button>
        </div>

        <!-- Modal -->
        <QuitarItem :items="allContent" :isModalOpen="showModalRemove" @close-modal="toggleModalRemove" @update:content="updateContent"/>
        
        <!-- Resultado -->
        <!-- <div v-if="result" class="result">
            <h3>¡Resultado!</h3>
            <p class="result-text">{{ result }}</p>
        </div> -->
    </div>
</template>

<style scoped>
.roulette-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 20px;
    width: 100%;
}

.roulette-wrapper {
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    align-items: center;
}

.roulette-wheel {
    width: 400px;
    height: 400px;
    border-radius: 50%;
    position: relative;
    border: 4px solid #fafafa;
    transition: transform 5s cubic-bezier(0.17, 0.67, 0.12, 0.99);
    overflow: hidden;
}

.roulette-pointer {
    position: absolute;
    top: -10px;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 0;
    border-left: 15px solid transparent;
    border-right: 15px solid transparent;
    border-top: 25px solid #fafafa;
    z-index: 10;
}

.controls {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    margin: 20px 0;
    width: 100%;
}

.spin-button {
    background-color: #fafafa;
    color: #18181b;
    border: none;
    padding: 8px 16px;
    font-size: 16px;
    font-weight: 500;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.spin-button:hover:not(:disabled) {
    background-color: #d4d4d8;
}

.spin-button:disabled {
    opacity: 0.7;
    cursor: not-allowed;
    transform: none;
}

.remove-button:disabled {
    display: none;
}

.result {
    text-align: center;
    margin-top: 20px;
    padding: 20px;
    background: linear-gradient(45deg, #f093fb 0%, #f5576c 100%);
    border-radius: 15px;
    color: white;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.result h3 {
    margin-top: 0;
    margin-bottom: 10px;
    font-size: 24px;
}

.result-text {
    font-size: 20px;
    font-weight: bold;
    margin: 0;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
}

/* Responsive */
@media (max-width: 768px) {
    .roulette-wheel {
        width: 300px;
        height: 300px;
    }

    .spin-button {
        padding: 10px 20px;
    }
}
</style>