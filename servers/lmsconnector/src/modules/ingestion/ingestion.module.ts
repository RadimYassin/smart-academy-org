import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Enrollment } from "./entities/enrollment.entity";
import { Student } from "./entities/student.entity";
import { RowData } from "./entities/raw-data.entity";
import { IngestionController } from "./ingestion.controller";
import { IngestionService } from "./ingestion.service";
import { HttpModule, HttpService } from "@nestjs/axios";
import { MoodleService } from "./moodle/moodle.service";
import { studentNormalizer } from "./normalizers/student.normalizer";


@Module({
    imports: [
        HttpModule,
        TypeOrmModule.forFeature([RowData, Student,Enrollment]),
        
    ],
    controllers: [IngestionController],
    providers: [IngestionService,MoodleService,studentNormalizer],
})

export class IngestionModule {}