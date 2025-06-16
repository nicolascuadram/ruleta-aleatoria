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
      		comentario: comentario.value
    	};
	
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

	} catch (error) {
    	console.error(error);
    	alert('Ocurrió un error al guardar el registro');
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
			<Ruleta3 :canSpin="can_spin" :items="contenido_ruleta" @result="actualizarRuleta" />
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
					type="button" @click="cargarEquipos">
					Girar Equipos
				</button>
				<button
					class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button"
					@click="() => {
						if (!equipo_seleccionado) {
							can_spin = false;
							return;
						}
						getIncidencias();
					}"
					:disabled="!equipo_seleccionado"
				>
					Girar Incidencias
				</button>
				
			</div>

			<!-- Resumen de la Ejecución -->
			<section class="flex flex-col w-full p-4 gap-2 bg-zinc-900 rounded-md border border-zinc-700 shadow-md">
				<h2 class="text-lg font-bold text-white">Resumen de la Ejecución:</h2>
				<!-- En la sección de Resumen de Ejecución -->
				<div class="flex flex-col w-full gap-1 text-white">
				<p><strong class="font-semibold">Equipo:</strong> 
					{{ equipo_seleccionado ? equipos.find(e => e.id === equipo_seleccionado)?.nombre : '--' }}
				</p>
				<p><strong class="font-semibold">Categoría:</strong> {{ categoria_seleccionada || '--' }}</p>
				<p><strong class="font-semibold">Subcategoría:</strong> {{ subcategoria_seleccionada || '--' }}</p>
				<p><strong class="font-semibold">Alumno:</strong> {{ alumno_seleccionado?.nombre || '--' }}</p>
				<p><strong class="font-semibold">Otro Equipo:</strong> 
					{{ otro_equipo_seleccionado ? equipos.find(e => e.id === otro_equipo_seleccionado)?.nombre : '--' }}
				</p>
				<p><strong class="font-semibold">Alumno otro equipo:</strong> {{ alumno_otro_equipo?.nombre || '--' }}</p>
				</div>

				<!-- Textarea de Comentario -->
				<div class="mt-4">
					<label for="comentario" class="block text-sm font-medium text-white mb-1">Comentario:</label>
					<textarea
						id="comentario"
						v-model="comentario"
						placeholder="Escribe tu comentario aquí..."
						rows="2"
						class="w-full p-2 rounded-md border border-zinc-600 bg-zinc-800 text-white resize-none shadow-inner"
					></textarea>
				</div>

				<!-- Botón Finalizar -->
				<button
					class="mt-4 bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap
					disabled:bg-zinc-600 disabled:cursor-not-allowed"
					type="button"
					:disabled="!hay_subcategoria"
					@click="subirBackend()"
				>
					Finalizar Ejecución
				</button>
			</section>
		</div>
	</div>
</template>
