import { Test, TestingModule } from '@nestjs/testing';
import { MoodleService } from './moodle.service';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { of, throwError } from 'rxjs';
import { HttpException, HttpStatus } from '@nestjs/common';

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

    describe('Constructor Configuration', () => {
        it('should throw error when MOODLE_URL is not set', async () => {
            mockConfigService.get.mockImplementation((key: string) => {
                if (key === 'MOODLE_URL') return null;
                if (key === 'MOODLE_TOKEN') return 'token123';
                return null;
            });

            await expect(async () => {
                await Test.createTestingModule({
                    providers: [
                        MoodleService,
                        { provide: HttpService, useValue: mockHttpService },
                        { provide: ConfigService, useValue: mockConfigService },
                    ],
                }).compile();
            }).rejects.toThrow('Configuration error: MOODLE_URL is not set');
        });

        it('should throw error when MOODLE_TOKEN is not set', async () => {
            mockConfigService.get.mockImplementation((key: string) => {
                if (key === 'MOODLE_URL') return 'http://moodle.test';
                if (key === 'MOODLE_TOKEN') return null;
                return null;
            });

            await expect(async () => {
                await Test.createTestingModule({
                    providers: [
                        MoodleService,
                        { provide: HttpService, useValue: mockHttpService },
                        { provide: ConfigService, useValue: mockConfigService },
                    ],
                }).compile();
            }).rejects.toThrow('Configuration error: MOODLE_TOKEN is not set');
        });
    });

    describe('fetchAllCourses', () => {
        it('should fetch all courses successfully', async () => {
            const mockResponse = { data: [{ id: 1, fullname: 'Course 1' }] };
            mockHttpService.get.mockReturnValue(of(mockResponse));

            const result = await service.fetchAllCourses();
            expect(result).toHaveLength(1);
            expect(result[0].id).toBe(1);
        });

        it('should handle HTTP errors', async () => {
            mockHttpService.get.mockReturnValue(
                throwError(() => new Error('Network error'))
            );

            await expect(service.fetchAllCourses()).rejects.toThrow(HttpException);
            await expect(service.fetchAllCourses()).rejects.toThrow('Failed to connect to LMS');
        });

        it('should handle Moodle API exceptions', async () => {
            const mockResponse = {
                data: {
                    exception: 'invalid_token',
                    message: 'Invalid token',
                },
            };
            mockHttpService.get.mockReturnValue(of(mockResponse));

            // Moodle API exceptions are caught and wrapped in HttpException
            await expect(service.fetchAllCourses()).rejects.toThrow(HttpException);
            await expect(service.fetchAllCourses()).rejects.toThrow('Failed to connect to LMS');
        });
    });

    describe('fecthEnreollledUsers', () => {
        it('should fetch enrolled users successfully', async () => {
            const mockResponse = { data: [{ id: 10, username: 'student' }] };
            mockHttpService.get.mockReturnValue(of(mockResponse));

            const result = await service.fecthEnreollledUsers(100);
            expect(result).toHaveLength(1);
        });

        it('should handle HTTP errors when fetching users', async () => {
            mockHttpService.get.mockReturnValue(
                throwError(() => new Error('Connection timeout'))
            );

            await expect(service.fecthEnreollledUsers(100)).rejects.toThrow(HttpException);
        });
    });

    describe('fetchUserProfile', () => {
        it('should fetch user profile successfully', async () => {
            const mockResponse = { data: [{ id: 5, fullname: 'John Doe' }] };
            mockHttpService.get.mockReturnValue(of(mockResponse));

            const result = await service.fetchUserProfile(5);
            expect(result).toBeDefined();
            expect(result.id).toBe(5);
        });

        it('should return null when user not found', async () => {
            const mockResponse = { data: [] };
            mockHttpService.get.mockReturnValue(of(mockResponse));

            const result = await service.fetchUserProfile(999);
            expect(result).toBeNull();
        });

        it('should return null when response is empty array', async () => {
            const mockResponse = { data: [] };
            mockHttpService.get.mockReturnValue(of(mockResponse));

            const result = await service.fetchUserProfile(999);
            expect(result).toBeNull();
        });
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

        it('should handle errors in student grade fetching', async () => {
            jest.spyOn(service, 'fetchAllCourses').mockResolvedValue([
                { id: 2, fullname: 'Course 2', shortname: 'C2' }
            ]);
            jest.spyOn(service, 'fecthEnreollledUsers').mockResolvedValue([
                { id: 101, fullname: 'Student A', email: 'a@test.com' },
                { id: 102, fullname: 'Student B', email: 'b@test.com' }
            ]);
            jest.spyOn(service, 'fetchUserGrades')
                .mockResolvedValueOnce({ usergrades: [{ gradeitems: [] }] })
                .mockRejectedValueOnce(new Error('Grade fetch failed'));

            const result = await service.fetchDataForAI();
            expect(result.success).toBe(true);
            expect(result.recordsCollected).toBe(1); // Only first student succeeded
        });

        it('should throw HttpException when fetchAllCourses fails', async () => {
            jest.spyOn(service, 'fetchAllCourses').mockRejectedValue(new Error('API Error'));

            await expect(service.fetchDataForAI()).rejects.toThrow(HttpException);
            await expect(service.fetchDataForAI()).rejects.toThrow('Failed to collect data from Moodle');
        });

        it('should skip site course (ID = 1)', async () => {
            jest.spyOn(service, 'fetchAllCourses').mockResolvedValue([
                { id: 1, fullname: 'Site' },
                { id: 2, fullname: 'Course 2', shortname: 'C2' }
            ]);
            jest.spyOn(service, 'fecthEnreollledUsers').mockResolvedValue([]);

            const result = await service.fetchDataForAI();

            expect(result.coursesProcessed).toBe(1); // Only Course 2 processed
            expect(service.fecthEnreollledUsers).toHaveBeenCalledTimes(1);
            expect(service.fecthEnreollledUsers).toHaveBeenCalledWith(2);
        });
    });
});
