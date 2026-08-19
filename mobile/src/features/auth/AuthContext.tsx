import { onAuthStateChanged, type User as FirebaseUser } from 'firebase/auth';
import { createContext, useContext, useEffect, useState, type PropsWithChildren } from 'react';
import { auth } from '../../firebase/config';
import { reloadCurrentUser } from './api';

interface AuthContextValue {
  user: FirebaseUser | null;
  isInitializing: boolean;
  isEmailVerified: boolean;
  /** Reloads the Firebase user and syncs context state from it. `user.reload()`
   * does NOT fire onAuthStateChanged, so without this, checking email
   * verification would update Firebase's copy but leave context stale —
   * any auth-gated screen reading isEmailVerified would still see false. */
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue>({
  user: null,
  isInitializing: true,
  isEmailVerified: false,
  refreshUser: async () => {},
});

export function AuthProvider({ children }: PropsWithChildren) {
  const [user, setUser] = useState<FirebaseUser | null>(null);
  const [isInitializing, setIsInitializing] = useState(true);
  const [isEmailVerified, setIsEmailVerified] = useState(false);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (nextUser) => {
      setUser(nextUser);
      setIsEmailVerified(nextUser?.emailVerified ?? false);
      setIsInitializing(false);
    });
    return unsubscribe;
  }, []);

  async function refreshUser() {
    const nextUser = await reloadCurrentUser();
    setUser(nextUser);
    setIsEmailVerified(nextUser?.emailVerified ?? false);
  }

  return (
    <AuthContext.Provider value={{ user, isInitializing, isEmailVerified, refreshUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  return useContext(AuthContext);
}
