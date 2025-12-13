/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    darkMode: 'class',
    theme: {
        extend: {
            colors: {
                // Simple, clean primary color - soft blue
                primary: '#3B82F6',
                'primary-dark': '#2563EB',

                // Clean backgrounds
                'light-bg': '#FFFFFF',
                'dark-bg': '#1F2937',

                // Card backgrounds
                'card-light': '#F9FAFB',
                'card-dark': '#374151',

                // Text colors
                'text-light': '#111827',
                'text-dark': '#F3F4F6',
            },
            fontFamily: {
                sans: ['Inter', 'system-ui', 'sans-serif'],
            },
        },
    },
    plugins: [],
}
