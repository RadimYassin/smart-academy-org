import { HttpService } from '@nestjs/axios';
import { Injectable, Logger, HttpStatus, HttpException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class MoodleService {
    private readonly logger = new Logger(MoodleService.name);
    private readonly moodelUrl: string;
    private readonly moodeleToken: string;

    constructor(
        private readonly httpService: HttpService,
        private readonly configService: ConfigService,
    ) {
        const moodelUrl = this.configService.get<string>('MOODLE_URL');
        const moodeleToken = this.configService.get<string>('MOODLE_TOKEN');

        if (!moodelUrl) {
            throw new Error('Configuration error: MOODLE_URL is not set');
        }
        if (!moodeleToken) {
            throw new Error('Configuration error: MOODLE_TOKEN is not set');
        }

        this.moodelUrl = moodelUrl;
        this.moodeleToken = moodeleToken;
    }

    /**
     * Fetches all courses from Moodle
     */
    async fetchAllCourses(): Promise<any[]> {
        this.logger.log('Fetching all courses from Moodle');
        return this.callMoodleApi('core_course_get_courses', {});
    }

    /**
     * Fetches users enrolled in a specific course
     */
    async fecthEnreollledUsers(courseId: number): Promise<any[]> {
        this.logger.log(`Fetching enrolled users for course ID: ${courseId}`);
        return this.callMoodleApi('core_enrol_get_enrolled_users', { courseid: courseId });
    }

    /**
     * Fetches grade items and grades for a specific course
     */
    async fetchCourseGrades(courseId: number): Promise<any> {
        this.logger.log(`Fetching grades for course ID: ${courseId}`);
        return this.callMoodleApi('core_grades_get_grades', { courseid: courseId });
    }

    /**
     * Fetches grades for a specific user in a course
     */
    async fetchUserGrades(userId: number, courseId: number): Promise<any> {
        this.logger.log(`Fetching grades for user ${userId} in course ${courseId}`);
        return this.callMoodleApi('gradereport_user_get_grade_items', {
            userid: userId,
            courseid: courseId,
        });
    }

    /**
     * Fetches user profile information
     */
    async fetchUserProfile(userId: number): Promise<any> {
        this.logger.log(`Fetching profile for user ID: ${userId}`);
        const users = await this.callMoodleApi('core_user_get_users_by_field', {
            field: 'id',
            'values[0]': userId,
        });
        return users && users.length > 0 ? users[0] : null;
    }

    /**
     * Fetches comprehensive data for all courses, students, and grades
     * This is the main method used for AI model data collection
     */
    async fetchDataForAI(): Promise<any> {
        this.logger.log('Starting comprehensive data collection for AI models');

        try {
            // Step 1: Fetch all courses
            const courses = await this.fetchAllCourses();
            this.logger.log(`Found ${courses.length} courses`);

            const allData: any[] = [];

            // Step 2: For each course, fetch students and grades
            for (const course of courses) {
                // Skip site-level course (ID = 1)
                if (course.id === 1) continue;

                this.logger.log(`Processing course: ${course.fullname} (ID: ${course.id})`);

                try {
                    // Fetch enrolled students
                    const students = await this.fecthEnreollledUsers(course.id);
                    this.logger.log(`  - Found ${students.length} students`);

                    // For each student, fetch their grades
                    for (const student of students) {
                        try {
                            const grades = await this.fetchUserGrades(student.id, course.id);

                            allData.push({
                                courseId: course.id,
                                courseName: course.fullname,
                                courseShortName: course.shortname,
                                student: {
                                    id: student.id,
                                    fullname: student.fullname,
                                    email: student.email,
                                },
                                grades: grades,
                            });
                        } catch (error) {
                            this.logger.warn(
                                `Failed to fetch grades for student ${student.id} in course ${course.id}: ${error.message}`,
                            );
                        }
                    }
                } catch (error) {
                    this.logger.warn(`Failed to process course ${course.id}: ${error.message}`);
                }
            }

            this.logger.log(`Data collection complete. Collected data for ${allData.length} student-course records`);
            return {
                success: true,
                coursesProcessed: courses.length - 1, // Exclude site course
                recordsCollected: allData.length,
                data: allData,
            };
        } catch (error) {
            this.logger.error(`Data collection failed: ${error.message}`);
            throw new HttpException('Failed to collect data from Moodle', HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Private helper method to call Moodle Web Service API
     */
    private async callMoodleApi(wsfunction: string, params: any): Promise<any> {
        const url = `${this.moodelUrl}/webservice/rest/server.php`;

        try {
            const response = await firstValueFrom(
                this.httpService.get(url, {
                    params: {
                        wstoken: this.moodeleToken,
                        wsfunction,
                        moodlewsrestformat: 'json',
                        ...params,
                    },
                }),
            );

            if (response.data.exception) {
                this.logger.error(`Moodle Exception: ${response.data.message}`);
                throw new Error(response.data.message);
            }

            return response.data;
        } catch (error) {
            this.logger.error(`Moodle API Request failed: ${error.message}`);
            throw new HttpException('Failed to connect to LMS', HttpStatus.BAD_GATEWAY);
        }
    }
}