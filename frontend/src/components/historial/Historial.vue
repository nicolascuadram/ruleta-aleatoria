<script setup>
import { ref } from 'vue';
import ModalHistorial from './ModalHistorial.vue';

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
});

const showModal = ref(false);

const toggleModal = () => {
    showModal.value = !showModal.value;
};
</script>

<template>
    <button
        class="bg-zinc-50 text-zinc-900 font-medium py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap"
        type="button" @click="toggleModal">
        Ver Historial
    </button>
    <ModalHistorial :isModalOpen="showModal" @close-modal="toggleModal" :id="id"/>
</template>