import React, { useState } from 'react';
import { Eye, EyeOff, ArrowLeft, GraduationCap } from 'lucide-react';
import { motion } from 'framer-motion';

interface RegisterPageProps {
    onRegister: (firstName: string, lastName: string, email: string, password: string) => void;
    onSwitchToLogin: () => void;
}

const RegisterPage: React.FC<RegisterPageProps> = ({ onRegister, onSwitchToLogin }) => {
    const [formData, setFormData] = useState({
        firstName: '',
        lastName: '',
        email: '',
        password: '',
        confirmPassword: '',
    });
    const [showPassword, setShowPassword] = useState(false);
    const [errors, setErrors] = useState<Record<string, string>>({});

    const validate = () => {
        const newErrors: Record<string, string> = {};

        if (!formData.firstName) {
            newErrors.firstName = 'First name is required';
        }

        if (!formData.lastName) {
            newErrors.lastName = 'Last name is required';
        }

        if (!formData.email) {
            newErrors.email = 'Email is required';
        } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
            newErrors.email = 'Email is invalid';
        }

        if (!formData.password) {
            newErrors.password = 'Password is required';
        } else if (formData.password.length < 8) {
            newErrors.password = 'Password must be at least 8 characters';
        }

        if (formData.password !== formData.confirmPassword) {
            newErrors.confirmPassword = 'Passwords do not match';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!validate()) return;

        // Call local handler
        onRegister(formData.firstName, formData.lastName, formData.email, formData.password);

        // Notify parent Shell via postMessage (Shell will handle API call)
        if (window.parent !== window) {
            window.parent.postMessage(
                {
                    type: 'AUTH_REGISTER',
                    firstName: formData.firstName,
                    lastName: formData.lastName,
                    email: formData.email,
                    password: formData.password,
                },
                '*'
            );
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
                    {/* Logo Icon */}
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

                    {/* Title */}
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-5xl font-bold mb-4 text-center"
                    >
                        Smart Academy
                    </motion.h1>

                    {/* Subtitle */}
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
                    {/* Back Button */}
                    <button
                        onClick={onSwitchToLogin}
                        className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-8 transition-colors"
                    >
                        <ArrowLeft size={20} />
                        <span className="text-sm font-medium">Back to Login</span>
                    </button>

                    <div className="mb-8">
                        <h2 className="text-3xl font-bold text-gray-900 mb-2">
                            Create Account
                        </h2>
                        <p className="text-gray-600 text-sm">
                            Sign up as a teacher to get started
                        </p>
                    </div>

                    <form onSubmit={handleSubmit} className="space-y-4">
                        {/* First Name */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                First Name
                            </label>
                            <input
                                type="text"
                                value={formData.firstName}
                                onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                                className={`w-full px-4 py-3 rounded-lg border ${errors.firstName
                                    ? 'border-red-500 focus:ring-red-500'
                                    : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                    } bg-white focus:ring-2 outline-none transition-all text-gray-900`}
                                placeholder="Enter your first name"
                            />
                            {errors.firstName && (
                                <p className="mt-1.5 text-sm text-red-500">{errors.firstName}</p>
                            )}
                        </div>

                        {/* Last Name */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Last Name
                            </label>
                            <input
                                type="text"
                                value={formData.lastName}
                                onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                                className={`w-full px-4 py-3 rounded-lg border ${errors.lastName
                                    ? 'border-red-500 focus:ring-red-500'
                                    : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                    } bg-white focus:ring-2 outline-none transition-all text-gray-900`}
                                placeholder="Enter your last name"
                            />
                            {errors.lastName && (
                                <p className="mt-1.5 text-sm text-red-500">{errors.lastName}</p>
                            )}
                        </div>

                        {/* Email */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Email
                            </label>
                            <input
                                type="email"
                                value={formData.email}
                                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                className={`w-full px-4 py-3 rounded-lg border ${errors.email
                                    ? 'border-red-500 focus:ring-red-500'
                                    : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                    } bg-white focus:ring-2 outline-none transition-all text-gray-900`}
                                placeholder="Enter your email"
                            />
                            {errors.email && (
                                <p className="mt-1.5 text-sm text-red-500">{errors.email}</p>
                            )}
                        </div>

                        {/* Password */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Password
                            </label>
                            <div className="relative">
                                <input
                                    type={showPassword ? 'text' : 'password'}
                                    value={formData.password}
                                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                                    className={`w-full px-4 py-3 rounded-lg border ${errors.password
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                        } bg-white focus:ring-2 outline-none transition-all pr-11 text-gray-900`}
                                    placeholder="Create a password"
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
                            <p className="mt-1 text-xs text-gray-500">At least 8 characters</p>
                        </div>

                        {/* Confirm Password */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Confirm Password
                            </label>
                            <input
                                type={showPassword ? 'text' : 'password'}
                                value={formData.confirmPassword}
                                onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                                className={`w-full px-4 py-3 rounded-lg border ${errors.confirmPassword
                                    ? 'border-red-500 focus:ring-red-500'
                                    : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                    } bg-white focus:ring-2 outline-none transition-all text-gray-900`}
                                placeholder="Confirm your password"
                            />
                            {errors.confirmPassword && (
                                <p className="mt-1.5 text-sm text-red-500">{errors.confirmPassword}</p>
                            )}
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            className="w-full bg-[#5B4FE9] hover:bg-[#4B3FD9] text-white py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-lg mt-2"
                        >
                            Create Account
                        </button>
                    </form>

                    {/* Login Link */}
                    <p className="mt-8 text-center text-gray-600 text-sm">
                        Already have an account?{' '}
                        <button
                            onClick={onSwitchToLogin}
                            className="text-[#5B4FE9] hover:text-[#4B3FD9] font-semibold transition-colors"
                        >
                            Sign in
                        </button>
                    </p>
                </motion.div>
            </div>
        </div>
    );
};

export default RegisterPage;
