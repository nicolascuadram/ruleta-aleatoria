<template>
  <div class="relative" v-if="id">
    <div class="flex flex-col items-start z-0">
      <div class="flex flex-row items-center justify-end">
        <a
          :href="`/historial/${id}`"
          class="bg-zinc-50 text-zinc-900 font-medium px-4 py-2 rounded-md cursor-pointer hover:bg-zinc-300 transition duration-300 shadow-md text-nowrap"
        >
          Historial
        </a>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const id = ref(null)

onMounted(() => {
  const pathSegments = window.location.pathname.split('/')
  id.value = pathSegments[pathSegments.length - 1]
})
</script>
