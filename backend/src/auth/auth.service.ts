import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  InternalServerErrorException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { getSupabaseClient } from '../supabase/supabase.client';
import { SignUpDto, SignInDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  private supabase = getSupabaseClient();

  constructor(private jwtService: JwtService) {}

  async signUp(signUpDto: SignUpDto) {
    const { name, email, password, ip, country, city } = signUpDto;

    try {
      // Check if user already exists
      const { data: existingUser } = await this.supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .single();

      if (existingUser) {
        throw new ConflictException('User with this email already exists');
      }

      // Hash password
      const saltRounds = 10;
      const passwordHash = await bcrypt.hash(password, saltRounds);

      // Insert user into Supabase
      const { data: newUser, error } = await this.supabase
        .from('users')
        .insert([
          {
            name,
            email,
            password_hash: passwordHash,
            signup_ip: ip || null,
            signup_country: country || null,
            signup_city: city || null,
          },
        ])
        .select()
        .single();

      if (error) {
        console.error('Supabase error:', error);
        throw new InternalServerErrorException('Failed to create user');
      }

      return {
        message: 'User created successfully',
        user: {
          id: newUser.id,
          name: newUser.name,
          email: newUser.email,
        },
      };
    } catch (error) {
      if (error instanceof ConflictException) {
        throw error;
      }
      console.error('Sign up error:', error);
      throw new InternalServerErrorException('Failed to create user');
    }
  }

  async signIn(signInDto: SignInDto) {
    const { email, password, ip, country, city, userAgent } = signInDto;

    try {
      // Find user by email
      const { data: user, error: userError } = await this.supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .single();

      // Debug logging
      console.log('Sign in attempt for email:', email);
      if (userError) {
        console.error('Supabase error finding user:', userError);
      }
      if (!user) {
        console.log('No user found with email:', email);
      } else {
        console.log('User found:', user.email);
      }

      let userId = null;
      let success = false;
      let failureReason: string | null = null;

      if (userError || !user) {
        failureReason = 'User not found';
      } else {
        // Verify password
        const passwordMatch = await bcrypt.compare(password, user.password_hash);

        if (!passwordMatch) {
          failureReason = 'Invalid password';
          userId = user.id;
        } else {
          success = true;
          userId = user.id;
        }
      }

      // Log sign-in attempt
      await this.supabase.from('sign_in_attempts').insert([
        {
          user_id: userId,
          email,
          ip_address: ip || null,
          country: country || null,
          city: city || null,
          user_agent: userAgent || null,
          success,
          failure_reason: failureReason,
        },
      ]);

      if (!success) {
        throw new UnauthorizedException(failureReason || 'Invalid credentials');
      }

      // Generate JWT token
      const payload = { sub: user.id, email: user.email };
      const token = this.jwtService.sign(payload);

      return {
        message: 'Sign in successful',
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
        },
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      console.error('Sign in error:', error);
      throw new InternalServerErrorException('Failed to sign in');
    }
  }

  async getSignInAttempts(userId: string) {
    try {
      const { data, error } = await this.supabase
        .from('sign_in_attempts')
        .select('*')
        .eq('user_id', userId)
        .order('attempted_at', { ascending: false })
        .limit(50);

      if (error) {
        console.error('Error fetching sign-in attempts:', error);
        throw new InternalServerErrorException('Failed to fetch sign-in attempts');
      }

      return data;
    } catch (error) {
      console.error('Get sign-in attempts error:', error);
      throw new InternalServerErrorException('Failed to fetch sign-in attempts');
    }
  }
}
