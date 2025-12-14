import React, { useState, useRef, useEffect } from 'react';
import { ArrowLeft, GraduationCap, Mail } from 'lucide-react';
import { motion } from 'framer-motion';

interface VerificationPageProps {
    email: string;
    onVerify: (code: string) => void;
    onBack: () => void;
}

const VerificationPage: React.FC<VerificationPageProps> = ({ email, onVerify, onBack }) => {
    const [code, setCode] = useState(['', '', '', '', '', '']);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState(false);
    const [loading, setLoading] = useState(false);
    const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

    useEffect(() => {
        // Focus first input on mount
        inputRefs.current[0]?.focus();

        // Listen for verification responses from Shell
        const handleMessage = (event: MessageEvent) => {
            if (event.data.type === 'VERIFICATION_SUCCESS') {
                setSuccess(true);
                setLoading(false);
                // Redirect to login after 2 seconds
                setTimeout(() => {
                    onBack();
                }, 2000);
            }

            if (event.data.type === 'VERIFICATION_ERROR') {
                setError(event.data.error || 'Verification failed');
                setLoading(false);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, [onBack]);

    const handleChange = (index: number, value: string) => {
        // Only allow digits
        if (value && !/^\d$/.test(value)) return;

        const newCode = [...code];
        newCode[index] = value;
        setCode(newCode);
        setError('');

        // Auto-focus next input
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

        // Focus the next empty input or the last one
        const nextIndex = Math.min(pastedData.length, 5);
        inputRefs.current[nextIndex]?.focus();
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        const verificationCode = code.join('');

        if (verificationCode.length !== 6) {
            setError('Please enter the complete 6-digit code');
            return;
        }

        setLoading(true);
        setError('');
        onVerify(verificationCode);
    };

    const handleResend = () => {
        // Send message to Shell to resend verification code
        if (window.parent !== window) {
            window.parent.postMessage(
                {
                    type: 'RESEND_VERIFICATION',
                    email: email,
                },
                '*'
            );
        }
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

            {/* Right Side - Verification Form */}
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
                            <Mail className="text-[#5B4FE9]" size={32} />
                        </div>
                        <h2 className="text-3xl font-bold text-gray-900 mb-2">
                            Verify Your Email
                        </h2>
                        <p className="text-gray-600 text-sm">
                            We've sent a 6-digit code to
                        </p>
                        <p className="text-gray-900 font-medium mt-1">
                            {email}
                        </p>
                    </div>

                    {/* Success Message */}
                    {success && (
                        <div className="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg">
                            <p className="text-sm text-green-800 text-center">
                                ✓ Email verified successfully! Redirecting to login...
                            </p>
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-6">
                        {/* 6-Digit Code Input */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-3 text-center">
                                Enter Verification Code
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
                                        onChange={(e) => handleChange(index, e.target.value)}
                                        onKeyDown={(e) => handleKeyDown(index, e)}
                                        onPaste={index === 0 ? handlePaste : undefined}
                                        disabled={loading || success}
                                        className="w-12 h-14 text-center text-2xl font-bold border-2 border-gray-300 rounded-lg focus:border-[#5B4FE9] focus:ring-2 focus:ring-[#5B4FE9] outline-none transition-all text-gray-900 disabled:opacity-50 disabled:cursor-not-allowed"
                                    />
                                ))}
                            </div>
                            {error && (
                                <p className="mt-2 text-sm text-red-500 text-center">{error}</p>
                            )}
                        </div>

                        {/* Verify Button */}
                        <button
                            type="submit"
                            disabled={loading || success}
                            className="w-full bg-[#5B4FE9] hover:bg-[#4B3FD9] text-white py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {loading ? 'Verifying...' : 'Verify Email'}
                        </button>

                        {/* Resend Code */}
                        <div className="text-center">
                            <p className="text-sm text-gray-600">
                                Didn't receive the code?{' '}
                                <button
                                    type="button"
                                    onClick={handleResend}
                                    disabled={loading || success}
                                    className="text-[#5B4FE9] hover:text-[#4B3FD9] font-semibold transition-colors disabled:opacity-50"
                                >
                                    Resend
                                </button>
                            </p>
                        </div>
                    </form>
                </motion.div>
            </div>
        </div>
    );
};

export default VerificationPage;
