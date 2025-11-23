import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Enrollment } from './modules/ingestion/entities/enrollment.entity';
import { Student } from './modules/ingestion/entities/student.entity';
import { RowData } from './modules/ingestion/entities/raw-data.entity';
import { IngestionModule } from './modules/ingestion/ingestion.module';


@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
     type: 'postgres',
      host: process.env.DATABASE_HOST || 'postgres',
      port: parseInt(process.env.DATABASE_PORT || '5432', 10),
      username: process.env.DATABASE_USER  || 'postgres',
      password: process.env.DATABASE_PASSWORD,
      database: process.env.DATABASE_NAME|| 'lmsconnector',
      entities: [RowData, Student, Enrollment],
      synchronize: true, // Set to false in production!
    }) ,

IngestionModule
  ],
})
export class AppModule {}
