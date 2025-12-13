import React from 'react'
import ReactDOM from 'react-dom/client'
import AuthApp from './AuthApp.tsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AuthApp />
  </React.StrictMode>,
)
