<script setup>
import CardInstancia from './CardInstancia.vue';
import { ref, onMounted } from 'vue';

const API_URL = import.meta.env.PUBLIC_API_URL;
const instancias = ref([]);

// Función para obtener las instancias desde la API
const getInstancias = async () => {
    try {
        const response = await fetch(API_URL + `/api/instancias/`, {
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
        instancias.value = data;
    } catch (err) {
        console.error("Error fetching instancias:", err);
    }
};

onMounted(() => {
    getInstancias();
});

// Simulación de datos para instancias
/* instancias.value = [
    {
        id: 1,
        semestre: '2025-1',
        profesor: 'Luis Silvestre',
    },
    {
        id: 2,
        semestre: '2025-2',
        profesor: 'Luis Silvestre',
    },
    {
        id: 3,
        semestre: '2026-1',
        profesor: 'Luis Silvestre',
    },
    {
        id: 4,
        semestre: '2026-1',
        profesor: 'Luis Silvestre',
    },
    {
        id: 5,
        semestre: '2026-1',
        profesor: 'Luis Silvestre',
    },
    {
        id: 6,
        semestre: '2026-1',
        profesor: 'Luis Silvestre',
    },
    {
        id: 7,
        semestre: '2026-1',
        profesor: 'Luis Silvestre',
    },
    {
        id: 8,
        semestre: '2026-1',
        profesor: 'Luis Silvestre',
    },
    {
        id: 9,
        semestre: '2026-1',
        profesor: 'Luis Silvestre',
    },
    {
        id: 10,
        semestre: '2026-1',
        profesor: 'Luis Silvestre',
    },
]; */
</script>

<template>
    <section class="flex flex-col items-center justify-start w-full h-full p-4">
        <!-- Header -->
        <div class="flex items-center justify-between w-full py-4">
            <!-- Título y descripción -->
            <div class="flex flex-col items-start justify-start w-full">
                <h1 class="text-2xl font-bold">Instancias</h1>
                <p class="text-base">Selecciona una instancia para gestionar los proyectos tecnológicos.</p>
            </div>
            <!-- Botones -->
            <div>
                <button class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap">
                    Crear nueva instancia
                </button>
            </div>
        </div>
        <!-- Lista de instancias -->
        <div class="flex flex-wrap gap-4 w-full h-full overflow-y-scroll">
            <CardInstancia v-for="instancia in instancias" :key="instancia.id" 
                :url="`/instancia/${instancia.id}`"
                titulo="Gestión de Proyectos Tecnológicos" 
                :semestre="instancia.semestre"
                :profesor="instancia.profesor"
            />
        </div>
    </section>
</template>