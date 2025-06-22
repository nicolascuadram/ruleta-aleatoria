<script setup>
import { ref, computed, onUnmounted, watch, onMounted } from 'vue';
import CardRegistro from './CardRegistro.vue';

const API_URL = import.meta.env.PUBLIC_API_URL;

const props = defineProps({
    isModalOpen: Boolean,
    id: {
        type: String,
        required: true,
    },
});

const emit = defineEmits(['close-modal']);

const modalContentRef = ref(null);

const closeModal = () => emit('close-modal');

const handleEscape = (e) => {
    if (e.key === 'Escape') closeModal();
};

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

const registros = ref([]);
const nroSemanas = ref(0);
const semanaSeleccionada = ref("");

// Obtener registros
const getHistorial = async () => {
    try {
        const response = await fetch(`${API_URL}/api/registros/${props.id}`);
        const data = await response.json();
        registros.value = data;
        console.log("registros: ", registros.value)
    } catch (err) {
        console.error("Error obteniendo historial:", err);
    }
};

// Obtener cantidad de semanas
const getNumeroSemanas = async () => {
    try {
        const response = await fetch(`${API_URL}/api/instancia/${props.id}/semanas`);
        const data = await response.json();
        nroSemanas.value = data.nro_semanas;
    } catch (err) {
        console.error("Error obteniendo nro_semanas:", err);
    }
};

const registrosFiltrados = computed(() => {
    if (!semanaSeleccionada.value) return registros.value;
    return registros.value.filter(r => r.semana === parseInt(semanaSeleccionada.value));
});

const formattedDate = (dateString) => {
    const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', options);
};

onMounted(() => {
    getHistorial();
    getNumeroSemanas();
});
</script>

<template>
    <section role="dialog" aria-modal="true" v-if="isModalOpen"
        class="fixed inset-0 flex items-start justify-center bg-[#000000dd] z-50 py-8 overflow-y-scroll hide-scrollbar">
        <div ref="modalContentRef"
            class="flex flex-col w-2/3 justify-start items-center rounded-md px-6 py-4 bg-zinc-950 border border-zinc-700">
            <!-- Lista de registros -->
            <select v-model="semanaSeleccionada"
                class="w-full text-base border border-zinc-700 rounded-md px-2 py-1 bg-zinc-900 text-zinc-50 outline-none mb-4">
                <option value="">Todas las semanas</option>
                <option v-for="n in nroSemanas" :key="n" :value="n">Semana {{ n }}</option>
            </select>

            <div class="flex flex-col items-center justify-start w-full h-full p-4 gap-4">
                <h1 class="text-2xl font-semibold">Historial</h1>
                <div class="flex flex-wrap gap-4 w-full h-full">
                    <CardRegistro
                        v-for="registro in registrosFiltrados"
                        :key="registro.id"
                        :semana="registro.semana"
                        :grupo="registro.grupo"
                        :categoria="registro.tipo_incidencia"
                        :subcategoria="registro.subcategoria"
                        :alumno="registro.alumno"
                        :otro_equipo="registro.otro_equipo"
                        :alumno_otro_equipo="registro.alumno_otro_equipo"
                        :incidencia="registro.incidencia"
                        :comentario="registro.comentario"
                        :fecha="formattedDate(registro.fecha)"
                    />
                </div>
            </div>
        </div>
    </section>
</template>

<style scoped>
select {
    &,
    &::picker(select) {
        appearance: base-select;
    }
}

::picker(select) {
    background-color: #18181b;
    color: #ffffff;
    border-radius: 6px;
    border: 1px solid #3f3f46;
    top: calc(anchor(bottom) + 2px);
}

select::picker-icon {
    width: 24px;
    height: 24px;
    content: url("../../assets/chevron-down.svg");
    transition: 0.3s rotate;
}

select:open::picker-icon {
    rotate: 180deg;
}

select option {
    background-color: #18181b;
    color: #ffffff;
    padding: 4px 8px;
}

select option:checked,
select option:hover {
    background-color: #fafafa;
    color: #18181b;
}

select option:disabled {
    background-color: #18181b;
    color: #3f3f46;
}

option::checkmark {
    display: none;
}
</style>
