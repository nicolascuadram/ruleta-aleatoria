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

/* const emit = defineEmits(['update:girar_ruleta']); */

// Este evento se debe ejecutar cuando el usuario quiera girar la ruleta clickeando el botón.
// El componente de la ruleta debe recibir este evento y hacer la animación.
// Al finalizar la animación el componente de la ruleta debe crear otro evento como este para actualizarla.
/* const girarRuleta = () => {
	emit('update:girar_ruleta', contenido_ruleta.value, generarResultado(contenido_ruleta.value));
}; */

// Actualizar contenido de la ruleta.
// Comprobar si el resultado recibido es una categoria, o una subcategoria, u otro resultado.
//   Si es categoria entonces el contenido de la ruleta será la lista de subcategorias asociadas a la categoria.
//   Si es subcategoria mostrar opciones para finalizar ejecución, o girar ruletas extras con alumnos del equipo
//   o nombres de otros equipos, registrar resultados.
// Se debe crear otro selector de equipos para saber si se deben girar los alumnos de este u otro equipo.
const categoria_seleccionada = ref(null);
const subcategoria_seleccionada = ref(null);

const actualizarRuleta = (resultado) => {
	console.log("Resultado de la ruleta:")
	if (categorias.value.includes(resultado)) {
		
		categoria_seleccionada.value = resultado;
		contenido_ruleta.value = getSubcategorias(resultado);
		contenido_boton.value = "Seleccionar Subcategoría";

	} else {

		subcategoria_seleccionada.value = resultado;
		console.log("Categoria seleccionada:", categoria_seleccionada.value);
		no_hay_subcategoria.value = false;
		// Mostrar botón para:
		// 1. Finalizar ejecución
		// 2. Girar ruleta de alumnos de un equipo (seleccionar equipo)
		// 3. Girar ruleta de equipos
	}
}

// Variables
const incidencias = ref([]);
const equipos = ref([]);
const categorias = ref([]);
const subcategorias = ref([]);
const equipo_seleccionado = ref('');
const alumnosdelequipo = ref([]);
const contenido_ruleta = ref([]);
const resultado_ruleta = ref(null);
const contenido_boton = ref(null);
const no_hay_subcategoria = ref(true);

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

// Función para obtener los equipos de la instancia desde la API
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
            throw new Error(
                `Error en la respuesta del servidor: ${response.statusText}`
            );
        }
        const data = await response.json();
        equipos.value = data;
    } catch (err) {
        console.error("Error fetching equipos:", err);
    }
};
// Función para obtener los alumnos de un grupo desde la API
const getAlumnos = async () => {
    try {
        const response = await fetch(`${API_URL}/api/grupos/${equipo_seleccionado.value}`, {
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
        }
        const data = await response.json();
        alumnosdelequipo.value = data;

		console.log(data)
		console.log("este es data")
    } catch (err) {
        console.error("Error fetching alumnos:", err);
    }
};
// Función para obtener las subcategorías de una categoría
function getSubcategorias(categoria) {
	return incidencias.value
		.filter(i => i.categoria === categoria)
		.map(i => i.subcategoria);
}
function cargarEquipos(){
	contenido_ruleta.value = equipos.value.map(equipo => equipo.nombre);
}
async function cargarAlumnosequipo() {
	try {
		await getAlumnos(); // Espera los datos del equipo
		console.log("Datos completos del equipo:", alumnosdelequipo.value);

		// Extrae solo los nombres
		contenido_ruleta.value = alumnosdelequipo.value.map(alumno => alumno.nombre);

		console.log("Nombres de los integrantes:", contenido_ruleta.value);
	} catch (error) {
		console.error("Error al cargar alumnos del equipo:", error);
	}
}

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
const actualizar_equipo = (resultado) => {
	// Aquí se debe actualizar el equipo seleccionado
	// Por ejemplo, si se selecciona un equipo en el componente Equipos,
	// se debe actualizar la variable equipo_seleccionado.
	equipo_seleccionado.value = resultado;
	console.log("Equipo seleccionado actualizado:", resultado);
}



onMounted(() => {
	getIncidencias();
	getEquipos();
});
</script>

<template>
	<div class="flex md:flex-row md:justify-between md:items-start md:overflow-clip flex-col justify-start items-center w-full h-full overflow-y-scroll">
		<!-- Lado Izquierdo -->
		<div class="w-full md:basis-1/4 grow h-full p-4">
			<!-- Opciones de la Instancia -->
			<div class="flex flex-wrap justify-start items-center w-full gap-2 mb-4">
				<CrearEquipos :id="id" />
				<Historial :id="id" />
			</div>
			<!-- Lista de Equipos de la Instancia -->
			<Equipos :id="id" :equipos="equipos" @equipo_seleccionado="actualizar_equipo"   />

			
		</div>
		<!-- Lado Central -->
		<div class="w-full md:basis-2/4 grow h-full">
			<!-- Componente Visual Ruleta -->
			<!-- <Ruleta :id="id" /> -->
			<!-- <Ruleta :contenido="contenido_ruleta" :resultado="resultado_ruleta" /> -->
			<Ruleta3 :items="contenido_ruleta" @result="actualizarRuleta" />
			<!-- Botón Girar Ruleta -->
			<!-- <button
				class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap"
				v-if="contenido_ruleta" @click="girarRuleta">
				Girar Ruleta
			</button> -->
		</div>
		<!-- Lado Derecho -->
		<div class="w-full md:basis-1/4 grow h-full p-4">
			<!-- <div class="flex flex-wrap justify-end items-center w-full gap-2 mb-4">
				<SubirIncidencias :id="id" /> <-- Mover al Navbar y hacerlo Global
			</div> -->
			<!-- Botones de Giros Extra -->
			<div class="flex flex-wrap justify-center md:justify-end items-center w-full gap-2 mb-4">
				<button
					class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button" @click="cargarAlumnosequipo" :disabled="no_hay_subcategoria">
					Girar Alumnos
				</button>
				<button
					class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button" @click="cargarEquipos" :disabled="no_hay_subcategoria">
					Girar Equipos
				</button>
			</div>
			<!-- Resumen de la Ejecución -->
			<section class="flex flex-col w-full p-4 gap-2 bg-zinc-900 rounded-md border border-zinc-700 shadow-md">
				<h2 class="text-lg font-bold">Resumen de la Ejecución:</h2>
				<div class="flex flex-col w-full gap-1">
					<p><strong class="font-semibold">Categoría: </strong>{{ categoria_seleccionada }}</p>
					<p><strong class="font-semibold">Subcategoría: </strong>{{ subcategoria_seleccionada }}</p>
				</div>
				<button
					class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button" :disabled="no_hay_subcategoria">
					Finalizar Ejecución
				</button>
			</section>
		</div>
	</div>
</template>
