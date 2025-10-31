import { config } from 'dotenv';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

// Load environment variables
config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS
  app.enableCors({  
    origin: ['http://localhost:5173', 'http://localhost:4173', 'http://localhost:3000', 'https://frontend-n5d2xqtia-amitkumarpsits-projects.vercel.app', 'https://frontend-cmhjx35r7-amitkumarpsits-projects.vercel.app'],
    credentials: true,
  });
  
  // Enable global validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  
  const port = process.env.PORT || 3001;
  await app.listen(port);
  console.log(`Backend running on http://localhost:${port}`);
}
bootstrap();
