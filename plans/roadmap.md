# LightPath - Development Roadmap

**Version:** 3.0 (GCP + Cost-Optimized)
**Date:** 2026-01-08
**Status:** Active Development Plan
**Based On:** Requirements v1.0 & Priorities v1.0
**Infrastructure:** Google Cloud Platform (GCP)
**Budget Constraint:** TIGHT - Cost optimization is mandatory at every step

---

## Executive Summary

This roadmap organizes LightPath development into **priority-based phases** with clear **dependencies and parallelization opportunities**. The goal is to coordinate multiple agents working simultaneously while ensuring work doesn't block each other.

**CRITICAL: All agents must prioritize cost-efficiency due to tight budget constraints. Use smallest viable GCP services, maximize free tiers, and implement aggressive caching.**

### Key Principles
1. **Dependency-Driven**: Work is organized by what must complete before other work can begin
2. **Parallelization-First**: Maximize concurrent workstreams where possible
3. **Agent-Specialized**: Match work to agent expertise for optimal efficiency
4. **Completion-Focused**: Clear "done" criteria for each work package
5. **Cost-Conscious**: Every infrastructure decision must justify cost vs. value (NEW)

### Agent Team Structure
- **Backend Lead**: APIs, business logic, integrations, query optimization
- **Data Engineer**: Database, models, persistence, caching, cost-efficient queries
- **AI Specialist**: LLM integration, prompt engineering, vector DB, aggressive caching
- **Frontend Lead**: UI components, user flows, responsive design, CDN optimization
- **Full-Stack Developer**: GCP infrastructure, DevOps, avatar system, cost monitoring
- **QA Engineer**: Testing, quality assurance, automation

### Infrastructure Provider: Google Cloud Platform (GCP)

**Why GCP:**
- Generous free tier ($300 credit for 90 days)
- Cost-effective for startups (per-second billing)
- Integrated services reduce complexity
- Strong serverless offerings (Cloud Run)

**Budget Philosophy:**
- Start with smallest viable instances
- Scale up only when metrics prove necessity
- Free tier first, paid tier only when required
- Monitor costs daily, set strict budget alerts

---

## Critical Path Analysis

The **critical path** is the sequence of dependent work that cannot be parallelized. This determines the minimum number of sequential steps to MVP:

```
1. Infrastructure Setup
   ↓
2. Database Schema + Authentication
   ↓
3. Core APIs (User, Profile, Session)
   ↓
4. AI Tutor Integration
   ↓
5. Quest System Backend
   ↓
6. Gamification Engine
   ↓
7. Frontend Integration
   ↓
8. Testing & Launch
```

**Total Critical Path Steps: 8 sequential phases**

All other work can happen in parallel with critical path work or depends on specific critical path milestones.

---

## Cost Optimization Strategy (MANDATORY)

**Monthly Budget Target: $50-150 during MVP development**

### GCP Service Selection (Cost-Optimized)

#### Compute (Backend Application)
**Primary Choice: Cloud Run (Serverless)**
- **Why**: Pay only for actual request time, scales to zero
- **Cost**: First 2 million requests/month FREE
- **Configuration**:
  - Start: 256MB RAM, 1 vCPU (minimum tier)
  - Max instances: 5 (prevent runaway costs)
  - Request timeout: 60s (default is 300s, costs more)
- **Estimated Cost**: $0-20/month for MVP traffic
- **Alternative**: GKE Autopilot ($70+/month - AVOID for MVP)

#### Database (PostgreSQL)
**Choice: Cloud SQL for PostgreSQL**
- **Tier**: db-f1-micro (shared-core, 0.6GB RAM)
- **Cost**: ~$7.67/month (cheapest option)
- **Storage**: 10GB SSD ($1.70/month)
- **Backups**: 7-day retention (included)
- **Region**: us-central1 (cheapest)
- **Optimize**:
  - Single instance (no HA for MVP)
  - Automated backups only (no manual snapshots)
  - Delete query logs after 7 days
- **Scale-up trigger**: >80% CPU for 24+ hours
- **Estimated Cost**: ~$10/month

#### Cache (Redis)
**Choice: Cloud Memorystore for Redis**
- **Tier**: Basic (non-HA), M1 (1GB)
- **Cost**: ~$36.50/month (cheapest Memorystore)
- **ALTERNATIVE (Better for MVP): Upstash Redis** (Serverless)
  - Free tier: 10,000 commands/day
  - Pay-as-you-go after that
  - **Recommended for MVP**: $0-10/month
  - Migrate to Memorystore only if Upstash limits hit
- **Estimated Cost**: $0-10/month (Upstash), $36/month (Memorystore)

#### Object Storage (Avatars, Images)
**Choice: Cloud Storage**
- **Class**: Standard (not Nearline/Coldline - avatars accessed frequently)
- **Region**: us-central1
- **Cost**: $0.020/GB/month storage + $0.12/GB egress
- **Free Tier**: 5GB storage, 1GB egress/month
- **Optimize**:
  - Lifecycle policy: Delete unused images after 90 days
  - Compress images before upload (frontend)
  - Use Cloud CDN for caching (reduces egress)
  - Max avatar size: 512×512, <100KB
- **Estimated Cost**: $0-5/month (within free tier initially)

#### CDN (Static Assets)
**Choice: Cloud CDN**
- **Cost**: $0.08/GB cache egress (cheaper than origin egress)
- **Optimize**:
  - Cache static assets for 1 year
  - Compress all assets with gzip/brotli
  - Use aggressive browser caching
- **Estimated Cost**: $0-10/month

#### CI/CD
**Choice: Cloud Build**
- **Free Tier**: 120 build-minutes/day
- **Optimize**:
  - Cache Docker layers aggressively
  - Build only on main branch + PRs
  - Use smallest builder (reduces minutes)
  - Parallel builds disabled (sequential is free tier friendly)
- **Estimated Cost**: $0/month (within free tier)

#### Monitoring & Logging
**Choice: Cloud Logging + Cloud Monitoring**
- **Free Tier**: 50GB logs/month, basic metrics
- **Optimize**:
  - Log only ERROR and WARN levels in production
  - 7-day log retention (not 30 days)
  - Sample 10% of INFO logs
  - Disable debug logs entirely
  - Use structured logging (more efficient queries)
- **Estimated Cost**: $0-5/month

#### Secrets Management
**Choice: Secret Manager**
- **Cost**: $0.06 per 10,000 access operations
- **Free Tier**: 6 secrets free
- **Optimize**: Cache secrets in memory (don't fetch on every request)
- **Estimated Cost**: $0/month (within free tier)

#### Container Registry
**Choice: Artifact Registry**
- **Storage**: $0.10/GB/month
- **Optimize**:
  - Delete old image versions (keep last 5)
  - Use multi-stage Docker builds (smaller images)
  - Compress layers
- **Estimated Cost**: $0-3/month

### Third-Party Services (Not GCP)

#### LLM API (Largest Cost Risk)
**Options Analysis:**
- **OpenAI GPT-4o**: $2.50/1M input tokens, $10/1M output tokens
- **Anthropic Claude Haiku**: $0.25/1M input, $1.25/1M output (RECOMMENDED)
- **Google Gemini 1.5 Flash**: $0.075/1M input, $0.30/1M output (CHEAPEST)

**Recommendation: Start with Gemini 1.5 Flash**
- Reason: Cheapest, native GCP integration, good quality
- Fallback: Claude Haiku if quality insufficient
- Cost mitigation:
  - Aggressive response caching (Redis): 80% cache hit rate target
  - Short system prompts (<500 tokens)
  - Limit conversation context to 10 messages (not 20)
  - Pre-generate common responses
  - Rate limit: 50 messages/user/day
  - Estimated cost: $10-30/month for 100 beta users

#### Vector Database (Conversation Memory)
**Options Analysis:**
- **Pinecone**: $70/month minimum (AVOID)
- **Weaviate Cloud**: $25/month minimum (AVOID)
- **Qdrant Cloud**: Free tier 1GB, then $25/month (BEST)
- **PostgreSQL pgvector**: $0 (use existing Cloud SQL) (RECOMMENDED for MVP)

**Recommendation: PostgreSQL pgvector extension**
- Reason: No additional cost, uses existing database
- Trade-off: Slightly slower than dedicated vector DB
- Performance: Sufficient for <10,000 users
- Migration path: Move to Qdrant if performance insufficient
- **Estimated Cost**: $0/month

#### Email Service (Verification, Password Reset)
**Choice: SendGrid**
- **Free Tier**: 100 emails/day forever
- **Sufficient for MVP**: 3,000 emails/month free
- **Alternative**: Mailgun (5,000 emails/month free for 3 months)
- **Estimated Cost**: $0/month

#### Image Generation (Avatar AI)
**Options Analysis:**
- **DALL-E 3**: $0.04/image (1024×1024)
- **Stable Diffusion API**: $0.01-0.02/image
- **Fallback**: Preset avatar library (free)

**Recommendation: Preset avatars + optional AI upgrade**
- Default: 20 preset avatars (free)
- Premium: AI generation ($0.02/user, pay on demand)
- 80% users use presets → $0.02 × 20 = $0.40/100 users
- **Estimated Cost**: $0-5/month for MVP

### Cost Monitoring & Alerts (CRITICAL)

**Budget Alerts (Set up immediately):**
1. **$50/month threshold**: Email alert to team
2. **$100/month threshold**: Email + Slack alert, review required
3. **$150/month threshold**: Emergency review, consider service shutdown
4. **Daily spending >$5**: Immediate investigation

**Cost Tracking Dashboard:**
- Daily cost by service (Cloud Billing Reports)
- Cost per user (manual calculation)
- Cost per API call (manual calculation)
- LLM API usage trends
- Database storage growth

**Weekly Cost Review:**
- Review Cloud Billing reports every Monday
- Identify cost spikes
- Optimize or shut down expensive services
- Document cost-saving decisions

### Cost Optimization Tactics by Service

#### Cloud SQL (Database)
- Use connection pooling (reduce connection overhead)
- Index all foreign keys and query WHERE clauses
- Analyze slow queries weekly (Cloud SQL Insights)
- Archive old data (move quests older than 90 days to Cloud Storage)
- Run VACUUM and ANALYZE weekly (reduce bloat)

#### Cloud Run (Backend)
- Set min-instances: 0 (scale to zero when idle)
- Set max-instances: 5 (prevent cost spikes)
- Optimize cold start time (<2s) with lightweight Docker images
- Use request coalescing (batch database queries)
- Implement aggressive caching (reduce request processing time)

#### Cloud Storage (Avatars)
- Compress all images before upload (frontend responsibility)
- Use Cloud CDN aggressively (reduces egress from storage)
- Set lifecycle policy: Delete unused images after 90 days
- Use signed URLs with short expiration (1 hour) for security

#### LLM API (Gemini/Claude)
- Cache responses in Redis with 24-hour TTL
- Implement semantic similarity search (avoid duplicate responses)
- Pre-generate 100 common responses (FAQ)
- Limit response length: 200 tokens max
- Summarize old conversations (don't send full history to LLM)

### Free Tier Maximization

**GCP Services with Generous Free Tiers:**
- Cloud Functions: 2 million invocations/month (use for scheduled tasks)
- Cloud Build: 120 build-minutes/day (sufficient for CI/CD)
- Cloud Logging: 50GB/month (log only errors)
- Cloud Monitoring: Basic metrics free
- Cloud Storage: 5GB storage, 1GB egress/month
- Secret Manager: 6 secrets free

**Strategy:**
- Stay within free tiers for first 3 months
- Use $300 GCP credit wisely (monitor burn rate)
- Graduate to paid tiers only when proven necessary

### Cost-Prohibitive Services (AVOID)

**Do NOT use these for MVP:**
- GKE (Kubernetes): $70+/month minimum (use Cloud Run instead)
- Pinecone: $70/month (use pgvector instead)
- Cloud Memorystore: $36/month (use Upstash Redis instead)
- Cloud SQL HA: +100% cost (single instance sufficient for MVP)
- NAT Gateway: $45/month (use Cloud Run's built-in egress)
- Load Balancer: $18/month (Cloud Run includes load balancing)
- Cloud Armor: $30+/month (use rate limiting in application code)
- BigQuery: $5/TB scanned (use Cloud SQL for analytics)

### Scaling Strategy (Stay Cost-Efficient)

**Tier 1: 0-100 users (MVP) - Target: <$100/month**
- Cloud SQL: db-f1-micro
- Cloud Run: 256MB RAM, max 5 instances
- Upstash Redis (free tier)
- Gemini 1.5 Flash with aggressive caching
- PostgreSQL pgvector

**Tier 2: 100-1,000 users - Target: <$300/month**
- Cloud SQL: db-g1-small (1 vCPU, 1.7GB RAM)
- Cloud Run: 512MB RAM, max 10 instances
- Upstash Redis (paid tier) or Memorystore M1
- Continue Gemini, evaluate Claude Haiku
- Consider Qdrant if pgvector too slow

**Tier 3: 1,000-10,000 users - Target: <$1,000/month**
- Cloud SQL: db-custom-2-4096 (2 vCPU, 4GB RAM)
- Cloud Run: 1GB RAM, max 20 instances
- Memorystore M3 (5GB Redis)
- Qdrant vector DB
- Evaluate OpenAI GPT-4o for quality

**Critical: Do not scale prematurely. Metrics must prove need.**

---

## Phase 0: Foundation (P0 - Critical Path Start)

**Objective**: Establish technical foundation enabling all parallel development

**Why This Must Come First**: All other work depends on infrastructure, database, and authentication being operational

### Batch 0.1: Infrastructure & Environment (4 parallel workstreams)

**No Dependencies - All Can Start Immediately**

#### Workstream 0.1A: Cloud Infrastructure (Full-Stack Developer)
**What**: Set up cloud environment and managed services
**Work**:
- Provision cloud infrastructure (AWS/GCP/DigitalOcean)
- Set up PostgreSQL managed database (RDS/Cloud SQL)
- Set up Redis managed cache
- Configure Docker development environment
- Set up object storage for avatars (S3/GCS)

**Done When**:
- [ ] Database is accessible from development environment
- [ ] Redis is accessible and tested
- [ ] Storage bucket created with proper permissions
- [ ] All credentials stored in secrets manager

**Blocks**: All database work, all backend work requiring DB

---

#### Workstream 0.1B: CI/CD Pipeline (Full-Stack Developer)
**What**: Automated deployment and testing infrastructure
**Work**:
- GitHub Actions workflow setup
- Development/Staging/Production environment configuration
- Secrets management (AWS Secrets Manager / Vault)
- Basic monitoring setup (Datadog/New Relic)
- Docker containerization
- TLS certificate setup (Let's Encrypt)

**Done When**:
- [ ] Code push triggers automated tests
- [ ] Successful tests auto-deploy to staging
- [ ] Production deployment requires manual approval
- [ ] Secrets are externalized and secure

**Blocks**: Nothing critical (improves workflow but not blocking)

---

#### Workstream 0.1C: Backend Foundation (Backend Lead)
**What**: Node.js backend boilerplate and structure
**Work**:
- Node.js + TypeScript project setup
- Express.js/Fastify framework configuration
- API routing patterns and structure
- Error handling middleware
- Request validation setup (Joi/Zod)
- Logging framework (Winston/Pino)
- API documentation setup (Swagger/OpenAPI)

**Done When**:
- [ ] Hello world API endpoint works
- [ ] Error handling catches and formats errors properly
- [ ] Logging captures all requests
- [ ] OpenAPI spec auto-generates from routes

**Blocks**: All backend API development

---

#### Workstream 0.1D: Frontend Foundation (Frontend Lead)
**What**: React frontend boilerplate and structure
**Work**:
- React 18 + TypeScript project setup (Vite/Next.js)
- UI component library selection and setup (MUI/Tailwind)
- State management configuration (Redux Toolkit/Zustand)
- Routing setup (React Router)
- i18n framework configuration (i18next)
- HTTP client setup (Axios/Fetch wrapper)

**Done When**:
- [ ] Hello world page renders
- [ ] Routing between pages works
- [ ] State management stores/retrieves data
- [ ] i18n switches languages
- [ ] API calls can be made to backend

**Blocks**: All frontend UI development

---

### Batch 0.2: Core Data & Auth (3 parallel workstreams)

**Dependencies**: Requires Batch 0.1A (Infrastructure), 0.1C (Backend Foundation)

#### Workstream 0.2E: Database Schema (Data Engineer)
**What**: Complete PostgreSQL schema design and deployment
**Work**:
- Design all tables: Users, User_Stats, Quests, Quest_Templates, Conversations, Achievements, Friendships, Metric_Logs
- Create migration scripts (Knex.js/TypeORM)
- Set up indexes for performance
- Implement foreign key constraints
- Create database access layer (ORM/query builder)

**Done When**:
- [ ] All tables created in dev database
- [ ] Migrations run successfully forward and backward
- [ ] Indexes exist on all foreign keys
- [ ] Sample data can be inserted and queried
- [ ] Database access layer works with TypeScript types

**Blocks**: All backend features that store data (basically everything)

**Critical Path Dependency**: BLOCKS ALL BACKEND DEVELOPMENT

---

#### Workstream 0.2F: Authentication System (Backend Lead)
**What**: Complete user authentication and session management
**Dependencies**: Requires 0.2E (Database Schema)
**Work**:
- User registration endpoint (email/password)
- Login endpoint with JWT/session tokens
- Password hashing (bcrypt, cost factor 12)
- Email verification flow
- Session management with Redis
- Password reset flow
- Rate limiting (5 failed attempts = lockout)

**Deliverables**:
- REQ-AUTH-001: User Registration
- REQ-AUTH-002: User Login
- REQ-AUTH-003: Password Security
- REQ-AUTH-004: Session Management
- REQ-AUTH-005: Email Verification

**Done When**:
- [ ] User can register with email/password
- [ ] User receives verification email
- [ ] User can verify email via link
- [ ] User can log in and receive session token
- [ ] Session token authenticates subsequent requests
- [ ] User can reset password
- [ ] Rate limiting works (tested with failed login attempts)

**Blocks**: All user-specific features (basically everything after foundation)

**Critical Path Dependency**: BLOCKS ALL USER FEATURES

---

#### Workstream 0.2G: LLM Integration Spike (AI Specialist)
**What**: Research and set up AI/LLM infrastructure
**No Dependencies**: Can work independently with test accounts
**Work**:
- LLM provider selection (OpenAI vs. Anthropic vs. Llama)
- Test API integration with simple prompts
- Set up prompt engineering framework (LangChain/LlamaIndex)
- Vector database setup (Pinecone/Weaviate/Qdrant)
- Cost analysis and rate limiting strategy
- Test conversation flows with memory

**Done When**:
- [ ] LLM provider selected with cost justification
- [ ] Can send prompt and receive response
- [ ] Prompt framework integrated
- [ ] Vector DB set up and tested
- [ ] Basic conversation memory works (store/retrieve)
- [ ] Cost per interaction calculated

**Blocks**: AI tutor chat, onboarding interview, AI feedback

**Critical Path Dependency**: BLOCKS AI FEATURES

---

#### Workstream 0.2H: Design System (Frontend Lead)
**What**: Reusable UI components and design patterns
**Dependencies**: Requires 0.1D (Frontend Foundation)
**Work**:
- Define color palette and typography
- Create base components (Button, Input, Card, Modal)
- Layout components (Navigation, Sidebar, Container)
- Responsive design patterns (mobile/tablet/desktop)
- Accessibility baseline (WCAG 2.1 AA)
- Loading states and error displays

**Done When**:
- [ ] Component library documented in Storybook
- [ ] All base components work in isolation
- [ ] Responsive breakpoints defined and tested
- [ ] Keyboard navigation works
- [ ] ARIA labels present on interactive elements

**Blocks**: All frontend UI pages

---

## Phase 1: Core MVP Features (P0)

**Objective**: Build the minimum viable product with core engagement loop

**Dependencies**: Requires Phase 0 complete (especially Auth, Database, LLM)

### Batch 1.1: User Onboarding (2 sequential workstreams)

#### Workstream 1.1I: Onboarding Backend (Backend Lead)
**Dependencies**: Requires 0.2F (Auth), 0.2G (LLM)
**What**: API endpoints for onboarding flow
**Work**:
- Interview flow API (save progress, resume)
- Language selection storage
- Goal identification and categorization
- Onboarding completion status
- Integration with LLM for conversational interview

**Deliverables**:
- REQ-ONBOARD-001: Interview Flow
- REQ-ONBOARD-002: Language Selection
- REQ-ONBOARD-003: Goal Identification

**Done When**:
- [ ] API accepts and stores interview answers
- [ ] API integrates with LLM for question generation
- [ ] User can pause and resume interview
- [ ] Language selection persists to user profile
- [ ] Goals are categorized for quest assignment

**Blocks**: Avatar system (needs completed onboarding), Quest assignment

---

#### Workstream 1.1P: Onboarding Frontend (Frontend Lead)
**Dependencies**: Requires 1.1I (Onboarding Backend), 0.2H (Design System)
**What**: User-facing onboarding flow
**Work**:
- Registration form with validation
- Email verification screen
- Interview chat interface
- Progress indicators
- Welcome/completion screen

**Done When**:
- [ ] User can complete full onboarding flow
- [ ] Interview feels conversational (not form-like)
- [ ] Progress is clearly visible
- [ ] User is redirected to dashboard after completion

**Blocks**: Nothing (but users need this to use the app)

---

### Batch 1.2: Core Engagement Loop (5 parallel workstreams)

**These can all work in parallel once dependencies are met**

#### Workstream 1.2J: Quest System Backend (Data Engineer)
**Dependencies**: Requires 0.2E (Database), 1.1I (Onboarding - for user goals)
**What**: Quest templates, assignment, and completion
**Work**:
- Quest templates data model and seed data
- Quest assignment algorithm (based on user goals, adaptive difficulty)
- Quest completion API
- Quest history storage
- Physical quest types (stairs, walking, weights)
- Mental/spiritual quest types (meditation, reading)

**Deliverables**:
- REQ-QUEST-001: Quest Assignment
- REQ-QUEST-002: Physical Quest Types
- REQ-QUEST-003: Mental/Spiritual Quest Types
- REQ-QUEST-005: Quest Completion

**Done When**:
- [ ] At least 10 quest templates exist per type (physical, mental)
- [ ] Quest assignment considers user goals and level
- [ ] User can mark quest complete via API
- [ ] Quest history is stored with timestamps
- [ ] Completed quests don't get reassigned

**Blocks**: Gamification engine (needs quests for XP), Dashboard (needs quest data)

---

#### Workstream 1.2K: Gamification Engine (Backend Lead)
**Dependencies**: Requires 1.2J (Quest System)
**What**: XP, levels, and stat progression
**Work**:
- XP calculation and awarding (proportional to difficulty)
- Level progression algorithm (exponential: XP_needed = 100 × level^1.5)
- Stat system (STR, MAG) with base value 10
- Stat calculation on quest completion
- Stat progression with diminishing returns
- Level-up detection and notification

**Deliverables**:
- REQ-GAME-001: Experience Points (XP)
- REQ-GAME-002: Level Progression
- REQ-GAME-003: Character Stats
- REQ-GAME-004: Stat Calculation

**Done When**:
- [ ] Quest completion awards XP
- [ ] XP accumulation triggers level-up
- [ ] Physical quests increase STR
- [ ] Mental quests increase MAG
- [ ] Stat gains use diminishing returns formula
- [ ] Stats and level persist correctly

**Blocks**: Dashboard (needs progression data)

**Critical Path Dependency**: Core engagement loop depends on this

---

#### Workstream 1.2L: AI Tutor Chat (AI Specialist)
**Dependencies**: Requires 0.2G (LLM Setup), 0.2F (Auth)
**What**: Conversational AI tutor with persistent memory
**Work**:
- Chat API (send message, receive response)
- LLM integration with conversation context (last 20 messages)
- Vector DB storage for conversation history
- Memory retrieval for context
- Daily language exercise generation
- Adaptive communication tone
- Response quality and safety filters

**Deliverables**:
- REQ-CHAT-001: Chat Interface (backend)
- REQ-CHAT-002: LLM Integration
- REQ-CHAT-003: Persistent Memory
- REQ-CHAT-004: Daily Exercise Presentation
- REQ-CHAT-005: Adaptive Communication
- REQ-DATA-004: Conversation Memory Storage

**Done When**:
- [ ] User can send message and receive response
- [ ] Tutor remembers previous conversation
- [ ] Response time is <5 seconds (P95)
- [ ] Tutor responds in user's selected language
- [ ] Tutor can present daily exercises
- [ ] Memory persists across sessions

**Blocks**: AI feedback system

**Critical Path Dependency**: Core differentiator, essential for MVP

---

#### Workstream 1.2M: Avatar System (Full-Stack Developer)
**Dependencies**: Requires 1.1I (Onboarding), 0.1A (Storage)
**What**: AI avatar generation and upload
**Work**:
- Avatar preference questions flow
- Integration with image generation API (DALL-E/Stable Diffusion)
- Avatar upload functionality (validation, resize, crop)
- Storage in S3/GCS with CDN
- Preset avatar library (fallback if AI fails)
- Avatar display endpoint

**Deliverables**:
- REQ-AVATAR-001: AI Avatar Generation
- REQ-AVATAR-002: Avatar Upload
- REQ-AVATAR-003: Avatar Display

**Done When**:
- [ ] Onboarding can trigger avatar generation
- [ ] Generated avatar completes within 30 seconds
- [ ] User can upload custom avatar (<5MB)
- [ ] Uploaded images are resized to 512×512
- [ ] Avatar displays in profile
- [ ] Preset avatars available if generation fails

**Blocks**: Nothing critical (but important for UX)

---

#### Workstream 1.2N: Dashboard UI (Frontend Lead)
**Dependencies**: Requires 0.2H (Design System), 1.2K (Gamification APIs), 1.2J (Quest APIs)
**What**: Main dashboard displaying user status
**Work**:
- Main dashboard layout
- Current level and XP progress bar
- Active quests display (quest cards)
- Stats visualization (STR, MAG gauges)
- Recent achievements section
- Navigation to other sections

**Deliverables**:
- REQ-PROGRESS-004: Activity Dashboard (basic version)

**Done When**:
- [ ] Dashboard loads in <2 seconds
- [ ] Displays current level, XP, and progress to next level
- [ ] Shows active quests with completion status
- [ ] Displays STR and MAG stats
- [ ] Works on mobile, tablet, desktop
- [ ] User can navigate to chat, quests, profile

**Blocks**: Nothing (but this is the main user-facing page)

---

### Batch 1.3: Supporting Features (4 parallel workstreams)

**These enhance the core loop but aren't blocking**

#### Workstream 1.3O: Chat Interface UI (Frontend Lead)
**Dependencies**: Requires 1.2L (Chat Backend), 0.2H (Design System)
**What**: User-facing chat interface
**Work**:
- Chat message display (conversation bubbles)
- Message input field with validation
- Typing indicator when AI is responding
- Conversation history scrolling
- Tutor avatar display
- Auto-scroll to newest message

**Done When**:
- [ ] User can type and send messages
- [ ] Messages display in conversation format
- [ ] Typing indicator shows while waiting for response
- [ ] Chat history loads previous conversations
- [ ] Works on mobile and desktop

**Blocks**: Nothing (but users need this to interact with tutor)

---

#### Workstream 1.3Q: Progress Tracking Backend (Data Engineer)
**Dependencies**: Requires 1.2K (Gamification Engine operational)
**What**: APIs for progress visualization
**Work**:
- Progress data aggregation APIs
- Quest history API with filtering
- Stat progression history (time-series data)
- Graph data endpoints (daily/weekly/monthly)
- XP progression over time

**Deliverables**:
- REQ-PROGRESS-002: Progress Visualization (backend)

**Done When**:
- [ ] API returns XP history for graphing
- [ ] API returns stat history for graphing
- [ ] Quest history can be filtered by type, date
- [ ] Data is aggregated efficiently (queries are fast)

**Blocks**: Progress visualization UI

---

#### Workstream 1.3R: AI Feedback System (AI Specialist)
**Dependencies**: Requires 1.2L (AI Tutor), 1.2K (Stats operational)
**What**: Weekly progress summaries from AI
**Work**:
- Scheduled weekly summary generation
- Feedback prompt engineering (encouraging + constructive)
- Integration with user stats and quest history
- On-demand feedback requests
- Feedback storage and history

**Deliverables**:
- REQ-PROGRESS-003: AI Feedback

**Done When**:
- [ ] Weekly summaries generate automatically
- [ ] Feedback references specific stats improvements
- [ ] User can request feedback anytime via chat
- [ ] Feedback is encouraging and actionable
- [ ] Feedback history is viewable

**Blocks**: Nothing critical

---

#### Workstream 1.3S: Progress Visualization UI (Frontend Lead)
**Dependencies**: Requires 1.3Q (Progress APIs), 0.2H (Design System)
**What**: Charts and graphs for progress
**Work**:
- XP progression line chart (Recharts/Chart.js)
- Stat progression charts
- Interactive date filtering
- Quest history list with filters
- Export data button

**Deliverables**:
- REQ-PROGRESS-002: Progress Visualization (frontend)

**Done When**:
- [ ] Graphs display correctly with real data
- [ ] User can filter by date range
- [ ] Graphs load in <2 seconds
- [ ] Responsive on all devices
- [ ] User can export data

**Blocks**: Nothing critical

---

### Batch 1.4: Quest Interfaces (2 parallel workstreams)

#### Workstream 1.4T: Quest UI Components (Frontend Lead)
**Dependencies**: Requires 1.2J (Quest APIs), 0.2H (Design System)
**What**: User interface for quests
**Work**:
- Quest card component (title, description, progress, rewards)
- Quest details modal
- Quest completion flow (mark complete button + confirmation)
- Quest history view with filters
- Active quests list

**Done When**:
- [ ] User can view active quests
- [ ] User can mark quest complete
- [ ] Quest history is browsable
- [ ] Quest details show clear completion criteria

**Blocks**: Nothing (but users need this to complete quests)

---

## Phase 2: Integration & Quality (P0 Completion)

**Objective**: Connect all systems, ensure production quality

**Dependencies**: Requires all Batch 1.x work packages complete

### Batch 2.1: System Integration (3 parallel workstreams)

#### Workstream 2.1U: End-to-End Integration (Full-Stack Developer)
**Dependencies**: ALL Phase 1 features must be complete
**What**: Connect frontend to backend, resolve integration issues
**Work**:
- Wire all frontend components to real APIs
- Fix authentication flow across all routes
- Resolve CORS and API contract mismatches
- Integration testing (Supertest for APIs)
- Bug fixing from integration
- Smoke test suite

**Done When**:
- [ ] User can complete full flow: register → onboard → chat → quest → level up
- [ ] All API calls from frontend work correctly
- [ ] No 401/403 errors after login
- [ ] Integration tests pass
- [ ] Critical user flows work end-to-end

**Blocks**: All subsequent work (system must work before polish)

**Critical Path Dependency**: Must complete before testing phase

---

#### Workstream 2.1V: Performance Optimization (Backend Lead + Data Engineer)
**Dependencies**: Requires 2.1U (Integration Complete)
**What**: Optimize for performance targets
**Work**:
- Database query optimization (add indexes, optimize queries)
- Redis caching for frequent queries (user profiles, quest templates)
- API response time improvements (target <500ms P95)
- LLM response caching for common questions
- Pagination for large datasets
- Lazy loading for frontend

**Deliverables**:
- REQ-PERF-001: Response Time (2s page loads, 500ms APIs, 5s AI)

**Done When**:
- [ ] Load testing shows <2s page loads
- [ ] API endpoints respond in <500ms (P95)
- [ ] AI tutor responds in <5s (P95)
- [ ] Dashboard with 100 quests loads quickly
- [ ] No N+1 query problems

**Blocks**: Nothing (improves performance)

---

#### Workstream 2.1W: UI/UX Polish (Frontend Lead)
**Dependencies**: Requires 2.1U (Integration Complete)
**What**: Responsive design and accessibility
**Work**:
- Mobile responsive fixes (test 375px+)
- Tablet layout optimization (768px+)
- Desktop layout refinement (1920px+)
- Accessibility improvements (keyboard nav, ARIA labels, screen reader testing)
- Loading states everywhere
- Error handling UI (clear error messages)
- Cross-browser testing (Chrome, Firefox, Safari, Edge)

**Deliverables**:
- REQ-USE-004: Accessibility (WCAG 2.1 AA)
- REQ-PORT-001: Browser Compatibility
- REQ-PORT-002: Device Compatibility

**Done When**:
- [ ] All pages work on mobile, tablet, desktop
- [ ] Keyboard navigation works for all interactive elements
- [ ] Screen reader can navigate the app
- [ ] Color contrast meets WCAG standards
- [ ] Works on all 4 target browsers

**Blocks**: Nothing (improves quality)

---

### Batch 2.2: Security & Compliance (4 parallel workstreams)

**Can work in parallel once integration is complete**

#### Workstream 2.2X: Data Backup & Recovery (Data Engineer)
**Dependencies**: Requires 0.2E (Database operational)
**What**: Backup and disaster recovery
**Work**:
- Daily backup automation (cron job or managed service)
- Backup retention policy (30 days)
- Backup restoration testing
- Database replication setup
- Disaster recovery runbook

**Deliverables**:
- REQ-DATA-008: Data Backup

**Done When**:
- [ ] Backups run daily automatically
- [ ] Backup restoration tested successfully
- [ ] Recovery time <4 hours (RTO)
- [ ] Data loss <1 hour (RPO)
- [ ] Runbook documented and tested

**Blocks**: Nothing (but required for production)

---

#### Workstream 2.2Y: GDPR Compliance (Backend Lead + Data Engineer)
**Dependencies**: Requires all data storage complete
**What**: User data rights implementation
**Work**:
- Data export API (JSON format, all user data)
- Account deletion flow (30-day grace period)
- User data access view (what we store about you)
- Privacy controls (profile visibility, data sharing)
- Consent management
- Privacy policy finalization

**Deliverables**:
- REQ-DATA-009: Data Export
- REQ-DATA-010: Data Deletion
- REQ-LEGAL-001: GDPR Compliance

**Done When**:
- [ ] User can request and download all their data
- [ ] User can delete account and all data is removed
- [ ] User can view what data we store
- [ ] Privacy controls work correctly
- [ ] Privacy policy is clear and accessible

**Blocks**: Nothing (but required for production, especially EU users)

---

#### Workstream 2.2Z: Security Hardening (Full-Stack Developer)
**Dependencies**: Requires 2.1U (Integration Complete)
**What**: Security audit and hardening
**Work**:
- CSRF protection verification
- XSS prevention review (input sanitization)
- SQL injection testing
- Secrets management audit (no secrets in code)
- Rate limiting implementation (prevent abuse)
- Security headers (Content-Security-Policy, etc.)
- HTTPS enforcement

**Deliverables**:
- REQ-SEC-001: Authentication Security
- REQ-SEC-002: Authorization
- REQ-SEC-003: Data Security
- REQ-SEC-004: Vulnerability Management

**Done When**:
- [ ] OWASP ZAP scan shows no critical issues
- [ ] Dependency scan (Snyk) shows no high/critical vulns
- [ ] Rate limiting prevents brute force
- [ ] All secrets in secrets manager
- [ ] HTTPS everywhere, no mixed content

**Blocks**: Production launch (security is critical)

---

#### Workstream 2.2AA: Internationalization (Frontend Lead)
**Dependencies**: Requires all UI complete
**What**: Multi-language support
**Work**:
- Externalize all UI strings to i18n files
- Language switching functionality
- Translation files for 5 languages (EN, ES, FR, DE, ZH)
- RTL support testing (not critical for v1)
- Date/number formatting by locale
- Verify tutor responds in correct language

**Deliverables**:
- REQ-I18N-001: Multi-Language Support
- REQ-I18N-002: Regional Settings

**Done When**:
- [ ] All UI text uses i18n system
- [ ] User can switch language without page reload
- [ ] 5 languages fully translated
- [ ] Dates format correctly by locale
- [ ] AI tutor speaks user's language

**Blocks**: Nothing (but required for non-English users)

---

## Phase 3: Testing & Launch Readiness (P0 Final)

**Objective**: Validate production readiness and launch

**Dependencies**: Requires Phase 2 complete

### Batch 3.1: Comprehensive Testing (3 parallel workstreams)

#### Workstream 3.1AB: Automated Testing (QA Engineer)
**Dependencies**: Requires all features complete
**What**: Test coverage and automation
**Work**:
- Unit test coverage validation (target: 80%+)
- Integration test suite for all APIs
- E2E tests for critical user flows (Playwright/Cypress)
- Regression test suite
- Bug triage and prioritization
- Test documentation

**Deliverables**:
- REQ-MAINT-002: Testability

**Done When**:
- [ ] 80%+ unit test coverage
- [ ] All critical API endpoints have integration tests
- [ ] E2E tests for: registration, onboarding, chat, quest completion, level up
- [ ] All tests pass in CI/CD pipeline
- [ ] No critical or high bugs remaining

**Blocks**: Production launch (need quality assurance)

---

#### Workstream 3.1AC: Performance & Load Testing (Full-Stack Developer)
**Dependencies**: Requires 2.1V (Performance Optimization)
**What**: Verify scalability
**Work**:
- Load testing (simulate 10,000 concurrent users)
- Stress testing (find breaking point)
- Spike testing (sudden load increase)
- Database performance under load
- LLM API rate limit testing
- Auto-scaling verification

**Deliverables**:
- REQ-TEST-003: Performance Testing
- REQ-PERF-002: Scalability

**Done When**:
- [ ] System handles 10k concurrent users
- [ ] Performance metrics maintained under load
- [ ] Auto-scaling triggers correctly
- [ ] No database deadlocks or timeouts
- [ ] LLM rate limits understood and handled

**Blocks**: Production launch (need to know capacity)

---

#### Workstream 3.1AD: Security Audit (Full-Stack Developer + External)
**Dependencies**: Requires 2.2Z (Security Hardening)
**What**: Independent security verification
**Work**:
- OWASP ZAP automated scan
- Manual penetration testing
- Dependency vulnerability scan (Snyk/npm audit)
- GDPR compliance review
- Privacy policy legal review
- Security runbook creation

**Deliverables**:
- REQ-TEST-004: Security Testing

**Done When**:
- [ ] Security audit report complete
- [ ] No critical/high vulnerabilities remaining
- [ ] GDPR compliance verified
- [ ] Privacy policy reviewed by legal
- [ ] Security incident response plan documented

**Blocks**: Production launch (security is critical)

---

### Batch 3.2: Documentation & Deployment (All Agents)

**Sequential work - must complete in order**

#### Workstream 3.2AE: Documentation (All Agents)
**Dependencies**: Requires all features finalized
**What**: Complete documentation for launch
**Work**:
- API documentation (Swagger/OpenAPI complete)
- User help articles (FAQ, common issues)
- Deployment procedures
- System architecture diagrams
- Monitoring and alerting runbook
- Support team training materials

**Deliverables**:
- REQ-MAINT-003: Documentation

**Done When**:
- [ ] API docs are complete and accurate
- [ ] User help covers onboarding, quests, chat, profile
- [ ] Deployment procedure is step-by-step and tested
- [ ] Architecture diagrams show all systems
- [ ] Support team trained

**Blocks**: Nothing (but needed for operations)

---

#### Workstream 3.2AF: Production Deployment (Full-Stack Developer)
**Dependencies**: Requires ALL testing passed
**What**: Deploy to production environment
**Work**:
- Production environment configuration
- Database migration execution
- Blue-green deployment setup
- Monitoring and alerting configuration (alerts for errors, performance)
- Smoke tests in production
- Rollback procedure testing

**Deliverables**:
- REQ-DEPLOY-001: Deployment Workflow
- REQ-DEPLOY-003: Rollback Procedure

**Done When**:
- [ ] Application deployed to production
- [ ] Smoke tests pass (registration, login, chat, quest)
- [ ] Monitoring shows all services healthy
- [ ] Alerts configured and tested
- [ ] Rollback procedure works

**Blocks**: Beta launch

**Critical Path Dependency**: Final step before users can access

---

#### Workstream 3.2AG: Beta Launch (All Agents + Product Manager)
**Dependencies**: Requires 3.2AF (Production Deployment)
**What**: Launch with beta testers
**Work**:
- Recruit 50-100 beta testers
- Create feedback collection system (surveys, interviews)
- Monitor metrics dashboard (DAU, quest completion, retention)
- Rapid bug fix process
- Weekly user interviews
- Iterate based on feedback

**Done When**:
- [ ] 50+ beta users registered and onboarded
- [ ] Collecting daily feedback
- [ ] No critical bugs reported
- [ ] Users completing quests regularly
- [ ] Retention metrics tracked

**Blocks**: Public launch (need validation first)

---

## Post-MVP: Phase 4 - Community Features (P1)

**Objective**: Add social features to boost retention

**Dependencies**: Requires MVP launched and validated (Phase 3 complete)

### Batch 4.1: Social Foundation (3 parallel workstreams)

#### Workstream 4.1AH: Friend System Backend (Backend Lead)
**Dependencies**: Requires MVP database operational
**What**: Friend connections and management
**Work**:
- Friend request APIs (send, accept, decline)
- Friends list management
- Privacy controls (what friends can see)
- Block user functionality
- Friend notifications

**Deliverables**:
- REQ-COMMUNITY-001: Friend System
- REQ-COMMUNITY-002: Friend Privacy

**Done When**:
- [ ] Users can send/accept friend requests
- [ ] Friends list is viewable
- [ ] Users can control what friends see
- [ ] Block functionality works

**Blocks**: Group quests, mentorship

---

#### Workstream 4.1AI: Matrix Server Integration (Data Engineer)
**Dependencies**: None (external service)
**What**: Chat server setup and integration
**Work**:
- Set up Matrix Synapse server (or use hosted)
- Matrix user account creation on LightPath registration
- Room creation and joining APIs
- Message sending integration
- Chat history persistence
- Basic moderation tools

**Deliverables**:
- REQ-COMMUNITY-003: Matrix Integration

**Done When**:
- [ ] Matrix server operational
- [ ] Users get Matrix account automatically
- [ ] Users can join public rooms
- [ ] Users can send messages
- [ ] Chat history persists

**Blocks**: Chat room features

---

#### Workstream 4.1AJ: Social UI (Frontend Lead)
**Dependencies**: Requires 4.1AH (Friend APIs), 4.1AI (Matrix APIs)
**What**: User interface for social features
**Work**:
- Friends list interface
- Friend request notifications
- Chat room browser
- Matrix chat UI (message bubbles, send message)
- Direct messaging interface

**Done When**:
- [ ] User can add friends via UI
- [ ] User sees friend requests
- [ ] User can browse and join chat rooms
- [ ] Chat interface works (send/receive messages)

**Blocks**: Nothing (but users need UI to use social features)

---

### Batch 4.2: Enhanced Tracking (2 parallel workstreams)

#### Workstream 4.2AK: Metric Logging Backend (Data Engineer)
**Dependencies**: Requires MVP database operational
**What**: Physical metrics tracking
**Work**:
- Metric types (1RM, BMI, weight, custom)
- Metric logging API
- Metric history storage
- Time-series queries for graphs
- Goal setting for metrics

**Deliverables**:
- REQ-PROGRESS-001: Metric Logging

**Done When**:
- [ ] User can log metrics via API
- [ ] Metric history is queryable
- [ ] Support for custom user metrics
- [ ] Can set goals for metrics

**Blocks**: Metric UI

---

#### Workstream 4.2AL: Streak Tracking Backend (Backend Lead)
**Dependencies**: Requires quest system operational
**What**: Daily/weekly streaks
**Work**:
- Daily login streak calculation
- Quest completion streak
- Exercise streak tracking
- Streak milestones and rewards (bonus XP)
- Streak freeze items (unlock at higher levels)

**Deliverables**:
- REQ-PROGRESS-005: Streak Tracking

**Done When**:
- [ ] Streaks calculate correctly
- [ ] Breaking streak handled gracefully
- [ ] Streak milestones award bonus XP
- [ ] Streak freeze items work

**Blocks**: Dashboard (to display streaks)

---

### Batch 4.3: History & Filtering (2 parallel workstreams)

#### Workstream 4.3AM: Quest History Backend (Data Engineer)
**Dependencies**: Requires quest system operational
**What**: Advanced quest history
**Work**:
- Quest history API with filtering (type, date, status)
- Sort options
- Export functionality (CSV/JSON)
- Quest analytics (completion rates by type)

**Deliverables**:
- REQ-QUEST-007: Quest History

**Done When**:
- [ ] Quest history API returns filtered results
- [ ] User can export quest history
- [ ] Analytics data available

**Blocks**: Quest history UI

---

#### Workstream 4.3AN: Quest History UI (Frontend Lead)
**Dependencies**: Requires 4.3AM (Quest History APIs)
**What**: User interface for quest history
**Work**:
- Quest history page
- Filter controls (type, date range)
- Sort options
- Export button
- Quest detail modal

**Done When**:
- [ ] User can view complete quest history
- [ ] Filters work correctly
- [ ] Export downloads file

**Blocks**: Nothing

---

## Post-MVP: Phase 5 - Content Variety (P2)

**Objective**: Prevent user boredom through variety

**Dependencies**: Requires Phase 4 complete

### Batch 5.1: Quest Expansion (3 parallel workstreams)

#### Workstream 5.1AO: Life Skills Quests (Backend Lead)
**Dependencies**: Requires quest system operational
**What**: Cooking, gardening, nutrition quests
**Work**:
- Life skills quest templates (20+ quests)
- Recipe/instruction content
- Season-aware suggestions
- Integration with quest assignment algorithm

**Deliverables**:
- REQ-QUEST-004: Life Skills Quest Types

**Done When**:
- [ ] 20+ life skills quests available
- [ ] Recipes include clear instructions
- [ ] Quests assigned appropriately to interested users

**Blocks**: Nothing

---

#### Workstream 5.1AP: Quest Adaptation (AI Specialist)
**Dependencies**: Requires AI tutor operational, quest system operational
**What**: Adaptive quest system based on user feedback
**Work**:
- Boredom detection in chat (sentiment analysis)
- Quest type switching logic
- User preference tracking in memory
- Alternative quest suggestions
- Preference persistence

**Deliverables**:
- REQ-QUEST-006: Quest Adaptation

**Done When**:
- [ ] System detects when user is bored
- [ ] Tutor suggests alternative quest types
- [ ] User preferences update quest assignment
- [ ] System avoids recently-boring quest types

**Blocks**: Nothing

---

#### Workstream 5.1AQ: Avatar Customization (Full-Stack Developer)
**Dependencies**: Requires avatar system operational, level system operational
**What**: Unlockable avatar items
**Work**:
- Customization item library (clothing, accessories, backgrounds)
- Unlock system (level-based thresholds)
- Preview functionality
- Apply customization API
- Item rendering

**Deliverables**:
- REQ-AVATAR-004: Avatar Customization
- REQ-GAME-005: Unlockable Customizations

**Done When**:
- [ ] 25+ customization items exist
- [ ] Items unlock at specific levels
- [ ] User can preview before applying
- [ ] Applied customizations persist

**Blocks**: Customization UI

---

### Batch 5.2: Gamification Depth (3 parallel workstreams)

#### Workstream 5.2AR: Achievement System (Backend Lead)
**Dependencies**: Requires gamification engine operational
**What**: Achievements for milestones
**Work**:
- Achievement definitions (30+ achievements)
- Achievement unlock tracking
- Achievement notification triggers
- Badge/icon system
- Achievement display in profile

**Deliverables**:
- REQ-GAME-006: Achievement System

**Done When**:
- [ ] 30+ achievements defined
- [ ] Achievements unlock correctly
- [ ] User receives notification on unlock
- [ ] Achievements visible in profile

**Blocks**: Achievement UI

---

#### Workstream 5.2AS: Celebration Events (Frontend Lead)
**Dependencies**: Requires achievement system, level system operational
**What**: Visual celebrations for milestones
**Work**:
- Level-up animations
- Achievement unlock celebrations
- Milestone celebrations (stat thresholds)
- Personalized messages from tutor
- Celebration history view

**Deliverables**:
- REQ-GAME-007: Celebration Events

**Done When**:
- [ ] Level-up triggers celebration
- [ ] Achievement unlock shows animation
- [ ] User can dismiss celebrations
- [ ] Celebrations feel rewarding

**Blocks**: Nothing (enhances UX)

---

#### Workstream 5.2AT: Customization UI (Frontend Lead)
**Dependencies**: Requires 5.1AQ (Customization APIs)
**What**: Avatar customization interface
**Work**:
- Customization shop interface
- Item preview system
- Avatar editor
- Unlock notifications
- Collection showcase

**Done When**:
- [ ] User can browse available items
- [ ] User can preview items on avatar
- [ ] User can apply customizations
- [ ] Collection shows locked/unlocked items

**Blocks**: Nothing

---

## Post-MVP: Phase 6 - Advanced Social (P3)

**Objective**: Build mature community features

**Dependencies**: Requires Phase 5 complete, friend system mature

### Batch 6.1: Collaborative Features (2 parallel workstreams)

#### Workstream 6.1AU: Group Quests Backend (Backend Lead + Data Engineer)
**Dependencies**: Requires friend system, quest system, Matrix chat operational
**What**: Multi-user collaborative quests
**Work**:
- Group quest creation API
- Invitation system
- Progress aggregation (all participants must complete)
- Completion coordination
- Group dashboard data
- Reward distribution
- Time limits

**Deliverables**:
- REQ-QUEST-008: Group Quests

**Done When**:
- [ ] User can create group quest and invite friends
- [ ] Invitations work correctly
- [ ] Progress tracked for all participants
- [ ] All participants receive rewards on completion
- [ ] Time limits enforced

**Blocks**: Group quest UI

---

#### Workstream 6.1AV: Group Quest UI (Frontend Lead)
**Dependencies**: Requires 6.1AU (Group Quest APIs)
**What**: User interface for group quests
**Work**:
- Group quest creation wizard
- Friend invitation interface
- Group progress dashboard
- Participant list
- Group chat integration

**Done When**:
- [ ] User can create group quest via UI
- [ ] User can invite friends
- [ ] Progress dashboard shows all participants
- [ ] Chat integration works

**Blocks**: Nothing

---

### Batch 6.2: Mentorship & Competition (3 parallel workstreams)

#### Workstream 6.2AW: Mentorship System (Backend Lead)
**Dependencies**: Requires friend system, level 20+ users
**What**: Experienced users mentoring newcomers
**Work**:
- Mentor opt-in functionality
- Mentorship matching algorithm (shared interests/languages)
- Relationship management
- Mentor recognition system (badges, bonus XP)
- Progress tracking for mentees
- Maximum 5 mentees per mentor

**Deliverables**:
- REQ-COMMUNITY-005: Mentorship System

**Done When**:
- [ ] Level 20+ users can opt-in as mentors
- [ ] System suggests mentors to new users
- [ ] Mentorship relationships tracked
- [ ] Mentors receive recognition

**Blocks**: Mentorship UI

---

#### Workstream 6.2AX: Leaderboards (Data Engineer)
**Dependencies**: Requires stats system, privacy controls operational
**What**: Optional competitive leaderboards
**Work**:
- Leaderboard data APIs (XP, level, stats)
- Opt-in/opt-out controls
- Filtering (global, friends, language)
- Anti-cheating measures (detect suspicious activity)
- Daily/weekly/monthly views
- Leaderboard caching

**Deliverables**:
- REQ-COMMUNITY-006: Leaderboards

**Done When**:
- [ ] Leaderboards display top users
- [ ] Opt-out works (user not shown)
- [ ] Filtering works correctly
- [ ] Updates daily
- [ ] Suspicious activity flagged

**Blocks**: Leaderboard UI

---

#### Workstream 6.2AY: Advanced Social UI (Frontend Lead)
**Dependencies**: Requires 6.2AW (Mentorship APIs), 6.2AX (Leaderboard APIs)
**What**: UI for mentorship and leaderboards
**Work**:
- Mentorship dashboard
- Leaderboard interface
- Mentor profile badges
- Recognition system UI
- Opt-in/opt-out controls

**Done When**:
- [ ] Users can view and interact with mentorship features
- [ ] Leaderboards display correctly
- [ ] Opt-out controls work

**Blocks**: Nothing

---

## Completion Criteria by Phase

### Phase 0 Complete When:
- [ ] Infrastructure operational (database, Redis, storage accessible)
- [ ] CI/CD pipeline deploys to staging automatically
- [ ] Backend and frontend boilerplate projects render
- [ ] Database schema deployed with all tables
- [ ] Authentication works (register, login, session)
- [ ] LLM API tested and integrated
- [ ] Design system documented with base components

### Phase 1 Complete When:
- [ ] User can register, verify email, and log in
- [ ] User can complete onboarding interview
- [ ] User can generate or upload avatar
- [ ] User can receive and complete quests
- [ ] Quest completion awards XP and increases stats
- [ ] User can level up
- [ ] User can chat with AI tutor
- [ ] Tutor uses persistent memory
- [ ] Dashboard displays all user data
- [ ] Progress graphs functional

### Phase 2 Complete When:
- [ ] All features integrated end-to-end (full user flow works)
- [ ] Page loads <2s, API responses <500ms, AI responses <5s
- [ ] 80%+ unit test coverage
- [ ] WCAG 2.1 AA compliance verified
- [ ] Responsive on mobile/tablet/desktop
- [ ] Works on Chrome, Firefox, Safari, Edge
- [ ] GDPR compliance verified (export, delete work)
- [ ] Security audit passed (no critical issues)
- [ ] Daily backups configured and tested
- [ ] 5 languages fully translated

### Phase 3 Complete When:
- [ ] Load testing passed (10k concurrent users)
- [ ] All automated tests passing
- [ ] Documentation complete
- [ ] Production deployment successful
- [ ] Smoke tests passed in production
- [ ] 50+ beta users recruited and onboarded
- [ ] Monitoring and alerting active
- [ ] Rollback procedure tested

### Phase 4 Complete When:
- [ ] Matrix chat functional
- [ ] Friend system working
- [ ] Users can log metrics
- [ ] Streaks tracked correctly
- [ ] Quest history filterable and exportable

### Phase 5 Complete When:
- [ ] Life skills quests available
- [ ] Quest adaptation detects boredom and switches
- [ ] Avatar customizations unlockable
- [ ] Achievements system working
- [ ] Celebration events trigger correctly

### Phase 6 Complete When:
- [ ] Group quests functional
- [ ] Mentorship system active
- [ ] Leaderboards operational with privacy controls

---

## Work Package Summary

### Foundation Packages (Phase 0)
**8 work packages, 4 in parallel, then 4 more in parallel**
- 0.1A: Infrastructure (Full-Stack) → Blocks: All DB work
- 0.1B: CI/CD (Full-Stack) → Blocks: Nothing
- 0.1C: Backend Foundation (Backend Lead) → Blocks: All backend APIs
- 0.1D: Frontend Foundation (Frontend Lead) → Blocks: All frontend UI
- 0.2E: Database Schema (Data Engineer) → **CRITICAL PATH** → Blocks: All backend features
- 0.2F: Authentication (Backend Lead) → **CRITICAL PATH** → Blocks: All user features
- 0.2G: LLM Integration (AI Specialist) → **CRITICAL PATH** → Blocks: AI features
- 0.2H: Design System (Frontend Lead) → Blocks: All UI pages

### Core MVP Packages (Phase 1)
**14 work packages, maximum 5 in parallel**
- 1.1I: Onboarding Backend (Backend Lead) → Blocks: Avatar, Quest assignment
- 1.1P: Onboarding Frontend (Frontend Lead) → Blocks: User access
- 1.2J: Quest System (Data Engineer) → **CRITICAL PATH** → Blocks: Gamification
- 1.2K: Gamification Engine (Backend Lead) → **CRITICAL PATH** → Blocks: Dashboard
- 1.2L: AI Tutor Chat (AI Specialist) → **CRITICAL PATH** → Blocks: AI Feedback
- 1.2M: Avatar System (Full-Stack) → Blocks: Nothing critical
- 1.2N: Dashboard UI (Frontend Lead) → Blocks: Nothing
- 1.3O: Chat UI (Frontend Lead) → Blocks: Nothing
- 1.3Q: Progress APIs (Data Engineer) → Blocks: Progress UI
- 1.3R: AI Feedback (AI Specialist) → Blocks: Nothing
- 1.3S: Progress UI (Frontend Lead) → Blocks: Nothing
- 1.4T: Quest UI (Frontend Lead) → Blocks: Nothing

### Integration & Quality Packages (Phase 2)
**7 work packages, 3 in parallel, then 4 in parallel**
- 2.1U: Integration (Full-Stack) → **CRITICAL PATH** → Blocks: All Phase 2 work
- 2.1V: Performance (Backend + Data) → Blocks: Nothing
- 2.1W: UI Polish (Frontend) → Blocks: Nothing
- 2.2X: Backup (Data Engineer) → Blocks: Nothing
- 2.2Y: GDPR (Backend + Data) → Blocks: Nothing
- 2.2Z: Security (Full-Stack) → Blocks: Production launch
- 2.2AA: i18n (Frontend) → Blocks: Nothing

### Testing & Launch Packages (Phase 3)
**5 work packages, 3 in parallel, then 2 sequential**
- 3.1AB: Automated Testing (QA) → Blocks: Production launch
- 3.1AC: Load Testing (Full-Stack) → Blocks: Production launch
- 3.1AD: Security Audit (Full-Stack) → Blocks: Production launch
- 3.2AE: Documentation (All) → Blocks: Nothing
- 3.2AF: Production Deployment (Full-Stack) → **CRITICAL PATH** → Blocks: Beta launch
- 3.2AG: Beta Launch (All) → Blocks: Public launch

### Post-MVP Packages (Phases 4-6)
**Phase 4 (P1): 7 work packages**
**Phase 5 (P2): 6 work packages**
**Phase 6 (P3): 5 work packages**

---

## Parallelization Opportunities

### Maximum Concurrent Workstreams by Phase

**Phase 0:**
- Batch 0.1: **4 parallel** (Infrastructure, CI/CD, Backend Foundation, Frontend Foundation)
- Batch 0.2: **4 parallel** (Database, Auth, LLM, Design System)
- **Total Phase 0: 8 work packages**

**Phase 1:**
- Batch 1.1: **2 sequential** (Backend → Frontend)
- Batch 1.2: **5 parallel** (Quest System, Gamification, AI Chat, Avatar, Dashboard)
- Batch 1.3: **4 parallel** (Chat UI, Progress APIs, AI Feedback, Progress UI)
- Batch 1.4: **2 parallel** (Quest UI)
- **Total Phase 1: 14 work packages**

**Phase 2:**
- Batch 2.1: **3 parallel** after integration (Performance, UI Polish, after Integration completes)
- Batch 2.2: **4 parallel** (Backup, GDPR, Security, i18n)
- **Total Phase 2: 8 work packages** (7 + Integration)

**Phase 3:**
- Batch 3.1: **3 parallel** (Testing, Load Testing, Security Audit)
- Batch 3.2: **3 sequential** (Documentation → Deployment → Beta)
- **Total Phase 3: 6 work packages**

**Maximum concurrent agents at peak (Phase 1, Batch 1.2): 5 agents working simultaneously**

---

## Agent Assignment Summary

### Backend Lead
- Authentication (0.2F)
- Onboarding Backend (1.1I)
- Gamification Engine (1.2K) **[Critical Path]**
- Performance Optimization (2.1V)
- GDPR Implementation (2.2Y)
- Friend System (4.1AH)
- Streak Tracking (4.2AL)
- Life Skills Quests (5.1AO)
- Achievement System (5.2AR)
- Group Quests (6.1AU)
- Mentorship System (6.2AW)

### Data Engineer
- Database Schema (0.2E) **[Critical Path]**
- Quest System (1.2J) **[Critical Path]**
- Progress APIs (1.3Q)
- Performance Optimization (2.1V)
- GDPR Implementation (2.2Y)
- Data Backup (2.2X)
- Matrix Integration (4.1AI)
- Metric Logging (4.2AK)
- Quest History (4.3AM)
- Group Quests (6.1AU)
- Leaderboards (6.2AX)

### AI Specialist
- LLM Integration (0.2G) **[Critical Path]**
- AI Tutor Chat (1.2L) **[Critical Path]**
- AI Feedback (1.3R)
- Quest Adaptation (5.1AP)

### Frontend Lead
- Frontend Foundation (0.1D)
- Design System (0.2H)
- Onboarding UI (1.1P)
- Dashboard (1.2N)
- Chat UI (1.3O)
- Progress Visualization (1.3S)
- Quest UI (1.4T)
- UI Polish (2.1W)
- Internationalization (2.2AA)
- Social UI (4.1AJ)
- Quest History UI (4.3AN)
- Celebration Events (5.2AS)
- Customization UI (5.2AT)
- Group Quest UI (6.1AV)
- Advanced Social UI (6.2AY)

### Full-Stack Developer
- Infrastructure (0.1A) **[Critical Path]**
- CI/CD (0.1B)
- Avatar System (1.2M)
- Integration (2.1U) **[Critical Path]**
- Security Hardening (2.2Z)
- Load Testing (3.1AC)
- Security Audit (3.1AD)
- Production Deployment (3.2AF) **[Critical Path]**
- Avatar Customization (5.1AQ)

### QA Engineer
- Test Automation Framework (0.1B timeframe)
- Continuous Testing (throughout Phase 1-2)
- Automated Testing (3.1AB)
- Beta Testing Coordination (3.2AG)

---

## Critical Path Visualization

```
[Infrastructure] → [Database Schema] → [Authentication] →
   ↓
[Onboarding Backend] → [Quest System] → [Gamification] →
   ↓
[Dashboard] → [Integration] → [Testing] → [Deployment] → [LAUNCH]

Parallel to Critical Path:
- LLM Integration → AI Tutor → AI Feedback
- Frontend Foundation → Design System → All UI Components
- Avatar System
- Progress Tracking
```

**Critical Path Total: 8 major sequential dependencies**

Everything else can work in parallel with the critical path or depends on specific milestones.

---

## Dependencies Matrix

| Work Package | Depends On | Blocks |
|--------------|-----------|--------|
| 0.1A: Infrastructure | None | 0.2E (Database) |
| 0.1B: CI/CD | None | Nothing critical |
| 0.1C: Backend Foundation | None | All backend APIs |
| 0.1D: Frontend Foundation | None | All frontend UI |
| 0.2E: Database Schema | 0.1A | **ALL BACKEND** |
| 0.2F: Authentication | 0.2E | **ALL USER FEATURES** |
| 0.2G: LLM Integration | None | AI Tutor, Onboarding, AI Feedback |
| 0.2H: Design System | 0.1D | All UI pages |
| 1.1I: Onboarding Backend | 0.2F, 0.2G | Avatar, Quest Assignment |
| 1.1P: Onboarding Frontend | 1.1I, 0.2H | User access |
| 1.2J: Quest System | 0.2E, 1.1I | Gamification, Dashboard |
| 1.2K: Gamification | 1.2J | Dashboard, Progress |
| 1.2L: AI Tutor | 0.2G, 0.2F | AI Feedback |
| 1.2M: Avatar | 1.1I, 0.1A | Nothing critical |
| 1.2N: Dashboard | 0.2H, 1.2K, 1.2J | Nothing |
| 1.3O: Chat UI | 1.2L, 0.2H | Nothing |
| 1.3Q: Progress APIs | 1.2K | Progress UI |
| 1.3R: AI Feedback | 1.2L, 1.2K | Nothing |
| 1.3S: Progress UI | 1.3Q, 0.2H | Nothing |
| 1.4T: Quest UI | 1.2J, 0.2H | Nothing |
| 2.1U: Integration | ALL Phase 1 | **ALL Phase 2** |
| 2.1V: Performance | 2.1U | Nothing |
| 2.1W: UI Polish | 2.1U | Nothing |
| 2.2X: Backup | 0.2E | Nothing |
| 2.2Y: GDPR | All data storage | Nothing |
| 2.2Z: Security | 2.1U | Production launch |
| 2.2AA: i18n | All UI | Nothing |
| 3.1AB: Testing | All features | Production launch |
| 3.1AC: Load Test | 2.1V | Production launch |
| 3.1AD: Security Audit | 2.2Z | Production launch |
| 3.2AE: Documentation | All finalized | Nothing |
| 3.2AF: Deployment | ALL testing | Beta launch |
| 3.2AG: Beta | 3.2AF | Public launch |

---

## How to Use This Roadmap

### For Project Managers
1. **Track phase completion**: Use completion criteria to determine when to move to next phase
2. **Identify blockers**: Check dependencies before assigning work
3. **Maximize parallelization**: Assign work packages with no dependencies to multiple agents simultaneously
4. **Monitor critical path**: Ensure critical path work packages are prioritized (marked with **[Critical Path]**)

### For Development Agents
1. **Check dependencies**: Before starting, ensure all dependent work packages are complete
2. **Review "Done When"**: Use completion criteria as your definition of done
3. **Communicate blockers**: If your work is on the critical path, communicate progress/blockers immediately
4. **Look for parallel work**: If blocked, check for other work packages you could start

### For Coordination
1. **Phase 0**: Get 4 agents working immediately (Infrastructure, CI/CD, Backend, Frontend)
2. **Phase 1 peak**: Maximum 5 agents working simultaneously (Quest System, Gamification, AI Chat, Avatar, Dashboard)
3. **Integration phase**: Full-stack developer focuses solely on integration while others do polish work
4. **Testing phase**: All agents contribute to testing and documentation

---

## Success Metrics

### Phase Completion Velocity
- **Phase 0**: Track when all 8 foundation work packages complete
- **Phase 1**: Track when all 14 MVP work packages complete
- **Phase 2**: Track when integration + 7 quality packages complete
- **Phase 3**: Track when all testing complete and production deployed

### Parallel Work Efficiency
- **Target**: Maintain 3-5 parallel workstreams throughout Phase 1
- **Measure**: Number of work packages in progress simultaneously
- **Optimize**: If agents are blocked, redistribute to non-blocked packages

### Blocker Resolution
- **Track**: How long work packages are blocked waiting for dependencies
- **Goal**: Resolve critical path blockers within 1 sprint
- **Mitigation**: Have backup work ready for agents when blocked

### Quality Gates
- Each phase must meet completion criteria before moving forward
- No skipping quality work to speed up (technical debt = slower later)
- Security and GDPR are non-negotiable for production

---

**END OF ROADMAP**

*This roadmap is a living document. Update as work completes and new dependencies are discovered.*
