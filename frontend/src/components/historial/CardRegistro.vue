<script setup>
import { UserPen } from 'lucide-vue-next';

defineProps({
	categoria: {
		type: String,
		required: true,
	},
	incidencia: {
		type: String,
		required: true,
	},
	grupo: {
		type: String,
		required: true,
	},
    alumnoescogido: {
        type: String,
		required: false,
        default: '',
	},
	otrogrupo: {
        type: Number,
		required: false,
        default: '',
	},
	otroalumno: {
        type: Number,
		required: false,
        default: '',
	},
	fecha: {
		type: String,
		required: true,
	},
	comentario: {
		type: String,
		required: false,
    default: 'No hay comentarios',
	},
  semana:{
    type: Number,
		required: false,
  }
});
</script>

<template>
  <a class="flex flex-col justify-between w-full px-4 py-3 gap-3 max-h-[350px] border border-zinc-700 rounded-md shadow-md bg-zinc-900 overflow-hidden">
    <!-- Header -->
    <div class="flex justify-between items-start w-full gap-2">
      <h1 class="text-xl font-semibold text-white truncate flex-1 min-w-0">{{ grupo }}</h1>
      <h1 class="text-xl font-semibold text-white truncate flex-1 min-w-0">Semana {{ semana }}</h1>
      <span class="text-sm font-medium text-zinc-400 whitespace-nowrap pl-2">{{ fecha }}</span>
    </div>

    <!-- Contenido - Versión optimizada sin espacios vacíos -->
    <div class="flex flex-col w-full gap-2 overflow-y-auto">
      <!-- Campo fijo: Categoría -->
      <div class="flex gap-2 items-baseline">
        <strong class="text-zinc-400 whitespace-nowrap">Categoría:</strong>
        <span class="text-white truncate">{{ categoria }}</span>
      </div>
      
      <!-- Campo fijo: Incidencia -->
      <div class="flex gap-2 items-baseline">
        <strong class="text-zinc-400 whitespace-nowrap">Incidencia:</strong>
        <span class="text-white truncate">{{ incidencia }}</span>
      </div>

      <!-- Campos condicionales (solo aparecen si tienen contenido) -->
      <template v-if="alumnoescogido">
        <div class="flex gap-2 items-baseline">
          <strong class="text-zinc-400 whitespace-nowrap">Alumno:</strong>
          <span class="text-white truncate">{{ alumnoescogido }}</span>
        </div>
      </template>

      <template v-if="otrogrupo">
        <div class="flex gap-2 items-baseline">
          <strong class="text-zinc-400 whitespace-nowrap">Otro Grupo:</strong>
          <span class="text-white truncate">{{ otrogrupo }}</span>
        </div>
      </template>

      <template v-if="otroalumno">
        <div class="flex gap-2 items-baseline">
          <strong class="text-zinc-400 whitespace-nowrap">Otro Alumno:</strong>
          <span class="text-white truncate">{{ otroalumno }}</span>
        </div>
      </template>

      <!-- Comentario (con tratamiento especial para multi-línea) -->
<template v-if="comentario">
  <div class="bg-zinc-800/50 rounded-md p-3 mt-2 max-h-32 overflow-y-auto">
    <p class="text-lg break-words">
      <strong class="text-zinc-300">Comentario: </strong>
      <span class="text-white whitespace-pre-wrap">{{ comentario }}</span>
    </p>
  </div>
</template>
    </div>
  </a>
</template>