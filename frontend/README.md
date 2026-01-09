# LightPath Frontend

React + TypeScript + Vite frontend application for LightPath.

## Tech Stack

- **Framework**: React 18
- **Language**: TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **Data Fetching**: React Query (TanStack Query)
- **Routing**: React Router v7
- **Charts**: Recharts
- **i18n**: react-i18next
- **Testing**: Vitest + React Testing Library

## Directory Structure

```
frontend/
├── src/
│   ├── components/      # Reusable React components
│   │   ├── ui/         # Basic UI components (Button, Input, etc.)
│   │   ├── layout/     # Layout components (Header, Sidebar, etc.)
│   │   └── features/   # Feature-specific components
│   ├── pages/          # Page components (route targets)
│   │   ├── HomePage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── ChatPage.tsx
│   │   ├── QuestsPage.tsx
│   │   └── ProfilePage.tsx
│   ├── hooks/          # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useQuests.ts
│   │   └── useStats.ts
│   ├── services/       # API service layer
│   │   ├── api.ts      # Axios instance
│   │   ├── auth.ts     # Auth API calls
│   │   ├── quests.ts   # Quest API calls
│   │   └── chat.ts     # Chat API calls
│   ├── store/          # Zustand stores
│   │   ├── authStore.ts
│   │   └── uiStore.ts
│   ├── types/          # TypeScript type definitions
│   │   ├── user.ts
│   │   ├── quest.ts
│   │   └── chat.ts
│   ├── utils/          # Helper functions
│   │   ├── formatters.ts
│   │   └── validators.ts
│   ├── assets/         # Static assets (images, fonts)
│   ├── styles/         # Global styles
│   │   └── index.css   # Tailwind imports
│   ├── routes.tsx      # Route configuration
│   ├── App.tsx         # Root component
│   └── main.tsx        # Application entry point
├── public/             # Public static files
├── index.html          # HTML template
├── vite.config.ts      # Vite configuration
├── tailwind.config.js  # Tailwind configuration
├── postcss.config.js   # PostCSS configuration
└── package.json
```

## Getting Started

### Prerequisites

- Node.js 20+
- npm 10+

### Installation

```bash
cd frontend
npm install
```

### Environment Setup

```bash
cp .env.example .env
# Edit .env with your configuration
```

### Development

```bash
# Start development server (with HMR)
npm run dev
# Access at http://localhost:5173
```

The dev server includes:
- Hot Module Replacement (HMR)
- Auto-reload on file changes
- Proxy to backend API at `/api`

### Building

```bash
# Build for production
npm run build
# Output in dist/

# Preview production build locally
npm run preview
```

### Testing

```bash
# Run tests
npm test

# Run tests with UI
npm run test:ui

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

## Application Structure

### Routing

Routes are defined in `src/routes.tsx`:

```typescript
- / - Home/Landing page
- /login - User login
- /register - User registration
- /dashboard - Main dashboard (protected)
- /chat - AI tutor chat (protected)
- /quests - Quest list and history (protected)
- /profile - User profile (protected)
```

Protected routes require authentication. Unauthenticated users are redirected to `/login`.

### State Management

**Zustand** is used for global state:

- `authStore` - User authentication state
- `uiStore` - UI state (modals, notifications, etc.)

**React Query** is used for server state:
- Automatic caching
- Background refetching
- Optimistic updates

### API Integration

API calls are centralized in `src/services/`:

```typescript
// Example: src/services/quests.ts
export const questsApi = {
  getActiveQuests: () => api.get('/quests'),
  completeQuest: (id: string) => api.post(`/quests/${id}/complete`),
  getQuestHistory: () => api.get('/quests/history')
};
```

### Styling

**Tailwind CSS** is used for styling with custom configuration:

- Custom color palette (primary, magic)
- Custom fonts
- Responsive breakpoints
- Utility-first approach

### Internationalization

**react-i18next** for multi-language support:

- English, Spanish, French, German, Mandarin Chinese
- Language selection stored in user profile
- Dynamic language switching without reload

## Component Guidelines

### Component Structure

```typescript
// Good component structure
interface Props {
  // Props interface
}

function ComponentName({ prop1, prop2 }: Props) {
  // Hooks
  const [state, setState] = useState();

  // Handlers
  const handleClick = () => {};

  // Render
  return <div>...</div>;
}

export default ComponentName;
```

### Naming Conventions

- Components: PascalCase (`UserProfile.tsx`)
- Hooks: camelCase with `use` prefix (`useAuth.ts`)
- Utilities: camelCase (`formatDate.ts`)
- Types: PascalCase (`User.ts`)

## Environment Variables

All environment variables must be prefixed with `VITE_`:

```
VITE_API_URL=http://localhost:3000/api/v1
VITE_APP_NAME=LightPath
VITE_ENABLE_AVATAR_GENERATION=true
```

Access in code:
```typescript
const apiUrl = import.meta.env.VITE_API_URL;
```

## Performance Optimization

- Code splitting with dynamic imports
- Lazy loading for routes
- Image optimization
- Bundle size optimization
- React Query caching
- CDN for assets in production

## Accessibility

- WCAG 2.1 AA compliance target
- Keyboard navigation
- Screen reader support
- ARIA labels on interactive elements
- Color contrast ratios met
- Focus indicators

## Browser Support

- Chrome (last 2 versions)
- Firefox (last 2 versions)
- Safari (last 2 versions)
- Edge (last 2 versions)

## Next Steps

1. Create design system components (Button, Input, Card, etc.)
2. Implement authentication flow (Login, Register)
3. Build dashboard layout and components
4. Implement chat interface
5. Create quest components
6. Add progress visualization (charts, graphs)
7. Implement avatar system
8. Add internationalization
9. Write comprehensive tests

## Resources

- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [Tailwind CSS Documentation](https://tailwindcss.com/)
- [React Query Documentation](https://tanstack.com/query/latest)
- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
