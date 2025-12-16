import React, { useState, useEffect } from 'react';
import { Plus, Users, BookOpen, Search, Trash2, Edit, X, UserPlus, GraduationCap, ChevronDown, ChevronRight, Download, Upload } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { classApi } from '../api/classApi';
import { authApi } from '../api/authApi';
import { userApi } from '../api/userApi';
import type { StudentClass, CreateClassRequest, ClassStudent, UserDto } from '../api/types';

const Students: React.FC = () => {
    const [classes, setClasses] = useState<StudentClass[]>([]);
    const [selectedClass, setSelectedClass] = useState<StudentClass | null>(null);
    const [classStudents, setClassStudents] = useState<ClassStudent[]>([]);
    const [studentsByClass, setStudentsByClass] = useState<Map<string, ClassStudent[]>>(new Map());
    const [loadingStudents, setLoadingStudents] = useState<Set<string>>(new Set());
    const [allStudents, setAllStudents] = useState<any[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    
    // Modals
    const [showCreateClassModal, setShowCreateClassModal] = useState(false);
    const [showCreateStudentModal, setShowCreateStudentModal] = useState(false);
    const [showAddStudentsModal, setShowAddStudentsModal] = useState(false);
    const [expandedClasses, setExpandedClasses] = useState<Set<string>>(new Set());

    // Form states
    const [newClass, setNewClass] = useState<CreateClassRequest>({ name: '', description: '' });
    const [newStudent, setNewStudent] = useState({
        email: '',
        password: '',
        firstName: '',
        lastName: '',
    });

    useEffect(() => {
        loadClasses();
        loadAllAvailableStudents();
    }, []);

    const loadAllAvailableStudents = async () => {
        try {
            const students = await userApi.getAllStudents();
            setAllStudents(students);
        } catch (err: any) {
            console.error('Failed to load all students:', err);
        }
    };

    const loadClasses = async () => {
        try {
            setIsLoading(true);
            const data = await classApi.getMyClasses();
            setClasses(data);
        } catch (err: any) {
            setError(err.message || 'Failed to load classes');
        } finally {
            setIsLoading(false);
        }
    };


    const handleCreateClass = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const created = await classApi.createClass(newClass);
            setClasses([...classes, created]);
            setShowCreateClassModal(false);
            setNewClass({ name: '', description: '' });
        } catch (err: any) {
            setError(err.message || 'Failed to create class');
        }
    };

    const handleCreateStudent = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await authApi.register({
                ...newStudent,
                role: 'STUDENT',
            });
            setShowCreateStudentModal(false);
            setNewStudent({ email: '', password: '', firstName: '', lastName: '' });
            alert('Student account created successfully!');
            // Reload students list if available
        } catch (err: any) {
            setError(err.message || 'Failed to create student account');
        }
    };

    const handleAddStudents = async (selectedStudentIds: number[]) => {
        if (!selectedClass) return;
        try {
            await classApi.addStudentsToClass(selectedClass.id, { studentIds: selectedStudentIds });
            // Reload students for expanded view
            if (expandedClasses.has(selectedClass.id)) {
                await loadClassStudentsForExpandedView(selectedClass.id);
            }
            // Reload classes to update counts
            await loadClasses();
            setShowAddStudentsModal(false);
        } catch (err: any) {
            setError(err.message || 'Failed to add students to class');
        }
    };

    const handleDeleteClass = async (classId: string) => {
        if (!confirm('Are you sure you want to delete this class?')) return;
        try {
            await classApi.deleteClass(classId);
            setClasses(classes.filter(c => c.id !== classId));
            if (selectedClass?.id === classId) {
                setSelectedClass(null);
            }
        } catch (err: any) {
            setError(err.message || 'Failed to delete class');
        }
    };

    const toggleClass = async (classId: string) => {
        const isExpanding = !expandedClasses.has(classId);
        setExpandedClasses(prev => {
            const newSet = new Set(prev);
            if (newSet.has(classId)) {
                newSet.delete(classId);
            } else {
                newSet.add(classId);
            }
            return newSet;
        });

        // Load students when expanding
        if (isExpanding && !studentsByClass.has(classId)) {
            await loadClassStudentsForExpandedView(classId);
        }
    };

    const loadClassStudentsForExpandedView = async (classId: string) => {
        try {
            setLoadingStudents(prev => new Set(prev).add(classId));
            const students = await classApi.getClassStudents(classId);
            setStudentsByClass(prev => new Map(prev).set(classId, students));
            // Also update the class student count in classes list
            setClasses(prev => prev.map(c => 
                c.id === classId ? { ...c, studentCount: students.length } : c
            ));
        } catch (err: any) {
            console.error('Failed to load class students:', err);
        } finally {
            setLoadingStudents(prev => {
                const newSet = new Set(prev);
                newSet.delete(classId);
                return newSet;
            });
        }
    };

    const handleAddStudentToClass = async (classId: string, studentIds: number[]) => {
        try {
            await classApi.addStudentsToClass(classId, { studentIds });
            // Reload students for this class
            await loadClassStudentsForExpandedView(classId);
            // Reload classes to update student count
            await loadClasses();
        } catch (err: any) {
            setError(err.message || 'Failed to add students to class');
        }
    };

    const handleRemoveStudentFromClass = async (classId: string, studentId: number) => {
        if (!confirm('Remove this student from the class?')) return;
        try {
            await classApi.removeStudentFromClass(classId, studentId);
            // Update local state
            setStudentsByClass(prev => {
                const newMap = new Map(prev);
                const students = newMap.get(classId) || [];
                newMap.set(classId, students.filter(s => s.studentId !== studentId));
                return newMap;
            });
            // Update class student count
            setClasses(prev => prev.map(c => 
                c.id === classId ? { ...c, studentCount: Math.max(0, c.studentCount - 1) } : c
            ));
        } catch (err: any) {
            setError(err.message || 'Failed to remove student');
        }
    };

    const exportStudentsToCSV = (classId: string, className: string) => {
        const students = studentsByClass.get(classId) || [];
        
        if (students.length === 0) {
            alert('No students to export');
            return;
        }

        // Prepare CSV headers
        const headers = ['Student ID', 'First Name', 'Last Name', 'Email', 'Added Date'];
        
        // Prepare CSV rows
        const rows = students.map(cs => {
            const studentInfo = allStudents.find(s => s.id === cs.studentId);
            const firstName = studentInfo?.firstName || '';
            const lastName = studentInfo?.lastName || '';
            const email = studentInfo?.email || '';
            const addedDate = new Date(cs.addedAt).toLocaleDateString();
            
            return [
                cs.studentId.toString(),
                firstName,
                lastName,
                email,
                addedDate
            ];
        });

        // Combine headers and rows
        const csvContent = [
            headers.join(','),
            ...rows.map(row => row.map(cell => `"${cell.replace(/"/g, '""')}"`).join(','))
        ].join('\n');

        // Create blob and download
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);
        
        link.setAttribute('href', url);
        link.setAttribute('download', `${className.replace(/\s+/g, '_')}_students_${new Date().toISOString().split('T')[0]}.csv`);
        link.style.visibility = 'hidden';
        
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        URL.revokeObjectURL(url);
    };

    const parseCSV = (csvText: string): string[][] => {
        const lines: string[][] = [];
        let currentLine: string[] = [];
        let currentField = '';
        let inQuotes = false;

        for (let i = 0; i < csvText.length; i++) {
            const char = csvText[i];
            const nextChar = csvText[i + 1];

            if (char === '"') {
                if (inQuotes && nextChar === '"') {
                    // Escaped quote
                    currentField += '"';
                    i++; // Skip next quote
                } else {
                    // Toggle quote state
                    inQuotes = !inQuotes;
                }
            } else if (char === ',' && !inQuotes) {
                // End of field
                currentLine.push(currentField.trim());
                currentField = '';
            } else if ((char === '\n' || char === '\r') && !inQuotes) {
                // End of line
                if (currentField.trim() || currentLine.length > 0) {
                    currentLine.push(currentField.trim());
                    lines.push(currentLine);
                    currentLine = [];
                    currentField = '';
                }
                // Skip \r\n
                if (char === '\r' && nextChar === '\n') {
                    i++;
                }
            } else {
                currentField += char;
            }
        }

        // Add last field and line
        if (currentField.trim() || currentLine.length > 0) {
            currentLine.push(currentField.trim());
            lines.push(currentLine);
        }

        return lines;
    };

    const handleImportCSV = async (classId: string, file: File) => {
        try {
            const text = await file.text();
            const lines = parseCSV(text);

            if (lines.length === 0) {
                alert('CSV file is empty');
                return;
            }

            // Skip header row if present
            const dataRows = lines[0][0]?.toLowerCase().includes('student id') || 
                           lines[0][0]?.toLowerCase().includes('id') 
                           ? lines.slice(1) 
                           : lines;

            // Extract student IDs from CSV
            // Support both formats: just IDs in first column, or full CSV with IDs
            const studentIds: number[] = [];
            const errors: string[] = [];

            for (let i = 0; i < dataRows.length; i++) {
                const row = dataRows[i];
                if (row.length === 0) continue;

                // Try to get ID from first column
                const idStr = row[0]?.trim();
                if (idStr) {
                    const id = parseInt(idStr);
                    if (!isNaN(id) && id > 0) {
                        // Check if student exists
                        const studentExists = allStudents.some(s => s.id === id);
                        if (studentExists) {
                            studentIds.push(id);
                        } else {
                            errors.push(`Row ${i + 2}: Student ID ${id} not found`);
                        }
                    } else {
                        errors.push(`Row ${i + 2}: Invalid student ID "${idStr}"`);
                    }
                }
            }

            if (studentIds.length === 0) {
                alert('No valid student IDs found in CSV file.\n' + 
                      (errors.length > 0 ? '\nErrors:\n' + errors.slice(0, 5).join('\n') : ''));
                return;
            }

            // Get existing student IDs in class
            const existingIds = (studentsByClass.get(classId) || []).map(cs => cs.studentId);
            const newIds = studentIds.filter(id => !existingIds.includes(id));

            if (newIds.length === 0) {
                alert('All students in the CSV are already in this class');
                return;
            }

            // Confirm import
            const skipped = studentIds.length - newIds.length;
            const confirmMessage = `Import ${newIds.length} student(s)?` + 
                (skipped > 0 ? `\n${skipped} student(s) already in class will be skipped.` : '') +
                (errors.length > 0 ? `\n\n${errors.length} error(s) found.` : '');
            
            if (!confirm(confirmMessage)) return;

            // Add students to class
            await classApi.addStudentsToClass(classId, { studentIds: newIds });
            
            // Reload students for expanded view
            if (expandedClasses.has(classId)) {
                await loadClassStudentsForExpandedView(classId);
            }
            // Reload classes to update counts
            await loadClasses();

            alert(`Successfully imported ${newIds.length} student(s) to the class!` + 
                (skipped > 0 ? `\n${skipped} student(s) were skipped (already in class).` : ''));
        } catch (err: any) {
            setError(err.message || 'Failed to import CSV file');
            console.error('CSV import error:', err);
        }
    };

    const handleFileSelect = (classId: string, event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (!file) return;

        if (!file.name.toLowerCase().endsWith('.csv')) {
            alert('Please select a CSV file');
            return;
        }

        handleImportCSV(classId, file);
        // Reset input
        event.target.value = '';
    };

    if (isLoading) {
        return (
            <div className="flex items-center justify-center h-full">
                <div className="text-center">
                    <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                    <p className="text-gray-600 dark:text-gray-400">Loading...</p>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4 sm:p-6 lg:p-8">
            <div className="max-w-7xl mx-auto space-y-6">
                {/* Header */}
                <motion.div
                    initial={{ opacity: 0, y: -20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-6"
                >
                    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                        <div>
                            <h1 className="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent mb-2">
                                Student Classes Management
                            </h1>
                            <p className="text-gray-600 dark:text-gray-400">
                                Create classes and manage student accounts
                            </p>
                        </div>
                        <div className="flex gap-3">
                            <button
                                onClick={() => setShowCreateStudentModal(true)}
                                className="flex items-center gap-2 px-6 py-3 bg-green-500 text-white rounded-xl hover:bg-green-600 transition-colors shadow-lg hover:shadow-xl"
                            >
                                <UserPlus size={20} />
                                <span>Create Student</span>
                            </button>
                            <button
                                onClick={() => setShowCreateClassModal(true)}
                                className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-primary to-secondary text-white rounded-xl hover:shadow-xl transition-all shadow-lg"
                            >
                                <Plus size={20} />
                                <span>Create Class</span>
                            </button>
                        </div>
                    </div>
                </motion.div>

                {error && (
                    <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4 text-red-800 dark:text-red-200">
                        {error}
                        <button onClick={() => setError(null)} className="float-right">
                            <X size={20} />
                        </button>
                    </div>
                )}

                {/* Classes List */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-white dark:bg-gray-800 rounded-2xl shadow-lg p-6"
                >
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                        <GraduationCap size={24} className="text-primary" />
                        My Classes ({classes.length})
                    </h2>

                    {classes.length === 0 ? (
                        <div className="text-center py-12">
                            <BookOpen size={48} className="text-gray-400 mx-auto mb-4" />
                            <p className="text-gray-600 dark:text-gray-400 mb-4">No classes yet</p>
                            <button
                                onClick={() => setShowCreateClassModal(true)}
                                className="px-6 py-3 bg-primary text-white rounded-xl hover:bg-primary/90 transition-colors"
                            >
                                Create First Class
                            </button>
                        </div>
                    ) : (
                        <div className="space-y-3">
                            {classes.map((cls) => (
                                <div
                                    key={cls.id}
                                    className="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden"
                                >
                                    <div
                                        className="p-4 bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-100 dark:hover:bg-gray-700 cursor-pointer transition-colors flex items-center justify-between"
                                        onClick={() => toggleClass(cls.id)}
                                    >
                                        <div className="flex items-center gap-3 flex-1">
                                            {expandedClasses.has(cls.id) ? (
                                                <ChevronDown size={20} />
                                            ) : (
                                                <ChevronRight size={20} />
                                            )}
                                            <div className="flex-1">
                                                <h3 className="font-semibold text-gray-900 dark:text-white">{cls.name}</h3>
                                                {cls.description && (
                                                    <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">{cls.description}</p>
                                                )}
                                            </div>
                                            <span className="text-sm text-gray-500 dark:text-gray-400">
                                                {cls.studentCount} students
                                            </span>
                                        </div>
                                        <div className="flex items-center gap-2 ml-4">
                                            <button
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    handleDeleteClass(cls.id);
                                                }}
                                                className="p-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"
                                                title="Delete Class"
                                            >
                                                <Trash2 size={18} />
                                            </button>
                                        </div>
                                    </div>

                                    {expandedClasses.has(cls.id) && (
                                        <div className="p-4 border-t border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800">
                                            {/* Class Info */}
                                            <div className="text-sm text-gray-600 dark:text-gray-400 mb-4 pb-4 border-b border-gray-200 dark:border-gray-700">
                                                <p><strong>Created:</strong> {new Date(cls.createdAt).toLocaleDateString()}</p>
                                                <p><strong>Updated:</strong> {new Date(cls.updatedAt).toLocaleDateString()}</p>
                                                <p><strong>Total Students:</strong> {cls.studentCount}</p>
                                            </div>

                                            {/* Students List Section */}
                                            <div className="space-y-3">
                                                <div className="flex items-center justify-between">
                                                    <h4 className="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
                                                        <Users size={18} />
                                                        Students in Class
                                                    </h4>
                                                    <div className="flex items-center gap-2">
                                                        <label className="flex items-center gap-2 px-3 py-1.5 text-sm bg-purple-500 text-white rounded-lg hover:bg-purple-600 transition-colors cursor-pointer">
                                                            <Upload size={16} />
                                                            Import CSV
                                                            <input
                                                                type="file"
                                                                accept=".csv"
                                                                className="hidden"
                                                                onChange={(e) => handleFileSelect(cls.id, e)}
                                                                onClick={(e) => e.stopPropagation()}
                                                            />
                                                        </label>
                                                        {(studentsByClass.get(cls.id) || []).length > 0 && (
                                                            <button
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    exportStudentsToCSV(cls.id, cls.name);
                                                                }}
                                                                className="flex items-center gap-2 px-3 py-1.5 text-sm bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                                                                title="Export to CSV"
                                                            >
                                                                <Download size={16} />
                                                                Export CSV
                                                            </button>
                                                        )}
                                                        <button
                                                            onClick={(e) => {
                                                                e.stopPropagation();
                                                                setSelectedClass(cls);
                                                                setShowAddStudentsModal(true);
                                                            }}
                                                            className="flex items-center gap-2 px-3 py-1.5 text-sm bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
                                                        >
                                                            <UserPlus size={16} />
                                                            Add Students
                                                        </button>
                                                    </div>
                                                </div>

                                                {loadingStudents.has(cls.id) ? (
                                                    <div className="text-center py-4">
                                                        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
                                                        <p className="text-sm text-gray-500 dark:text-gray-400">Loading students...</p>
                                                    </div>
                                                ) : (
                                                    <>
                                                        {(!studentsByClass.has(cls.id) || (studentsByClass.get(cls.id) || []).length === 0) ? (
                                                            <div className="text-center py-6 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg">
                                                                <Users size={32} className="text-gray-400 mx-auto mb-2" />
                                                                <p className="text-sm text-gray-500 dark:text-gray-400 mb-3">
                                                                    No students in this class yet
                                                                </p>
                                                                <button
                                                                    onClick={(e) => {
                                                                        e.stopPropagation();
                                                                        setSelectedClass(cls);
                                                                        setShowAddStudentsModal(true);
                                                                    }}
                                                                    className="px-4 py-2 text-sm bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
                                                                >
                                                                    Add First Student
                                                                </button>
                                                            </div>
                                                        ) : (
                                                            <div className="space-y-2 max-h-64 overflow-y-auto">
                                                                {(studentsByClass.get(cls.id) || []).map((cs) => {
                                                                    const studentInfo = allStudents.find(s => s.id === cs.studentId);
                                                                    return (
                                                                        <div
                                                                            key={cs.studentId}
                                                                            className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                                                                        >
                                                                            <div className="flex-1">
                                                                                <div className="flex items-center gap-2">
                                                                                    {studentInfo ? (
                                                                                        <>
                                                                                            <p className="font-medium text-gray-900 dark:text-white">
                                                                                                {studentInfo.firstName} {studentInfo.lastName}
                                                                                            </p>
                                                                                            <span className="text-xs px-2 py-0.5 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 rounded">
                                                                                                ID: {cs.studentId}
                                                                                            </span>
                                                                                        </>
                                                                                    ) : (
                                                                                        <p className="font-medium text-gray-900 dark:text-white">
                                                                                            Student ID: {cs.studentId}
                                                                                        </p>
                                                                                    )}
                                                                                </div>
                                                                                {studentInfo && (
                                                                                    <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                                                                                        {studentInfo.email}
                                                                                    </p>
                                                                                )}
                                                                                <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
                                                                                    Added {new Date(cs.addedAt).toLocaleDateString()}
                                                                                </p>
                                                                            </div>
                                                                            <button
                                                                                onClick={(e) => {
                                                                                    e.stopPropagation();
                                                                                    handleRemoveStudentFromClass(cls.id, cs.studentId);
                                                                                }}
                                                                                className="p-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors ml-2"
                                                                                title="Remove from class"
                                                                            >
                                                                                <Trash2 size={16} />
                                                                            </button>
                                                                        </div>
                                                                    );
                                                                })}
                                                            </div>
                                                        )}
                                                    </>
                                                )}
                                            </div>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>
                    )}
                </motion.div>


                {/* Create Class Modal */}
                {showCreateClassModal && (
                    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                        <motion.div
                            initial={{ opacity: 0, scale: 0.9 }}
                            animate={{ opacity: 1, scale: 1 }}
                            className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full p-6"
                        >
                            <div className="flex items-center justify-between mb-6">
                                <h3 className="text-2xl font-bold text-gray-900 dark:text-white">Create New Class</h3>
                                <button
                                    onClick={() => setShowCreateClassModal(false)}
                                    className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
                                >
                                    <X size={20} />
                                </button>
                            </div>
                            <form onSubmit={handleCreateClass} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        Class Name *
                                    </label>
                                    <input
                                        type="text"
                                        required
                                        minLength={3}
                                        maxLength={255}
                                        value={newClass.name}
                                        onChange={(e) => setNewClass({ ...newClass, name: e.target.value })}
                                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                        placeholder="e.g., Mathematics 101 - Section A"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        Description
                                    </label>
                                    <textarea
                                        value={newClass.description}
                                        onChange={(e) => setNewClass({ ...newClass, description: e.target.value })}
                                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                        rows={3}
                                        placeholder="Optional description"
                                    />
                                </div>
                                <div className="flex gap-3 pt-4">
                                    <button
                                        type="button"
                                        onClick={() => setShowCreateClassModal(false)}
                                        className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        type="submit"
                                        className="flex-1 px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90"
                                    >
                                        Create Class
                                    </button>
                                </div>
                            </form>
                        </motion.div>
                    </div>
                )}

                {/* Create Student Modal */}
                {showCreateStudentModal && (
                    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                        <motion.div
                            initial={{ opacity: 0, scale: 0.9 }}
                            animate={{ opacity: 1, scale: 1 }}
                            className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-md w-full p-6"
                        >
                            <div className="flex items-center justify-between mb-6">
                                <h3 className="text-2xl font-bold text-gray-900 dark:text-white">Create Student Account</h3>
                                <button
                                    onClick={() => setShowCreateStudentModal(false)}
                                    className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
                                >
                                    <X size={20} />
                                </button>
                            </div>
                            <form onSubmit={handleCreateStudent} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        First Name *
                                    </label>
                                    <input
                                        type="text"
                                        required
                                        value={newStudent.firstName}
                                        onChange={(e) => setNewStudent({ ...newStudent, firstName: e.target.value })}
                                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        Last Name *
                                    </label>
                                    <input
                                        type="text"
                                        required
                                        value={newStudent.lastName}
                                        onChange={(e) => setNewStudent({ ...newStudent, lastName: e.target.value })}
                                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        Email *
                                    </label>
                                    <input
                                        type="email"
                                        required
                                        value={newStudent.email}
                                        onChange={(e) => setNewStudent({ ...newStudent, email: e.target.value })}
                                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        Password *
                                    </label>
                                    <input
                                        type="password"
                                        required
                                        minLength={6}
                                        value={newStudent.password}
                                        onChange={(e) => setNewStudent({ ...newStudent, password: e.target.value })}
                                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                                    />
                                </div>
                                <div className="flex gap-3 pt-4">
                                    <button
                                        type="button"
                                        onClick={() => setShowCreateStudentModal(false)}
                                        className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        type="submit"
                                        className="flex-1 px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600"
                                    >
                                        Create Student
                                    </button>
                                </div>
                            </form>
                        </motion.div>
                    </div>
                )}

                {/* Add Students Modal */}
                {showAddStudentsModal && selectedClass && (
                    <AddStudentsModal
                        classId={selectedClass.id}
                        existingStudentIds={(studentsByClass.get(selectedClass.id) || []).map(cs => cs.studentId)}
                        onClose={() => setShowAddStudentsModal(false)}
                        onSuccess={async () => {
                            if (expandedClasses.has(selectedClass.id)) {
                                await loadClassStudentsForExpandedView(selectedClass.id);
                            }
                            await loadClasses();
                            setShowAddStudentsModal(false);
                        }}
                    />
                )}
            </div>
        </div>
    );
};

// Add Students Modal Component
interface AddStudentsModalProps {
    classId: string;
    existingStudentIds: number[];
    onClose: () => void;
    onSuccess: () => void;
}

const AddStudentsModal: React.FC<AddStudentsModalProps> = ({ classId, existingStudentIds, onClose, onSuccess }) => {
    const [allStudents, setAllStudents] = useState<UserDto[]>([]);
    const [filteredStudents, setFilteredStudents] = useState<UserDto[]>([]);
    const [selectedIds, setSelectedIds] = useState<number[]>([]);
    const [searchQuery, setSearchQuery] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        loadAllStudents();
    }, []);

    useEffect(() => {
        if (searchQuery.trim()) {
            const query = searchQuery.toLowerCase();
            setFilteredStudents(
                allStudents.filter(
                    student =>
                        student.firstName.toLowerCase().includes(query) ||
                        student.lastName.toLowerCase().includes(query) ||
                        student.email.toLowerCase().includes(query) ||
                        student.id.toString().includes(query)
                )
            );
        } else {
            setFilteredStudents(allStudents);
        }
    }, [searchQuery, allStudents]);

    const loadAllStudents = async () => {
        try {
            setIsLoading(true);
            // Use the dedicated endpoint for students (available for TEACHER role)
            const students = await userApi.getAllStudents();
            setAllStudents(students);
            setFilteredStudents(students);
        } catch (err: any) {
            setError(err.message || 'Failed to load students');
            console.error('Error loading students:', err);
        } finally {
            setIsLoading(false);
        }
    };

    const toggleStudentSelection = (studentId: number) => {
        setSelectedIds(prev => {
            if (prev.includes(studentId)) {
                return prev.filter(id => id !== studentId);
            } else {
                return [...prev, studentId];
            }
        });
    };

    const handleSelectAll = () => {
        const availableIds = filteredStudents
            .filter(s => !existingStudentIds.includes(s.id))
            .map(s => s.id);
        
        if (availableIds.every(id => selectedIds.includes(id))) {
            // Deselect all filtered
            setSelectedIds(prev => prev.filter(id => !availableIds.includes(id)));
        } else {
            // Select all filtered
            setSelectedIds(prev => [...new Set([...prev, ...availableIds])]);
        }
    };

    const handleAddStudents = async () => {
        try {
            if (selectedIds.length === 0) {
                setError('Please select at least one student');
                return;
            }

            await classApi.addStudentsToClass(classId, { studentIds: selectedIds });
            setSelectedIds([]);
            onSuccess();
        } catch (err: any) {
            setError(err.message || 'Failed to add students');
        }
    };

    const availableStudents = filteredStudents.filter(s => !existingStudentIds.includes(s.id));
    const allSelected = availableStudents.length > 0 && availableStudents.every(s => selectedIds.includes(s.id));

    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
            <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-2xl w-full p-6 max-h-[90vh] flex flex-col"
            >
                <div className="flex items-center justify-between mb-6">
                    <h3 className="text-2xl font-bold text-gray-900 dark:text-white">Add Students to Class</h3>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
                    >
                        <X size={20} />
                    </button>
                </div>

                {error && (
                    <div className="mb-4 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg text-red-800 dark:text-red-200 text-sm">
                        {error}
                        <button onClick={() => setError(null)} className="float-right">
                            <X size={16} />
                        </button>
                    </div>
                )}

                <div className="flex-1 overflow-y-auto space-y-4">
                    {/* Search Bar */}
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
                        <input
                            type="text"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            placeholder="Search students by name, email, or ID..."
                            className="w-full pl-11 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary outline-none"
                        />
                    </div>

                    {/* Select All */}
                    {availableStudents.length > 0 && (
                        <div className="flex items-center gap-2 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
                            <input
                                type="checkbox"
                                checked={allSelected}
                                onChange={handleSelectAll}
                                className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
                            />
                            <label className="text-sm font-medium text-gray-700 dark:text-gray-300 cursor-pointer">
                                Select All ({availableStudents.length} available)
                            </label>
                            {selectedIds.length > 0 && (
                                <span className="ml-auto text-sm text-primary font-medium">
                                    {selectedIds.length} selected
                                </span>
                            )}
                        </div>
                    )}

                    {/* Students List */}
                    {isLoading ? (
                        <div className="text-center py-12">
                            <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                            <p className="text-gray-600 dark:text-gray-400">Loading students...</p>
                        </div>
                    ) : availableStudents.length === 0 ? (
                        <div className="text-center py-12">
                            <Users size={48} className="text-gray-400 mx-auto mb-4" />
                            <p className="text-gray-600 dark:text-gray-400">
                                {filteredStudents.length === 0 
                                    ? 'No students found' 
                                    : 'All students are already in this class'}
                            </p>
                        </div>
                    ) : (
                        <div className="space-y-2 max-h-96 overflow-y-auto">
                            {availableStudents.map((student) => {
                                const isSelected = selectedIds.includes(student.id);
                                return (
                                    <div
                                        key={student.id}
                                        onClick={() => toggleStudentSelection(student.id)}
                                        className={`p-4 border rounded-lg cursor-pointer transition-all ${
                                            isSelected
                                                ? 'border-primary bg-primary/5 dark:bg-primary/10'
                                                : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                                        }`}
                                    >
                                        <div className="flex items-center gap-3">
                                            <input
                                                type="checkbox"
                                                checked={isSelected}
                                                onChange={() => toggleStudentSelection(student.id)}
                                                onClick={(e) => e.stopPropagation()}
                                                className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
                                            />
                                            <div className="flex-1">
                                                <div className="flex items-center gap-2">
                                                    <p className="font-semibold text-gray-900 dark:text-white">
                                                        {student.firstName} {student.lastName}
                                                    </p>
                                                    <span className="text-xs px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 rounded">
                                                        ID: {student.id}
                                                    </span>
                                                </div>
                                                <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                                                    {student.email}
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    )}

                    {/* Already in class students (for info) */}
                    {filteredStudents.filter(s => existingStudentIds.includes(s.id)).length > 0 && (
                        <div className="pt-4 border-t border-gray-200 dark:border-gray-700">
                            <p className="text-sm text-gray-500 dark:text-gray-400 mb-2">
                                Already in class ({filteredStudents.filter(s => existingStudentIds.includes(s.id)).length}):
                            </p>
                            <div className="space-y-1 max-h-32 overflow-y-auto">
                                {filteredStudents
                                    .filter(s => existingStudentIds.includes(s.id))
                                    .map((student) => (
                                        <div
                                            key={student.id}
                                            className="p-2 bg-gray-50 dark:bg-gray-700/30 rounded text-sm text-gray-500 dark:text-gray-400"
                                        >
                                            {student.firstName} {student.lastName} ({student.email})
                                        </div>
                                    ))}
                            </div>
                        </div>
                    )}
                </div>

                {/* Actions */}
                <div className="flex gap-3 pt-4 mt-4 border-t border-gray-200 dark:border-gray-700">
                    <button
                        type="button"
                        onClick={onClose}
                        className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
                    >
                        Cancel
                    </button>
                    <button
                        type="button"
                        onClick={handleAddStudents}
                        disabled={selectedIds.length === 0}
                        className="flex-1 px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        Add {selectedIds.length > 0 ? `${selectedIds.length} ` : ''}Student{selectedIds.length !== 1 ? 's' : ''}
                    </button>
                </div>
            </motion.div>
        </div>
    );
};

export default Students;

