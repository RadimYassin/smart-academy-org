import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import RemoteApp from '../components/RemoteApp';
import { useAuth } from '../contexts/AuthContext';
import { authApi, handleApiError } from '../api';

const AuthPage: React.FC = () => {
    const { isAuthenticated, login } = useAuth();
    const navigate = useNavigate();

    // Redirect if already authenticated
    useEffect(() => {
        if (isAuthenticated) {
            navigate('/', { replace: true });
        }
    }, [isAuthenticated, navigate]);

    // Listen for auth events from auth microfrontend
    useEffect(() => {
        const handleMessage = async (event: MessageEvent) => {
            // Handle login event
            if (event.data.type === 'AUTH_LOGIN') {
                try {
                    const { email, password } = event.data;
                    const response = await authApi.login({ email, password });

                    // Use decoded user from JWT token
                    if (response.decodedUser) {
                        login(response.decodedUser);

                        // Redirect based on role
                        const redirectPath = response.decodedUser.role === 'TEACHER'
                            ? '/teacher/dashboard'
                            : '/student/dashboard';
                        navigate(redirectPath, { replace: true });
                    } else {
                        // Fallback if decoding failed
                        login({ email });
                        navigate('/', { replace: true });
                    }
                } catch (err) {
                    const errorMsg = handleApiError(err);
                    if (errorMsg.includes('not verified') || errorMsg.includes('verification')) {
                        const authIframe = document.querySelector('iframe');
                        if (authIframe && authIframe.contentWindow) {
                            authIframe.contentWindow.postMessage(
                                { type: 'SHOW_VERIFICATION', email: event.data.email },
                                '*'
                            );
                        }
                    } else {
                        console.error('Login failed:', errorMsg);
                    }
                }
            }

            // Handle register event
            if (event.data.type === 'AUTH_REGISTER') {
                try {
                    const { firstName, lastName, email, password } = event.data;
                    await authApi.register({
                        firstName,
                        lastName,
                        email,
                        password,
                        role: 'TEACHER',
                    });

                    try {
                        const response = await authApi.login({ email, password });

                        if (response.decodedUser) {
                            login(response.decodedUser);
                            const redirectPath = response.decodedUser.role === 'TEACHER'
                                ? '/teacher/dashboard'
                                : '/student/dashboard';
                            navigate(redirectPath, { replace: true });
                        } else {
                            login({ email });
                            navigate('/', { replace: true });
                        }
                    } catch (loginErr) {
                        const errorMsg = handleApiError(loginErr);
                        if (errorMsg.includes('not verified') || errorMsg.includes('verification')) {
                            const authIframe = document.querySelector('iframe');
                            if (authIframe && authIframe.contentWindow) {
                                authIframe.contentWindow.postMessage(
                                    { type: 'SHOW_VERIFICATION', email: email },
                                    '*'
                                );
                            }
                        }
                    }
                } catch (err) {
                    console.error('Registration failed:', handleApiError(err));
                }
            }

            // Handle email verification
            if (event.data.type === 'VERIFY_EMAIL') {
                try {
                    const { email, code } = event.data;
                    await authApi.verifyEmail(email, code);
                    const authIframe = document.querySelector('iframe');
                    if (authIframe && authIframe.contentWindow) {
                        authIframe.contentWindow.postMessage(
                            { type: 'VERIFICATION_SUCCESS' },
                            '*'
                        );
                    }
                } catch (err) {
                    const authIframe = document.querySelector('iframe');
                    if (authIframe && authIframe.contentWindow) {
                        authIframe.contentWindow.postMessage(
                            { type: 'VERIFICATION_ERROR', error: handleApiError(err) },
                            '*'
                        );
                    }
                }
            }

            // Handle resend verification
            if (event.data.type === 'RESEND_VERIFICATION') {
                try {
                    await authApi.resendVerificationCode(event.data.email);
                } catch (err) {
                    console.error('Resend verification failed:', handleApiError(err));
                }
            }

            // Handle forgot password
            if (event.data.type === 'FORGOT_PASSWORD') {
                try {
                    await authApi.forgotPassword(event.data.email);
                } catch (err) {
                    console.error('Forgot password failed:', handleApiError(err));
                }
            }

            // Handle reset password
            if (event.data.type === 'RESET_PASSWORD') {
                try {
                    const { email, code, newPassword } = event.data;
                    await authApi.resetPassword(email, code, newPassword);
                    const authIframe = document.querySelector('iframe');
                    if (authIframe && authIframe.contentWindow) {
                        authIframe.contentWindow.postMessage(
                            { type: 'RESET_PASSWORD_SUCCESS' },
                            '*'
                        );
                    }
                } catch (err) {
                    const authIframe = document.querySelector('iframe');
                    if (authIframe && authIframe.contentWindow) {
                        authIframe.contentWindow.postMessage(
                            { type: 'RESET_PASSWORD_ERROR', error: handleApiError(err) },
                            '*'
                        );
                    }
                }
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, [login, navigate]);

    return <RemoteApp moduleName="auth" />;
};

export default AuthPage;
