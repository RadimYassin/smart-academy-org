import React, { useState, useEffect } from 'react';
import { X, AlertCircle } from 'lucide-react';

interface ModuleFormData {
    title: string;
    description: string;
    orderIndex: number;
}

interface ModuleFormModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (data: ModuleFormData) => void;
    initialData?: Partial<ModuleFormData>;
    existingModulesCount?: number;
}

const ModuleFormModal: React.FC<ModuleFormModalProps> = ({
    isOpen,
    onClose,
    onSubmit,
    initialData,
    existingModulesCount = 0,
}) => {
    const [formData, setFormData] = useState<ModuleFormData>({
        title: '',
        description: '',
        orderIndex: existingModulesCount + 1,
    });
    const [errors, setErrors] = useState<Partial<Record<keyof ModuleFormData, string>>>({});

    useEffect(() => {
        if (initialData) {
            setFormData({
                title: initialData.title || '',
                description: initialData.description || '',
                orderIndex: initialData.orderIndex || existingModulesCount + 1,
            });
        } else {
            setFormData({
                title: '',
                description: '',
                orderIndex: existingModulesCount + 1,
            });
        }
        setErrors({});
    }, [initialData, isOpen, existingModulesCount]);

    const validate = (): boolean => {
        const newErrors: Partial<Record<keyof ModuleFormData, string>> = {};

        if (!formData.title.trim()) {
            newErrors.title = 'Title is required';
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
                        {initialData ? 'Edit Module' : 'Add Module'}
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
                            Module Title *
                        </label>
                        <input
                            type="text"
                            value={formData.title}
                            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                            placeholder="e.g., Introduction to React"
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
                            placeholder="Describe what students will learn in this module..."
                            rows={3}
                            className="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none transition-all resize-none"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                            Order Index
                        </label>
                        <input
                            type="number"
                            value={formData.orderIndex}
                            onChange={(e) => setFormData({ ...formData, orderIndex: parseInt(e.target.value) || 1 })}
                            min={1}
                            className="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                        />
                        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                            Determines the order of this module in the course
                        </p>
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
                            className="flex-1 px-6 py-3 bg-gradient-to-r from-primary to-secondary text-white font-semibold rounded-lg hover:shadow-lg hover:shadow-primary/30 transition-all"
                        >
                            {initialData ? 'Update' : 'Create'} Module
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default ModuleFormModal;

