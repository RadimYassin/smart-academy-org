import React, { useState, useEffect } from 'react';
import { X, AlertCircle, Plus, Trash2, Check, X as XIcon } from 'lucide-react';

interface QuestionOption {
    optionText: string;
    isCorrect: boolean;
    optionOrder: number;
}

interface QuestionFormData {
    questionText: string;
    questionType: string;
    points: number;
    options: QuestionOption[];
}

interface QuestionFormModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (data: QuestionFormData) => void;
    initialData?: Partial<QuestionFormData & { options?: Array<{ optionText: string; isCorrect: boolean; optionOrder?: number }> }>;
}

const QuestionFormModal: React.FC<QuestionFormModalProps> = ({
    isOpen,
    onClose,
    onSubmit,
    initialData,
}) => {
    const [formData, setFormData] = useState<QuestionFormData>({
        questionText: '',
        questionType: 'MULTIPLE_CHOICE',
        points: 1,
        options: [
            { optionText: '', isCorrect: false, optionOrder: 1 },
            { optionText: '', isCorrect: false, optionOrder: 2 },
        ],
    });
    const [errors, setErrors] = useState<Partial<Record<keyof QuestionFormData, string>>>({});

    useEffect(() => {
        if (initialData) {
            setFormData({
                questionText: initialData.questionText || '',
                questionType: initialData.questionType || 'MULTIPLE_CHOICE',
                points: initialData.points || 1,
                options: initialData.options?.map((opt, idx) => ({
                    optionText: opt.optionText || '',
                    isCorrect: opt.isCorrect || false,
                    optionOrder: opt.optionOrder || idx + 1,
                })) || [
                    { optionText: '', isCorrect: false, optionOrder: 1 },
                    { optionText: '', isCorrect: false, optionOrder: 2 },
                ],
            });
        } else {
            setFormData({
                questionText: '',
                questionType: 'MULTIPLE_CHOICE',
                points: 1,
                options: [
                    { optionText: '', isCorrect: false, optionOrder: 1 },
                    { optionText: '', isCorrect: false, optionOrder: 2 },
                ],
            });
        }
        setErrors({});
    }, [initialData, isOpen]);

    const validate = (): boolean => {
        const newErrors: Partial<Record<keyof QuestionFormData, string>> = {};

        if (!formData.questionText.trim()) {
            newErrors.questionText = 'Question text is required';
        }

        if (formData.questionType === 'MULTIPLE_CHOICE') {
            const filledOptions = formData.options.filter(opt => opt.optionText.trim());
            if (filledOptions.length < 2) {
                newErrors.options = 'At least 2 options are required';
            }
            const correctOptions = formData.options.filter(opt => opt.isCorrect);
            if (correctOptions.length === 0) {
                newErrors.options = 'At least one correct answer must be selected';
            }
        }

        if (formData.points < 1) {
            newErrors.points = 'Points must be at least 1';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!validate()) return;
        
        // Filter out empty options
        const cleanedOptions = formData.options
            .filter(opt => opt.optionText.trim())
            .map((opt, idx) => ({ ...opt, optionOrder: idx + 1 }));

        onSubmit({
            ...formData,
            options: cleanedOptions,
        });
    };

    const addOption = () => {
        setFormData({
            ...formData,
            options: [
                ...formData.options,
                {
                    optionText: '',
                    isCorrect: false,
                    optionOrder: formData.options.length + 1,
                },
            ],
        });
    };

    const removeOption = (index: number) => {
        if (formData.options.length > 2) {
            setFormData({
                ...formData,
                options: formData.options.filter((_, i) => i !== index),
            });
        }
    };

    const updateOption = (index: number, field: keyof QuestionOption, value: any) => {
        const newOptions = [...formData.options];
        newOptions[index] = { ...newOptions[index], [field]: value };
        
        // If setting this option as correct and question type is MULTIPLE_CHOICE,
        // ensure only one is correct (unless we want multiple correct answers)
        if (field === 'isCorrect' && value && formData.questionType === 'MULTIPLE_CHOICE') {
            // Allow multiple correct answers - comment out if you want only one
            // newOptions.forEach((opt, i) => {
            //     if (i !== index) opt.isCorrect = false;
            // });
        }
        
        setFormData({ ...formData, options: newOptions });
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
            <div className="bg-white dark:bg-gray-900 rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                <div className="sticky top-0 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 px-6 py-4 flex items-center justify-between">
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                        {initialData ? 'Edit Question' : 'Add Question'}
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
                            Question Text *
                        </label>
                        <textarea
                            value={formData.questionText}
                            onChange={(e) => setFormData({ ...formData, questionText: e.target.value })}
                            placeholder="Enter your question..."
                            rows={3}
                            className={`w-full px-4 py-3 rounded-lg border ${
                                errors.questionText
                                    ? 'border-red-500 focus:ring-red-500'
                                    : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                            } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none transition-all resize-none`}
                        />
                        {errors.questionText && (
                            <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                <AlertCircle size={14} />
                                {errors.questionText}
                            </div>
                        )}
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Question Type
                            </label>
                            <select
                                value={formData.questionType}
                                onChange={(e) => setFormData({ ...formData, questionType: e.target.value })}
                                className="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                            >
                                <option value="MULTIPLE_CHOICE">Multiple Choice</option>
                                <option value="TRUE_FALSE">True/False</option>
                                <option value="SHORT_ANSWER">Short Answer</option>
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Points *
                            </label>
                            <input
                                type="number"
                                value={formData.points}
                                onChange={(e) => setFormData({ ...formData, points: parseInt(e.target.value) || 1 })}
                                min={1}
                                className={`w-full px-4 py-3 rounded-lg border ${
                                    errors.points
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none`}
                            />
                            {errors.points && (
                                <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                    <AlertCircle size={14} />
                                    {errors.points}
                                </div>
                            )}
                        </div>
                    </div>

                    {(formData.questionType === 'MULTIPLE_CHOICE' || formData.questionType === 'TRUE_FALSE') && (
                        <div>
                            <div className="flex items-center justify-between mb-3">
                                <label className="block text-sm font-semibold text-gray-900 dark:text-white">
                                    Options *
                                </label>
                                <button
                                    type="button"
                                    onClick={addOption}
                                    className="flex items-center gap-1 px-3 py-1 text-sm text-primary hover:bg-primary/10 rounded-lg transition-colors"
                                >
                                    <Plus size={16} />
                                    Add Option
                                </button>
                            </div>

                            <div className="space-y-2">
                                {formData.options.map((option, index) => (
                                    <div
                                        key={index}
                                        className="flex items-center gap-2 p-3 border border-gray-300 dark:border-gray-600 rounded-lg"
                                    >
                                        <input
                                            type="text"
                                            value={option.optionText}
                                            onChange={(e) => updateOption(index, 'optionText', e.target.value)}
                                            placeholder={`Option ${index + 1}`}
                                            className="flex-1 px-3 py-2 rounded border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                        />
                                        <button
                                            type="button"
                                            onClick={() => updateOption(index, 'isCorrect', !option.isCorrect)}
                                            className={`p-2 rounded-lg transition-colors ${
                                                option.isCorrect
                                                    ? 'bg-green-500 text-white hover:bg-green-600'
                                                    : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
                                            }`}
                                            title={option.isCorrect ? 'Correct answer' : 'Mark as correct'}
                                        >
                                            {option.isCorrect ? <Check size={18} /> : <XIcon size={18} />}
                                        </button>
                                        {formData.options.length > 2 && (
                                            <button
                                                type="button"
                                                onClick={() => removeOption(index)}
                                                className="p-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"
                                            >
                                                <Trash2 size={18} />
                                            </button>
                                        )}
                                    </div>
                                ))}
                            </div>

                            {errors.options && (
                                <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                    <AlertCircle size={14} />
                                    {errors.options}
                                </div>
                            )}

                            <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
                                Click the checkmark to mark an option as correct
                            </p>
                        </div>
                    )}

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
                            {initialData ? 'Update' : 'Add'} Question
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default QuestionFormModal;

