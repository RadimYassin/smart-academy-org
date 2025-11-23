import { Injectable } from "@nestjs/common";
import { Student } from "../entities/student.entity";


@Injectable()
export class studentNormalizer {
    normalize(rawMoodleUser: any): Student {
        const student=new Student();
        student.id=rawMoodleUser.id;
        student.fullname=`${rawMoodleUser.firstname} ${rawMoodleUser.lastname}`;
        student.email=rawMoodleUser.email || `user${rawMoodleUser.id}@exmple.com`;
       if(rawMoodleUser.lastaccess){
        student.lastAcces=new Date(rawMoodleUser.lastaccess * 1000);
       }else{
        student.lastAcces=new Date();
       }
        return student;
    }
}