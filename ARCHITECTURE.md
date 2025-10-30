# System Architecture

## Overview

This document describes the architecture of the Secure Authentication Application.

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                           USER BROWSER                           │
│                      (http://your-app.com)                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP/HTTPS
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      FRONTEND (SvelteKit)                        │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │    Landing   │  │    Sign Up   │  │   Sign In    │         │
│  │     Page     │  │     Page     │  │     Page     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐      │
│  │              Dashboard Page                          │      │
│  │  - User Info                                         │      │
│  │  - Sign-in Attempts Table                           │      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                  │
│  Libraries:                                                     │
│  - API Client (axios)                                          │
│  - State Management (Svelte stores)                            │
│  - Password Validation                                         │
│  - IP Detection Service                                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ REST API
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      BACKEND (NestJS)                            │
│                                                                  │
│  ┌────────────────────────────────────────────────────┐         │
│  │           Authentication Module                     │         │
│  │                                                     │         │
│  │  POST /auth/signup                                 │         │
│  │  - Validate input                                  │         │
│  │  - Hash password (bcrypt)                         │         │
│  │  - Store user with location                       │         │
│  │                                                     │         │
│  │  POST /auth/signin                                 │         │
│  │  - Verify credentials                              │         │
│  │  - Log attempt (success/failure)                  │         │
│  │  - Generate JWT token                             │         │
│  │                                                     │         │
│  │  GET /auth/signin-attempts/:userId                │         │
│  │  - Fetch user's login history                     │         │
│  └────────────────────────────────────────────────────┘         │
│                                                                  │
│  Security Features:                                             │
│  - JWT Authentication                                           │
│  - Password Hashing (bcrypt)                                   │
│  - Input Validation (class-validator)                          │
│  - CORS Protection                                             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ PostgreSQL Protocol
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                    DATABASE (Supabase)                           │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │  Users Table                                        │        │
│  │  ┌──────────────────────────────────────────┐      │        │
│  │  │ id, name, email, password_hash           │      │        │
│  │  │ signup_ip, signup_country, signup_city   │      │        │
│  │  │ created_at, updated_at                   │      │        │
│  │  └──────────────────────────────────────────┘      │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │  Sign-In Attempts Table                             │        │
│  │  ┌──────────────────────────────────────────┐      │        │
│  │  │ id, user_id, email                       │      │        │
│  │  │ ip_address, country, city, user_agent    │      │        │
│  │  │ success, failure_reason, attempted_at    │      │        │
│  │  └──────────────────────────────────────────┘      │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│  Features:                                                       │
│  - Row Level Security (RLS)                                     │
│  - Indexes for performance                                      │
│  - Automatic timestamps                                         │
└──────────────────────────────────────────────────────────────────┘

External Services:
┌──────────────────────┐
│   ipapi.co           │  → IP Geolocation
│   (IP Detection)     │     - Country
└──────────────────────┘     - City
```

## Data Flow

### Sign-Up Flow

```
User → Frontend
  │
  ├─→ Enter: name, email, password
  │
  ├─→ Real-time password validation
  │     ├─ Min 8 characters
  │     ├─ Uppercase letter
  │     ├─ Lowercase letter
  │     ├─ Number
  │     └─ Special character
  │
  ├─→ Fetch IP data from ipapi.co
  │
  └─→ Submit to Backend

Backend
  │
  ├─→ Validate input
  │
  ├─→ Check if email exists
  │
  ├─→ Hash password (bcrypt)
  │
  ├─→ Save to Supabase:
  │     - User data
  │     - IP address
  │     - Country
  │     - City
  │
  └─→ Return success

Frontend
  │
  └─→ Redirect to Sign In
```

### Sign-In Flow

```
User → Frontend
  │
  ├─→ Enter: email, password
  │
  ├─→ Fetch IP data from ipapi.co
  │
  └─→ Submit to Backend

Backend
  │
  ├─→ Find user by email
  │
  ├─→ Verify password
  │
  ├─→ Log sign-in attempt:
  │     - User ID
  │     - IP address
  │     - Location
  │     - User agent
  │     - Success/Failure
  │     - Timestamp
  │
  ├─→ If successful:
  │     └─→ Generate JWT token
  │
  └─→ Return token + user data

Frontend
  │
  ├─→ Store token in localStorage
  │
  ├─→ Store user data in store
  │
  └─→ Redirect to Dashboard
```

### Dashboard Flow

```
User → Dashboard Page
  │
  ├─→ Check authentication
  │
  ├─→ Fetch sign-in attempts from Backend
  │
  └─→ Display:
        - User information
        - Table of sign-in attempts
          ├─ Date/Time
          ├─ Status (Success/Failure)
          ├─ IP Address
          ├─ Location
          ├─ Device Info
          └─ Failure Reason (if failed)
```

## Technology Stack Details

### Frontend Stack
```
SvelteKit (Framework)
  │
  ├─→ Svelte Stores (State Management)
  ├─→ Axios (HTTP Client)
  ├─→ SvelteKit Router (Navigation)
  └─→ Custom Services:
        ├─ API Client
        ├─ Password Validator
        └─ IP Service
```

### Backend Stack
```
NestJS (Framework)
  │
  ├─→ TypeScript (Language)
  ├─→ JWT (Authentication)
  ├─→ bcrypt (Password Hashing)
  ├─→ class-validator (Validation)
  ├─→ class-transformer (DTO Transformation)
  └─→ Supabase Client (Database)
```

### Database Stack
```
Supabase (PostgreSQL)
  │
  ├─→ Row Level Security (RLS)
  ├─→ Indexes (Performance)
  ├─→ Triggers (Auto-update timestamps)
  └─→ Policies (Data access control)
```

## Deployment Architecture

### Docker Deployment
```
┌────────────────────────────────────────┐
│         Docker Compose                  │
│                                         │
│  ┌─────────────────┐  ┌──────────────┐│
│  │   Frontend      │  │   Backend    ││
│  │   Container     │  │   Container  ││
│  │   (Port 3000)   │  │   (Port 3001)││
│  └─────────────────┘  └──────────────┘│
│         │                     │        │
└─────────┼─────────────────────┼────────┘
          │                     │
          │                     │
          ▼                     ▼
    Public Access          Public Access
```

### Cloud Deployment (AWS Example)
```
┌────────────────────────────────────────────────┐
│              AWS EC2 Instance                   │
│              (Ubuntu + Docker)                  │
│                                                 │
│  ┌───────────┐                                 │
│  │   Nginx   │  (Reverse Proxy)                │
│  │  Port 80  │  - SSL/HTTPS                    │
│  └─────┬─────┘  - Route /api to backend        │
│        │                                        │
│  ┌─────▼──────────────────┐                    │
│  │  Frontend  │  Backend  │                    │
│  │  (3000)    │  (3001)   │                    │
│  └────────────┴───────────┘                    │
└────────────────────────────────────────────────┘
           │
           ▼
    ┌──────────────┐
    │   Supabase   │  (External)
    │   Database   │
    └──────────────┘
```

### Modern Platform Deployment
```
┌──────────────┐         ┌──────────────┐
│   Vercel     │         │   Railway    │
│  (Frontend)  │◄───────►│  (Backend)   │
│              │   API   │              │
└──────────────┘         └───────┬──────┘
                                 │
                                 ▼
                         ┌──────────────┐
                         │   Supabase   │
                         │  (Database)  │
                         └──────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────┐
│          Security Layers                 │
│                                          │
│  1. Frontend Validation                 │
│     └─→ Password policy enforcement     │
│                                          │
│  2. Backend Validation                  │
│     └─→ DTO validation                  │
│     └─→ Input sanitization              │
│                                          │
│  3. Authentication                      │
│     └─→ Password hashing (bcrypt)       │
│     └─→ JWT tokens (7-day expiry)       │
│                                          │
│  4. Database Security                   │
│     └─→ Row Level Security (RLS)        │
│     └─→ Prepared statements             │
│                                          │
│  5. Network Security                    │
│     └─→ CORS configuration              │
│     └─→ HTTPS/SSL                       │
└─────────────────────────────────────────┘
```

## File Structure Map

```
Project Root
│
├── Frontend (SvelteKit)
│   ├── Pages: /, /signup, /signin, /dashboard
│   ├── Services: API, IP, Password Validation
│   └── State: Svelte Stores
│
├── Backend (NestJS)
│   ├── Modules: Auth
│   ├── Services: Auth Service
│   ├── Controllers: Auth Controller
│   └── Database: Supabase Client
│
├── Database (Supabase)
│   ├── Tables: users, sign_in_attempts
│   ├── Security: RLS policies
│   └── Performance: Indexes
│
└── Infrastructure
    ├── Docker: Frontend & Backend containers
    ├── Deployment: AWS, GCP, OCI, Vercel, Railway
    └── Documentation: Complete guides
```

## API Endpoints Overview

```
Backend API (http://localhost:3001)

POST /auth/signup
├─→ Input: name, email, password, ip, country, city
├─→ Process: Validate, hash password, save user
└─→ Output: Success message, user data

POST /auth/signin
├─→ Input: email, password, ip, country, city, user_agent
├─→ Process: Validate, verify password, log attempt, create token
└─→ Output: JWT token, user data

GET /auth/signin-attempts/:userId
├─→ Input: userId (URL parameter)
├─→ Process: Fetch attempts from database
└─→ Output: Array of sign-in attempts
```

## Performance Considerations

### Database Indexes
- `users.email` - Fast user lookup
- `sign_in_attempts.user_id` - Fast attempt queries
- `sign_in_attempts.attempted_at` - Ordered results

### Caching Strategy
- JWT tokens cached in localStorage (frontend)
- User data cached in Svelte stores (frontend)

### Optimization
- Multi-stage Docker builds (smaller images)
- Production dependencies only in containers
- Database connection pooling (Supabase)

---

This architecture provides:
- ✅ Scalability
- ✅ Security
- ✅ Performance
- ✅ Maintainability
- ✅ Flexibility for deployment options
