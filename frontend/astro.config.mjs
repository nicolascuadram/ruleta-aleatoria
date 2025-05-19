import { defineConfig } from 'astro/config';

import vue from '@astrojs/vue';
import node from '@astrojs/node';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
	integrations: [vue()],
	output: 'server',
	adapter: node({ mode: 'standalone' }),
	vite: {
		plugins: [tailwindcss()]
	}
});