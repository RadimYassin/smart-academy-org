import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { EurekaService } from './eureka.service';

/**
 * Eureka Module
 * Provides Eureka client functionality for service discovery
 * Marked as Global to make EurekaService available throughout the application
 */
@Global()
@Module({
    imports: [ConfigModule],
    providers: [EurekaService],
    exports: [EurekaService],
})
export class EurekaModule { }
