import axios from 'axios';

const API_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:3001';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests if available
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const authApi = {
  signup: async (name, email, password, ipData) => {
    const response = await api.post('/auth/signup', {
      name,
      email,
      password,
      ...ipData,
    });
    return response.data;
  },

  signin: async (email, password, ipData) => {
    const response = await api.post('/auth/signin', {
      email,
      password,
      ...ipData,
    });
    return response.data;
  },

  getSignInAttempts: async (userId) => {
    const response = await api.get(`/auth/signin-attempts/${userId}`);
    return response.data;
  },

  forgotPassword: async (email) => {
    const response = await api.post('/auth/forgot-password', { email });
    return response.data;
  },

  resetPassword: async (token, newPassword) => {
    const response = await api.post('/auth/reset-password', { token, newPassword });
    return response.data;
  },
};

export default api;
