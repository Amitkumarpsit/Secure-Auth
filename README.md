# Secure Authentication Application

A full-stack authentication application with comprehensive sign-in tracking, built with modern technologies.

## 🚀 Features

### Frontend (SvelteKit)
- **Landing Page**: Welcome page with sign-up and sign-in options
- **Sign-Up Page**: 
  - User registration with name and email
  - Real-time password policy validation (visual feedback with green/red indicators)
  - Automatic IP address, country, and city detection
  - Password requirements:
    - Minimum 8 characters
    - At least one uppercase letter
    - At least one lowercase letter
    - At least one number
    - At least one special character
- **Sign-In Page**:
  - Email and password authentication
  - Real-time credential validation
  - Automatic IP and location tracking
- **Dashboard**:
  - Display user account information
  - Comprehensive sign-in attempt history
  - Shows successful and failed login attempts
  - Displays IP addresses, locations, devices, and timestamps

### Backend (NestJS)
- **RESTful API** with NestJS framework
- **Authentication Endpoints**:
  - POST `/auth/signup` - User registration
  - POST `/auth/signin` - User authentication
  - GET `/auth/signin-attempts/:userId` - Fetch sign-in history
- **Security Features**:
  - Password hashing with bcrypt
  - JWT token-based authentication
  - Password policy enforcement
  - Sign-in attempt tracking (success and failures)
- **Data Storage**: Supabase (PostgreSQL)

### Database (Supabase)
- **Users Table**: Stores user information with sign-up location
- **Sign-In Attempts Table**: Tracks all authentication attempts
- **Row Level Security**: Proper data access policies
- **Indexes**: Optimized for performance

## 🛠️ Tech Stack

- **Frontend**: SvelteKit, JavaScript, Axios
- **Backend**: NestJS, TypeScript
- **Database**: Supabase (PostgreSQL)
- **Authentication**: JWT, bcrypt
- **Containerization**: Docker, Docker Compose
- **IP Geolocation**: ipapi.co

## 📁 Project Structure

```
.
├── frontend/                 # SvelteKit application
│   ├── src/
│   │   ├── lib/             # Utility libraries
│   │   │   ├── api.js       # API client
│   │   │   ├── stores.js    # Svelte stores
│   │   │   ├── supabase.js  # Supabase client
│   │   │   ├── ipService.js # IP detection service
│   │   │   └── passwordPolicy.js # Password validation
│   │   └── routes/          # SvelteKit pages
│   │       ├── +page.svelte           # Landing page
│   │       ├── signup/+page.svelte    # Sign-up page
│   │       ├── signin/+page.svelte    # Sign-in page
│   │       └── dashboard/+page.svelte # Dashboard
│   ├── Dockerfile
│   └── package.json
│
├── backend/                 # NestJS application
│   ├── src/
│   │   ├── auth/           # Authentication module
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.module.ts
│   │   │   └── dto/
│   │   │       └── auth.dto.ts
│   │   ├── supabase/       # Supabase client
│   │   │   └── supabase.client.ts
│   │   ├── app.module.ts
│   │   └── main.ts
│   ├── Dockerfile
│   └── package.json
│
├── docker-compose.yml       # Docker orchestration
├── supabase-setup.sql      # Database schema
├── DEPLOYMENT.md           # Deployment guide
├── .env.example            # Environment variables template
└── README.md               # This file
```

## 🚦 Getting Started

### Prerequisites

- Node.js 20 or higher
- npm or yarn
- Docker and Docker Compose (optional)
- Supabase account

### 1. Set Up Supabase

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Go to SQL Editor and run the script from `supabase-setup.sql`
4. Get your credentials from Settings → API:
   - Project URL
   - Anon/Public Key (for frontend)
   - Service Role Key (for backend)

### 2. Local Development Setup

#### Option A: Without Docker

**Backend Setup:**
```bash
cd backend
cp .env.example .env
# Edit .env and add your Supabase credentials:
# SUPABASE_URL=your_url
# SUPABASE_KEY=your_service_role_key
# JWT_SECRET=your_secret_key
# PORT=3001

npm install
npm run start:dev
```

**Frontend Setup:**
```bash
cd frontend
cp .env.example .env
# Edit .env and add your credentials:
# VITE_SUPABASE_URL=your_url
# VITE_SUPABASE_ANON_KEY=your_anon_key
# VITE_BACKEND_URL=http://localhost:3001

npm install
npm run dev
```

#### Option B: With Docker

```bash
# In the root directory
cp .env.example .env
# Edit .env with your credentials

docker-compose up --build
```

### 3. Access the Application

- **Frontend**: http://localhost:5173 (dev) or http://localhost:3000 (Docker)
- **Backend**: http://localhost:3001

## 📝 API Documentation

### Authentication Endpoints

#### Sign Up
```http
POST /auth/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "ip": "192.168.1.1",
  "country": "United States",
  "city": "New York"
}
```

#### Sign In
```http
POST /auth/signin
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123!",
  "ip": "192.168.1.1",
  "country": "United States",
  "city": "New York"
}
```

Response:
```json
{
  "message": "Sign in successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

#### Get Sign-In Attempts
```http
GET /auth/signin-attempts/:userId
Authorization: Bearer {token}
```

## 🌐 Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for comprehensive deployment guides covering:

- **Cloud Platforms**:
  - AWS EC2 (with Docker)
  - Google Cloud Platform
  - Oracle Cloud Infrastructure (Free Tier)
  
- **Modern Platforms**:
  - Vercel (Frontend)
  - Railway (Backend)
  - Render (Backend)
  - Heroku (Backend)

- **Features**:
  - Docker containerization
  - Nginx reverse proxy setup
  - SSL/HTTPS configuration
  - Production best practices

## 🔒 Security Features

- **Password Hashing**: bcrypt with salt rounds
- **JWT Authentication**: Secure token-based auth (7-day expiry)
- **Password Policy**: Strong password requirements enforced
- **Row Level Security**: Supabase RLS policies
- **CORS Protection**: Configured for specific origins
- **Input Validation**: class-validator on all inputs
- **Sign-In Tracking**: All attempts logged with details

## 🎨 UI/UX Features

- **Responsive Design**: Works on desktop and mobile
- **Real-Time Validation**: Instant password policy feedback
- **Visual Indicators**: Green/red indicators for password requirements
- **Loading States**: Spinner animations during async operations
- **Error Handling**: User-friendly error messages
- **Modern Styling**: Gradient backgrounds, smooth animations

## 📊 Database Schema

### Users Table
- `id` (UUID, primary key)
- `name` (VARCHAR)
- `email` (VARCHAR, unique)
- `password_hash` (VARCHAR)
- `signup_ip` (VARCHAR)
- `signup_country` (VARCHAR)
- `signup_city` (VARCHAR)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### Sign-In Attempts Table
- `id` (UUID, primary key)
- `user_id` (UUID, foreign key)
- `email` (VARCHAR)
- `ip_address` (VARCHAR)
- `country` (VARCHAR)
- `city` (VARCHAR)
- `user_agent` (TEXT)
- `success` (BOOLEAN)
- `failure_reason` (VARCHAR)
- `attempted_at` (TIMESTAMP)

## 🧪 Testing

```bash
# Backend tests
cd backend
npm run test

# Frontend tests
cd frontend
npm run test
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 🐛 Troubleshooting

### Common Issues

1. **Frontend can't connect to backend**
   - Ensure backend is running on port 3001
   - Check CORS configuration in backend
   - Verify `VITE_BACKEND_URL` in frontend .env

2. **Database connection fails**
   - Verify Supabase credentials are correct
   - Ensure Supabase project is active
   - Check if SQL schema was properly executed

3. **IP detection not working**
   - ipapi.co has rate limits (free tier: 1000 requests/day)
   - Consider using a paid plan or alternative service

4. **Docker containers won't start**
   - Check if ports 3000 and 3001 are available
   - Verify .env file exists with correct values
   - Run `docker-compose logs` to see errors

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Check the [DEPLOYMENT.md](./DEPLOYMENT.md) guide
- Review Supabase, SvelteKit, and NestJS documentation

## 🎯 Future Enhancements

- [ ] Email verification
- [ ] Password reset functionality
- [ ] Two-factor authentication (2FA)
- [ ] Rate limiting on API endpoints
- [ ] Admin dashboard
- [ ] User profile management
- [ ] Session management
- [ ] Account activity notifications
- [ ] Export sign-in history as CSV
- [ ] Dark mode toggle

---

**Built with ❤️ using SvelteKit, NestJS, and Supabase**
