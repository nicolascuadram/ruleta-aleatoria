<script setup>
import { ref, watch, onMounted } from 'vue';
import { User, SquareKanban } from 'lucide-vue-next';

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
    equipos: {
        type: Array,
        default: () => [],
        required: true,
    }
});

// Emits
const emit = defineEmits(['equipo_seleccionado']);

const API_URL = import.meta.env.PUBLIC_API_URL;
const equipoSeleccionado = ref('');
const alumnos = ref(null);

// Función para obtener los alumnos de un grupo desde la API
const getAlumnos = async (grupoId) => {
    if (!grupoId) return;

    try {
        const response = await fetch(`${API_URL}/api/grupos/${grupoId}`, {
            method: "GET",
            headers: {
                "Content-Type": "application/json",
            },
        });

        if (!response.ok) {
            console.error("Status:", response.status);
            throw new Error(`Error en la respuesta del servidor: ${response.statusText}`);
        }

        const data = await response.json();
        alumnos.value = data;
        console.log("alumnos: ", alumnos.value)
    } catch (err) {
        console.error("Error fetching alumnos:", err);
    }
};

watch(equipoSeleccionado, (nuevoValor) => {
    getAlumnos(nuevoValor.id);
    emit('equipo_seleccionado', nuevoValor.id);
});

</script>

<template>
    <section class="flex flex-col justify-center items-center w-full h-full">
        <div v-if="equipos" class="flex flex-col items-center justify-start w-full h-full gap-2">
            <!-- Selector de equipo -->
            <div class="flex flex-col justify-start items-start w-full gap-1">
                <select v-model="equipoSeleccionado"
                    class="block w-full text-base border border-zinc-700 rounded-md px-2 py-1 bg-zinc-900 text-zinc-50 outline-none">
                    <option value="" disabled selected>Selecciona un equipo</option>
                    <option v-for="equipo in equipos" :key="equipo.id" :value="equipo" :disabled="equipo.yaEjecutado">
                        {{ equipo.nombre }}
                        <span v-if="equipo.yaEjecutado"> (ya ejecutado)</span>
                    </option>
                </select>
            </div>
            <!-- Equipo seleccionado -->
            <div v-if="equipoSeleccionado"
                class="flex flex-col w-full bg-zinc-900 border border-zinc-700 rounded-md p-6 gap-4 transition-all duration-300">
                <!-- Lista de proyectos -->
                <div class="flex flex-col justify-start items-start gap-2 w-full border-b border-zinc-700">
                    <h2 class="text-base font-semibold w-full">Proyectos:</h2>
                    <div class="w-full">
                        <div class="flex justify-start items-center w-full p-2 gap-2 border-t border-zinc-700">
                            <SquareKanban color="#fff" size="20" />
                            <p class="text-base font-medium">{{ equipoSeleccionado.proyecto1 }}</p>
                        </div>
                        <div class="flex justify-start items-center w-full p-2 gap-2 border-t border-zinc-700">
                            <SquareKanban color="#fff" size="20" />
                            <p class="text-base font-medium">{{ equipoSeleccionado.proyecto2 }}</p>
                        </div>
                    </div>
                </div>
                <!-- Lista de alumnos -->
                <section v-if="alumnos" class="flex flex-col items-start justify-start w-full gap-2">
                    <h2 class="text-base font-semibold">Integrantes:</h2>
                    <div class="flex flex-col items-center justify-start w-full border-b border-zinc-700">
                        <div v-for="alumno in alumnos" :key="alumno.id"
                            class="flex justify-start items-center w-full p-2 gap-2 border-t border-zinc-700">
                            <User color="#fff" size="20" />
                            <p class="text-base font-medium">{{ alumno.nombre }}</p>
                        </div>
                    </div>
                </section>
                <div v-else class="flex justify-center items-center w-full h-full">
                    <p class="text-lg font-medium text-zinc-50">Cargando alumnos...</p>
                </div>
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

    &,
    &::picker(select) {
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