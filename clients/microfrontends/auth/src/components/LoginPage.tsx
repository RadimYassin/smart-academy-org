import React, { useState } from 'react';
import { Mail, Phone, Eye, EyeOff, ArrowLeft, BookOpen } from 'lucide-react';
import { motion } from 'framer-motion';

interface LoginPageProps {
    onLogin: (email: string, password: string) => void;
    onSwitchToRegister: () => void;
    onForgotPassword: () => void;
}

const LoginPage: React.FC<LoginPageProps> = ({ onLogin, onSwitchToRegister, onForgotPassword }) => {
    const [loginMethod, setLoginMethod] = useState<'email' | 'phone'>('email');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [errors, setErrors] = useState<{ email?: string; password?: string }>({});

    const validate = () => {
        const newErrors: { email?: string; password?: string } = {};

        if (!email) {
            newErrors.email = loginMethod === 'email' ? 'Email is required' : 'Phone is required';
        } else if (loginMethod === 'email' && !/\S+@\S+\.\S+/.test(email)) {
            newErrors.email = 'Email is invalid';
        }

        if (!password) {
            newErrors.password = 'Password is required';
        } else if (password.length < 6) {
            newErrors.password = 'Password must be at least 6 characters';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (validate()) {
            // Call local handler
            onLogin(email, password);

            // Notify parent Shell via postMessage (for iframe integration)
            if (window.parent !== window) {
                window.parent.postMessage(
                    {
                        type: 'AUTH_SUCCESS',
                        email,
                        password
                    },
                    '*' // Use wildcard for cross-origin iframe communication
                );
            }
        }
    };

    return (
        <div className="min-h-screen flex">
            {/* Left Side - Purple Gradient Branding */}
            <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-[#5B4FE9] via-[#6B5FFF] to-[#4B3FD9] relative overflow-hidden">
                {/* Decorative circles */}
                <div className="absolute top-20 left-20 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
                <div className="absolute bottom-20 right-20 w-96 h-96 bg-white/10 rounded-full blur-3xl"></div>

                <div className="relative z-10 flex flex-col items-center justify-center w-full text-white p-12">
                    {/* Book Icon */}
                    <motion.div
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        transition={{ duration: 0.5, type: "spring" }}
                        className="mb-8"
                    >
                        <div className="w-24 h-24 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center">
                            <BookOpen size={48} strokeWidth={2} />
                        </div>
                    </motion.div>

                    {/* Title */}
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-5xl font-bold mb-4 text-center"
                    >
                        Master New Skills
                    </motion.h1>

                    {/* Subtitle */}
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.3 }}
                        className="text-xl text-white/90 text-center max-w-md"
                    >
                        Join thousands of learners advancing their careers with Overskill
                    </motion.p>
                </div>
            </div>

            {/* Right Side - White Form */}
            <div className="w-full lg:w-1/2 flex items-center justify-center bg-gray-50 p-8">
                <motion.div
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    className="w-full max-w-md"
                >


                    {/* Sign In Header */}
                    <div className="mb-8">
                        <h2 className="text-3xl font-bold text-gray-900 mb-2">
                            Sign In
                        </h2>
                        <p className="text-gray-600 text-sm">
                            Welcome back! Please enter your details
                        </p>
                    </div>

                    {/* Email/Phone Toggle */}
                    <div className="flex gap-3 mb-6">
                        <button
                            onClick={() => setLoginMethod('email')}
                            className={`flex-1 flex items-center justify-center gap-2 py-3 px-4 rounded-lg font-medium transition-all ${loginMethod === 'email'
                                    ? 'bg-[#5B4FE9] text-white shadow-md'
                                    : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50'
                                }`}
                        >
                            <Mail size={18} />
                            Email
                        </button>
                        <button
                            onClick={() => setLoginMethod('phone')}
                            className={`flex-1 flex items-center justify-center gap-2 py-3 px-4 rounded-lg font-medium transition-all ${loginMethod === 'phone'
                                    ? 'bg-[#5B4FE9] text-white shadow-md'
                                    : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50'
                                }`}
                        >
                            <Phone size={18} />
                            Phone
                        </button>
                    </div>

                    <form onSubmit={handleSubmit} className="space-y-5">
                        {/* Email/Phone Input */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                {loginMethod === 'email' ? 'Email' : 'Phone'}
                            </label>
                            <input
                                type={loginMethod === 'email' ? 'email' : 'tel'}
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                className={`w-full px-4 py-3 rounded-lg border ${errors.email
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                    } bg-white focus:ring-2 outline-none transition-all text-gray-900`}
                                placeholder={loginMethod === 'email' ? 'Enter your email' : 'Enter your phone'}
                            />
                            {errors.email && (
                                <p className="mt-1.5 text-sm text-red-500">{errors.email}</p>
                            )}
                        </div>

                        {/* Password Input */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Password
                            </label>
                            <div className="relative">
                                <input
                                    type={showPassword ? 'text' : 'password'}
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    className={`w-full px-4 py-3 rounded-lg border ${errors.password
                                            ? 'border-red-500 focus:ring-red-500'
                                            : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                        } bg-white focus:ring-2 outline-none transition-all pr-11 text-gray-900`}
                                    placeholder="Enter your password"
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
                                >
                                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                                </button>
                            </div>
                            {errors.password && (
                                <p className="mt-1.5 text-sm text-red-500">{errors.password}</p>
                            )}
                        </div>

                        {/* Forgot Password Link */}
                        <div className="flex justify-end">
                            <button
                                type="button"
                                onClick={onForgotPassword}
                                className="text-sm text-[#5B4FE9] hover:text-[#4B3FD9] font-medium transition-colors"
                            >
                                Forgot Password?
                            </button>
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            className="w-full bg-[#5B4FE9] hover:bg-[#4B3FD9] text-white py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-lg"
                        >
                            Sign In
                        </button>
                    </form>

                    {/* Register Link */}
                    <p className="mt-8 text-center text-gray-600 text-sm">
                        Don't have an account?{' '}
                        <button
                            onClick={onSwitchToRegister}
                            className="text-[#5B4FE9] hover:text-[#4B3FD9] font-semibold transition-colors"
                        >
                            Sign Up
                        </button>
                    </p>
                </motion.div>
            </div>
        </div>
    );
};

export default LoginPage;
