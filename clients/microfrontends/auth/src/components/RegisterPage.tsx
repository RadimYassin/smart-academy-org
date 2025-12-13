import React, { useState, useRef, useEffect } from 'react';
import { Eye, EyeOff, ArrowLeft, BookOpen } from 'lucide-react';
import { motion } from 'framer-motion';

interface RegisterPageProps {
    onRegister: (name: string, email: string, password: string) => void;
    onSwitchToLogin: () => void;
}

type RegistrationStep = 'account' | 'verification' | 'phone';

const RegisterPage: React.FC<RegisterPageProps> = ({ onRegister, onSwitchToLogin }) => {
    const [step, setStep] = useState<RegistrationStep>('account');
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        password: '',
        verificationCode: ['', '', '', '', ''],
        phone: '',
    });
    const [showPassword, setShowPassword] = useState(false);
    const [errors, setErrors] = useState<Record<string, string>>({});

    // Refs for verification code inputs
    const codeInputRefs = useRef<(HTMLInputElement | null)[]>([]);

    const validateAccount = () => {
        const newErrors: Record<string, string> = {};

        if (!formData.name) {
            newErrors.name = 'Full name is required';
        } else if (formData.name.length < 2) {
            newErrors.name = 'Name must be at least 2 characters';
        }

        if (!formData.email) {
            newErrors.email = 'Email is required';
        } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
            newErrors.email = 'Email is invalid';
        }

        if (!formData.password) {
            newErrors.password = 'Password is required';
        } else if (formData.password.length < 6) {
            newErrors.password = 'Password must be at least 6 characters';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleAccountSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (validateAccount()) {
            setStep('verification');
        }
    };

    const handleVerificationSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        const code = formData.verificationCode.join('');
        if (code.length === 5) {
            setStep('phone');
        } else {
            setErrors({ verification: 'Please enter the complete verification code' });
        }
    };

    const handlePhoneSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        // Complete registration
        completeRegistration();
    };

    const handleSkipPhone = () => {
        // Skip phone step and complete registration
        completeRegistration();
    };

    const completeRegistration = () => {
        onRegister(formData.name, formData.email, formData.password);
    };

    const handleCodeInput = (index: number, value: string) => {
        // Only allow single digit
        if (value.length > 1) {
            value = value.slice(-1);
        }

        const newCode = [...formData.verificationCode];
        newCode[index] = value;
        setFormData({ ...formData, verificationCode: newCode });

        // Auto-advance to next input
        if (value && index < 4) {
            codeInputRefs.current[index + 1]?.focus();
        }
    };

    const handleCodeKeyDown = (index: number, e: React.KeyboardEvent) => {
        if (e.key === 'Backspace' && !formData.verificationCode[index] && index > 0) {
            codeInputRefs.current[index - 1]?.focus();
        }
    };

    const handleBack = () => {
        if (step === 'verification') {
            setStep('account');
        } else if (step === 'phone') {
            setStep('verification');
        } else {
            onSwitchToLogin();
        }
    };

    // Auto-focus first code input when entering verification step
    useEffect(() => {
        if (step === 'verification') {
            codeInputRefs.current[0]?.focus();
        }
    }, [step]);

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

            {/* Right Side - Form */}
            <div className="w-full lg:w-1/2 flex items-center justify-center bg-gray-50 p-8">
                <motion.div
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    className="w-full max-w-md"
                >
                    {/* Back Button */}
                    <button
                        onClick={handleBack}
                        className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-8 transition-colors"
                    >
                        <ArrowLeft size={20} />
                        <span className="text-sm font-medium">Back</span>
                    </button>

                    {/* Step 1: Create Account */}
                    {step === 'account' && (
                        <motion.div
                            key="account"
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                        >
                            <div className="mb-8">
                                <h2 className="text-3xl font-bold text-gray-900 mb-2">
                                    Create Account
                                </h2>
                                <p className="text-gray-600 text-sm">
                                    Sign up to get started
                                </p>
                            </div>

                            <form onSubmit={handleAccountSubmit} className="space-y-5">
                                {/* Full Name */}
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2">
                                        Full Name
                                    </label>
                                    <input
                                        type="text"
                                        value={formData.name}
                                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                        className={`w-full px-4 py-3 rounded-lg border ${errors.name
                                                ? 'border-red-500 focus:ring-red-500'
                                                : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                            } bg-white focus:ring-2 outline-none transition-all text-gray-900`}
                                        placeholder="Enter your full name"
                                    />
                                    {errors.name && (
                                        <p className="mt-1.5 text-sm text-red-500">{errors.name}</p>
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
                                </div>

                                {/* Submit Button */}
                                <button
                                    type="submit"
                                    className="w-full bg-[#5B4FE9] hover:bg-[#4B3FD9] text-white py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-lg mt-2"
                                >
                                    Sign Up
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
                    )}

                    {/* Step 2: Verification Code */}
                    {step === 'verification' && (
                        <motion.div
                            key="verification"
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                        >
                            <div className="mb-8">
                                <h2 className="text-3xl font-bold text-gray-900 mb-2">
                                    Verification Code
                                </h2>
                                <p className="text-gray-600 text-sm">
                                    We've sent a code to
                                </p>
                            </div>

                            <form onSubmit={handleVerificationSubmit} className="space-y-8">
                                {/* 5-Digit Code Input */}
                                <div className="flex gap-3 justify-center">
                                    {[0, 1, 2, 3, 4].map((index) => (
                                        <input
                                            key={index}
                                            ref={(el) => (codeInputRefs.current[index] = el)}
                                            type="text"
                                            maxLength={1}
                                            value={formData.verificationCode[index]}
                                            onChange={(e) => handleCodeInput(index, e.target.value)}
                                            onKeyDown={(e) => handleCodeKeyDown(index, e)}
                                            className="w-14 h-14 text-center text-2xl font-semibold border-2 border-gray-300 rounded-lg focus:border-[#5B4FE9] focus:ring-2 focus:ring-[#5B4FE9] outline-none transition-all text-gray-900"
                                        />
                                    ))}
                                </div>
                                {errors.verification && (
                                    <p className="text-sm text-red-500 text-center">{errors.verification}</p>
                                )}

                                {/* Verify Button */}
                                <button
                                    type="submit"
                                    className="w-full bg-[#5B4FE9] hover:bg-[#4B3FD9] text-white py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-lg"
                                >
                                    Verify
                                </button>

                                {/* Resend Link */}
                                <p className="text-center text-sm text-gray-600">
                                    Didn't receive the code?{' '}
                                    <button
                                        type="button"
                                        className="text-[#5B4FE9] hover:text-[#4B3FD9] font-semibold transition-colors"
                                    >
                                        Resend
                                    </button>
                                </p>
                            </form>
                        </motion.div>
                    )}

                    {/* Step 3: Phone Number */}
                    {step === 'phone' && (
                        <motion.div
                            key="phone"
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                        >
                            <div className="mb-8">
                                <h2 className="text-3xl font-bold text-gray-900 mb-2">
                                    Phone Number
                                </h2>
                                <p className="text-gray-600 text-sm">
                                    Add your phone number for account security
                                </p>
                            </div>

                            <form onSubmit={handlePhoneSubmit} className="space-y-6">
                                {/* Phone Number */}
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2">
                                        Phone Number
                                    </label>
                                    <input
                                        type="tel"
                                        value={formData.phone}
                                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                                        className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9] bg-white focus:ring-2 outline-none transition-all text-gray-900"
                                        placeholder="Enter your phone number"
                                    />
                                </div>

                                {/* Send Code Button */}
                                <button
                                    type="submit"
                                    className="w-full bg-[#5B4FE9] hover:bg-[#4B3FD9] text-white py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-lg"
                                >
                                    Send Code
                                </button>

                                {/* Skip Link */}
                                <p className="text-center">
                                    <button
                                        type="button"
                                        onClick={handleSkipPhone}
                                        className="text-sm text-gray-600 hover:text-gray-900 transition-colors"
                                    >
                                        Skip for now
                                    </button>
                                </p>
                            </form>
                        </motion.div>
                    )}
                </motion.div>
            </div>
        </div>
    );
};

export default RegisterPage;
