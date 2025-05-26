<script setup>
import { ref, computed } from 'vue'

// Variables reactivas
const seed = ref(Date.now())
const categoriaSeleccionada = ref(null)
const incidenciaSeleccionada = ref(null)

// Lista de incidencias
const incidencias = [
    { id: 1, categoria: 'Organizacional', descripcion: 'Cambia de JP/SM' },
    { id: 2, categoria: 'Organizacional', descripcion: 'Cambia de proyecto principal' },
    { id: 3, categoria: 'Organizacional', descripcion: 'Cambia de tablero kanban' },
    { id: 4, categoria: 'Organizacional', descripcion: 'Cambia de horario de trabajo' },
    { id: 5, categoria: 'Organizacional', descripcion: 'Cambia de planificación' },
    { id: 6, categoria: 'Operativo', descripcion: 'Error en el sistema' },
    { id: 7, categoria: 'Operativo', descripcion: 'Error en la planificación' },
    { id: 8, categoria: 'Operativo', descripcion: 'Error de hardware' },
    { id: 9, categoria: 'Operativo', descripcion: 'Error de comunicación' },
    { id: 10, categoria: 'Operativo', descripcion: 'Error de equipo' },
    { id: 11, categoria: 'Tecnológico', descripcion: 'Actualizar librerías/api a última versión' },
    { id: 12, categoria: 'Tecnológico', descripcion: 'Cambiar el IDE de desarrollo' },
    { id: 13, categoria: 'Tecnológico', descripcion: 'Explora implementación alternativa' },
    { id: 14, categoria: 'Tecnológico', descripcion: 'Cambia de librería/api de desarrollo' },
    { id: 15, categoria: 'Tecnológico', descripcion: 'Cambia de entorno de desarrollo' },
    { id: 16, categoria: 'Proyecto', descripcion: 'Desarrollador con licencia' },
    { id: 17, categoria: 'Proyecto', descripcion: 'Cambiar el horario de reunión' },
    { id: 18, categoria: 'Proyecto', descripcion: 'Intercambia un desarrollador(a) a otro proyecto' },
    { id: 19, categoria: 'Proyecto', descripcion: 'Priorizar un solo proyecto' },
    { id: 20, categoria: 'Proyecto', descripcion: 'Grupo en congeladora' },
    { id: 21, categoria: 'Personal', descripcion: 'Desarrollador con actividad personal' },
    { id: 22, categoria: 'Personal', descripcion: 'Desarrollador genera conflicto grupal' },
    { id: 23, categoria: 'Personal', descripcion: 'Desarrollador prioriza tareas administrativas de proyecto' },
    { id: 24, categoria: 'Personal', descripcion: 'Desarrollador genera malestar invididual' },
    { id: 25, categoria: 'Personal', descripcion: 'Solicita cambio de SM/JP' },
]

// Extraer las categorías únicas
const categorias = computed(() => [...new Set(incidencias.map(i => i.categoria))])

// Algoritmo Xorshift
function xorshift() {
    let x = seed.value >>> 0
    x ^= x << 13
    x ^= x >> 17
    x ^= x << 5
    seed.value = x >>> 0
    return seed.value
}

// Función para generar categoría e incidencia aleatoria
function generarIncidenciaAleatoria() {
    // Elegir categoría aleatoria
    const indiceCategoria = xorshift() % categorias.value.length
    categoriaSeleccionada.value = categorias.value[indiceCategoria]

    // Filtrar incidencias por categoría
    const incidenciasPorCategoria = incidencias.filter(i => i.categoria === categoriaSeleccionada.value)

    // Elegir una incidencia aleatoria dentro de esa categoría
    const indiceIncidencia = xorshift() % incidenciasPorCategoria.length
    incidenciaSeleccionada.value = incidenciasPorCategoria[indiceIncidencia]
}
</script>

<template>
  <section class="flex flex-col justify-center items-center w-full h-full gap-2 text-center">
    <button
      class="bg-zinc-50 text-zinc-900 font-medium text-base py-2 px-4 rounded-md hover:bg-zinc-300 transition duration-300 cursor-pointer shadow-md text-nowrap"
      @click="generarIncidenciaAleatoria"
    >
      Generar Incidencia
    </button>

    <div v-if="incidenciaSeleccionada">
      <p class="font-semibold text-lg">Categoría: {{ categoriaSeleccionada }}</p>
      <p class="text-zinc-700">Descripción: {{ incidenciaSeleccionada.descripcion }}</p>
    </div>
  </section>
</template>