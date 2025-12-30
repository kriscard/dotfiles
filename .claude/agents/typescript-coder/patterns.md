# TypeScript Patterns Reference

Modern TypeScript patterns that embody the "inevitable code" philosophy.

## React Patterns

### Function Components

```tsx
// Inevitable: Simple props, inferred return type
type UserCardProps = {
  user: User;
  onEdit?: () => void;
};

function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div>
      <h3>{user.name}</h3>
      {onEdit && <button onClick={onEdit}>Edit</button>}
    </div>
  );
}

// Avoid: React.FC is unnecessary ceremony
const UserCard: React.FC<UserCardProps> = ({ user }) => { ... }
```

### Hooks

```tsx
// useState: Let TypeScript infer when possible
const [count, setCount] = useState(0);

// Explicit type only when needed (nullable, complex types)
const [user, setUser] = useState<User | null>(null);

// useRef: DOM refs use null initial value
const inputRef = useRef<HTMLInputElement>(null);

// useRef: Mutable refs include in generic
const intervalRef = useRef<number | undefined>(undefined);
```

### Event Handlers

```tsx
// Inline: TypeScript infers automatically
<input onChange={(e) => setName(e.target.value)} />

// Extracted: Use the handler type
const handleChange: React.ChangeEventHandler<HTMLInputElement> = (e) => {
  setName(e.target.value);
};

// Form submission
const handleSubmit: React.FormEventHandler<HTMLFormElement> = (e) => {
  e.preventDefault();
  // ...
};
```

### Extending Native Elements

```tsx
// Button with custom props + native button attributes
type ButtonProps = {
  variant?: 'primary' | 'secondary';
  isLoading?: boolean;
} & React.ButtonHTMLAttributes<HTMLButtonElement>;

function Button({ variant = 'primary', isLoading, children, ...rest }: ButtonProps) {
  return (
    <button className={variant} disabled={isLoading} {...rest}>
      {isLoading ? 'Loading...' : children}
    </button>
  );
}
```

### Context with Type Safety

```tsx
// Create context with undefined default
const UserContext = createContext<User | undefined>(undefined);

// Custom hook that throws if missing
function useUser() {
  const user = useContext(UserContext);
  if (!user) {
    throw new Error('useUser must be used within UserProvider');
  }
  return user; // TypeScript knows this is User, not User | undefined
}
```

### Extract Component Props

```tsx
// Get props from existing component
type ButtonProps = React.ComponentProps<typeof Button>;

// Get props from native element
type InputProps = React.ComponentProps<'input'>;

// Omit specific props
type CustomInputProps = Omit<React.ComponentProps<'input'>, 'onChange'> & {
  onChange: (value: string) => void;
};
```

## General TypeScript Patterns

### Discriminated Unions

```tsx
// State machines with type safety
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function UserProfile({ state }: { state: RequestState<User> }) {
  switch (state.status) {
    case 'idle':
      return <p>Ready to load</p>;
    case 'loading':
      return <Spinner />;
    case 'success':
      return <UserCard user={state.data} />; // TypeScript knows data exists
    case 'error':
      return <ErrorMessage error={state.error} />;
  }
}
```

### Type Guards

```tsx
// Custom type guard
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value
  );
}

// Usage
const data: unknown = await fetchData();
if (isUser(data)) {
  console.log(data.name); // TypeScript knows it's User
}
```

### Assertion Functions

```tsx
// Assert and narrow in one step
function assertIsUser(value: unknown): asserts value is User {
  if (!value || typeof value !== 'object' || !('name' in value)) {
    throw new Error('Invalid user');
  }
}

// Usage
const data: unknown = await fetchData();
assertIsUser(data);
console.log(data.name); // TypeScript knows it's User after assertion
```

### Satisfies Operator

```tsx
// Validate type while preserving literal types
const routes = {
  home: '/',
  users: '/users',
  user: '/users/:id',
} satisfies Record<string, string>;

// routes.home is typed as '/' not string
type HomeRoute = typeof routes.home; // '/'
```

### Const Assertions

```tsx
// Preserve literal types
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;

// config.apiUrl is 'https://api.example.com', not string
// config.timeout is 5000, not number
```

### Template Literal Types

```tsx
// Type-safe route patterns
type Route = `/${string}`;
type ApiRoute = `/api/${string}`;

// Event names
type EventName = `on${Capitalize<string>}`;

// CSS units
type CSSUnit = `${number}${'px' | 'rem' | 'em' | '%'}`;
```

### Utility Types

```tsx
// Partial: Make all properties optional
type UpdateUser = Partial<User>;

// Required: Make all properties required
type CompleteUser = Required<User>;

// Pick: Select specific properties
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit: Exclude specific properties
type CreateUser = Omit<User, 'id' | 'createdAt'>;

// Record: Type for object maps
type UserMap = Record<string, User>;

// Extract/Exclude: Filter union types
type StringOrNumber = string | number | boolean;
type OnlyStrNum = Extract<StringOrNumber, string | number>; // string | number
```

## API & Data Fetching

### Typed Fetch Wrapper

```tsx
async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
  return response.json();
}

// Usage
const user = await fetchJson<User>('/api/users/1');
```

### API Response Types

```tsx
// Define once, use everywhere
type ApiResponse<T> = {
  data: T;
  meta: {
    timestamp: string;
    requestId: string;
  };
};

// Specific responses
type UserResponse = ApiResponse<User>;
type UsersResponse = ApiResponse<User[]>;
```

## Error Handling

### Error Types

```tsx
// Custom error with type discrimination
class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public code: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

// Type guard for errors
function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError;
}

// Usage
try {
  await fetchUser(id);
} catch (error) {
  if (isApiError(error)) {
    console.log(error.statusCode, error.code);
  }
  throw error;
}
```

## TSConfig Recommendations

```json
{
  "compilerOptions": {
    // Essential strict checks
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,

    // Modern module settings
    "module": "ESNext",
    "moduleResolution": "bundler",
    "verbatimModuleSyntax": true,
    "isolatedModules": true,

    // Output settings
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],

    // Path mapping (optional)
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

## Anti-Patterns to Avoid

| Don't | Do |
|-------|-----|
| `React.FC<Props>` | `function Component(props: Props)` |
| `any` | `unknown` with type guards |
| `as` for unsafe casts | Type guards or assertion functions |
| `!` non-null assertion | Proper null checks or optional chaining |
| Excessive generics | Concrete types until 3+ uses |
| Branded types for IDs | Descriptive function names |
| `defaultProps` | Parameter defaults |
| Complex union returns | Separate focused functions |

## Quick Reference

```tsx
// Props with children
type Props = { title: string; children: React.ReactNode };

// Optional callback
type Props = { onComplete?: () => void };

// Style prop
type Props = { style?: React.CSSProperties };

// Class name prop
type Props = { className?: string };

// Forward ref (pre-React 19)
const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => (
  <input ref={ref} {...props} />
));

// Generic component
function List<T>({ items, renderItem }: {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
}) {
  return <ul>{items.map(renderItem)}</ul>;
}
```
