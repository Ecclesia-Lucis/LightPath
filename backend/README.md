# LightPath Backend

Node.js + TypeScript + Express API server for LightPath.

## Tech Stack

- **Runtime**: Node.js 20 LTS
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL 15+ (with pgvector extension)
- **Cache**: Redis
- **ORM**: TBD (pg driver for now)
- **Authentication**: JWT + bcrypt
- **Validation**: Zod
- **Logging**: Pino
- **Testing**: Jest + Supertest

## Directory Structure

```
backend/
├── src/
│   ├── routes/          # API route definitions
│   ├── controllers/     # Request handlers
│   ├── services/        # Business logic layer
│   ├── models/          # Database models
│   ├── middleware/      # Express middleware
│   │   ├── auth.ts     # Authentication middleware
│   │   ├── errorHandler.ts
│   │   └── validation.ts
│   ├── utils/           # Helper functions
│   │   ├── logger.ts    # Pino logger setup
│   │   └── errors.ts    # Custom error classes
│   ├── config/          # Configuration files
│   │   ├── database.ts  # DB connection config
│   │   ├── redis.ts     # Redis config
│   │   └── llm.ts       # LLM API config
│   └── index.ts         # Application entry point
├── tests/               # Test files (to be created)
├── .env.example         # Environment variables template
├── package.json
└── tsconfig.json
```

## Getting Started

### Prerequisites

- Node.js 20+
- PostgreSQL 15+ running (via Docker or local)
- Redis running (via Docker or local)

### Installation

```bash
cd backend
npm install
```

### Environment Setup

```bash
cp .env.example .env
# Edit .env with your configuration
```

### Development

```bash
# Start development server with hot reload
npm run dev

# Build TypeScript
npm run build

# Run built application
npm start
```

### Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Linting & Formatting

```bash
# Check for linting errors
npm run lint

# Fix linting errors
npm run lint:fix

# Format code with Prettier
npm run format
```

## API Structure

### Planned Routes

- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/logout` - User logout
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `GET /api/v1/users/me` - Get current user profile
- `PUT /api/v1/users/me` - Update current user profile
- `GET /api/v1/quests` - Get user's quests
- `POST /api/v1/quests/:id/complete` - Mark quest complete
- `POST /api/v1/chat` - Send message to AI tutor
- `GET /api/v1/chat/history` - Get chat history
- `GET /api/v1/stats` - Get user stats and progression

## Database

### Connection

The application uses the native `pg` driver for PostgreSQL. Connection is managed via a connection pool.

### Migrations

Database migrations will be handled by a migration tool (TBD). For development, you can use the init script in `database/init.sql`.

### Extensions

- **pgvector**: For semantic memory / vector embeddings

## Environment Variables

See `.env.example` for all available configuration options.

Critical variables:
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `JWT_SECRET` - Secret for JWT signing
- `LLM_PROVIDER` - Which LLM to use (gemini, anthropic, openai)
- `GEMINI_API_KEY` / `ANTHROPIC_API_KEY` / `OPENAI_API_KEY`

## Error Handling

Custom error handler middleware catches all errors and returns consistent JSON responses:

```typescript
{
  error: {
    message: "Error description",
    statusCode: 400,
    stack: "..." // Only in development
  }
}
```

## Logging

Uses Pino for structured JSON logging. In development, logs are pretty-printed to console.

Log levels: debug, info, warn, error

## Security

- Passwords hashed with bcrypt (cost factor 12)
- JWT tokens for authentication
- Rate limiting on authentication endpoints
- Helmet.js for security headers
- CORS configured for frontend origin
- Input validation with Zod

## Cost Optimization

- Connection pooling (max 10 connections for MVP)
- Redis caching for frequent queries
- LLM response caching (24h TTL)
- Efficient database queries with proper indexing
- Compression middleware for responses

## Next Steps

1. Implement authentication routes and JWT middleware
2. Set up database models and query functions
3. Implement LLM integration service
4. Create quest system backend
5. Implement gamification engine (XP, levels, stats)
6. Add comprehensive test coverage

## Resources

- [Express.js Documentation](https://expressjs.com/)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Pino Logger](https://getpino.io/)
