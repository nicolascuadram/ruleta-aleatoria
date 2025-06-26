<template>
  <div class="relative" v-if="id">
    <div class="flex flex-col items-start z-0">
      <div class="flex flex-row items-center justify-end">
        <a
        :href="`/instancia/${id}`"
        class="bg-zinc-50 text-zinc-900 font-medium px-4 py-2 rounded-md cursor-pointer hover:bg-zinc-300 transition duration-300 shadow-md text-nowrap w-28 text-center flex items-center justify-center gap-2"
        >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
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

