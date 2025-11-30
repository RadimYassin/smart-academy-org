import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Eureka } from 'eureka-js-client';

/**
 * Eureka Service
 * Handles service registration and deregistration with Eureka server
 */
@Injectable()
export class EurekaService implements OnModuleInit, OnModuleDestroy {
    private readonly logger = new Logger(EurekaService.name);
    private eurekaClient: Eureka;

    constructor(private configService: ConfigService) {
        const eurekaConfig = this.configService.get('eureka');

        this.eurekaClient = new Eureka({
            instance: eurekaConfig.instance,
            eureka: eurekaConfig.eureka,
        });

        // Listen for Eureka events
        this.eurekaClient.on('started', () => {
            this.logger.log('Eureka client started successfully');
        });

        this.eurekaClient.on('registered', () => {
            this.logger.log('Service registered with Eureka');
        });

        this.eurekaClient.on('deregistered', () => {
            this.logger.log('Service deregistered from Eureka');
        });

        this.eurekaClient.on('registryUpdated', () => {
            this.logger.debug('Service registry updated');
        });

        this.eurekaClient.on('heartbeat', () => {
            this.logger.debug('Heartbeat sent to Eureka server');
        });
    }

    /**
     * Initialize Eureka client when module starts
     */
    async onModuleInit() {
        try {
            this.logger.log('Starting Eureka client...');
            this.eurekaClient.start((error) => {
                if (error) {
                    this.logger.error('Failed to start Eureka client', error);
                } else {
                    this.logger.log('Eureka client started and service registered');
                }
            });
        } catch (error) {
            this.logger.error('Error initializing Eureka client', error);
        }
    }

    /**
     * Deregister from Eureka when module is destroyed
     */
    async onModuleDestroy() {
        try {
            this.logger.log('Stopping Eureka client...');
            await new Promise<void>((resolve) => {
                this.eurekaClient.stop(() => {
                    this.logger.log('Eureka client stopped and service deregistered');
                    resolve();
                });
            });
        } catch (error) {
            this.logger.error('Error stopping Eureka client', error);
        }
    }

    /**
     * Get an instance of a service by application name
     * @param appName - The application name registered in Eureka
     * @returns Service instance information
     */
    getInstancesByAppId(appName: string) {
        return this.eurekaClient.getInstancesByAppId(appName);
    }

    /**
     * Get the Eureka client instance for advanced usage
     */
    getClient() {
        return this.eurekaClient;
    }
}
