<script setup>
import { ref, onMounted } from 'vue';
import Equipos from "../equipos/Equipos.vue";
import CrearEquipos from "../equipos/CrearEquipos.vue";
import Ruleta from "../ruleta/Ruleta2Aleatoria.vue";
import Ruleta3 from '../ruleta/Ruleta3.vue';
import Historial from "../historial/Historial.vue";
import SubirIncidencias from "../incidencias/SubirIncidencias.vue";

const API_URL = import.meta.env.PUBLIC_API_URL;

// Props
const props = defineProps({
	id: {
		type: String,
		required: true
	}
});

// Variables
const incidencias = ref([]);
const categorias = ref([]);
const subcategorias = ref([]);
const equipos = ref([]);
const alumnosdelequipo = ref([]);

const equipo_seleccionado = ref(null);
const categoria_seleccionada = ref(null);
const subcategoria_seleccionada = ref(null);

const contenido_ruleta = ref([]);
const hay_subcategoria = ref(false);
const comentario = ref('');

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
			throw new Error(`Error en la respuesta del servidor: ${response.statusText}`);
		}
		const data = await response.json();
		incidencias.value = data;
		categorias.value = [...new Set(data.map(i => i.categoria))];
		subcategorias.value = data.map(i => i.subcategoria);
		contenido_ruleta.value = categorias.value;		
	} catch (err) {
		console.error("Error fetching incidencias:", err);
	}
};

// Obtener equipos
const getEquipos = async () => {
	try {
		const response = await fetch(`${API_URL}/api/instancias/${props.id}`, {
			method: "GET",
			headers: {
				"Content-Type": "application/json",
			},
		});
		if (!response.ok) {
			console.error("Status:", response.status);
			throw new Error(`Error en la respuesta del servidor: ${response.statusText}`);
		}
		const data = await response.json();
		equipos.value = data;
	} catch (err) {
		console.error("Error fetching equipos:", err);
	}
};

// Obtener alumnos
const getAlumnos = async (id_equipo) => {
	try {
		const response = await fetch(`${API_URL}/api/grupos/${id_equipo}`, {
			method: "GET",
			headers: {
				"Content-Type": "application/json",
			},
		});
		if (!response.ok) {
			console.error("Status:", response.status);
			throw new Error(`Error en la respuesta del servidor: ${response.statusText}`);
		}
		const data = await response.json();
		alumnosdelequipo.value = data;
	} catch (err) {
		console.error("Error fetching alumnos:", err);
	}
};

// Obtener subcategorías
function getSubcategorias(categoria) {
	return incidencias.value
		.filter(i => i.categoria === categoria)
		.map(i => i.subcategoria);
};

// Cargar equipos a la ruleta
function cargarEquipos() {
	contenido_ruleta.value = equipos.value.map(equipo => equipo.nombre);
};

// Cargar alumnos del equipo
async function cargarAlumnosequipo() {
	try {
		await getAlumnos(equipo_seleccionado.value);
		contenido_ruleta.value = alumnosdelequipo.value.map(alumno => alumno.nombre);
	} catch (error) {
		console.error("Error al cargar alumnos del equipo:", error);
	}
}

// Actualizar equipo desde componente hijo
const actualizar_equipo = (resultado) => {
	equipo_seleccionado.value = resultado;
}

// Actualizar ruleta según resultado
const actualizarRuleta = (resultado) => {
	if (categorias.value.includes(resultado)) {
		categoria_seleccionada.value = resultado;
		contenido_ruleta.value = getSubcategorias(resultado);
	} else {
		subcategoria_seleccionada.value = resultado;
		console.log("Categoria seleccionada:", categoria_seleccionada.value);
		hay_subcategoria.value = true;
	}
}

// Al montar el componente
onMounted(() => {
	getIncidencias();
	getEquipos();
});
</script>

<template>
	<div class="flex md:flex-row md:justify-between md:items-start md:overflow-clip flex-col justify-start items-center w-full h-full overflow-y-scroll">
		<!-- Lado Izquierdo -->
		<div class="w-full md:basis-1/4 grow h-full p-4">
			<div class="flex flex-wrap justify-start items-center w-full gap-2 mb-4">
				<CrearEquipos :id="id" />
				<Historial :id="id" />
			</div>
			<Equipos :id="id" :equipos="equipos" @equipo_seleccionado="actualizar_equipo" />
		</div>

		<!-- Lado Central -->
		<div class="w-full md:basis-2/4 grow h-full">
			<Ruleta3 :items="contenido_ruleta" @result="actualizarRuleta" />
		</div>

		<!-- Lado Derecho -->
		<div class="w-full md:basis-1/4 grow h-full p-4">
			<div class="flex flex-wrap justify-center md:justify-end items-center w-full gap-2 mb-4">
				<button
					class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button" @click="cargarAlumnosequipo" :disabled="!hay_subcategoria">
					Girar Alumnos
				</button>
				<button
					class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button" @click="cargarEquipos" :disabled="!hay_subcategoria">
					Girar Equipos
				</button>
			</div>

			<!-- Resumen de la Ejecución -->
			<section class="flex flex-col w-full p-4 gap-2 bg-zinc-900 rounded-md border border-zinc-700 shadow-md">
				<h2 class="text-lg font-bold text-white">Resumen de la Ejecución:</h2>
				<div class="flex flex-col w-full gap-1 text-white">
					<p><strong class="font-semibold">Categoría:</strong> {{ categoria_seleccionada }}</p>
					<p><strong class="font-semibold">Subcategoría:</strong> {{ subcategoria_seleccionada }}</p>
				</div>

				<!-- Textarea de Comentario -->
				<div class="mt-4">
					<label for="comentario" class="block text-sm font-medium text-white mb-1">Comentario:</label>
					<textarea
						id="comentario"
						v-model="comentario"
						placeholder="Escribe tu comentario aquí..."
						rows="4"
						class="w-full p-2 rounded-md border border-zinc-600 bg-zinc-800 text-white resize-none shadow-inner"
					></textarea>
				</div>

				<!-- Botón Finalizar -->
				<button
					class="mt-4 bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button"
					:disabled="!hay_subcategoria"
					@click="console.log('Comentario:', comentario)"
				>
					Finalizar Ejecución
				</button>
			</section>
		</div>
	</div>
</template>
