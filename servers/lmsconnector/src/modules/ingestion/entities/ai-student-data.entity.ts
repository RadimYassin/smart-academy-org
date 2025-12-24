import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

/**
 * Entity to store student data in AI model format
 * Maps directly to the format required by PrepaData, StudentProfiler, PathPredictor
 */
@Entity('ai_student_data')
export class AIStudentData {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    studentId: number; // Maps to ID in AI models

    @Column({ nullable: true })
    studentName: string;

    @Column({ nullable: true })
    major: string; // Student's program (CS, IT, etc.)

    @Column({ nullable: true, type: 'int' })
    majorYear: number; // Year in program (1-4)

    @Column()
    subject: string; // Course name

    @Column()
    courseId: number; // Moodle course ID

    @Column({ type: 'int' })
    semester: number; // Academic semester

    @Column({ type: 'float', nullable: true })
    practical: number; // Practical/Lab grade

    @Column({ type: 'float', nullable: true })
    theoretical: number; // Theory/Exam grade

    @Column({ type: 'float' })
    total: number; // Combined grade

    @Column({ nullable: true })
    status: string; // Passed/Failed/Absent/Withdrawal

    @CreateDateColumn()
    createdAt: Date;

    @Column({ type: 'timestamp', nullable: true })
    lastUpdated: Date;
}
