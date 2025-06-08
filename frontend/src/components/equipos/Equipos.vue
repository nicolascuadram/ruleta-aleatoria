<script setup> 
import Alumnos from "./Alumnos.vue";
import { ref, onMounted, watch} from 'vue';

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
    equipos: {
        type: Array,
        default: () => [],
        required: true,
    },
});

// Emits
const emit = defineEmits(['equipo_seleccionado']);

const API_URL = import.meta.env.PUBLIC_API_URL;
const equipoSeleccionado = ref('');



watch(equipoSeleccionado, (nuevoValor) => {
    console.log("Equipo seleccionado (id):", equipoSeleccionado.value);
    emit('equipo_seleccionado',equipoSeleccionado.value);
    console.log("Nuevo equipo seleccionado (id):", nuevoValor);
    
});
</script>

<template>
    <section class="flex flex-col justify-center items-center w-full h-full">
        <div v-if="equipos" class="flex flex-col items-center justify-start w-full h-full gap-2">
            <!-- Selector de equipo -->
            <div class="flex flex-col justify-start items-start w-full gap-1">
                <!-- <label class="block text-base font-medium text-zinc-50">Equipo seleccionado:</label> -->
                <select v-model="equipoSeleccionado" class="block w-full text-base border border-zinc-700 rounded-md px-2 py-1 bg-zinc-900 text-zinc-50 outline-none">
                    <option value="" disabled selected>Selecciona un equipo</option>
                    <option v-for="equipo in equipos" :key="equipo.id" :value="equipo.id">
                        {{ equipo.nombre }}
                        
                    </option>
                </select>
            </div>
            <!-- Equipo seleccionado -->
            <div v-if="equipoSeleccionado" class="flex flex-col justify-start items-start w-full bg-zinc-900 border border-zinc-700 rounded-md shadow-md p-4">
                <Alumnos :id="equipoSeleccionado" />
            </div>
        </div>
        <div v-else class="flex justify-center items-center w-full h-full">
            <p class="text-lg font-medium text-zinc-50">Cargando equipos...</p>
        </div>
    </section>
</template>

<style scoped>
/* Habilitar estilos personalizables para el select (Chrome) */
select {
    &, &::picker(select) {
        appearance: base-select;
    }
}

/* Estilos del select */
::picker(select) {
    background-color: #18181b;
    color: #ffffff;
    border-radius: 6px;
    border: 1px solid #3f3f46;
    top: calc(anchor(bottom) + 2px);
}

/* Icono del select */
select::picker-icon {
    width: 24px;
    height: 24px;
    content: url("../../assets/chevron-down.svg");
    transition: 0.3s rotate;
}

select:open::picker-icon {
  rotate: 180deg;
}

/* Estilos de las opciones del select */
select option {
    background-color: #18181b;
    color: #ffffff;
    padding: 4px 8px;
}

select option:checked, select option:hover {
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