<script setup>
import Alumnos from "./Alumnos.vue";
import { ref, onMounted } from 'vue';

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
});

const API_URL = import.meta.env.PUBLIC_API_URL;
const equipos = ref(null);

// Función para obtener los equipos de la instancia desde la API
const getEquipos = async () => {
    try {
        const response = await fetch(API_URL + `/api/instancias/${props.id}`, {
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
        equipos.value = data;
    } catch (err) {
        console.error("Error fetching equipos:", err);
    }
};

onMounted(() => {
    getEquipos();
});
</script>

<template>
    <section class="flex flex-col justify-center items-center w-full p-4">
        <div v-if="equipos" class="flex flex-col items-center justify-start w-full h-full overflow-y-scroll border border-zinc-700 rounded-md shadow-md">
            <div class="p-4 w-full">
                <h1 class="text-lg font-bold text-center">Lista de Equipos</h1>
            </div>
            <div v-for="equipo in equipos" :key="equipo.id" class="flex flex-col items-start justify-start w-full p-4 border-t border-zinc-700">
                <h2 class="text-base font-semibold">{{ equipo.nombre }}</h2>
                <Alumnos :id="equipo.id"/>
            </div>
        </div>
        <div v-else class="flex justify-center items-center w-full h-full">
            <p class="text-lg font-medium text-zinc-500">Cargando equipos...</p>
        </div>
    </section>
</template>