<script setup> 
import Alumnos from "./Alumnos.vue";
import { ref, onMounted, computed } from 'vue';

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
});

const API_URL = import.meta.env.PUBLIC_API_URL;
const equipos = ref([]);
const equipoSeleccionado = ref(null);

// Función para obtener los equipos de la instancia desde la API
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
            throw new Error(
                `Error en la respuesta del servidor: ${response.statusText}`
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

const equipoActual = computed(() => {
    return equipos.value.find(e => e.id === equipoSeleccionado.value);
});
</script>

<template>
    <section class="flex flex-col justify-center items-center w-full h-full p-4">
        <div v-if="equipos.length" class="flex flex-col items-center justify-start w-full h-full">
            <!-- Selector de equipo -->
            <div class="mb-4 w-full max-w-md">
                <label class="block mb-2 text-sm font-medium text-zinc-200">Selecciona un equipo:</label>
                <select v-model="equipoSeleccionado" class="w-full p-2 rounded-md bg-zinc-800 text-white border border-zinc-600">
                    <option disabled value="">-- Selecciona --</option>
                    <option v-for="equipo in equipos" :key="equipo.id" :value="equipo.id">
                        {{ equipo.nombre }}
                    </option>
                </select>
            </div>

            <!-- Equipo seleccionado -->
            <!-- Equipo seleccionado -->
            <div v-if="equipoActual" class="w-full max-w-2xl bg-zinc-800 border border-zinc-700 rounded-xl shadow-md p-6 space-y-4">
            <h2 class="text-lg font-semibold text-white">{{ equipoActual.nombre }}</h2>
            <div class="bg-zinc-900 rounded-md p-4">
                <Alumnos :id="equipoActual.id" />
            </div>
            </div>

        </div>

        <div v-else class="flex justify-center items-center w-full h-full">
            <p class="text-lg font-medium text-zinc-500">Cargando equipos...</p>
        </div>
    </section>
</template>
