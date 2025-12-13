import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import federation from '@originjs/vite-plugin-federation'

export default defineConfig({
  plugins: [
    react(),
    federation({
      name: 'courses',
      filename: 'remoteEntry.js',
      exposes: {
        './CoursesApp': './src/CoursesApp.tsx',
      },
      shared: ['react', 'react-dom']
    })
  ],
  server: {
    port: 5004,
    strictPort: true,
    cors: true,
  },
  preview: {
    port: 5004,
    strictPort: true,
    cors: true,
  },
  build: {
    target: 'esnext',
    minify: false,
    cssCodeSplit: false
  }
})
