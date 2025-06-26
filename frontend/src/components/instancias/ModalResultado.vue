<script setup>
import { ref, onUnmounted, watch } from 'vue';

/* LÓGICA DEL MODAL */

// Recibe la propiedad isModalOpen
const props = defineProps({
    isModalOpen: Boolean,
    resultado: String
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

</script>

<template>
    <section role="dialog" aria-modal="true" v-if="isModalOpen"
        class="fixed inset-0 flex items-center justify-center bg-[#000000dd] z-50">
        <transition name="fade-scale" appear>
            <div ref="modalContentRef"
                class="flex flex-col justify-center items-center rounded-md px-6 py-4 min-w-[300px] bg-zinc-950 border border-zinc-700">
                <div class="flex flex-col justify-start items-center gap-6 w-full">
                    <header class="flex flex-col justify-center items-center w-full text-center gap-4">
                        <h2 class="text-2xl font-bold">Resultado</h2>
                        <span class="bg-zinc-800 py-2 px-4 rounded-md border border-zinc-700 w-full">
                            <p class="text-xl">{{ resultado }}</p>
                        </span>
                    </header>
                    <div class="flex justify-center items-center w-full gap-4">
                        <button
                            class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap"
                            type="button" @click="closeModal">
                            Continuar
                        </button>
                    </div>
                </div>
            </div>
        </transition>
    </section>
</template>

<style scoped>
.fade-scale-enter-active,
.fade-scale-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}
.fade-scale-enter-from,
.fade-scale-leave-to {
  opacity: 0;
  transform: scale(0.95);
}
.fade-scale-enter-to,
.fade-scale-leave-from {
  opacity: 1;
  transform: scale(1);
}
</style>