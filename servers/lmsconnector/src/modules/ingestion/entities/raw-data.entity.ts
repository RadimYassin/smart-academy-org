import {Column, CreateDateColumn, Entity, PrimaryColumn, PrimaryGeneratedColumn} from "typeorm";


@Entity()
export class RowData {

    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    source:string  // lms name

    @Column()
    dataType : string  // exmple : ENRROLLED_USERS,GRADES
    @Column("jsonb")
    data: any; // return data by moodle
    @CreateDateColumn()
    fetchedAt: Date;
}