<script setup>
import { ref, onUnmounted, watch } from 'vue';
import { Check, X } from 'lucide-vue-next';

/* LÓGICA DEL MODAL */

// Recibe la propiedad isModalOpen
const props = defineProps({
    items: {
        type: Object,
        required: true,
    },
    isModalOpen: Boolean
});

// Emitir eventos
const emit = defineEmits(['close-modal', 'update:content']);

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

const alert = ref(false);

// Función para actualizar el contenido de la ruleta
const updateContent = () => {
    const content = props.items.filter(item => item.active);
    if (content.length > 1){
        emit('update:content', content);
        closeModal();
    } else {
        alert.value = true;
    }
};
</script>

<template>
    <section role="dialog" aria-modal="true" v-if="isModalOpen"
        class="fixed inset-0 flex items-center justify-center bg-[#000000dd] z-50">
        <div ref="modalContentRef"
            class="flex flex-col justify-center items-center rounded-md px-6 py-4 bg-zinc-950 border border-zinc-700">
            <div class="flex flex-col justify-center items-center gap-4">
                <header class="flex flex-col w-full text-start gap-1">
                    <h2 class="text-xl font-bold">Quitar Items</h2>
                    <p class="text-sm">Desmarca los items que quieres quitar de la ruleta.</p>
                </header>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 w-full">
                    <span v-for="item in items" :key="item.name" @click="(item.active = !item.active) && (alert = false)"
                        :class="['flex justify-between items-center gap-8 p-2 bg-zinc-900 border border-zinc-700 rounded-md shadow-md cursor-pointer', { 'opacity-50': !item.active }]"
                    >
                        <p class="text-base font-medium">{{ item.name }}</p>
                        <Check v-if="item.active" />
                        <X v-else />
                    </span>
                </div>
                <div v-if="alert" class="flex justify-center items-center text-center w-full">
                    <p class="text-sm text-red-500">Debes seleccionar al menos 2 items!</p>
                </div>
                <div class="flex justify-end items-center w-full gap-4">
                    <button
                        class="bg-zinc-800 text-white font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-700 transition duration-300 cursor-pointer shadow-md text-nowrap"
                        type="button" @click="closeModal">
                        Cancelar
                    </button>
                    <button
                        class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap"
                        type="button" @click="updateContent">
                        Guardar
                    </button>
                </div>
            </div>
        </div>
    </section>
</template>