import { Test, TestingModule } from '@nestjs/testing';
import { studentNormalizer } from './student.normalizer';

describe('studentNormalizer', () => {
    let normalizer: studentNormalizer;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [studentNormalizer],
        }).compile();

        normalizer = module.get<studentNormalizer>(studentNormalizer);
    });

    it('should be defined', () => {
        expect(normalizer).toBeDefined();
    });

    it('should normalize moodle user with lastaccess', () => {
        const rawUser = {
            id: 1,
            firstname: 'John',
            lastname: 'Doe',
            email: 'john@example.com',
            lastaccess: 1678886400 // Timestamp
        };

        const result = normalizer.normalize(rawUser);

        expect(result.id).toBe(1);
        expect(result.fullname).toBe('John Doe');
        expect(result.email).toBe('john@example.com');
        expect(result.lastAcces).toEqual(new Date(1678886400 * 1000));
    });

    it('should normalize moodle user without lastaccess', () => {
        const rawUser = {
            id: 2,
            firstname: 'Jane',
            lastname: 'Doe',
            // email missing, lastaccess missing
        };

        const result = normalizer.normalize(rawUser);

        expect(result.id).toBe(2);
        expect(result.fullname).toBe('Jane Doe');
        expect(result.email).toBe('user2@exmple.com'); // Check default email logic
        expect(result.lastAcces).toBeInstanceOf(Date);
    });
});
