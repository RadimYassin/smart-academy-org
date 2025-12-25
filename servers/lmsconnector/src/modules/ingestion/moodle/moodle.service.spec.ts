import { Test, TestingModule } from '@nestjs/testing';
import { MoodleService } from './moodle.service';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { of } from 'rxjs';

describe('MoodleService', () => {
    let service: MoodleService;
    let httpService: HttpService;
    let configService: ConfigService;

    const mockHttpService = {
        get: jest.fn(),
    };

    const mockConfigService = {
        get: jest.fn(),
    };

    beforeEach(async () => {
        // Simple mock reset
        jest.clearAllMocks();

        mockConfigService.get.mockImplementation((key: string) => {
            if (key === 'MOODLE_URL') return 'http://moodle.test';
            if (key === 'MOODLE_TOKEN') return 'token123';
            return null;
        });

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                MoodleService,
                { provide: HttpService, useValue: mockHttpService },
                { provide: ConfigService, useValue: mockConfigService },
            ],
        }).compile();

        service = module.get<MoodleService>(MoodleService);
        httpService = module.get<HttpService>(HttpService);
        configService = module.get<ConfigService>(ConfigService);
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });

    it('should fetch all courses successfully', async () => {
        const mockResponse = { data: [{ id: 1, fullname: 'Course 1' }] };
        mockHttpService.get.mockReturnValue(of(mockResponse));

        const result = await service.fetchAllCourses();
        expect(result).toHaveLength(1);
        expect(result[0].id).toBe(1);
    });

    it('should fetch enrolled users successfully', async () => {
        const mockResponse = { data: [{ id: 10, username: 'student' }] };
        mockHttpService.get.mockReturnValue(of(mockResponse));

        const result = await service.fecthEnreollledUsers(100);
        expect(result).toHaveLength(1);
    });

    describe('fetchDataForAI orchestration', () => {
        it('should orchestrate calls correctly', async () => {
            jest.spyOn(service, 'fetchAllCourses').mockResolvedValue([
                { id: 1, fullname: 'Site' },
                { id: 2, fullname: 'Course 2', shortname: 'C2' }
            ]);
            jest.spyOn(service, 'fecthEnreollledUsers').mockResolvedValue([
                { id: 101, fullname: 'Student A', email: 'a@test.com' }
            ]);
            jest.spyOn(service, 'fetchUserGrades').mockResolvedValue({
                usergrades: [{ gradeitems: [] }]
            });

            const result = await service.fetchDataForAI();

            expect(result.success).toBe(true);
            expect(result.coursesProcessed).toBe(1);
            expect(result.recordsCollected).toBe(1);
            expect(service.fetchAllCourses).toHaveBeenCalled();
            expect(service.fecthEnreollledUsers).toHaveBeenCalledWith(2);
        });

        it('should handle errors in course processing loop', async () => {
            jest.spyOn(service, 'fetchAllCourses').mockResolvedValue([
                { id: 2, fullname: 'Course 2' }
            ]);
            jest.spyOn(service, 'fecthEnreollledUsers').mockRejectedValue(new Error('Fetch Fail'));

            const result = await service.fetchDataForAI();
            expect(result.success).toBe(true);
            expect(result.recordsCollected).toBe(0);
        });
    });
});
