<script setup>
import { UserPen } from 'lucide-vue-next';

defineProps({
	url: {
		type: String,
		required: true,
	},
	titulo: {
		type: String,
		required: true,
	},
	semestre: {
		type: String,
		required: true,
	},
	profesor: {
		type: String,
		required: true,
	},
});
</script>
<template>
	<a class="flex flex-col justify-between items-center w-[240px] h-[240px] p-4 border border-zinc-700 rounded-md shadow-md transition duration-300 cursor-pointer bg-zinc-950 hover:bg-gradient-to-br from-zinc-950 to-zinc-800" :href="`${url}`">
		<header class="flex flex-col items-start text-start w-full">
			<h1 class="text-lg font-semibold leading-snug">{{ titulo }}</h1>
			<h2 class="text-sm font-medium text-zinc-300">{{ semestre }}</h2>
		</header>
		<aside class="flex justify-start items-center gap-2 text-center w-full">
			<span class="flex justify-center items-center gap-2 px-2 py-1 bg-zinc-50 text-zinc-900 font-medium rounded-md shadow-md">
				<UserPen color="#18181b" :size="20"/>
				<p class="text-xs font-medium">{{ profesor }}</p>
			</span>
		</aside>
	</a>
</template>