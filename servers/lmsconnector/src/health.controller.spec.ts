import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';

describe('HealthController', () => {
    let controller: HealthController;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            controllers: [HealthController],
        }).compile();

        controller = module.get<HealthController>(HealthController);
    });

    it('should be defined', () => {
        expect(controller).toBeDefined();
    });

    describe('healthCheck', () => {
        it('should return health status', () => {
            const result = controller.healthCheck();
            expect(result).toHaveProperty('status', 'UP');
            expect(result).toHaveProperty('service', 'lmsconnector');
            expect(result).toHaveProperty('timestamp');
        });
    });

    describe('root', () => {
        it('should return service info', () => {
            const result = controller.root();
            expect(result).toEqual({
                service: 'LMS Connector Service',
                version: '1.0.0',
                status: 'running',
            });
        });
    });
});
