<script setup>
import { ref, onMounted, watch, computed } from 'vue';
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

//
const alumno_seleccionado = ref(null);
const otro_equipo_seleccionado = ref(null);
const alumno_otro_equipo = ref(null);
const alumnos_otros_equipos = ref([]);
//

const contenido_ruleta = ref([]);
const hay_subcategoria = ref(false);
const comentario = ref('');
const can_spin = ref(false);
const isSpinning = ref(false);

//########## para distinción por semana ##########
const semanaSeleccionada = ref(0);
const nroSemanas = ref(1);
const gruposYaEjecutados = ref([]);
const semanasCompletas = ref([]);


// Cargar el número de semanas de la instancia
async function cargarNumeroDeSemanas() {
	try {
		const response = await fetch(`${API_URL}/api/instancia/${props.id}/semanas`);
		const data = await response.json();
		nroSemanas.value = data.nro_semanas;
	} catch (error) {
		console.error("Error al cargar nro_semanas:", error);
	}
}
const cargarSemanasCompletas = async () => {
	try {
		const response = await fetch(`${API_URL}/api/instancia/${props.id}/semanas-completas`);
		const data = await response.json();
		semanasCompletas.value = data;
		console.log(semanasCompletas.value, " semanas completas")
	} catch (error) {
		console.error("Error al obtener semanas completas:", error);
	}
};


// Observar semana seleccionada y actualizar grupos ya ejecutados
watch(semanaSeleccionada, async (nuevaSemana) => {
	try {
		const response = await fetch(`${API_URL}/api/instancia/${props.id}/semana/${nuevaSemana}/grupos-ejecutados`);
		const data = await response.json();
		gruposYaEjecutados.value = data.map(g => g.id);
	} catch (error) {
		console.error("Error al cargar grupos ejecutados:", error);
	}
});

const equiposConEstado = computed(() => {
	return equipos.value.map(e => ({
		...e,
		yaEjecutado: gruposYaEjecutados.value.includes(e.id)
	}));
});


// ############# fin distincion semana #############

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
		//console.log(data);
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

// Cargar equipos a la ruleta boton Girar Equipos
function cargarEquipos() {
	contenido_ruleta.value = equipos.value.map(equipo => equipo.nombre);
	can_spin.value = true;
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
	can_spin.value = true;
}
const equipoEncontrado = equipos.value.find(e => e.nombre === resultado);
// Actualizar ruleta según resultado
const actualizarRuleta = async (resultado) => {
	if (categorias.value.includes(resultado)) {
		categoria_seleccionada.value = resultado;
		contenido_ruleta.value = getSubcategorias(resultado);
	}
	else if (subcategorias.value.includes(resultado)) {
		subcategoria_seleccionada.value = resultado;
		hay_subcategoria.value = true;
	}
	else {
		// Verificar si es un equipo
		const equipoEncontrado = equipos.value.find(e => e.nombre === resultado);

		if (equipoEncontrado) {
			// Si ya hay un equipo principal, este es el "otro equipo"
			if (equipo_seleccionado.value) {
				otro_equipo_seleccionado.value = equipoEncontrado.id;
				await getAlumnos(equipoEncontrado.id);  // Espera a cargar los alumnos
				alumnos_otros_equipos.value = [...alumnosdelequipo.value];  // Guarda una COPIA
				contenido_ruleta.value = alumnosdelequipo.value.map(a => a.nombre);
			}
			else {
				// Es el primer equipo (principal)
				equipo_seleccionado.value = equipoEncontrado.id;
				await getAlumnos(equipoEncontrado.id);  // Espera a cargar los alumnos
			}
			return;
		}

		// Verificar si es un alumno
		const alumnoEncontrado = [...alumnosdelequipo.value, ...alumnos_otros_equipos.value]
			.find(a => a.nombre === resultado);

		if (alumnoEncontrado) {
			// ¿Pertenece al OTRO equipo? (verifica en alumnos_otros_equipos)
			if (alumnos_otros_equipos.value.some(a => a.id === alumnoEncontrado.id)) {
				alumno_otro_equipo.value = alumnoEncontrado;  // Guarda en "otro equipo"
				console.log("Alumno de OTRO equipo asignado:", alumno_otro_equipo.value);
			}
			else {
				alumno_seleccionado.value = alumnoEncontrado;  // Guarda en "equipo principal"
				console.log("Alumno del equipo principal asignado:", alumno_seleccionado.value);
			}
		}
	}
};

async function subirBackend() {
	try {
		//console.log("Buscando incidencia con:", categoria_seleccionada.value, subcategoria_seleccionada.value);
		//console.log("Lista de incidencias:", incidencias.value);
		const incidenciaSeleccionada = incidencias.value.find(
			i => i.categoria === categoria_seleccionada.value && i.subcategoria === subcategoria_seleccionada.value
		);

		if (!incidenciaSeleccionada) {
			alert('Incidencia no encontrada');
			return;
		}
		const body = {
			ref_incidencia: incidenciaSeleccionada.id,
			ref_grupo: equipo_seleccionado.value,
			alumno_escogido: alumno_seleccionado.value?.id,
			grupo_intercambio: otro_equipo_seleccionado.value,
			alumno_intercambio: alumno_otro_equipo.value?.id,
			semana: semanaSeleccionada.value,
			comentario: comentario.value
		};

		console.log("enviando: ", body)
		//console.log('Body a enviar:', body);
		const response = await fetch(`${API_URL}/api/registros/${props.id}`, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify(body)
		});

		if (!response.ok) throw new Error('Error en la solicitud');

		const data = await response.json();
		//console.log('Registro guardado:', data);
		alert('Registro guardado correctamente');

		// Limpiar los campos
		categoria_seleccionada.value = null;
		subcategoria_seleccionada.value = null;
		hay_subcategoria.value = false;
		comentario.value = '';
		alumno_seleccionado.value = null;
		otro_equipo_seleccionado.value = null;
		alumno_otro_equipo.value = null;
		//semanaSeleccionada.value = 0

		gruposYaEjecutados.value.push(equipo_seleccionado.value);
		updateAll()
	} catch (error) {
		console.error(error);
		alert('Ocurrió un error al guardar el registro');
	}
}

const updateSpinState = (state) => {
	isSpinning.value = state;
}

const updateAll = () => {
	getIncidencias();
	getEquipos();
	cargarNumeroDeSemanas();
	cargarSemanasCompletas();
}

// Al montar el componente
onMounted(() => {
	updateAll()
}
);

</script>

<template>
	<div class="grid grid-cols-1 md:grid-cols-[1fr_1.5fr_1fr] w-full overflow-y-hidden hide-scrollbar">
		<!-- Lado Izquierdo -->
		<div class="flex flex-col p-4 md:overflow-y-scroll hide-scrollbar gap-4">
			<div class="flex flex-wrap justify-start items-center gap-2">
				<CrearEquipos :id="id" />
				<Historial :id="id" />
			</div>
			<!-- Selector de semana -->
			<div class="flex flex-col">
				<label for="semana" class="block text-sm font-medium ">Semana actual</label>
				<select v-model="semanaSeleccionada" id="semana"
					class="block w-full text-base border border-zinc-700 rounded-md px-2 py-1 bg-zinc-900 text-zinc-50 outline-none">
					<option value=0 disabled selected>Selecciona una semana</option>
					<option v-for="n in nroSemanas" :key="n" :value="n" :disabled="semanasCompletas.includes(n)">Semana
						{{ n }}<span v-if="semanasCompletas.includes(n)"> (completa)</span></option>
				</select>
			</div>

			<!-- Lista de equipos (con distintivo si ya tiraron) -->
			<Equipos v-if="semanaSeleccionada > 0" :id="id" :equipos="equiposConEstado"
				@equipo_seleccionado="actualizar_equipo" />
		</div>

		<!-- Lado Central -->
		<Ruleta3 :canSpin="can_spin" :items="contenido_ruleta" @result="actualizarRuleta" @isSpinning="updateSpinState" />

		<!-- Lado Derecho -->
		<div class="flex flex-col p-4 md:overflow-y-scroll hide-scrollbar gap-4">
			<div class="flex justify-start items-center w-full">
				<div class="flex flex-nowrap justify-start items-center gap-2 overflow-x-scroll hide-scrollbar">
					<button class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed" type="button" @click="() => {
						if (!equipo_seleccionado) {
							can_spin = false;
							return;
						}
						getIncidencias();
					}" :disabled="!equipo_seleccionado || isSpinning">
						Girar Incidencias
					</button>
					<button class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
						disabled:bg-zinc-600 disabled:cursor-not-allowed"
						type="button" @click="cargarAlumnosequipo" :disabled="(!hay_subcategoria || (otro_equipo_seleccionado && !alumno_otro_equipo)) || isSpinning"
					>
						Girar Alumnos
					</button>
					<button class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
						disabled:bg-zinc-600 disabled:cursor-not-allowed"
						type="button" @click="cargarEquipos" :disabled="!alumno_seleccionado || isSpinning"
					>
						Girar Equipos
					</button>
				</div>
			</div>
			<!-- Resumen de la Ejecución -->
			<section class="flex flex-col w-full p-4 gap-2 bg-zinc-900 rounded-md border border-zinc-700 shadow-md">
				<h2 class="text-lg font-bold text-white">Resumen de la Ejecución:</h2>
				<!-- En la sección de Resumen de Ejecución -->
				<div class="flex flex-col w-full gap-1 text-white">
					<p v-if="!semanaSeleccionada" class="text-center text-zinc-200">
						Selecciona una semana, un equipo, y gira la ruleta para ver resultados!
					</p>
					<p v-if="semanaSeleccionada">
						<strong class="font-semibold">Semana: </strong>
						{{ semanaSeleccionada }}
					</p>
					<p v-if="equipo_seleccionado">
						<strong class="font-semibold">Equipo: </strong>
						{{ equipos.find(e => e.id === equipo_seleccionado)?.nombre }}
					</p>
					<p v-if="categoria_seleccionada">
						<strong class="font-semibold">Categoría: </strong>
						{{ categoria_seleccionada }}
					</p>
					<p v-if="subcategoria_seleccionada">
						<strong class="font-semibold">Subcategoría: </strong>
						{{ subcategoria_seleccionada }}
					</p>
					<p v-if="alumno_seleccionado">
						<strong class="font-semibold">Alumno del equipo: </strong>
						{{ alumno_seleccionado.nombre }}
					</p>
					<p v-if="otro_equipo_seleccionado">
						<strong class="font-semibold">Otro Equipo: </strong>
						{{ equipos.find(e => e.id === otro_equipo_seleccionado)?.nombre }}
					</p>
					<p v-if="alumno_otro_equipo">
						<strong class="font-semibold">Alumno de otro equipo: </strong>
						{{ alumno_otro_equipo.nombre }}
					</p>
				</div>
				
				<!-- Textarea de Comentario -->
				<div v-if="subcategoria_seleccionada" class="mt-4">
					<label for="comentario" class="block text-base font-medium text-white mb-1">Comentario:</label>
					<textarea id="comentario" v-model="comentario" placeholder="Escribe tu comentario aquí..." rows="2"
						class="w-full p-2 rounded-md border border-zinc-600 bg-zinc-800 text-white resize-none shadow-inner"></textarea>
				</div>

				<!-- Botón Finalizar -->
				<button class="mt-4 bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed" type="button" :disabled="!hay_subcategoria"
					@click="subirBackend()">
					Finalizar Ejecución
				</button>
			</section>
		</div>
	</div>
</template>

<style scoped>
/* Habilitar estilos personalizables para el select (Chrome) */
select {

	&,
	&::picker(select) {
		appearance: base-select;
	}
}

/* Estilos del select */
::picker(select) {
	background-color: #18181b;
	color: #ffffff;
	border-radius: 6px;
	border: 1px solid #3f3f46;
	top: calc(anchor(bottom) + 2px);
}

/* Icono del select */
select::picker-icon {
	width: 24px;
	height: 24px;
	content: url("../../assets/chevron-down.svg");
	transition: 0.3s rotate;
}

select:open::picker-icon {
	rotate: 180deg;
}

/* Estilos de las opciones del select */
select option {
	background-color: #18181b;
	color: #ffffff;
	padding: 4px 8px;
}

select option:checked,
select option:hover {
	background-color: #fafafa;
	color: #18181b;
}

select option:disabled {
	background-color: #18181b;
	color: #3f3f46;
}

option::checkmark {
	display: none;
}
</style>