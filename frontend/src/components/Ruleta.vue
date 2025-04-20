<script setup>
import { ref, onMounted } from 'vue';

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
});

const API_URL = import.meta.env.PUBLIC_API_URL;
const grupos = ref(null);

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
    <div class="flex justify-center items-center w-full p-4">
        <p>Instancia: {{ id }}</p>
        <!-- Lista de Grupos de la Instancia -->
        <!-- Ruleta Aleatoria -->
        <!-- Detalles o Configuraciones de la Ruleta -->
    </div>
</template>