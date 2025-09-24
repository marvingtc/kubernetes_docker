/**
 * Utilidades de validación para formularios
 */

export const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

export const validateUsername = (username) => {
  const usernameRegex = /^[a-zA-Z0-9_]+$/;
  return usernameRegex.test(username) && username.length >= 3 && username.length <= 50;
};

export const validateFullName = (fullName) => {
  return fullName && fullName.trim().length > 0 && fullName.length <= 100;
};

export const getValidationErrors = (formData) => {
  const errors = {};
  
  if (!formData.username) {
    errors.username = 'Username is required';
  } else if (!validateUsername(formData.username)) {
    errors.username = 'Username must be 3-50 characters and contain only letters, numbers, and underscores';
  }
  
  if (!formData.email) {
    errors.email = 'Email is required';
  } else if (!validateEmail(formData.email)) {
    errors.email = 'Please enter a valid email address';
  }
  
  if (!formData.fullName) {
    errors.fullName = 'Full name is required';
  } else if (!validateFullName(formData.fullName)) {
    errors.fullName = 'Full name cannot exceed 100 characters';
  }
  
  return errors;
};

export const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  
  try {
    return new Date(dateString).toLocaleString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  } catch (error) {
    return 'Invalid Date';
  }
};

export const getInitials = (fullName) => {
  if (!fullName) return '??';
  
  return fullName
    .split(' ')
    .map(name => name.charAt(0).toUpperCase())
    .slice(0, 2)
    .join('');
};

export const truncateText = (text, maxLength = 50) => {
  if (!text || text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
};
