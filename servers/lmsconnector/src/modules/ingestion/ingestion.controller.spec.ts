import { Test, TestingModule } from '@nestjs/testing';
import { IngestionController } from './ingestion.controller';
import { IngestionService } from './ingestion.service';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';

describe('IngestionController', () => {
    let controller: IngestionController;
    let service: IngestionService;

    const mockIngestionService = {
        syncCourseStudents: jest.fn(),
        pullAndTransformData: jest.fn(),
        getAllAIStudentData: jest.fn(),
        getStudentAIData: jest.fn(),
        exportAIDataAsCSV: jest.fn(),
        getDataStatistics: jest.fn(),
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            controllers: [IngestionController],
            providers: [
                {
                    provide: IngestionService,
                    useValue: mockIngestionService,
                },
            ],
        })
            .overrideGuard(JwtAuthGuard)
            .useValue({ canActivate: () => true })
            .compile();

        controller = module.get<IngestionController>(IngestionController);
        service = module.get<IngestionService>(IngestionService);
    });

    it('should be defined', () => {
        expect(controller).toBeDefined();
    });

    it('should sync course students', async () => {
        const courseId = 123;
        await controller.syncCourseStudents(courseId);
        expect(service.syncCourseStudents).toHaveBeenCalledWith(courseId);
    });

    it('should pull data from moodle', async () => {
        await controller.pullDataFromMoodle();
        expect(service.pullAndTransformData).toHaveBeenCalled();
    });

    it('should return health status', async () => {
        const result = await controller.healthCheck();
        expect(result).toEqual({ status: 'ok', service: 'ingestion' });
    });

    it('should get all AI data', async () => {
        await controller.getAllAIData();
        expect(service.getAllAIStudentData).toHaveBeenCalled();
    });

    it('should get student AI data', async () => {
        await controller.getStudentAIData(1);
        expect(service.getStudentAIData).toHaveBeenCalledWith(1);
    });

    it('should export CSV', async () => {
        await controller.exportAsCSV();
        expect(service.exportAIDataAsCSV).toHaveBeenCalled();
    });

    it('should get stats', async () => {
        await controller.getStats();
        expect(service.getDataStatistics).toHaveBeenCalled();
    });
});
