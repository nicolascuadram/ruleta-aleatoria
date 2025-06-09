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
            throw new Error(
                `Error en la respuesta del servidor: ${response.statusText}`
            );
        }
        const data = await response.json();
        alumnosdelequipo.value = data;
    } catch (err) {
        console.error("Error fetching alumnos:", err);
    }
};

// Función para obtener las subcategorías de una categoría
function getSubcategorias(categoria) {
	return incidencias.value
		.filter(i => i.categoria === categoria)
		.map(i => i.subcategoria);
};

// Función para cargar nombres de equipos a la ruleta
function cargarEquipos(){
	contenido_ruleta.value = equipos.value.map(equipo => equipo.nombre);
};

// Función para cargar nombres de alumnos a la ruleta
async function cargarAlumnosequipo() {
	try {
		// Espera los datos del equipo
		await getAlumnos(equipo_seleccionado.value);

		// Extrae solo los nombres
		contenido_ruleta.value = alumnosdelequipo.value.map(alumno => alumno.nombre);
	} catch (error) {
		console.error("Error al cargar alumnos del equipo:", error);
	}
}

// Función para obtener el equipo seleccionado desde Equipos.vue
const actualizar_equipo = (resultado) => {
	equipo_seleccionado.value = resultado;
}

// Función para cambiar el contenido de la ruleta dependiendo del resultado obtenido
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
			<Equipos :id="id" :equipos="equipos" @equipo_seleccionado="actualizar_equipo" />
		</div>
		<!-- Lado Central -->
		<div class="w-full md:basis-2/4 grow h-full">
			<!-- Componente Visual Ruleta -->
			<!-- <Ruleta :id="id" /> -->
			<!-- <Ruleta :contenido="contenido_ruleta" :resultado="resultado_ruleta" /> -->
			<Ruleta3 :items="contenido_ruleta" @result="actualizarRuleta" />
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
				<h2 class="text-lg font-bold">Resumen de la Ejecución:</h2>
				<div class="flex flex-col w-full gap-1">
					<p><strong class="font-semibold">Categoría: </strong>{{ categoria_seleccionada }}</p>
					<p><strong class="font-semibold">Subcategoría: </strong>{{ subcategoria_seleccionada }}</p>
				</div>
				<button
					class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button" :disabled="!hay_subcategoria">
					Finalizar Ejecución
				</button>
			</section>
		</div>
	</div>
</template>
