<script setup>
import { ref, computed, onMounted } from 'vue';
import CardRegistro from './CardRegistro.vue';

const API_URL = import.meta.env.PUBLIC_API_URL;

const props = defineProps({
    id: {
        type: String,
        required: true,
    },
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
        console.log("registros: ", registros.value);
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
    <main class="min-h-screen bg-zinc-950 text-zinc-50 p-8">
        <div class="max-w-6xl mx-auto">
            <!-- Encabezado -->
            <header class="mb-8">
                <h1 class="text-3xl font-bold mb-4">Historial Instancia {{id}}</h1>
                
                <!-- Selector de semana -->
                <select v-model="semanaSeleccionada"
                    class="w-full md:w-64 text-base border border-zinc-700 rounded-md px-4 py-2 bg-zinc-900 text-zinc-50 outline-none">
                    <option value="">Todas las semanas</option>
                    <option v-for="n in nroSemanas" :key="n" :value="n">Semana {{ n }}</option>
                </select>
            </header>

            <!-- Lista de registros -->
            <section>
                <div v-if="registrosFiltrados.length > 0" class="grid grid-cols-1 md:grid-cols-1 lg:grid-cols-1 gap-6">
                    <CardRegistro 
                        v-for="registro in registrosFiltrados" 
                        :key="registro.id"
                        :categoria="registro.tipo_incidencia" 
                        :incidencia="registro.incidencia" 
                        :grupo="registro.grupo"
                        :alumnoescogido="registro.alumno" 
                        :otrogrupo="Number(registro.grupo_intercambio)"
                        :otroalumno="Number(registro.alumno_intercambio)"
                        :fecha="formattedDate(registro.fecha)"
                        :comentario="registro.comentario" 
                        :semana="registro.semana"
                    />
                </div>
                
                <div v-else class="text-center py-12 text-zinc-400">
                    <p>No hay registros disponibles</p>
                </div>
            </section>
        </div>
    </main>
</template>

<style scoped>
/* Estilos para el select */
select {
    appearance: none;
    background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='white'%3e%3cpath d='M7 10l5 5 5-5z'/%3e%3c/svg%3e");
    background-repeat: no-repeat;
    background-position: right 0.75rem center;
    background-size: 1.5rem;
}

select:focus {
    border-color: #6366f1;
    outline: none;
    box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.25);
}

/* Estilos para las opciones */
select option {
    background-color: #18181b;
    color: #ffffff;
    padding: 0.5rem;
}

select option:hover {
    background-color: #3f3f46;
}
</style>