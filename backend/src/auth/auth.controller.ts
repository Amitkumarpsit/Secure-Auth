import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Headers,
  ValidationPipe,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { SignUpDto, SignInDto } from './dto/auth.dto';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('signup')
  async signUp(@Body(ValidationPipe) signUpDto: SignUpDto) {
    return this.authService.signUp(signUpDto);
  }

  @Post('signin')
  async signIn(
    @Body(ValidationPipe) signInDto: SignInDto,
    @Headers('user-agent') userAgent: string,
  ) {
    // Add user-agent to the DTO
    signInDto.userAgent = userAgent;
    return this.authService.signIn(signInDto);
  }

  @Get('signin-attempts/:userId')
  async getSignInAttempts(@Param('userId') userId: string) {
    return this.authService.getSignInAttempts(userId);
  }
}
