import React, { useState, useEffect } from 'react';
import { X, Upload, AlertCircle } from 'lucide-react';

interface CourseFormData {
    title: string;
    description: string;
    category: string;
    level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
    thumbnailUrl: string;
}

interface CourseFormModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (data: Partial<CourseFormData>) => void;
    initialData?: Partial<CourseFormData>;
    title: string;
}

const categories = [
    'Development',
    'Design',
    'Business',
    'Marketing',
    'IT & Software',
    'Personal Development',
    'Photography',
    'Music',
    'Health & Fitness',
    'Teaching & Academics',
];

const CourseFormModal: React.FC<CourseFormModalProps> = ({
    isOpen,
    onClose,
    onSubmit,
    initialData,
    title,
}) => {
    const [formData, setFormData] = useState<CourseFormData>({
        title: '',
        description: '',
        category: 'Development',
        level: 'BEGINNER',
        thumbnailUrl: '',
    });

    const [errors, setErrors] = useState<Partial<Record<keyof CourseFormData, string>>>({});
    const [isSubmitting, setIsSubmitting] = useState(false);

    useEffect(() => {
        if (initialData) {
            setFormData({
                title: initialData.title || '',
                description: initialData.description || '',
                category: initialData.category || 'Development',
                level: initialData.level || 'BEGINNER',
                thumbnailUrl: initialData.thumbnailUrl || '',
            });
        } else {
            setFormData({
                title: '',
                description: '',
                category: 'Development',
                level: 'BEGINNER',
                thumbnailUrl: '',
            });
        } setErrors({});
    }, [initialData, isOpen]);

    const validate = (): boolean => {
        const newErrors: Partial<Record<keyof CourseFormData, string>> = {};

        if (!formData.title.trim()) {
            newErrors.title = 'Title is required';
        }

        if (!formData.description.trim()) {
            newErrors.description = 'Description is required';
        }

        if (formData.thumbnailUrl && !formData.thumbnailUrl.match(/^https?:\/\/.+/)) {
            newErrors.thumbnailUrl = 'Please enter a valid URL';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!validate()) return;

        setIsSubmitting(true);
        try {
            await onSubmit(formData);
        } catch (error) {
            console.error('Failed to submit course:', error);
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleChange = (field: keyof CourseFormData, value: any) => {
        setFormData((prev) => ({ ...prev, [field]: value }));
        // Clear error for this field
        if (errors[field]) {
            setErrors((prev) => {
                const newErrors = { ...prev };
                delete newErrors[field];
                return newErrors;
            });
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
            <div className="bg-white dark:bg-gray-900 rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                {/* Header */}
                <div className="sticky top-0 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 px-6 py-4 flex items-center justify-between">
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-white">{title}</h2>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
                    >
                        <X size={24} className="text-gray-500" />
                    </button>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="p-6 space-y-6">
                    {/* Title */}
                    <div>
                        <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                            Course Title *
                        </label>
                        <input
                            type="text"
                            value={formData.title}
                            onChange={(e) => handleChange('title', e.target.value)}
                            placeholder="e.g., Complete Web Development Bootcamp"
                            className={`w-full px-4 py-3 rounded-lg border ${errors.title
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

                    {/* Description */}
                    <div>
                        <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                            Description *
                        </label>
                        <textarea
                            value={formData.description}
                            onChange={(e) => handleChange('description', e.target.value)}
                            placeholder="Describe what students will learn in this course..."
                            rows={4}
                            className={`w-full px-4 py-3 rounded-lg border ${errors.description
                                ? 'border-red-500 focus:ring-red-500'
                                : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none transition-all resize-none`}
                        />
                        {errors.description && (
                            <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                <AlertCircle size={14} />
                                {errors.description}
                            </div>
                        )}
                    </div>

                    {/* Category and Level */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Category *
                            </label>
                            <select
                                value={formData.category}
                                onChange={(e) => handleChange('category', e.target.value)}
                                className="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                            >
                                {categories.map((cat) => (
                                    <option key={cat} value={cat}>
                                        {cat}
                                    </option>
                                ))}
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Level *
                            </label>
                            <select
                                value={formData.level}
                                onChange={(e) => handleChange('level', e.target.value as any)}
                                className="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                            >
                                <option value="BEGINNER">Beginner</option>
                                <option value="INTERMEDIATE">Intermediate</option>
                                <option value="ADVANCED">Advanced</option>
                            </select>
                        </div>
                    </div>

                    {/* Thumbnail URL */}
                    <div>
                        <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                            Thumbnail URL
                        </label>
                        <input
                            type="url"
                            value={formData.thumbnailUrl}
                            onChange={(e) => handleChange('thumbnailUrl', e.target.value)}
                            placeholder="https://example.com/image.jpg"
                            className={`w-full px-4 py-3 rounded-lg border ${errors.thumbnailUrl
                                ? 'border-red-500 focus:ring-red-500'
                                : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none`}
                        />
                        {errors.thumbnailUrl && (
                            <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                <AlertCircle size={14} />
                                {errors.thumbnailUrl}
                            </div>
                        )}
                        {formData.thumbnailUrl && !errors.thumbnailUrl && (
                            <div className="mt-2">
                                <img
                                    src={formData.thumbnailUrl}
                                    alt="Thumbnail preview"
                                    className="h-32 w-full object-cover rounded-lg"
                                    onError={(e) => {
                                        (e.target as HTMLImageElement).style.display = 'none';
                                        setErrors((prev) => ({ ...prev, thumbnailUrl: 'Invalid image URL' }));
                                    }}
                                />
                            </div>
                        )}
                    </div>



                    {/* Actions */}
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
                            disabled={isSubmitting}
                            className="flex-1 px-6 py-3 bg-gradient-to-r from-primary to-secondary text-white font-semibold rounded-lg hover:shadow-lg hover:shadow-primary/30 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {isSubmitting ? 'Saving...' : initialData ? 'Update Course' : 'Create Course'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default CourseFormModal;
