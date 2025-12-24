import { Injectable, Logger } from "@nestjs/common";
import { MoodleService } from "./moodle/moodle.service";
import { studentNormalizer } from "./normalizers/student.normalizer";
import { InjectRepository } from "@nestjs/typeorm";
import { RowData } from "./entities/raw-data.entity";
import { Repository } from "typeorm";
import { Student } from "./entities/student.entity";
import { AIStudentData } from "./entities/ai-student-data.entity";
import { MoodleToAITransformer } from "./transformers/moodle-to-ai.transformer";


@Injectable()

export class IngestionService {

    private readonly logger = new Logger(IngestionService.name);
    constructor(
        private readonly moodelService: MoodleService,
        private readonly studentNormalizer: studentNormalizer,
        private readonly moodleToAITransformer: MoodleToAITransformer,
        @InjectRepository(RowData) private readonly rawDataRepository: Repository<RowData>,
        @InjectRepository(Student) private readonly studentRepository: Repository<Student>,
        @InjectRepository(AIStudentData) private readonly aiStudentDataRepository: Repository<AIStudentData>,
    ) { }


    async syncCourseStudents(courseId: number) {
        this.logger.log(`Starting ingestion of enrolled users for course ID: ${courseId}`);

        // Step 1: Fetch raw enrolled users data from Moodle
        const rowUsers = await this.moodelService.fecthEnreollledUsers(courseId);
        this.logger.log(`Fetched ${rowUsers.length} users from Moodle for course ID: ${courseId}`);

        // Step 2: Store raw data
        await this.rawDataRepository.save({
            source: 'MOODLE',
            dataType: 'ENROLLED_USERS',
            data: rowUsers
        });

        // Step 3: Normalize and store students
        const sutdentsTosave = rowUsers.map((user) => this.studentNormalizer.normalize(user));

        // Step 4: store in Sutdent table
        await this.studentRepository.save(sutdentsTosave);

        this.logger.log(`Synced ${sutdentsTosave.length} students.`);

        return { status: 'success', syncedStudents: sutdentsTosave }
    }

    /**
     * Main method to pull data from Moodle and transform for AI models
     */
    async pullAndTransformData() {
        this.logger.log('Starting comprehensive data pull and transformation for AI models');

        try {
            // Step 1: Fetch all data from Moodle
            const moodleData = await this.moodelService.fetchDataForAI();

            if (!moodleData.success) {
                throw new Error('Failed to fetch data from Moodle');
            }

            this.logger.log(`Fetched ${moodleData.recordsCollected} records from Moodle`);

            // Step 2: Store raw data for auditing
            await this.rawDataRepository.save({
                source: 'MOODLE',
                dataType: 'AI_COMPREHENSIVE_DATA',
                data: moodleData.data,
            });

            // Step 3: Transform each record to AI format
            const transformedRecords: AIStudentData[] = [];
            for (const record of moodleData.data) {
                try {
                    const transformed = this.moodleToAITransformer.transform(record);

                    // Create AIStudentData entity
                    const aiRecord: AIStudentData = {
                        id: undefined as any, // Will be auto-generated
                        ...transformed,
                        lastUpdated: new Date(),
                        createdAt: new Date(),
                    };

                    transformedRecords.push(aiRecord);
                } catch (error) {
                    this.logger.warn(`Failed to transform record for student ${record.student.id}: ${error.message}`);
                }
            }

            // Step 4: Save transformed data
            let savedRecords: AIStudentData[] = [];
            if (transformedRecords.length > 0) {
                savedRecords = await this.aiStudentDataRepository.save(transformedRecords as AIStudentData[]);
                this.logger.log(`Successfully saved ${savedRecords.length} records in AI format`);
            } else {
                this.logger.log('No records to save');
            }

            return {
                status: 'success',
                coursesProcessed: moodleData.coursesProcessed,
                recordsCollected: moodleData.recordsCollected,
                recordsSaved: savedRecords.length,
                message: 'Data successfully pulled from Moodle and stored in AI format',
            };
        } catch (error) {
            this.logger.error(`Data pull and transformation failed: ${error.message}`, error.stack);
            return {
                status: 'error',
                message: error.message,
            };
        }
    }

    /**
     * Get all AI student data from database
     */
    async getAllAIStudentData() {
        return this.aiStudentDataRepository.find({
            order: { createdAt: 'DESC' }
        });
    }

    /**
     * Get AI data for a specific student
     */
    async getStudentAIData(studentId: number) {
        return this.aiStudentDataRepository.find({
            where: { studentId },
            order: { semester: 'ASC' }
        });
    }

    /**
     * Export AI data as CSV
     */
    async exportAIDataAsCSV() {
        const data = await this.aiStudentDataRepository.find({
            order: { studentId: 'ASC', semester: 'ASC' }
        });

        if (data.length === 0) {
            return { message: 'No data available to export' };
        }

        // CSV Header
        const csvHeader = 'ID,Major,MajorYear,Subject,Semester,Practical,Theoretical,Total,Status';

        // CSV Rows
        const csvRows = data.map(record =>
            `${record.studentId},${record.major},${record.majorYear},${record.subject},${record.semester},${record.practical},${record.theoretical},${record.total},${record.status}`
        );

        const csv = [csvHeader, ...csvRows].join('\n');

        return {
            format: 'csv',
            data: csv,
            recordCount: data.length
        };
    }

    /**
     * Get data collection statistics
     */
    async getDataStatistics() {
        const totalRecords = await this.aiStudentDataRepository.count();
        const uniqueStudents = await this.aiStudentDataRepository
            .createQueryBuilder('data')
            .select('COUNT(DISTINCT data.studentId)', 'count')
            .getRawOne();

        const uniqueCourses = await this.aiStudentDataRepository
            .createQueryBuilder('data')
            .select('COUNT(DISTINCT data.subject)', 'count')
            .getRawOne();

        const avgGrade = await this.aiStudentDataRepository
            .createQueryBuilder('data')
            .select('AVG(data.total)', 'average')
            .getRawOne();

        const statusDistribution = await this.aiStudentDataRepository
            .createQueryBuilder('data')
            .select('data.status', 'status')
            .addSelect('COUNT(*)', 'count')
            .groupBy('data.status')
            .getRawMany();

        return {
            totalRecords,
            uniqueStudents: parseInt(uniqueStudents.count),
            uniqueCourses: parseInt(uniqueCourses.count),
            averageGrade: parseFloat(avgGrade.average).toFixed(2),
            statusDistribution
        };
    }
}