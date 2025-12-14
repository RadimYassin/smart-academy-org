import React, { useState } from 'react';
import { Mail, ArrowLeft, GraduationCap, Lock } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface ForgotPasswordProps {
    onBack: () => void;
    onCodeSent: (email: string) => void;
}

const ForgotPassword: React.FC<ForgotPasswordProps> = ({ onBack, onCodeSent }) => {
    const [email, setEmail] = useState('');
    const [isSubmitted, setIsSubmitted] = useState(false);
    const [error, setError] = useState('');

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        if (!email) {
            setError('Email is required');
            return;
        }

        if (!/\S+@\S+\.\S+/.test(email)) {
            setError('Please enter a valid email');
            return;
        }

        setError('');

        // Send message to Shell to handle password reset
        if (window.parent !== window) {
            window.parent.postMessage(
                {
                    type: 'FORGOT_PASSWORD',
                    email: email,
                },
                '*'
            );
        }

        setIsSubmitted(true);

        // Transition to reset password page after showing success
        setTimeout(() => {
            onCodeSent(email);
        }, 2000);
    };

    return (
        <div className="min-h-screen flex">
            {/* Left Side - Purple Gradient Branding */}
            <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-[#5B4FE9] via-[#6B5FFF] to-[#4B3FD9] relative overflow-hidden">
                <div className="absolute top-20 left-20 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
                <div className="absolute bottom-20 right-20 w-96 h-96 bg-white/10 rounded-full blur-3xl"></div>

                <div className="relative z-10 flex flex-col items-center justify-center w-full text-white p-12">
                    <motion.div
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        transition={{ duration: 0.5, type: "spring" }}
                        className="mb-8"
                    >
                        <div className="w-24 h-24 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center">
                            <GraduationCap size={48} strokeWidth={2} />
                        </div>
                    </motion.div>

                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-5xl font-bold mb-4 text-center"
                    >
                        Smart Academy
                    </motion.h1>

                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.3 }}
                        className="text-xl text-white/90 text-center max-w-md"
                    >
                        Your Learning Journey Starts Here
                    </motion.p>
                </div>
            </div>

            {/* Right Side - Form */}
            <div className="w-full lg:w-1/2 flex items-center justify-center bg-gray-50 p-8">
                <motion.div
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    className="w-full max-w-md"
                >
                    <button
                        onClick={onBack}
                        className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-8 transition-colors"
                    >
                        <ArrowLeft size={20} />
                        <span className="text-sm font-medium">Back to Login</span>
                    </button>

                    <AnimatePresence mode="wait">
                        {!isSubmitted ? (
                            <motion.div
                                key="form"
                                initial={{ opacity: 0 }}
                                animate={{ opacity: 1 }}
                                exit={{ opacity: 0 }}
                            >
                                <div className="mb-8 text-center">
                                    <div className="w-16 h-16 bg-[#5B4FE9]/10 rounded-full flex items-center justify-center mx-auto mb-4">
                                        <Lock className="text-[#5B4FE9]" size={32} />
                                    </div>
                                    <h2 className="text-3xl font-bold text-gray-900 mb-2">
                                        Forgot Password?
                                    </h2>
                                    <p className="text-gray-600 text-sm">
                                        No worries! Enter your email and we'll send you reset instructions.
                                    </p>
                                </div>

                                <form onSubmit={handleSubmit} className="space-y-6">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-2">
                                            Email Address
                                        </label>
                                        <div className="relative">
                                            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
                                            <input
                                                type="email"
                                                value={email}
                                                onChange={(e) => setEmail(e.target.value)}
                                                className={`w-full pl-11 pr-4 py-3 rounded-lg border ${error
                                                    ? 'border-red-500 focus:ring-red-500'
                                                    : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                                    } bg-white focus:ring-2 outline-none transition-all text-gray-900`}
                                                placeholder="Enter your email"
                                            />
                                        </div>
                                        {error && (
                                            <p className="mt-1.5 text-sm text-red-500">{error}</p>
                                        )}
                                    </div>

                                    <button
                                        type="submit"
                                        className="w-full bg-[#5B4FE9] hover:bg-[#4B3FD9] text-white py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-lg"
                                    >
                                        Send Reset Link
                                    </button>
                                </form>
                            </motion.div>
                        ) : (
                            <motion.div
                                key="success"
                                initial={{ opacity: 0, scale: 0.9 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0 }}
                                className="text-center py-8"
                            >
                                <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
                                    <svg className="w-10 h-10 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                </div>
                                <h3 className="text-2xl font-bold text-gray-900 mb-4">
                                    Check Your Email
                                </h3>
                                <p className="text-gray-600 mb-2">
                                    We've sent password reset instructions to
                                </p>
                                <p className="font-semibold text-gray-900 mb-6">
                                    {email}
                                </p>
                                <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                                    <p className="text-sm text-blue-800">
                                        📧 Check your inbox and follow the instructions to reset your password.
                                    </p>
                                </div>
                                <p className="text-sm text-gray-500 mt-6">
                                    Didn't receive the email? Check your spam folder or{' '}
                                    <button
                                        onClick={() => setIsSubmitted(false)}
                                        className="text-[#5B4FE9] hover:text-[#4B3FD9] font-semibold transition-colors"
                                    >
                                        try again
                                    </button>
                                </p>
                            </motion.div>
                        )}
                    </AnimatePresence>
                </motion.div>
            </div>
        </div>
    );
};

export default ForgotPassword;
