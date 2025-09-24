import axios from 'axios';

// API base URL - works with both development and production
const API_BASE_URL = process.env.REACT_APP_API_URL || '/api';

// Axios instance with interceptors
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    console.log(`🚀 API Request: ${config.method?.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    console.error('❌ Request Error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor
api.interceptors.response.use(
  (response) => {
    console.log(`✅ API Response: ${response.status} ${response.config.url}`);
    return response;
  },
  (error) => {
    console.error('❌ Response Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

// User API functions
export const userAPI = {
  // Get all active users
  getAllUsers: () => api.get('/users'),
  
  // Get user by ID
  getUserById: (id) => api.get(`/users/${id}`),
  
  // Create new user
  createUser: (userData) => api.post('/users', userData),
  
  // Update user
  updateUser: (id, userData) => api.put(`/users/${id}`, userData),
  
  // Deactivate user
  deactivateUser: (id) => api.delete(`/users/${id}`),
  
  // Search users by name
  searchUsers: (name) => api.get(`/users/search`, { params: { name } }),
  
  // Get user by username (async endpoint - Java 21 Virtual Threads)
  getUserByUsername: (username) => api.get(`/users/by-username/${username}`),
};

// Health API functions
export const healthAPI = {
  // Get health status
  getHealth: () => api.get('/health'),
  
  // Get cache statistics
  getCacheStats: () => api.get('/cache/stats'),
  
  // Ping Redis
  pingRedis: () => api.get('/redis/ping'),
};

export default api;
