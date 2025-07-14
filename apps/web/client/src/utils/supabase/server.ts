import { env } from '@/env';
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { mockAuth } from './mock-auth';

export async function createClient() {
    const cookieStore = await cookies();

    // Create a server's supabase client with newly configured cookie,
    // which could be used to maintain user's session
    const supabase = createServerClient(
        env.NEXT_PUBLIC_SUPABASE_URL,
        env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
        {
            cookies: {
                getAll() {
                    return cookieStore.getAll();
                },
                setAll(cookiesToSet) {
                    try {
                        cookiesToSet.forEach(({ name, value, options }) =>
                            cookieStore.set(name, value, options),
                        );
                    } catch {
                        // The `setAll` method was called from a Server Component.
                        // This can be ignored if you have middleware refreshing
                        // user sessions.
                    }
                },
            },
        },
    );

    // Override auth methods with mock in development
    if (env.SKIP_ENV_VALIDATION === 'true') {
        console.log('🔧 Using mock authentication (server)');
        // Override auth object with mock methods
        (supabase as any).auth = {
            ...supabase.auth,
            ...mockAuth,
            admin: {
                getUserById: mockAuth.getUser,
                createUser: async (options: any) => {
                    console.log('Mock create user:', options);
                    return { data: { user: { ...mockAuth.getUser, ...options } }, error: null };
                },
            },
        };
    }

    return supabase;
}
