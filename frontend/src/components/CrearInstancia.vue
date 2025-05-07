<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue';
const API_URL = import.meta.env.PUBLIC_API_URL;

/* LÓGICA DEL MODAL */

// Recibe la propiedad isModalOpen
const props = defineProps({
    isModalOpen: Boolean
});

// Emitir eventos
const emit = defineEmits(['close-modal', 'update:instancias']);

// Referencia al modal
const modalContentRef = ref(null);

// Función para cerrar el modal
const closeModal = () => {
    emit('close-modal');
};

// Cerrar el modal con la tecla Escape
const handleEscape = (e) => {
    if (e.key === 'Escape') closeModal();
};

// Cerrar al hacer clic fuera del modal
const handleClickOutside = (e) => {
    if (modalContentRef.value && !modalContentRef.value.contains(e.target)) {
        closeModal();
    }
};

watch(() => props.isModalOpen, (isOpen) => {
    if (isOpen) {
        window.addEventListener('keydown', handleEscape);
        window.addEventListener('mousedown', handleClickOutside);
    } else {
        window.removeEventListener('keydown', handleEscape);
        window.removeEventListener('mousedown', handleClickOutside);
    }
});

onUnmounted(() => {
    window.removeEventListener('keydown', handleEscape);
    window.removeEventListener('mousedown', handleClickOutside);
});

/* LÓGICA DEL COMPONENTE ESPECÍFICO */

const semestre = ref('');

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

// Función para actualizar las instancias
const updateInstancias = (instancia) => {
    emit('update:instancias', instancia);
};
</script>

<template>
    <section role="dialog" aria-modal="true" v-if="isModalOpen" class="fixed inset-0 flex items-center justify-center bg-[#000000dd] z-50">
        <div ref="modalContentRef" class="flex flex-col justify-center items-center rounded-md px-6 py-4 bg-zinc-950 border border-zinc-700">
            <form @submit.prevent="postInstancia" class="flex flex-col justify-center items-center gap-4">
                <header class="flex flex-col w-full text-start gap-1">
                    <h2 class="text-xl font-bold">Nueva Instancia</h2>
                    <p class="text-sm">Selecciona un semestre para crear una nueva instancia.</p>
                </header>
                <div class="flex flex-col items-start w-full gap-1">
                    <label for="semestre" class="block text-sm font-bold">Semestre</label>
                    <input type="text" id="semestre" v-model="semestre" required
                        class="block w-full text-base border border-zinc-700 rounded-md px-2 py-1" />
                </div>
                <div class="flex justify-end items-center w-full gap-4">
                    <button
                        class="bg-zinc-800 text-white font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-700 transition duration-300 cursor-pointer shadow-md text-nowrap"
                        type="button" @click="closeModal">
                        Cancelar
                    </button>
                    <button
                        class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap"
                        type="submit">
                        Crear Instancia
                    </button>
                </div>
            </form>
        </div>
    </section>
</template>