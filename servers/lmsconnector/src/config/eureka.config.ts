import { registerAs } from '@nestjs/config';

/**
 * Eureka Client Configuration
 * Registers this NestJS service with the Eureka service registry
 */
export default registerAs('eureka', () => ({
    // Eureka server connection details
    eureka: {
        host: process.env.EUREKA_HOST || 'localhost',
        port: parseInt(process.env.EUREKA_PORT || '8761', 10),
        servicePath: '/eureka/apps/',
        maxRetries: 3,
        requestRetryDelay: 2000,
    },

    // This application's registration info
    instance: {
        app: process.env.APP_NAME || 'LMS-CONNECTOR',
        instanceId: `${process.env.APP_NAME || 'LMS-CONNECTOR'}:${process.env.PORT || 3000}`,
        hostName: process.env.HOSTNAME || 'localhost',
        ipAddr: process.env.IP_ADDRESS || '127.0.0.1',
        statusPageUrl: `http://localhost:${process.env.PORT || 3000}/`,
        healthCheckUrl: `http://localhost:${process.env.PORT || 3000}/health`,
        port: {
            '$': parseInt(process.env.PORT || '3000', 10),
            '@enabled': true,
        },
        vipAddress: process.env.APP_NAME || 'LMS-CONNECTOR',
        dataCenterInfo: {
            '@class': 'com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo',
            name: 'MyOwn',
        },
        // Heartbeat configuration
        leaseInfo: {
            renewalIntervalInSecs: 30,
            durationInSecs: 90,
        },
    },
}));
