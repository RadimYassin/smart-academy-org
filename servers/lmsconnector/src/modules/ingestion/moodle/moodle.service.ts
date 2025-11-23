import { HttpService } from '@nestjs/axios';
import { Injectable, Logger,HttpStatus, HttpException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { firstValueFrom } from 'rxjs';



@Injectable()
export class MoodleService {


    private readonly logger=new Logger(MoodleService.name);
    private readonly moodelUrl:string;
    private readonly moodeleToken:string;
    constructor(private readonly httpService: HttpService, private readonly configService: ConfigService) {

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

// Fetches users enrolled in a specific course
    async fecthEnreollledUsers(courseId:number){
return this.callMoodleApi('core_enrol_get_enrolled_users',{courseid:courseId});
    }

    private async callMoodleApi(wsfunction:string,params:{}){
        const url = `${this.moodelUrl}/webservice/rest/server.php`;


        try{
const reponse= await firstValueFrom(
    this.httpService.get(url,{
        params:{
            wstoken:this.moodeleToken,
            wsfunction,
            moodlewsrestformat:'json',
            ...params
        }
    })
)
if (reponse.data.exception){
    this.logger.error(`moodle Exception : ${reponse.data.message}`);
    throw new Error(reponse.data.message);
}

return reponse.data;
        }catch(error){
            this.logger.error(`moodle API Request fialed : ${error.message}`);
            throw new HttpException('Fialed to connect to LMS',HttpStatus.BAD_GATEWAY);
    }
    }
}