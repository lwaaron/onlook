// Mock authentication service for development
export const mockUser = {
    id: 'mock-user-123',
    email: 'developer@onlook.dev',
    user_metadata: {
        name: 'Onlook Developer',
        avatar_url: 'https://avatars.githubusercontent.com/u/1?v=4',
    },
    app_metadata: {},
    aud: 'authenticated',
    created_at: new Date().toISOString(),
};

export const mockSession = {
    access_token: 'mock-access-token',
    token_type: 'bearer',
    expires_in: 3600,
    refresh_token: 'mock-refresh-token',
    user: mockUser,
};

// Check if we're in mock mode
const isMockMode = typeof window !== 'undefined' 
    ? window.location.hostname === 'localhost' 
    : true; // Server-side always returns mock in dev

export const mockAuth = {
    getUser: async () => {
        if (isMockMode) {
            return { data: { user: mockUser }, error: null };
        }
        return { data: { user: null }, error: new Error('Not authenticated') };
    },
    
    getSession: async () => {
        if (isMockMode) {
            return { data: { session: mockSession }, error: null };
        }
        return { data: { session: null }, error: null };
    },
    
    signInWithOAuth: async (options: any) => {
        if (isMockMode) {
            // Simulate OAuth redirect
            console.log('Mock OAuth sign-in with:', options);
            return { 
                data: { url: '/auth/callback?code=mock-code', provider: options.provider },
                error: null 
            };
        }
        return { data: null, error: new Error('OAuth not configured') };
    },
    
    signOut: async () => {
        console.log('Mock sign out');
        return { error: null };
    },
    
    onAuthStateChange: (callback: (event: string, session: any) => void) => {
        // Simulate auth state change
        if (isMockMode) {
            setTimeout(() => {
                callback('SIGNED_IN', mockSession);
            }, 100);
        }
        
        return {
            data: { subscription: { unsubscribe: () => {} } },
        };
    },
};