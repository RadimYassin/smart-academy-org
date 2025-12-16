import React, { useState, useEffect } from 'react';
import { X, AlertCircle, FileText, Video, Image as ImageIcon, FileQuestion, Type } from 'lucide-react';

interface ContentFormData {
    type: 'PDF' | 'TEXT' | 'VIDEO' | 'IMAGE' | 'QUIZ';
    textContent?: string;
    pdfUrl?: string;
    videoUrl?: string;
    imageUrl?: string;
    quizId?: string;
    orderIndex: number;
}

interface ContentFormModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (data: ContentFormData) => void;
    initialData?: Partial<ContentFormData>;
    existingContentCount?: number;
    availableQuizzes?: Array<{ id: string; title: string }>;
}

const ContentFormModal: React.FC<ContentFormModalProps> = ({
    isOpen,
    onClose,
    onSubmit,
    initialData,
    existingContentCount = 0,
    availableQuizzes = [],
}) => {
    const [formData, setFormData] = useState<ContentFormData>({
        type: 'TEXT',
        textContent: '',
        pdfUrl: '',
        videoUrl: '',
        imageUrl: '',
        quizId: '',
        orderIndex: existingContentCount + 1,
    });
    const [errors, setErrors] = useState<Partial<Record<keyof ContentFormData, string>>>({});

    useEffect(() => {
        if (initialData) {
            setFormData({
                type: initialData.type || 'TEXT',
                textContent: initialData.textContent || '',
                pdfUrl: initialData.pdfUrl || '',
                videoUrl: initialData.videoUrl || '',
                imageUrl: initialData.imageUrl || '',
                quizId: initialData.quizId || '',
                orderIndex: initialData.orderIndex || existingContentCount + 1,
            });
        } else {
            setFormData({
                type: 'TEXT',
                textContent: '',
                pdfUrl: '',
                videoUrl: '',
                imageUrl: '',
                quizId: '',
                orderIndex: existingContentCount + 1,
            });
        }
        setErrors({});
    }, [initialData, isOpen, existingContentCount]);

    const validate = (): boolean => {
        const newErrors: Partial<Record<keyof ContentFormData, string>> = {};

        if (formData.type === 'TEXT' && !formData.textContent?.trim()) {
            newErrors.textContent = 'Text content is required';
        }
        if (formData.type === 'PDF' && !formData.pdfUrl?.trim()) {
            newErrors.pdfUrl = 'PDF URL is required';
        }
        if (formData.type === 'VIDEO' && !formData.videoUrl?.trim()) {
            newErrors.videoUrl = 'Video URL is required';
        }
        if (formData.type === 'IMAGE' && !formData.imageUrl?.trim()) {
            newErrors.imageUrl = 'Image URL is required';
        }
        if (formData.type === 'QUIZ' && !formData.quizId) {
            newErrors.quizId = 'Quiz selection is required';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!validate()) return;
        
        // Clean up unused fields based on type
        const cleanedData: ContentFormData = {
            type: formData.type,
            orderIndex: formData.orderIndex,
        };

        if (formData.type === 'TEXT') cleanedData.textContent = formData.textContent;
        if (formData.type === 'PDF') cleanedData.pdfUrl = formData.pdfUrl;
        if (formData.type === 'VIDEO') cleanedData.videoUrl = formData.videoUrl;
        if (formData.type === 'IMAGE') cleanedData.imageUrl = formData.imageUrl;
        if (formData.type === 'QUIZ') cleanedData.quizId = formData.quizId;

        onSubmit(cleanedData);
    };

    if (!isOpen) return null;

    const contentTypes = [
        { value: 'TEXT', label: 'Text', icon: Type },
        { value: 'PDF', label: 'PDF', icon: FileText },
        { value: 'VIDEO', label: 'Video', icon: Video },
        { value: 'IMAGE', label: 'Image', icon: ImageIcon },
        { value: 'QUIZ', label: 'Quiz', icon: FileQuestion },
    ] as const;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
            <div className="bg-white dark:bg-gray-900 rounded-2xl shadow-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
                <div className="sticky top-0 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 px-6 py-4 flex items-center justify-between">
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                        {initialData ? 'Edit Content' : 'Add Content'}
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
                            Content Type *
                        </label>
                        <div className="grid grid-cols-2 gap-2">
                            {contentTypes.map((type) => {
                                const Icon = type.icon;
                                return (
                                    <button
                                        key={type.value}
                                        type="button"
                                        onClick={() => setFormData({ ...formData, type: type.value as any })}
                                        className={`p-3 rounded-lg border-2 transition-all flex items-center gap-2 ${
                                            formData.type === type.value
                                                ? 'border-primary bg-primary/10'
                                                : 'border-gray-300 dark:border-gray-600 hover:border-primary/50'
                                        }`}
                                    >
                                        <Icon size={18} />
                                        <span className="font-medium text-sm">{type.label}</span>
                                    </button>
                                );
                            })}
                        </div>
                    </div>

                    {formData.type === 'TEXT' && (
                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Text Content *
                            </label>
                            <textarea
                                value={formData.textContent || ''}
                                onChange={(e) => setFormData({ ...formData, textContent: e.target.value })}
                                placeholder="Enter text content..."
                                rows={6}
                                className={`w-full px-4 py-3 rounded-lg border ${
                                    errors.textContent
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none transition-all resize-none`}
                            />
                            {errors.textContent && (
                                <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                    <AlertCircle size={14} />
                                    {errors.textContent}
                                </div>
                            )}
                        </div>
                    )}

                    {formData.type === 'PDF' && (
                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                PDF URL *
                            </label>
                            <input
                                type="url"
                                value={formData.pdfUrl || ''}
                                onChange={(e) => setFormData({ ...formData, pdfUrl: e.target.value })}
                                placeholder="https://example.com/document.pdf"
                                className={`w-full px-4 py-3 rounded-lg border ${
                                    errors.pdfUrl
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none transition-all`}
                            />
                            {errors.pdfUrl && (
                                <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                    <AlertCircle size={14} />
                                    {errors.pdfUrl}
                                </div>
                            )}
                        </div>
                    )}

                    {formData.type === 'VIDEO' && (
                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Video URL *
                            </label>
                            <input
                                type="url"
                                value={formData.videoUrl || ''}
                                onChange={(e) => setFormData({ ...formData, videoUrl: e.target.value })}
                                placeholder="https://example.com/video.mp4"
                                className={`w-full px-4 py-3 rounded-lg border ${
                                    errors.videoUrl
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none transition-all`}
                            />
                            {errors.videoUrl && (
                                <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                    <AlertCircle size={14} />
                                    {errors.videoUrl}
                                </div>
                            )}
                        </div>
                    )}

                    {formData.type === 'IMAGE' && (
                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Image URL *
                            </label>
                            <input
                                type="url"
                                value={formData.imageUrl || ''}
                                onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                                placeholder="https://example.com/image.jpg"
                                className={`w-full px-4 py-3 rounded-lg border ${
                                    errors.imageUrl
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none transition-all`}
                            />
                            {errors.imageUrl && (
                                <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                    <AlertCircle size={14} />
                                    {errors.imageUrl}
                                </div>
                            )}
                        </div>
                    )}

                    {formData.type === 'QUIZ' && (
                        <div>
                            <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-2">
                                Select Quiz *
                            </label>
                            <select
                                value={formData.quizId || ''}
                                onChange={(e) => setFormData({ ...formData, quizId: e.target.value })}
                                className={`w-full px-4 py-3 rounded-lg border ${
                                    errors.quizId
                                        ? 'border-red-500 focus:ring-red-500'
                                        : 'border-gray-300 dark:border-gray-600 focus:ring-primary'
                                } bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 outline-none`}
                            >
                                <option value="">Select a quiz...</option>
                                {availableQuizzes.map((quiz) => (
                                    <option key={quiz.id} value={quiz.id}>
                                        {quiz.title}
                                    </option>
                                ))}
                            </select>
                            {errors.quizId && (
                                <div className="flex items-center gap-1 mt-1 text-red-500 text-sm">
                                    <AlertCircle size={14} />
                                    {errors.quizId}
                                </div>
                            )}
                            {availableQuizzes.length === 0 && (
                                <p className="text-sm text-gray-500 dark:text-gray-400 mt-2">
                                    No quizzes available. Create a quiz first.
                                </p>
                            )}
                        </div>
                    )}

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
                            {initialData ? 'Update' : 'Add'} Content
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default ContentFormModal;

