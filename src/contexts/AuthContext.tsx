import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { mockUsers } from '@/data/mockUsers';
import { mockRoles } from '@/data/mockRoles';
import { User } from '@/types/user';
import { Role } from '@/types/role';

interface AuthContextType {
  user: User | null;
  role: Role | null;
  login: (email: string, password: string) => Promise<{ error?: string }>;
  signup: (email: string, password: string, name: string, roleId: string) => Promise<{ error?: string }>;
  logout: () => void;
  resetPassword: (email: string) => Promise<{ error?: string }>;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<Role | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const storedUser = localStorage.getItem('auth_user');
    if (storedUser) {
      const userData = JSON.parse(storedUser);
      setUser(userData);
      const userRole = mockRoles.find(r => r.roleType === userData.role);
      setRole(userRole || null);
    }
    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    const foundUser = mockUsers.find(u => u.email === email);
    
    if (!foundUser) {
      return { error: 'Invalid email or password' };
    }

    if (foundUser.status === 'inactive') {
      return { error: 'Account is inactive. Please contact administrator.' };
    }

    const updatedUser = { ...foundUser, lastLogin: new Date().toISOString() };
    setUser(updatedUser);
    localStorage.setItem('auth_user', JSON.stringify(updatedUser));
    
    const userRole = mockRoles.find(r => r.roleType === updatedUser.role);
    setRole(userRole || null);

    return {};
  };

  const signup = async (email: string, password: string, name: string, roleId: string) => {
    const existingUser = mockUsers.find(u => u.email === email);
    
    if (existingUser) {
      return { error: 'An account with this email already exists' };
    }

    const selectedRole = mockRoles.find(r => r.id === roleId);
    if (!selectedRole) {
      return { error: 'Invalid role selected' };
    }

    const newUser: User = {
      id: `user_${Date.now()}`,
      name,
      email,
      role: selectedRole.roleType,
      status: 'active',
      lastLogin: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };

    setUser(newUser);
    localStorage.setItem('auth_user', JSON.stringify(newUser));
    setRole(selectedRole);

    return {};
  };

  const logout = () => {
    setUser(null);
    setRole(null);
    localStorage.removeItem('auth_user');
  };

  const resetPassword = async (email: string) => {
    const foundUser = mockUsers.find(u => u.email === email);
    
    if (!foundUser) {
      return {};
    }

    return {};
  };

  return (
    <AuthContext.Provider value={{ user, role, login, signup, logout, resetPassword, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
