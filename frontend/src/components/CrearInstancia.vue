<script setup>
import { ref } from 'vue';
const API_URL = import.meta.env.PUBLIC_API_URL;

// Recibe la propiedad isModalOpen
const props = defineProps({
    isModalOpen: Boolean
});

const semestre = ref('');

// Emitir eventos
const emit = defineEmits(['close-modal', 'update:instancias']);

// Función para cerrar el modal
const closeModal = () => {
    emit('close-modal');
};

// Función para actualizar las instancias
const updateInstancias = (instancia) => {
    emit('update:instancias', instancia);
};

// Función para crear una nueva instancia
const postInstancia = async () => {
    try {
        const response = await fetch(API_URL + `/api/instancias/`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                semestre: semestre.value,
                profesor: "Luis Silvestre", // Cambiar por el nombre del profesor logeado
            }),
        });
        if (!response.ok) {
            console.error("Status:", response.status);
            throw new Error(
                "Error en la respuesta del servidor: " + response.statusText
            );
        }
        const data = await response.json();
        updateInstancias(data);
        semestre.value = '';
        closeModal();
    } catch (err) {
        console.error("Error posting instancia:", err);
    }
};
</script>

<template>
    <div v-if="isModalOpen" class="fixed inset-0 flex items-center justify-center bg-[#00000090] z-50">
        <div class="flex flex-col justify-center items-center rounded-md p-8 bg-zinc-900">
            <form @submit.prevent="postInstancia" class="flex flex-col justify-center items-center gap-4">
                <div class="w-full text-center">
                    <h2 class="text-xl font-bold">Crear Nueva Instancia</h2>
                </div>
                <div class="flex flex-col gap-1">
                    <label for="semestre" class="block text-sm font-medium">Semestre</label>
                    <input type="text" id="semestre" v-model="semestre" required
                        class="block w-full text-base border border-gray-300 rounded-md outline-none px-2 py-1" />
                </div>
                <div class="flex justify-between items-center w-full gap-6">
                    <button
                        class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-red-400 transition duration-300 cursor-pointer shadow-md text-nowrap w-full"
                        type="button" @click="closeModal">
                        Cancelar
                    </button>
                    <button
                        class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-green-300 transition duration-300 cursor-pointer shadow-md text-nowrap w-full"
                        type="submit">
                        Crear
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>