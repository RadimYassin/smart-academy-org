import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable graceful shutdown for Eureka deregistration
  app.enableShutdownHooks();

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`LMS Connector Service is running on port ${port}`);
  console.log(`Health check available at: http://localhost:${port}/health`);
}
bootstrap();