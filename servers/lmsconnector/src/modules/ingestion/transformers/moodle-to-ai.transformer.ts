import { Injectable, Logger } from '@nestjs/common';

/**
 * Transformer to convert Moodle API data to AI model format
 */
@Injectable()
export class MoodleToAITransformer {
    private readonly logger = new Logger(MoodleToAITransformer.name);

    /**
     * Transform raw Moodle data to AI model format
     */
    transform(moodleData: any): any {
        const { courseId, courseName, courseShortName, student, grades } = moodleData;

        // Extract grades
        const { practical, theoretical, total } = this.extractGrades(grades);

        // Determine status based on total grade
        const status = this.determineStatus(total, grades);

        // Calculate semester from course short name (e.g., CS101 -> Semester 1)
        const semester = this.extractSemester(courseShortName);

        return {
            studentId: student.id,
            studentName: student.fullname,
            major: this.extractMajor(student), // Default or from custom fields
            majorYear: this.extractMajorYear(student),
            subject: courseName,
            courseId: courseId,
            semester: semester,
            practical: practical,
            theoretical: theoretical,
            total: total,
            status: status,
        };
    }

    /**
     * Extract practical and theoretical grades from Moodle grade items
     */
    private extractGrades(grades: any): { practical: number; theoretical: number; total: number } {
        if (!grades || !grades.usergrades || grades.usergrades.length === 0) {
            return { practical: 0, theoretical: 0, total: 0 };
        }

        const userGrade = grades.usergrades[0];
        const gradeItems = userGrade.gradeitems || [];

        let practicalSum = 0;
        let theoreticalSum = 0;
        let practicalCount = 0;
        let theoreticalCount = 0;

        gradeItems.forEach((item: any) => {
            const itemName = (item.itemname || '').toLowerCase();
            const gradeRaw = parseFloat(item.graderaw) || 0;

            // Categorize based on item name
            if (this.isPracticalItem(itemName)) {
                practicalSum += gradeRaw;
                practicalCount++;
            } else if (this.isTheoreticalItem(itemName)) {
                theoreticalSum += gradeRaw;
                theoreticalCount++;
            }
        });

        const practical = practicalCount > 0 ? practicalSum / practicalCount : 0;
        const theoretical = theoreticalCount > 0 ? theoreticalSum / theoreticalCount : 0;
        const total = practical + theoretical;

        return { practical, theoretical, total };
    }

    /**
     * Check if grade item is practical/lab work
     */
    private isPracticalItem(itemName: string): boolean {
        const practicalKeywords = ['lab', 'practical', 'assignment', 'project', 'tp', 'td'];
        return practicalKeywords.some((keyword) => itemName.includes(keyword));
    }

    /**
     * Check if grade item is theoretical/exam
     */
    private isTheoreticalItem(itemName: string): boolean {
        const theoreticalKeywords = ['exam', 'test', 'quiz', 'midterm', 'final', 'theory'];
        return theoreticalKeywords.some((keyword) => itemName.includes(keyword));
    }

    /**
     * Determine student status based on grade
     */
    private determineStatus(total: number, grades: any): string {
        if (total === 0) {
            return 'Absent';
        } else if (total < 50) {
            return 'Failed';
        } else {
            return 'Passed';
        }
    }

    /**
     * Extract semester number from course code
     * Example: CS101 -> 1, CS201 -> 2
     */
    private extractSemester(courseShortName: string): number {
        const match = courseShortName.match(/(\d)0\d$/);
        if (match) {
            return parseInt(match[1]);
        }
        return 1; // Default to semester 1
    }

    /**
     * Extract major from student profile
     * TODO: Implement when Moodle has custom profile fields
     */
    private extractMajor(student: any): string {
        // Check for custom fields if available
        if (student.customfields) {
            const majorField = student.customfields.find((f: any) => f.shortname === 'major');
            if (majorField) {
                return majorField.value;
            }
        }
        return 'Unknown'; // Default
    }

    /**
     * Extract major year from student profile
     * TODO: Implement when Moodle has custom profile fields
     */
    private extractMajorYear(student: any): number {
        // Check for custom fields if available
        if (student.customfields) {
            const yearField = student.customfields.find((f: any) => f.shortname === 'year');
            if (yearField) {
                return parseInt(yearField.value) || 1;
            }
        }
        return 1; // Default
    }
}
