import React, { useState, useEffect } from 'react';
import { X, AlertCircle } from 'lucide-react';

interface QuizFormData {
    title: string;
    description: string;
    difficulty: 'EASY' | 'MEDIUM' | 'HARD';
    passingScore: number;
    mandatory: boolean;
}

interface QuizFormModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (data: QuizFormData) => void;
    initialData?: Partial<QuizFormData>;
}

const QuizFormModal: React.FC<QuizFormModalProps> = ({
    isOpen,
    onClose,
    onSubmit,
    initialData,
}) => {
    const [formData, setFormData] = useState<QuizFormData>({
        title: '',
        description: '',
        difficulty: 'MEDIUM',
        passingScore: 60,
        mandatory: false,
    });
    const [errors, setErrors] = useState<Partial<Record<keyof QuizFormData, string>>>({});

    useEffect(() => {
        if (initialData) {
            setFormData({
                title: initialData.title || '',
                description: initialData.description || '',
                difficulty: initialData.difficulty || 'MEDIUM',
                passingScore: initialData.passingScore || 60,
                mandatory: initialData.mandatory ?? false,
            });
        } else {
            setFormData({
                title: '',
                description: '',
                difficulty: 'MEDIUM',
                passingScore: 60,
                mandatory: false,
            });
        }
        setErrors({});
    }, [initialData, isOpen]);

    const validate = (): boolean => {
        const newErrors: Partial<Record<keyof QuizFormData, string>> = {};

        if (!formData.title.trim()) {
            newErrors.title = 'Title is required';
        }
        if (formData.passingScore < 0 || formData.passingScore > 100) {
            newErrors.passingScore = 'Passing score must be between 0 and 100';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!validate()) return;
        onSubmit(formData);
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
            <div className="bg-white dark:bg-gray-900 rounded-2xl shadow-2xl max-w-md w-full">
                <div className="sticky top-0 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 px-6 py-4 flex items-center justify-between">
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                        {initialData ? 'Edit Quiz' : 'Add Quiz'}
                    </h2>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
                    >
                        <X size={24} className="text-gray-500" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    <div>
                        <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                            Quiz Title *
                        </label>
                        <input
                            type="text"
                            value={formData.title}
                            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                            placeholder="e.g., Chapter 1 Assessment"
                            className={`w-full px-4 py-3 rounded-lg border ${
                                errors.title
                                    ? 'border-red-500 focus:ring-red-500'
                                    : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                            } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none transition-all`}
                        />
                        {errors.title && (
                            <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                <AlertCircle size={14} />
                                {errors.title}
                            </div>
                        )}
                    </div>

                    <div>
                        <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                            Description
                        </label>
                        <textarea
                            value={formData.description}
                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                            placeholder="Quiz description..."
                            rows={3}
                            className="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none transition-all resize-none"
                        />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Difficulty
                            </label>
                            <select
                                value={formData.difficulty}
                                onChange={(e) => setFormData({ ...formData, difficulty: e.target.value as any })}
                                className="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                            >
                                <option value="EASY">Easy</option>
                                <option value="MEDIUM">Medium</option>
                                <option value="HARD">Hard</option>
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Passing Score (%) *
                            </label>
                            <input
                                type="number"
                                value={formData.passingScore}
                                onChange={(e) => setFormData({ ...formData, passingScore: parseInt(e.target.value) || 0 })}
                                min={0}
                                max={100}
                                className={`w-full px-4 py-3 rounded-lg border ${
                                    errors.passingScore
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none`}
                            />
                            {errors.passingScore && (
                                <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                    <AlertCircle size={14} />
                                    {errors.passingScore}
                                </div>
                            )}
                        </div>
                    </div>

                    <div className="flex items-center gap-2">
                        <input
                            type="checkbox"
                            id="mandatory"
                            checked={formData.mandatory}
                            onChange={(e) => setFormData({ ...formData, mandatory: e.target.checked })}
                            className="w-4 h-4 text-primary rounded focus:ring-primary"
                        />
                        <label htmlFor="mandatory" className="text-sm font-medium text-gray-900 dark:text-white">
                            Mandatory quiz (students must pass to continue)
                        </label>
                    </div>

                    <div className="flex gap-3 pt-4 border-t border-gray-200 dark:border-gray-700">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 px-6 py-3 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 font-semibold rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            className="flex-1 px-6 py-3 bg-gradient-to-r from-orange-500 to-orange-600 text-white font-semibold rounded-lg hover:shadow-lg hover:shadow-orange-500/30 transition-all"
                        >
                            {initialData ? 'Update' : 'Create'} Quiz
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default QuizFormModal;

