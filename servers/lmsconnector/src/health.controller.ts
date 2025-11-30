import { Controller, Get } from '@nestjs/common';

/**
 * Health Check Controller
 * Provides health check endpoint for Eureka and monitoring
 */
@Controller()
export class HealthController {
    @Get('health')
    healthCheck() {
        return {
            status: 'UP',
            timestamp: new Date().toISOString(),
            service: 'lmsconnector',
        };
    }

    @Get()
    root() {
        return {
            service: 'LMS Connector Service',
            version: '1.0.0',
            status: 'running',
        };
    }
}
