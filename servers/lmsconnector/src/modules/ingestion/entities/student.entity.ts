import { PrimaryColumn,Entity,Column, OneToMany } from "typeorm";
import {Enrollment} from "./enrollment.entity";



@Entity()
export class Student {
    @PrimaryColumn()
    id:number;
    @Column()
    fullname:string
    @Column({unique:true})
    email:string
    @Column({nullable:true})
    lastAcces:Date

    @OneToMany(() => Enrollment, (enrollment) => enrollment.student)
    enrollments: Enrollment[];

}