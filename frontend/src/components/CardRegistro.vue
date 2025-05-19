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
	fecha: {
		type: String,
		required: true,
	},
	comentario: {
		type: String,
		required: false,
        default: 'No hay comentarios',
	},
});
</script>
<template>
	<a class="flex flex-col justify-between items-center w-full px-4 py-3 gap-2 border border-zinc-700 rounded-md shadow-md transition duration-300 cursor-default bg-zinc-900">
		<header class="flex justify-between items-center w-full">
			<h1 class="text-xl font-semibold leading-snug">{{ grupo }}</h1>
			<h2 class="text-sm font-medium text-zinc-300">{{ fecha }}</h2>
		</header>
		<div class="flex flex-col justify-start items-start w-full">
			<p class="text-lg"><strong>Categoria: </strong>{{ categoria }}</p>
			<span class="flex w-full justify-start items-start">
				<p class="text-lg"><strong>Incidencia: </strong>{{ incidencia }}</p>
            	<p v-if="alumnoescogido" class="text-lg"><strong>. Alumno: </strong>{{ alumnoescogido }}</p>
			</span>
            <p v-if="comentario" class="text-lg"><strong>Comentario: </strong>{{ comentario }}</p>
			<!-- <span class="flex justify-center items-center gap-2 px-2 py-1 bg-zinc-50 text-zinc-900 font-medium rounded-md shadow-md">
				<UserPen color="#18181b" :size="20"/>
				<p class="text-xs font-medium">{{ comentario }}</p>
			</span> -->
		</div>
	</a>
</template>