<script setup>
import Equipos from "../equipos/Equipos.vue";
import CrearEquipos from "../equipos/CrearEquipos.vue";
import Ruleta from "../ruleta/Ruleta2Aleatoria.vue";
import Historial from "../historial/Historial.vue";
import SubirIncidencias from "../incidencias/SubirIncidencias.vue";

const props = defineProps({
    id: {
        type: String,
        required: true
    }
});
</script>

<template>
	<div class="flex justify-between items-start w-full h-full">
		<!-- Lado Izquierdo -->
		<div class="basis-1/4 grow h-full">
			<!-- Lista de Equipos de la Instancia -->
			<Equipos :id="id" />
		</div>
		<!-- Lado Central -->
		<div class="basis-2/4 grow h-full">
			<!-- Ruleta Aleatoria -->
			<Ruleta :id="id" />
		</div>
		<!-- Lado Derecho -->
		<div class="basis-1/4 grow h-full">
			<!-- Detalles o Configuraciones de la Ruleta -->
			<div class="flex flex-wrap justify-start items-center w-full p-4 gap-2">
				<CrearEquipos :id="id" />
				<SubirIncidencias :id="id" />
				<Historial :id="id" />
			</div>
		</div>
	</div>
</template>
