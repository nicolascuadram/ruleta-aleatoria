<script setup>
import CardInstancia from './CardInstancia.vue';
import { ref, onMounted } from 'vue';

const instancias = ref([]);

// Simulación de datos para instancias
instancias.value = [
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
];

/* const getInstancias = async (id) => {
    try {
        const response = await fetch("http://localhost:3000/api/instancias", {
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
}); */
</script>

<template>
    <section class="flex flex-col items-center justify-center w-full h-[530px] p-4">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 overflow-y-scroll">
            <CardInstancia v-for="instancia in instancias" :key="instancia.id" 
                :url="`/instancia/${instancia.id}`"
                titulo="Gestión de Proyectos Tecnológicos" 
                :semestre="instancia.semestre"
                :profesor="instancia.profesor"
            />
        </div>
    </section>
</template>