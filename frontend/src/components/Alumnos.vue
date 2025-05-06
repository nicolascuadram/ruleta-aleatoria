<script setup>
import { ref, onMounted } from 'vue';

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
});

const API_URL = import.meta.env.PUBLIC_API_URL;
const alumnos = ref(null);

// Función para obtener los alumnos de un grupo desde la API
const getAlumnos = async () => {
    try {
        const response = await fetch(API_URL + `/api/grupos/${props.id}`, {
            method: "GET",
            headers: {
                "Content-Type": "application/json",
            },
        });
        if (!response.ok) {
            console.error("Status:", response.status);
            throw new Error(
                "Error en la respuesta del servidor: " + response.statusText
            );
        }
        const data = await response.json();
        alumnos.value = data;
    } catch (err) {
        console.error("Error fetching alumnos:", err);
    }
};

onMounted(() => {
    getAlumnos();
});
</script>

<template>
    <div v-if="alumnos" class="flex flex-col items-center justify-start w-full h-full overflow-hidden border border-zinc-700 rounded-md shadow-md mt-4">
        <!-- Lista de alumnos -->
        <div v-for="alumno in alumnos" :key="alumno.id" class="flex flex-col items-start justify-start w-full p-2 border-t border-zinc-700">
            <h2 class="text-base font-semibold">{{ alumno.nombre }}</h2>
        </div>
    </div>
    <div v-else class="flex justify-center items-center w-full h-full">
        <p class="text-lg font-medium text-zinc-500">Cargando alumnos...</p>
    </div>
</template>