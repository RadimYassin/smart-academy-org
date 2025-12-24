// Quick TypeScript diagnostic script
import { Repository } from 'typeorm';
import { AIStudentData } from './entities/ai-student-data.entity';

// The Repository.save() method has these signatures:
// save<T>(entity: T): Promise<T>
// save<T>(entities: T[]): Promise<T[]>

// Our usage:
const transformedRecords: AIStudentData[] = [];
// const savedRecords = await this.aiStudentDataRepository.save(transformedRecords);

// The error suggests TypeScript thinks we're calling save(entity: T) instead of save(entities: T[])
// Solution: Cast or explicitly type the parameter
