<script setup>
import { ref, onUnmounted, watch, onMounted } from 'vue';
import CardRegistro from './CardRegistro.vue';
const API_URL = import.meta.env.PUBLIC_API_URL;

/* LÓGICA DEL MODAL */

// Recibe la propiedad isModalOpen
const props = defineProps({
    isModalOpen: Boolean,
    id: {
        type: String,
        required: true,
    },
});

// Emitir eventos
const emit = defineEmits(['close-modal']);

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

const registros = ref(null);

// Función para obtener los registros del historial
const getHistorial = async () => {
    try {
        const response = await fetch(API_URL + `/api/registros/${props.id}`, {
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
        registros.value = data;
    } catch (err) {
        console.error("Error obteniendo historial:", err);
    }
};

const formattedDate = (dateString) => {
    const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', options);
};

onMounted(() => {
    getHistorial();
});
</script>

<template>
    <section role="dialog" aria-modal="true" v-if="isModalOpen" class="fixed inset-0 flex items-start justify-center bg-[#000000dd] z-50 py-8 overflow-y-scroll hide-scrollbar">
        <div ref="modalContentRef" class="flex flex-col w-2/3 justify-start items-center rounded-md px-6 py-4 bg-zinc-950 border border-zinc-700">
            <!-- Lista de registros -->
            <div class="flex flex-col items-center justify-start w-full h-full p-4 gap-4">
                <h1 class="text-2xl font-semibold">Historial</h1>
                <div class="flex flex-wrap gap-4 w-full h-full">
                    <CardRegistro v-for="registro in registros" :key="registro.id" 
                        :categoria="registro.tipo_incidencia"
                        :incidencia="registro.incidencia"
                        :grupo="registro.grupo"
                        :alumno="registro.alumno"
                        :fecha="formattedDate(registro.fecha)"
                        :comentario="registro.comentario"
                    />
                </div>
            </div>
        </div>
    </section>
</template>