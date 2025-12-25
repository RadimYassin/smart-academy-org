import { Test, TestingModule } from '@nestjs/testing';
import { IngestionService } from './ingestion.service';
import { MoodleService } from './moodle/moodle.service';
import { studentNormalizer } from './normalizers/student.normalizer';
import { MoodleToAITransformer } from './transformers/moodle-to-ai.transformer';
import { getRepositoryToken } from '@nestjs/typeorm';
import { RowData } from './entities/raw-data.entity';
import { Student } from './entities/student.entity';
import { AIStudentData } from './entities/ai-student-data.entity';

describe('IngestionService', () => {
    let service: IngestionService;
    let moodleService: MoodleService;

    // Mocks with matching typos from service implementation
    const mockMoodleService = {
        fecthEnreollledUsers: jest.fn(),
        fetchDataForAI: jest.fn(),
    };
    const mockStudentNormalizer = {
        normalize: jest.fn((user) => user),
    };
    const mockMoodleToAITransformer = {
        transform: jest.fn(),
    };

    // Mock QueryBuilder
    const mockQueryBuilder = {
        select: jest.fn().mockReturnThis(),
        addSelect: jest.fn().mockReturnThis(),
        groupBy: jest.fn().mockReturnThis(),
        getRawOne: jest.fn(),
        getRawMany: jest.fn(),
    };

    const mockRepository = {
        save: jest.fn(),
        find: jest.fn(),
        count: jest.fn(),
        createQueryBuilder: jest.fn(() => mockQueryBuilder),
    };

    beforeEach(async () => {
        // Clear mocks
        jest.clearAllMocks();
        mockQueryBuilder.select.mockReturnThis();

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                IngestionService,
                { provide: MoodleService, useValue: mockMoodleService },
                { provide: studentNormalizer, useValue: mockStudentNormalizer },
                { provide: MoodleToAITransformer, useValue: mockMoodleToAITransformer },
                { provide: getRepositoryToken(RowData), useValue: mockRepository },
                { provide: getRepositoryToken(Student), useValue: mockRepository },
                { provide: getRepositoryToken(AIStudentData), useValue: mockRepository },
            ],
        }).compile();

        service = module.get<IngestionService>(IngestionService);
        moodleService = module.get<MoodleService>(MoodleService);
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });

    describe('syncCourseStudents', () => {
        it('should sync students successfully', async () => {
            const courseId = 100;
            const mockUsers = [{ id: 1 }, { id: 2 }];
            mockMoodleService.fecthEnreollledUsers.mockResolvedValue(mockUsers);
            mockRepository.save.mockResolvedValue(mockUsers);

            const result = await service.syncCourseStudents(courseId);

            expect(mockMoodleService.fecthEnreollledUsers).toHaveBeenCalledWith(courseId);
            expect(mockRepository.save).toHaveBeenCalledTimes(2); // Once for RowData, once for Student
            expect(result.status).toBe('success');
            expect(result.syncedStudents).toHaveLength(2);
        });
    });

    describe('pullAndTransformData', () => {
        it('should pull and transform data successfully', async () => {
            const moodleData = {
                success: true,
                recordsCollected: 1,
                data: [{ student: { id: 1 } }],
                coursesProcessed: 5
            };
            mockMoodleService.fetchDataForAI.mockResolvedValue(moodleData);
            mockMoodleToAITransformer.transform.mockReturnValue({ studentId: 1, grade: 90 });
            mockRepository.save.mockResolvedValue([{ studentId: 1 }]);

            const result = await service.pullAndTransformData();

            expect(mockMoodleService.fetchDataForAI).toHaveBeenCalled();
            expect(mockRepository.save).toHaveBeenCalled();
            expect(result.status).toBe('success');
            expect(result.recordsCollected).toBe(1);
        });

        it('should handle failure in moodle fetch', async () => {
            mockMoodleService.fetchDataForAI.mockResolvedValue({ success: false });

            const result = await service.pullAndTransformData();

            expect(result.status).toBe('error');
            expect(result.message).toBe('Failed to fetch data from Moodle');
        });
    });

    describe('getDataStatistics', () => {
        it('should return statistics', async () => {
            mockRepository.count.mockResolvedValue(100);

            // Mock QueryBuilder responses
            mockQueryBuilder.getRawOne
                .mockResolvedValueOnce({ count: '50' }) // distinct students
                .mockResolvedValueOnce({ count: '10' }) // distinct courses
                .mockResolvedValueOnce({ average: '85.5' }); // avg grade

            mockQueryBuilder.getRawMany.mockResolvedValue([{ status: 'PASS', count: '90' }]);

            const stats = await service.getDataStatistics();

            expect(stats.totalRecords).toBe(100);
            expect(stats.uniqueStudents).toBe(50);
            expect(stats.uniqueCourses).toBe(10);
            expect(stats.averageGrade).toBe('85.50');
        });
    });
});
