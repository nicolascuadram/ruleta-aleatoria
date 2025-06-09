<script setup>
import { ref, onMounted } from 'vue'
const API_URL = import.meta.env.PUBLIC_API_URL;

// Props y Emits
const emit = defineEmits(['update:roulette_content']);

const updateRouletteContent = (roulette_content) => {
    emit('update:roulette_content', roulette_content);
};

// Variables
const incidencias = ref([]);
const categorias = ref([]);
const integrantes = ref([]);
// Obtener Lista de incidencias
const getIncidencias = async () => {
    try {
        const response = await fetch(`${API_URL}/api/incidencias/`, {
            method: "GET",
            headers: {
                "Content-Type": "application/json",
            },
        });
        if (!response.ok) {
            console.error("Status:", response.status);
            throw new Error(
                `Error en la respuesta del servidor: ${response.statusText}`
            );
        };
        const data = await response.json();
        incidencias.value = data;
		categorias.value = [...new Set(data.map(i => i.categoria))];
		updateRouletteContent(categorias.value);
    } catch (err) {
        console.error("Error fetching incidencias:", err);
    }
};

// Función para obtener las subcategorías de una categoría
function getSubcategorias(categoria) {
	return incidencias.value.filter(i => i.categoria === categoria);
};

function getIntegrantes(grupo) {
	// Filtrar los integrantes del grupo seleccionado
	return integrantes.value.filter(i => i.grupo === grupo);
};


// Algoritmo Xorshift
function xorshift() {
	const seed = ref(Date.now());
	const min = 1;
	const max = 1000;
	let x = seed.value >>> 0
	x ^= x << 13
	x ^= x >> 17
	x ^= x << 5
	const normalized = (x >>> 0) / 2 ** 32;
	return Math.floor(min + normalized * (max - min + 1));
};

const categoriaSeleccionada = ref(null);
const incidenciaSeleccionada = ref(null);
const alumnoSeleccionado = ref(null);
// Función para generar categoría e incidencia aleatoria
function generarIncidenciaAleatoria() {
	// Elegir categoría aleatoria
	const indiceCategoria = xorshift() % categorias.value.length;
	categoriaSeleccionada.value = categorias.value[indiceCategoria];

	// Filtrar incidencias por categoría
	const incidenciasPorCategoria = getSubcategorias(categoriaSeleccionada.value);
	
	// Elegir una incidencia aleatoria dentro de esa categoría
	const indiceIncidencia = xorshift() % incidenciasPorCategoria.length;
	incidenciaSeleccionada.value = incidenciasPorCategoria[indiceIncidencia];

	// Obtener los integrantes del grupo seleccionado
	const integrantesDelGrupo = getIntegrantes(grupoSeleccionado.value)

	// Elegir un integrante aleatorio
    const alumnoSeleccionado = xorshift() % integrantesDelGrupo.length;
	alumnoSeleccionado.value = integrantesDelGrupo[alumnoSeleccionado];

};

onMounted(() => {
	getIncidencias();
});
</script>

<template>
	<section class="flex flex-col justify-center items-center w-full h-full gap-2 text-center">
		<button
			class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap"
			@click="generarIncidenciaAleatoria">
			Generar Incidencia
		</button>

		<div v-if="incidenciaSeleccionada">
			<p class="font-semibold text-lg">Categoría: {{ categoriaSeleccionada }}</p>
			<p class="text-zinc-700">Subcategoría: {{ incidenciaSeleccionada.subcategoria }}</p>
		</div>
	</section>
</template>