<script setup>
import Alumnos from "../../components/Alumnos.vue";
import { ref, onMounted } from 'vue';

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
});

const API_URL = import.meta.env.PUBLIC_API_URL;
const grupos = ref(null);

// Función para obtener los grupos de la instancia desde la API
const getGrupos = async () => {
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
        grupos.value = data;
    } catch (err) {
        console.error("Error fetching grupos:", err);
    }
};

onMounted(() => {
    getGrupos();
});
</script>

<template>
    <section class="flex flex-col justify-center items-center w-full p-4">
        <div v-if="grupos" class="flex flex-col items-center justify-start w-full h-full rounded-md overflow-hidden border border-zinc-300">
            <div class="p-4 w-full">
                <h1 class="text-lg font-bold text-center">Lista de Equipos</h1>
            </div>
            <div v-for="grupo in grupos" :key="grupo.id" class="flex flex-col items-start justify-start w-full p-4 border border-zinc-300">
                <h2 class="text-base font-semibold">{{ grupo.nombre }}</h2>
                <!--<Alumnos :id="grupo.id"/>-->
            </div>
        </div>
        <div v-else class="flex justify-center items-center w-full h-full">
            <p class="text-lg font-medium text-zinc-500">Cargando grupos...</p>
        </div>
    </section>
</template>