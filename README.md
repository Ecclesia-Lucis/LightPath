# LightPath

A gamified personal development platform combining language learning with life improvement through AI-guided quests and character progression.

## 🎯 Project Overview

LightPath helps users develop language skills and healthy life habits through an engaging RPG-style progression system. Users interact with an AI tutor, complete daily quests (physical, mental, spiritual, and language-based), earn XP, level up, and improve character stats.

### Key Features

- **AI-Powered Tutor**: Conversational AI with persistent memory for personalized guidance
- **Quest System**: Physical activities, meditation, reading, language exercises
- **Gamification**: XP, levels, stats (STR, MAG), achievements, customizable avatars
- **Community**: Friend system, group quests, Matrix chat integration
- **Progress Tracking**: Detailed analytics, graphs, metric logging

## 🏗️ Architecture

### Tech Stack

**Backend**
- Node.js 20 LTS + TypeScript
- Express.js REST API
- PostgreSQL 15+ (with pgvector)
- Redis (caching & sessions)
- GCP (Cloud Run, Cloud SQL, Cloud Storage)

**Frontend**
- React 18 + TypeScript
- Vite build tool
- Tailwind CSS
- Zustand (state management)
- React Router v6
- React Query (data fetching)

**AI/LLM**
- Gemini 1.5 Flash (primary, cost-optimized)
- PostgreSQL pgvector (semantic memory)

**Infrastructure**
- Docker & Docker Compose (development)
- Google Cloud Platform (production)
- Cloud Build (CI/CD)

## 📁 Project Structure

```
LightPath/
├── backend/                 # Node.js backend API
│   ├── src/
│   │   ├── routes/         # API routes
│   │   ├── controllers/    # Request handlers
│   │   ├── services/       # Business logic
│   │   ├── models/         # Database models
│   │   ├── middleware/     # Express middleware
│   │   ├── utils/          # Helper functions
│   │   ├── config/         # Configuration
│   │   └── index.ts        # Entry point
│   ├── package.json
│   └── tsconfig.json
├── frontend/                # React frontend
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── pages/          # Page components
│   │   ├── hooks/          # Custom hooks
│   │   ├── services/       # API services
│   │   ├── store/          # State management
│   │   ├── utils/          # Helper functions
│   │   ├── types/          # TypeScript types
│   │   └── main.tsx        # Entry point
│   ├── package.json
│   └── vite.config.ts
├── database/               # Database scripts
│   └── init.sql           # Initial setup
├── plans/                  # Project documentation
│   ├── requirements.md    # Detailed requirements
│   ├── priorities.md      # Feature priorities
│   └── roadmap.md         # Development roadmap
├── docker-compose.yml     # Development environment
├── package.json           # Root package.json (workspaces)
└── README.md             # This file
```

## 🚀 Getting Started

### Prerequisites

- Node.js 20+ and npm 10+
- Docker and Docker Compose
- Git

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone git@github.com:Ecclesia-Lucis/LightPath.git
   cd LightPath
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   # Backend
   cp backend/.env.example backend/.env
   # Edit backend/.env with your configuration

   # Frontend
   cp frontend/.env.example frontend/.env
   # Edit frontend/.env with your configuration
   ```

4. **Start development services (PostgreSQL, Redis)**
   ```bash
   npm run docker:up
   ```

5. **Verify services are running**
   ```bash
   npm run docker:logs
   ```

6. **Start development servers**
   ```bash
   # In separate terminals, or use:
   npm run dev

   # Or individually:
   npm run dev:backend    # Backend on http://localhost:3000
   npm run dev:frontend   # Frontend on http://localhost:5173
   ```

7. **Access the application**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:3000
   - API Health: http://localhost:3000/health
   - PgAdmin (optional): http://localhost:5050
     - Email: admin@lightpath.local
     - Password: admin

### Development Workflow

```bash
# Start all services
npm run dev

# Run tests
npm run test

# Lint code
npm run lint

# Build for production
npm run build

# Stop Docker services
npm run docker:down
```

## 🗄️ Database

### Accessing PostgreSQL

**Via Docker CLI:**
```bash
docker exec -it lightpath-postgres psql -U lightpath -d lightpath
```

**Via PgAdmin:**
1. Start services with tools profile: `docker-compose --profile tools up -d`
2. Access http://localhost:5050
3. Add new server:
   - Host: postgres
   - Port: 5432
   - Database: lightpath
   - Username: lightpath
   - Password: password

### Database Migrations

Migrations will be handled by a migration tool (to be set up). For now, schema is managed manually.

## 📊 Cost Optimization

This project prioritizes cost efficiency:

- **Cloud Run**: Scales to zero when idle (pay per request)
- **Cloud SQL**: db-f1-micro instance (~$10/month)
- **Redis**: Upstash free tier or Cloud Memorystore M1
- **LLM**: Gemini 1.5 Flash (cheapest option)
- **Vector DB**: PostgreSQL pgvector (no additional cost)
- **Storage**: Cloud Storage with CDN caching
- **Email**: SendGrid free tier (100 emails/day)

**Target MVP Budget: $50-150/month**

See `plans/roadmap.md` for detailed cost optimization strategy.

## 📖 Documentation

- [Requirements](plans/requirements.md) - Comprehensive feature specifications
- [Priorities](plans/priorities.md) - Feature prioritization and rationale
- [Roadmap](plans/roadmap.md) - Development phases and timeline

## 🧪 Testing

```bash
# Run all tests
npm run test

# Backend tests
npm run test --workspace=backend

# Frontend tests
npm run test --workspace=frontend

# Test coverage
npm run test:coverage
```

## 🔒 Security

- Passwords hashed with bcrypt (cost factor 12)
- JWT for authentication
- HTTPS only in production
- Rate limiting on API endpoints
- CSRF protection
- Input validation with Zod
- Secrets managed via GCP Secret Manager

## 📝 API Documentation

API documentation will be available via Swagger/OpenAPI at `/api/docs` (to be implemented).

## 🤝 Contributing

This is a private project for Ecclesia Lucis. If you have access:

1. Create a feature branch from `main`
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## 📄 License

UNLICENSED - Private project

## 🔗 Links

- [GitHub Repository](https://github.com/Ecclesia-Lucis/LightPath)
- [GCP Project Dashboard](https://console.cloud.google.com)

## 📞 Support

For issues or questions, create a GitHub issue or contact the development team.

---

**Status**: 🚧 Initial Setup Phase - Development in Progress
