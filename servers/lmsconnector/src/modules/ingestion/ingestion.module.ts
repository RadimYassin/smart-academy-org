import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Enrollment } from "./entities/enrollment.entity";
import { Student } from "./entities/student.entity";
import { RowData } from "./entities/raw-data.entity";
import { AIStudentData } from "./entities/ai-student-data.entity";
import { IngestionController } from "./ingestion.controller";
import { IngestionService } from "./ingestion.service";
import { HttpModule } from "@nestjs/axios";
import { MoodleService } from "./moodle/moodle.service";
import { studentNormalizer } from "./normalizers/student.normalizer";
import { MoodleToAITransformer } from "./transformers/moodle-to-ai.transformer";


@Module({
    imports: [
        HttpModule,
        TypeOrmModule.forFeature([RowData, Student, Enrollment, AIStudentData]),

    ],
    controllers: [IngestionController],
    providers: [IngestionService, MoodleService, studentNormalizer, MoodleToAITransformer],
})

export class IngestionModule { }