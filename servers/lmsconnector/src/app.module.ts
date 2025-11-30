import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Enrollment } from './modules/ingestion/entities/enrollment.entity';
import { Student } from './modules/ingestion/entities/student.entity';
import { RowData } from './modules/ingestion/entities/raw-data.entity';
import { IngestionModule } from './modules/ingestion/ingestion.module';
import { AuthModule } from './auth/auth.module';
import { EurekaModule } from './modules/eureka/eureka.module';
import { HealthController } from './health.controller';
import jwtConfig from './config/jwt.config';
import eurekaConfig from './config/eureka.config';


@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [jwtConfig, eurekaConfig],
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DATABASE_HOST || 'postgres',
      port: parseInt(process.env.DATABASE_PORT || '5432', 10),
      username: process.env.DATABASE_USER || 'postgres',
      password: process.env.DATABASE_PASSWORD,
      database: process.env.DATABASE_NAME || 'lmsconnector',
      entities: [RowData, Student, Enrollment],
      synchronize: true, // Set to false in production!
    }),
    AuthModule,
    EurekaModule,
    IngestionModule
  ],
  controllers: [HealthController],
})
export class AppModule { }
