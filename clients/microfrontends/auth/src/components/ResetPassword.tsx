import React, { useState, useRef, useEffect } from 'react';
import { ArrowLeft, GraduationCap, Lock, Eye, EyeOff, CheckCircle2 } from 'lucide-react';
import { motion } from 'framer-motion';

interface ResetPasswordProps {
    email: string;
    onReset: (code: string, newPassword: string) => void;
    onBack: () => void;
}

const ResetPassword: React.FC<ResetPasswordProps> = ({ email, onReset, onBack }) => {
    const [code, setCode] = useState(['', '', '', '', '', '']);
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [errors, setErrors] = useState<Record<string, string>>({});
    const [loading, setLoading] = useState(false);
    const [success, setSuccess] = useState(false);
    const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

    useEffect(() => {
        // Focus first input on mount
        inputRefs.current[0]?.focus();

        // Listen for reset password responses from Shell
        const handleMessage = (event: MessageEvent) => {
            if (event.data.type === 'RESET_PASSWORD_SUCCESS') {
                setSuccess(true);
                setLoading(false);
                // Redirect to login after 2 seconds
                setTimeout(() => {
                    onBack();
                }, 2000);
            }

            if (event.data.type === 'RESET_PASSWORD_ERROR') {
                setErrors({ api: event.data.error || 'Reset failed' });
                setLoading(false);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, [onBack]);

    const handleCodeChange = (index: number, value: string) => {
        if (value && !/^\d$/.test(value)) return;

        const newCode = [...code];
        newCode[index] = value;
        setCode(newCode);
        setErrors({});

        if (value && index < 5) {
            inputRefs.current[index + 1]?.focus();
        }
    };

    const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
        if (e.key === 'Backspace' && !code[index] && index > 0) {
            inputRefs.current[index - 1]?.focus();
        }
    };

    const handlePaste = (e: React.ClipboardEvent) => {
        e.preventDefault();
        const pastedData = e.clipboardData.getData('text').slice(0, 6);

        if (!/^\d+$/.test(pastedData)) return;

        const newCode = pastedData.split('').concat(Array(6 - pastedData.length).fill(''));
        setCode(newCode);

        const nextIndex = Math.min(pastedData.length, 5);
        inputRefs.current[nextIndex]?.focus();
    };

    const validatePassword = () => {
        const newErrors: Record<string, string> = {};

        if (!newPassword) {
            newErrors.password = 'Password is required';
        } else if (newPassword.length < 8) {
            newErrors.password = 'Password must be at least 8 characters';
        } else if (!/(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])/.test(newPassword)) {
            newErrors.password = 'Password must contain uppercase, lowercase, number, and special character';
        }

        if (newPassword !== confirmPassword) {
            newErrors.confirmPassword = 'Passwords do not match';
        }

        const verificationCode = code.join('');
        if (verificationCode.length !== 6) {
            newErrors.code = 'Please enter the complete 6-digit code';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        if (!validatePassword()) return;

        setLoading(true);
        setErrors({});
        onReset(code.join(''), newPassword);
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

            {/* Right Side - Reset Password Form */}
            <div className="w-full lg:w-1/2 flex items-center justify-center bg-gray-50 p-8">
                <motion.div
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    className="w-full max-w-md"
                >
                    <button
                        onClick={onBack}
                        disabled={loading}
                        className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-8 transition-colors disabled:opacity-50"
                    >
                        <ArrowLeft size={20} />
                        <span className="text-sm font-medium">Back to Login</span>
                    </button>

                    <div className="mb-8 text-center">
                        <div className="w-16 h-16 bg-[#5B4FE9]/10 rounded-full flex items-center justify-center mx-auto mb-4">
                            <Lock className="text-[#5B4FE9]" size={32} />
                        </div>
                        <h2 className="text-3xl font-bold text-gray-900 mb-2">
                            Reset Password
                        </h2>
                        <p className="text-gray-600 text-sm">
                            Enter the code sent to <span className="font-medium">{email}</span>
                        </p>
                    </div>

                    {/* Success Message */}
                    {success && (
                        <div className="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg flex items-center gap-3">
                            <CheckCircle2 className="text-green-600" size={20} />
                            <p className="text-sm text-green-800">
                                Password reset successfully! Redirecting to login...
                            </p>
                        </div>
                    )}

                    {/* API Error */}
                    {errors.api && (
                        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                            <p className="text-sm text-red-800">{errors.api}</p>
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-5">
                        {/* 6-Digit Code */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-3 text-center">
                                Verification Code
                            </label>
                            <div className="flex gap-2 justify-center">
                                {code.map((digit, index) => (
                                    <input
                                        key={index}
                                        ref={(el) => (inputRefs.current[index] = el)}
                                        type="text"
                                        inputMode="numeric"
                                        maxLength={1}
                                        value={digit}
                                        onChange={(e) => handleCodeChange(index, e.target.value)}
                                        onKeyDown={(e) => handleKeyDown(index, e)}
                                        onPaste={index === 0 ? handlePaste : undefined}
                                        disabled={loading || success}
                                        className="w-12 h-14 text-center text-2xl font-bold border-2 border-gray-300 rounded-lg focus:border-[#5B4FE9] focus:ring-2 focus:ring-[#5B4FE9] outline-none transition-all text-gray-900 disabled:opacity-50"
                                    />
                                ))}
                            </div>
                            {errors.code && (
                                <p className="mt-2 text-sm text-red-500 text-center">{errors.code}</p>
                            )}
                        </div>

                        {/* New Password */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                New Password
                            </label>
                            <div className="relative">
                                <input
                                    type={showPassword ? 'text' : 'password'}
                                    value={newPassword}
                                    onChange={(e) => setNewPassword(e.target.value)}
                                    disabled={loading || success}
                                    className={`w-full px-4 py-3 pr-11 rounded-lg border ${errors.password
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                        } bg-white focus:ring-2 outline-none transition-all text-gray-900 disabled:opacity-50`}
                                    placeholder="Enter new password"
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    disabled={loading || success}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors disabled:opacity-50"
                                >
                                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                                </button>
                            </div>
                            {errors.password && (
                                <p className="mt-1.5 text-sm text-red-500">{errors.password}</p>
                            )}
                            <p className="mt-1 text-xs text-gray-500">
                                At least 8 characters with uppercase, lowercase, number & special character
                            </p>
                        </div>

                        {/* Confirm Password */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Confirm Password
                            </label>
                            <input
                                type={showPassword ? 'text' : 'password'}
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                disabled={loading || success}
                                className={`w-full px-4 py-3 rounded-lg border ${errors.confirmPassword
                                    ? 'border-red-500 focus:ring-red-500'
                                    : 'border-gray-300 focus:ring-[#5B4FE9] focus:border-[#5B4FE9]'
                                    } bg-white focus:ring-2 outline-none transition-all text-gray-900 disabled:opacity-50`}
                                placeholder="Confirm new password"
                            />
                            {errors.confirmPassword && (
                                <p className="mt-1.5 text-sm text-red-500">{errors.confirmPassword}</p>
                            )}
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            disabled={loading || success}
                            className="w-full bg-[#5B4FE9] hover:bg-[#4B3FD9] text-white py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {loading ? 'Resetting...' : 'Reset Password'}
                        </button>
                    </form>
                </motion.div>
            </div>
        </div>
    );
};

export default ResetPassword;
