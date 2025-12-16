import React, { useState, useEffect } from 'react';
import { X, Search, Check } from 'lucide-react';
import { motion } from 'framer-motion';

interface Student {
    id: number;
    email: string;
    firstName: string;
    lastName: string;
}

interface Class {
    id: string;
    name: string;
    description?: string;
    studentCount: number;
}

interface AssignModalProps {
    isOpen: boolean;
    onClose: () => void;
    mode: 'student' | 'class';
    courseId: string;
    onAssign: (studentIds?: number[], classId?: string) => void;
}

const AssignModal: React.FC<AssignModalProps> = ({ isOpen, onClose, mode, courseId, onAssign }) => {
    const [students, setStudents] = useState<Student[]>([]);
    const [classes, setClasses] = useState<Class[]>([]);
    const [selectedStudents, setSelectedStudents] = useState<Set<number>>(new Set());
    const [selectedClass, setSelectedClass] = useState<string | null>(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        if (isOpen) {
            loadData();
        } else {
            // Reset state when modal closes
            setSelectedStudents(new Set());
            setSelectedClass(null);
            setSearchTerm('');
        }
    }, [isOpen, mode]);

    const loadData = async () => {
        setIsLoading(true);
        console.log('[AssignModal] Loading data for mode:', mode);
        try {
            if (mode === 'student') {
                // Request students from Shell
                console.log('[AssignModal] Requesting students from Shell');
                window.parent.postMessage({
                    type: 'FETCH_ALL_STUDENTS'
                }, '*');
            } else {
                // Request classes from Shell
                console.log('[AssignModal] Requesting classes from Shell');
                window.parent.postMessage({
                    type: 'FETCH_TEACHER_CLASSES'
                }, '*');
            }
            // Don't set loading to false here - wait for message response
        } catch (error) {
            console.error('Error loading data:', error);
            setIsLoading(false);
        }
    };

    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            console.log('[AssignModal] Received message:', event.data.type);
            if (event.data.type === 'ALL_STUDENTS_LOADED') {
                console.log('[AssignModal] Students received:', event.data.students);
                setStudents(event.data.students || []);
                setIsLoading(false);
            } else if (event.data.type === 'TEACHER_CLASSES_LOADED') {
                console.log('[AssignModal] Classes received:', event.data.classes);
                setClasses(event.data.classes || []);
                setIsLoading(false);
            }
        };

        window.addEventListener('message', handleMessage);
        return () => window.removeEventListener('message', handleMessage);
    }, []);

    const handleStudentToggle = (studentId: number) => {
        setSelectedStudents(prev => {
            const newSet = new Set(prev);
            if (newSet.has(studentId)) {
                newSet.delete(studentId);
            } else {
                newSet.add(studentId);
            }
            return newSet;
        });
    };

    const handleAssign = () => {
        if (mode === 'student' && selectedStudents.size > 0) {
            onAssign(Array.from(selectedStudents), undefined);
        } else if (mode === 'class' && selectedClass) {
            onAssign(undefined, selectedClass);
        }
    };

    const filteredStudents = students.filter(student =>
        `${student.firstName} ${student.lastName} ${student.email}`
            .toLowerCase()
            .includes(searchTerm.toLowerCase())
    );

    const filteredClasses = classes.filter(cl =>
        `${cl.name} ${cl.description || ''}`
            .toLowerCase()
            .includes(searchTerm.toLowerCase())
    );

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
            <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-2xl w-full max-h-[80vh] flex flex-col"
            >
                <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
                    <h3 className="text-2xl font-bold text-gray-900 dark:text-white">
                        Assign {mode === 'student' ? 'Student(s)' : 'Class'}
                    </h3>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
                    >
                        <X size={20} />
                    </button>
                </div>

                <div className="p-6 flex-1 overflow-hidden flex flex-col">
                    {/* Search */}
                    <div className="relative mb-4">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={18} />
                        <input
                            type="text"
                            placeholder={`Search ${mode === 'student' ? 'students' : 'classes'}...`}
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                        />
                    </div>

                    {/* Content */}
                    <div className="flex-1 overflow-y-auto">
                        {isLoading ? (
                            <div className="text-center py-8">
                                <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
                                <p className="text-sm text-gray-500 dark:text-gray-400">Loading...</p>
                            </div>
                        ) : mode === 'student' ? (
                            filteredStudents.length === 0 ? (
                                <div className="text-center py-8 text-gray-500 dark:text-gray-400">
                                    No students found
                                </div>
                            ) : (
                                <div className="space-y-2">
                                    {filteredStudents.map((student) => {
                                        const isSelected = selectedStudents.has(student.id);
                                        return (
                                            <div
                                                key={student.id}
                                                onClick={() => handleStudentToggle(student.id)}
                                                className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                                                    isSelected
                                                        ? 'bg-primary/10 border-primary'
                                                        : 'bg-gray-50 dark:bg-gray-700/50 border-gray-200 dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-700'
                                                }`}
                                            >
                                                <div className="flex items-center justify-between">
                                                    <div>
                                                        <p className="font-medium text-gray-900 dark:text-white">
                                                            {student.firstName} {student.lastName}
                                                        </p>
                                                        <p className="text-sm text-gray-500 dark:text-gray-400">
                                                            {student.email}
                                                        </p>
                                                    </div>
                                                    {isSelected && (
                                                        <div className="p-1 bg-primary text-white rounded-full">
                                                            <Check size={16} />
                                                        </div>
                                                    )}
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            )
                        ) : (
                            filteredClasses.length === 0 ? (
                                <div className="text-center py-8 text-gray-500 dark:text-gray-400">
                                    No classes found
                                </div>
                            ) : (
                                <div className="space-y-2">
                                    {filteredClasses.map((cls) => (
                                        <div
                                            key={cls.id}
                                            onClick={() => setSelectedClass(cls.id)}
                                            className={`p-4 rounded-lg border cursor-pointer transition-colors ${
                                                selectedClass === cls.id
                                                    ? 'bg-primary/10 border-primary'
                                                    : 'bg-gray-50 dark:bg-gray-700/50 border-gray-200 dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-700'
                                            }`}
                                        >
                                            <div className="flex items-center justify-between">
                                                <div>
                                                    <p className="font-medium text-gray-900 dark:text-white">
                                                        {cls.name}
                                                    </p>
                                                    {cls.description && (
                                                        <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                                                            {cls.description}
                                                        </p>
                                                    )}
                                                    <p className="text-xs text-gray-400 dark:text-gray-500 mt-1">
                                                        {cls.studentCount} students
                                                    </p>
                                                </div>
                                                {selectedClass === cls.id && (
                                                    <div className="p-1 bg-primary text-white rounded-full">
                                                        <Check size={16} />
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )
                        )}
                    </div>
                </div>

                {/* Footer */}
                <div className="flex items-center justify-end gap-3 p-6 border-t border-gray-200 dark:border-gray-700">
                    <button
                        onClick={onClose}
                        className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleAssign}
                        disabled={
                            mode === 'student' ? selectedStudents.size === 0 : !selectedClass
                        }
                        className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        Assign {mode === 'student' && selectedStudents.size > 0 && `(${selectedStudents.size})`}
                    </button>
                </div>
            </motion.div>
        </div>
    );
};

export default AssignModal;

