import { writable } from 'svelte/store';

// Auth store
export const user = writable(null);
export const isAuthenticated = writable(false);

// Initialize from localStorage if available
if (typeof window !== 'undefined') {
  const storedUser = localStorage.getItem('user');
  const storedToken = localStorage.getItem('authToken');
  
  if (storedUser && storedToken) {
    user.set(JSON.parse(storedUser));
    isAuthenticated.set(true);
  }
}

// Helper functions
export const setUser = (userData, token) => {
  if (typeof window !== 'undefined') {
    localStorage.setItem('user', JSON.stringify(userData));
    localStorage.setItem('authToken', token);
  }
  user.set(userData);
  isAuthenticated.set(true);
};

export const logout = () => {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('user');
    localStorage.removeItem('authToken');
  }
  user.set(null);
  isAuthenticated.set(false);
};
