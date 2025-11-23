import { Injectable, Logger } from "@nestjs/common";
import { MoodleService } from "./moodle/moodle.service";
import { studentNormalizer } from "./normalizers/student.normalizer";
import { InjectRepository } from "@nestjs/typeorm";
import { RowData } from "./entities/raw-data.entity";
import { Repository } from "typeorm";
import { Student } from "./entities/student.entity";


@Injectable()

export class IngestionService {

    private readonly logger=new Logger(IngestionService.name);
    constructor(
        private readonly moodelService:MoodleService,
        private readonly studentNormalizer: studentNormalizer,
        @InjectRepository(RowData) private readonly rawDataRepository: Repository<RowData>,
        @InjectRepository(Student) private readonly studentRepository: Repository<Student>,
    ) {}


    async syncCourseStudents(courseId:number){
        this.logger.log(`Starting ingestion of enrolled users for course ID: ${courseId}`); 

        // Step 1: Fetch raw enrolled users data from Moodle
        const rowUsers=await this.moodelService.fecthEnreollledUsers(courseId);
        this.logger.log(`Fetched ${rowUsers.length} users from Moodle for course ID: ${courseId}`);

        // Step 2: Store raw data
        await this.rawDataRepository.save({
            source:'MOODLE',
            dataType:'ENROLLED_USERS',
            data:rowUsers
        });

        // Step 3: Normalize and store students
         const sutdentsTosave=rowUsers.map((user)=>this.studentNormalizer.normalize(user));

        // Step 4: store in Sutdent table
        await this.studentRepository.save(sutdentsTosave); 

        this.logger.log(`Synced ${sutdentsTosave.length} students.`);

        return {status:'success', syncedStudents:sutdentsTosave}
    }
}