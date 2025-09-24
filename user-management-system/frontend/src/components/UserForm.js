import React, { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from 'react-query';
import { toast } from 'react-hot-toast';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';

import { userAPI } from '../services/api';
import LoadingSpinner from './LoadingSpinner';

const UserForm = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEdit = Boolean(id);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
    setValue
  } = useForm();

  // Fetch user data for editing
  const { data: user, isLoading } = useQuery(
    ['user', id],
    () => userAPI.getUserById(id).then(res => res.data),
    {
      enabled: isEdit,
      onSuccess: (userData) => {
        setValue('username', userData.username);
        setValue('email', userData.email);
        setValue('fullName', userData.fullName);
        setValue('isActive', userData.isActive);
      }
    }
  );

  const onSubmit = async (data) => {
    try {
      if (isEdit) {
        await userAPI.updateUser(id, data);
        toast.success(`User "${data.username}" updated successfully`);
      } else {
        await userAPI.createUser(data);
        toast.success(`User "${data.username}" created successfully`);
      }
      navigate('/');
    } catch (error) {
      const message = error.response?.data?.message || 
                    error.response?.data?.validationErrors ||
                    'Operation failed';
      
      if (typeof message === 'object') {
        Object.values(message).forEach(msg => toast.error(msg));
      } else {
        toast.error(message);
      }
    }
  };

  if (isEdit && isLoading) {
    return <LoadingSpinner text="Loading user data..." />;
  }

  return (
    <div className="max-w-2xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center text-gray-600 hover:text-gray-800 mb-4"
        >
          <ArrowLeftIcon className="w-5 h-5 mr-2" />
          Back
        </button>
        
        <h1 className="text-3xl font-bold text-gray-900">
          {isEdit ? 'Edit User' : 'Create User'}
        </h1>
        <p className="text-gray-600 mt-1">
          {isEdit ? 'Update user information' : 'Add a new user to the system'}
        </p>
      </div>

      {/* Form */}
      <div className="card">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          {/* Username */}
          <div className="form-group">
            <label htmlFor="username" className="form-label">
              Username *
            </label>
            <input
              id="username"
              type="text"
              className={`input-field ${errors.username ? 'border-red-500' : ''}`}
              {...register('username', {
                required: 'Username is required',
                minLength: {
                  value: 3,
                  message: 'Username must be at least 3 characters'
                },
                maxLength: {
                  value: 50,
                  message: 'Username must not exceed 50 characters'
                },
                pattern: {
                  value: /^[a-zA-Z0-9_]+$/,
                  message: 'Username can only contain letters, numbers, and underscores'
                }
              })}
              placeholder="Enter username"
            />
            {errors.username && (
              <p className="form-error">{errors.username.message}</p>
            )}
          </div>

          {/* Email */}
          <div className="form-group">
            <label htmlFor="email" className="form-label">
              Email *
            </label>
            <input
              id="email"
              type="email"
              className={`input-field ${errors.email ? 'border-red-500' : ''}`}
              {...register('email', {
                required: 'Email is required',
                pattern: {
                  value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                  message: 'Please enter a valid email address'
                }
              })}
              placeholder="Enter email address"
            />
            {errors.email && (
              <p className="form-error">{errors.email.message}</p>
            )}
          </div>

          {/* Full Name */}
          <div className="form-group">
            <label htmlFor="fullName" className="form-label">
              Full Name *
            </label>
            <input
              id="fullName"
              type="text"
              className={`input-field ${errors.fullName ? 'border-red-500' : ''}`}
              {...register('fullName', {
                required: 'Full name is required',
                maxLength: {
                  value: 100,
                  message: 'Full name must not exceed 100 characters'
                }
              })}
              placeholder="Enter full name"
            />
            {errors.fullName && (
              <p className="form-error">{errors.fullName.message}</p>
            )}
          </div>

          {/* Active Status (only for edit) */}
          {isEdit && (
            <div className="form-group">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  className="mr-2 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  {...register('isActive')}
                />
                <span className="text-sm font-medium text-gray-700">
                  Active user
                </span>
              </label>
              <p className="text-sm text-gray-500 mt-1">
                Inactive users cannot access the system
              </p>
            </div>
          )}

          {/* Form Actions */}
          <div className="flex items-center justify-between pt-4 border-t border-gray-200">
            <button
              type="button"
              onClick={() => navigate('/')}
              className="btn-secondary"
            >
              Cancel
            </button>
            
            <button
              type="submit"
              disabled={isSubmitting}
              className="btn-primary"
            >
              {isSubmitting ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent mr-2"></div>
                  {isEdit ? 'Updating...' : 'Creating...'}
                </div>
              ) : (
                isEdit ? 'Update User' : 'Create User'
              )}
            </button>
          </div>
        </form>
      </div>

      {/* Help Text */}
      <div className="mt-6 text-sm text-gray-500">
        <p>* Required fields</p>
        {!isEdit && (
          <p className="mt-1">New users are active by default</p>
        )}
      </div>
    </div>
  );
};

export default UserForm;