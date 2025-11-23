import {Column, Entity, ManyToMany, ManyToOne, PrimaryGeneratedColumn} from "typeorm"
import{Student} from "./student.entity"



@Entity()
export class Enrollment {
@PrimaryGeneratedColumn()
id:number;

@Column()
courseId:number;

@ManyToOne(() => Student, (student) => student.enrollments)
student:Student;
@Column({type:"float",default:0})
currentGrade:number;

}