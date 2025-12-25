import { Test, TestingModule } from '@nestjs/testing';
import { EurekaService } from './eureka.service';
import { ConfigService } from '@nestjs/config';
import { Eureka } from 'eureka-js-client';

jest.mock('eureka-js-client');

describe('EurekaService', () => {
    let service: EurekaService;
    let mockEurekaClient: any;

    beforeEach(async () => {
        mockEurekaClient = {
            start: jest.fn((cb) => cb && cb(null)),
            stop: jest.fn((cb) => cb && cb()),
            on: jest.fn(),
            getInstancesByAppId: jest.fn(),
        };
        (Eureka as unknown as jest.Mock).mockImplementation(() => mockEurekaClient);

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                EurekaService,
                {
                    provide: ConfigService,
                    useValue: {
                        get: jest.fn().mockReturnValue({
                            instance: {},
                            eureka: {},
                        }),
                    },
                },
            ],
        }).compile();

        service = module.get<EurekaService>(EurekaService);
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });

    it('should initialize eureka client on init', async () => {
        await service.onModuleInit();
        expect(mockEurekaClient.start).toHaveBeenCalled();
    });

    it('should stop eureka client on destroy', async () => {
        await service.onModuleDestroy();
        expect(mockEurekaClient.stop).toHaveBeenCalled();
    });

    it('should get instances by app id', () => {
        service.getInstancesByAppId('test-app');
        expect(mockEurekaClient.getInstancesByAppId).toHaveBeenCalledWith('test-app');
    });
});
