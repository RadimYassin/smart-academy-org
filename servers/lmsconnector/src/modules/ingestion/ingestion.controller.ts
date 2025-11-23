import { Controller, Param, ParseIntPipe, Post } from "@nestjs/common";
import { IngestionService } from "./ingestion.service";

@Controller('ingestion')
export class IngestionController {
    // Controller methods would go here
    constructor(private readonly ingestionService:IngestionService) {}

    @Post('sync-course-students/:id')
    async syncCourseStudents(@Param('id',ParseIntPipe) courseId: number) {
        // Implementation for syncing course students
        return this.ingestionService.syncCourseStudents(courseId);
    }
}