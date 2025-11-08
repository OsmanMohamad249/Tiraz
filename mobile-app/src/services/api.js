import axios from 'axios';

// Configure API base URL
const API_BASE_URL = process.env.API_URL || 'http://localhost:5000/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for authentication
api.interceptors.request.use(
  config => {
    // Add auth token if available
    const token = ''; // Get from AsyncStorage
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  },
);

// Response interceptor for error handling
api.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response) {
      // Server responded with error
      console.error('API Error:', error.response.data);
    } else if (error.request) {
      // Request made but no response
      console.error('Network Error:', error.request);
    } else {
      // Something else happened
      console.error('Error:', error.message);
    }
    return Promise.reject(error);
  },
);

// API endpoints
export const measurementAPI = {
  uploadPhotos: formData => api.post('/measurements/upload', formData, {
    headers: {'Content-Type': 'multipart/form-data'},
  }),
  processMeasurements: data => api.post('/measurements/process', data),
  getMeasurements: userId => api.get(`/measurements/${userId}`),
};

export const designAPI = {
  getCategories: () => api.get('/design/categories'),
  getFabrics: category => api.get(`/design/fabrics/${category}`),
  saveDesign: data => api.post('/design/save', data),
  getDesigns: userId => api.get(`/design/user/${userId}`),
};

export const orderAPI = {
  createOrder: data => api.post('/orders', data),
  getOrders: userId => api.get(`/orders/user/${userId}`),
  getOrderById: orderId => api.get(`/orders/${orderId}`),
  updateOrderStatus: (orderId, status) =>
    api.patch(`/orders/${orderId}/status`, {status}),
};

export const userAPI = {
  register: data => api.post('/users/register', data),
  login: data => api.post('/users/login', data),
  getProfile: userId => api.get(`/users/${userId}`),
  updateProfile: (userId, data) => api.put(`/users/${userId}`, data),
};

export default api;
