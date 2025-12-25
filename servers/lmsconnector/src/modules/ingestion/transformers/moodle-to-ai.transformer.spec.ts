import { Test, TestingModule } from '@nestjs/testing';
import { MoodleToAITransformer } from './moodle-to-ai.transformer';

describe('MoodleToAITransformer', () => {
    let transformer: MoodleToAITransformer;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [MoodleToAITransformer],
        }).compile();

        transformer = module.get<MoodleToAITransformer>(MoodleToAITransformer);
    });

    it('should be defined', () => {
        expect(transformer).toBeDefined();
    });

    it('should transform complete data correctly', () => {
        const input = {
            courseId: 101,
            courseName: 'Intro to CS',
            courseShortName: 'CS101',
            student: {
                id: 1,
                fullname: 'Test User',
            },
            grades: {
                usergrades: [{
                    gradeitems: [
                        { itemname: 'Lab 1', graderaw: '10' },     // Practical
                        { itemname: 'Assignment', graderaw: '20' }, // Practical
                        { itemname: 'Final Exam', graderaw: '50' }  // Theoretical
                    ]
                }]
            }
        };

        const result = transformer.transform(input);

        expect(result.studentId).toBe(1);
        expect(result.studentName).toBe('Test User');
        expect(result.subject).toBe('Intro to CS');
        expect(result.semester).toBe(1); // CS101 -> 1

        // Practical: (10 + 20) / 2 = 15
        expect(result.practical).toBe(15);

        // Theoretical: 50 / 1 = 50
        expect(result.theoretical).toBe(50);

        // Total: 15 + 50 = 65
        expect(result.total).toBe(65);
        expect(result.status).toBe('Passed');
    });

    it('should handle zero grades and absent status', () => {
        const input = {
            courseId: 102,
            courseName: 'Math',
            courseShortName: 'MATH201',
            student: { id: 2, fullname: 'Student Two' },
            grades: {
                usergrades: [{
                    gradeitems: []
                }]
            }
        };

        const result = transformer.transform(input);
        expect(result.total).toBe(0);
        expect(result.status).toBe('Absent');
    });

    it('should handle failed status', () => {
        const input = {
            courseId: 103,
            courseName: 'Physics',
            courseShortName: 'PHY101',
            student: { id: 3, fullname: 'Student Three' },
            grades: {
                usergrades: [{
                    gradeitems: [
                        { itemname: 'Test', graderaw: '40' } // Theo: 40, Prac 0, Total 40
                    ]
                }]
            }
        };

        const result = transformer.transform(input);
        expect(result.total).toBe(40);
        expect(result.status).toBe('Failed');
    });

    it('should extract semester correctly from shortname', () => {
        // Test the extractSemester privacy method via transform
        const input = {
            courseId: 1, courseName: 'Test',
            courseShortName: 'ABC305', // pattern (\d)0\d -> matches 305
            student: { id: 1, fullname: 'Test' },
            grades: {}
        };
        const result = transformer.transform(input);
        expect(result.semester).toBe(3);
    });

    it('should extract major from custom fields', () => {
        const input = {
            courseId: 1, courseName: 'Test', courseShortName: 'CS101',
            student: {
                id: 1, fullname: 'Test',
                customfields: [{ shortname: 'major', value: 'Computer Science' }]
            },
            grades: {}
        };
        const result = transformer.transform(input);
        expect(result.major).toBe('Computer Science');
    });
});
