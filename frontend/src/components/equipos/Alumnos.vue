<script setup>
import { ref, onMounted } from 'vue';
import { User } from 'lucide-vue-next';

const props = defineProps({
    id: {
        type: Number,
        required: true,
    },
});

const API_URL = import.meta.env.PUBLIC_API_URL;
const alumnos = ref(null);

// Función para obtener los alumnos de un grupo desde la API
const getAlumnos = async () => {
    try {
        const response = await fetch(`${API_URL}/api/grupos/${props.id}`, {
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
    <!-- Lista de alumnos -->
    <section v-if="alumnos" class="flex flex-col items-start justify-start w-full gap-2">
        <h2 class="text-base font-semibold">Integrantes:</h2>
        <div class="flex flex-col items-center justify-start w-full border-b border-zinc-700">
            <div v-for="alumno in alumnos" :key="alumno.id" class="flex justify-start items-center w-full p-2 gap-2 border-t border-zinc-700">
                <User color="#fff" size="20" />
                <p class="text-base font-medium">{{ alumno.nombre }}</p>
            </div>
        </div>
    </section>
    <div v-else class="flex justify-center items-center w-full h-full">
        <p class="text-lg font-medium text-zinc-50">Cargando alumnos...</p>
    </div>
</template>