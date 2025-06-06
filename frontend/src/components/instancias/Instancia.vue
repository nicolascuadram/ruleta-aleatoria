<script setup>
import { ref, onMounted } from 'vue';
import Equipos from "../equipos/Equipos.vue";
import CrearEquipos from "../equipos/CrearEquipos.vue";
import Ruleta from "../ruleta/Ruleta2Aleatoria.vue";
import Historial from "../historial/Historial.vue";
import SubirIncidencias from "../incidencias/SubirIncidencias.vue";
import Ejecucion from '../Ejecucion.vue';
const API_URL = import.meta.env.PUBLIC_API_URL;

// Props
const props = defineProps({
	id: {
		type: String,
		required: true
	}
});

const emit = defineEmits(['update:girar_ruleta']);

// Este evento se debe ejecutar cuando el usuario quiera girar la ruleta clickeando el botón.
// El componente de la ruleta debe recibir este evento y hacer la animación.
// Al finalizar la animación el componente de la ruleta debe crear otro evento como este para actualizarla.
const girarRuleta = () => {
	emit('update:girar_ruleta', contenido_ruleta.value, generarResultado(contenido_ruleta.value));
};

// Actualizar contenido de la ruleta.
// Comprobar si el resultado recibido es una categoria, o una subcategoria, u otro resultado.
//   Si es categoria entonces el contenido de la ruleta será la lista de subcategorias asociadas a la categoria.
//   Si es subcategoria mostrar opciones para finalizar ejecución, o girar ruletas extras con alumnos del equipo
//   o nombres de otros equipos, registrar resultados.
// Se debe crear otro selector de equipos para saber si se deben girar los alumnos de este u otro equipo.
const categoria_seleccionada = ref(null);
const subcategoria_seleccionada = ref(null);

const actualizarRuleta = (res) => {
	if (categorias.value.includes(res)) {
		contenido_ruleta.value = getSubcategorias(res);
		contenido_boton.value = "Seleccionar Subcategoría";
	} else {
		// Mostrar botón para:
		// 1. Finalizar ejecución
		// 2. Girar ruleta de alumnos de un equipo (seleccionar equipo)
		// 3. Girar ruleta de equipos
	}
}

// Variables
const incidencias = ref([]);
const categorias = ref([]);
const subcategorias = ref([]);
const equipo_seleccionado = ref(null);
const contenido_ruleta = ref([]);
const resultado_ruleta = ref(null);
const contenido_boton = ref(null);

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
		subcategorias.value = data.map(i => i.subcategoria);
		contenido_ruleta.value = categorias.value;
		contenido_boton.value = "Seleccionar Categoría";
		console.log(`Categorias: ${categorias.value}`);
		console.log(`Subcategorias: ${subcategorias.value}`);
		console.log(`Contenido Ruleta: ${contenido_ruleta.value}`);
	} catch (err) {
		console.error("Error fetching incidencias:", err);
	}
};

// Función para obtener las subcategorías de una categoría
function getSubcategorias(categoria) {
	return incidencias.value.filter(i => i.categoria === categoria);
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

// Función para generar un resultado aleatorio para la ruleta
function generarResultado(opciones) {
	const indice_resultado = xorshift() % opciones.value.length;
	return opciones.value[indice_resultado];
};

onMounted(() => {
	getIncidencias();
});
</script>

<template>
	<div class="flex justify-between items-start w-full h-full">
		<!-- Lado Izquierdo -->
		<div class="basis-1/4 grow h-full">
			<!-- Opciones de la Instancia -->
			<div class="flex flex-wrap justify-start items-center w-full p-4 gap-2">
				<CrearEquipos :id="id" />
				<Historial :id="id" />
			</div>
			<!-- Lista de Equipos de la Instancia -->
			<Equipos :id="id" />
		</div>
		<!-- Lado Central -->
		<div class="basis-2/4 grow h-full">
			<!-- Componente Visual Ruleta -->
			<Ruleta :id="id" />
			<!-- <Ruleta :contenido="contenido_ruleta" :resultado="resultado_ruleta" /> -->
			<!-- Botón Girar Ruleta -->
			<button
				class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap"
				v-if="contenido_ruleta" @click="girarRuleta">
				Girar Ruleta
			</button>
		</div>
		<!-- Lado Derecho -->
		<div class="basis-1/4 grow h-full">
			<!-- <div class="flex flex-wrap justify-start items-center w-full p-4 gap-2">
				<SubirIncidencias :id="id" /> <-- Mover al Navbar y hacerlo Global
			</div> -->
			<!-- Resumen de la Ejecución -->
			
		</div>
	</div>
</template>
