import React, { useEffect, useRef } from 'react';

interface RemoteAppProps {
    moduleName: 'auth' | 'dashboard' | 'courses';
    theme?: 'light' | 'dark';
    page?: string;
    onAuth?: (email: string, password: string) => void;
}

const REMOTE_URLS = {
    auth: 'http://localhost:5002',
    dashboard: 'http://localhost:5003',
    courses: 'http://localhost:5004',
};

const RemoteApp: React.FC<RemoteAppProps> = ({ moduleName, theme, page, onAuth }) => {
    const iframeRef = useRef<HTMLIFrameElement>(null);

    // Send theme updates to iframe
    useEffect(() => {
        if (iframeRef.current && theme) {
            const iframe = iframeRef.current;
            // Wait a bit for iframe to load before sending message
            const timer = setTimeout(() => {
                iframe.contentWindow?.postMessage(
                    { type: 'THEME_CHANGE', theme },
                    REMOTE_URLS[moduleName]
                );
            }, 500);
            return () => clearTimeout(timer);
        }
    }, [theme, moduleName]);

    // Send page updates to iframe
    useEffect(() => {
        if (iframeRef.current && page) {
            const iframe = iframeRef.current;
            const timer = setTimeout(() => {
                iframe.contentWindow?.postMessage(
                    { type: 'PAGE_CHANGE', page },
                    REMOTE_URLS[moduleName]
                );
            }, 500);
            return () => clearTimeout(timer);
        }
    }, [page, moduleName]);

    // Listen for messages from iframe
    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            // Verify origin is from localhost (for development)
            if (!event.origin.includes('localhost') && !event.origin.includes('127.0.0.1')) {
                return;
            }

            if (event.data.type === 'AUTH_SUCCESS' && onAuth) {
                onAuth(event.data.email, event.data.password);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, [onAuth]);

    // Send initial theme and page when iframe loads
    const handleIframeLoad = () => {
        if (iframeRef.current) {
            if (theme) {
                iframeRef.current.contentWindow?.postMessage(
                    { type: 'THEME_CHANGE', theme },
                    REMOTE_URLS[moduleName]
                );
            }
            if (page) {
                iframeRef.current.contentWindow?.postMessage(
                    { type: 'PAGE_CHANGE', page },
                    REMOTE_URLS[moduleName]
                );
            }
        }
    };

    return (
        <iframe
            ref={iframeRef}
            src={REMOTE_URLS[moduleName]}
            onLoad={handleIframeLoad}
            className="w-full h-full border-0"
            style={{
                minHeight: '100vh',
                display: 'block'
            }}
            title={`${moduleName} microfrontend`}
        />
    );
};

export default RemoteApp;

