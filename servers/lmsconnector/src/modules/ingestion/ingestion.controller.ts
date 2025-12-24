import { Controller, Param, ParseIntPipe, Post, Get, Logger } from '@nestjs/common';
import { IngestionService } from './ingestion.service';

@Controller('ingestion')
export class IngestionController {
    private readonly logger = new Logger(IngestionController.name);

    constructor(private readonly ingestionService: IngestionService) { }

    @Post('sync-course-students/:id')
    async syncCourseStudents(@Param('id', ParseIntPipe) courseId: number) {
        // Implementation for syncing course students
        return this.ingestionService.syncCourseStudents(courseId);
    }

    /**
     * Main endpoint to pull all data from Moodle for AI models
     * This fetches courses, students, grades and stores in AI-ready format
     */
    @Post('pull')
    async pullDataFromMoodle() {
        this.logger.log('Received request to pull data from Moodle for AI models');
        return this.ingestionService.pullAndTransformData();
    }

    /**
     * Health check endpoint
     */
    @Get('health')
    async healthCheck() {
        return { status: 'ok', service: 'ingestion' };
    }

    /**
     * Get all AI student data from database
     */
    @Get('ai-data')
    async getAllAIData() {
        this.logger.log('Fetching all AI student data from database');
        return this.ingestionService.getAllAIStudentData();
    }

    /**
     * Get AI data for a specific student
     */
    @Get('ai-data/student/:id')
    async getStudentAIData(@Param('id', ParseIntPipe) studentId: number) {
        this.logger.log(`Fetching AI data for student ${studentId}`);
        return this.ingestionService.getStudentAIData(studentId);
    }

    /**
     * Export AI data as CSV format
     */
    @Get('export-csv')
    async exportAsCSV() {
        this.logger.log('Exporting AI data as CSV');
        return this.ingestionService.exportAIDataAsCSV();
    }

    /**
     * Get statistics about collected data
     */
    @Get('stats')
    async getStats() {
        return this.ingestionService.getDataStatistics();
    }
}