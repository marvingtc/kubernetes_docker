import React from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useQuery } from 'react-query';
import { toast } from 'react-hot-toast';
import { 
  ArrowLeftIcon,
  PencilIcon,
  TrashIcon,
  UserIcon,
  EnvelopeIcon,
  CalendarIcon,
  CheckBadgeIcon,
  XCircleIcon
} from '@heroicons/react/24/outline';

import { userAPI } from '../services/api';
import LoadingSpinner from './LoadingSpinner';

const UserDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();

  const { 
    data: user, 
    isLoading, 
    error,
    refetch 
  } = useQuery(
    ['user', id],
    () => userAPI.getUserById(id).then(res => res.data),
    {
      onError: (error) => {
        if (error.response?.status === 404) {
          toast.error('User not found');
          navigate('/');
        }
      }
    }
  );

  const handleDelete = async () => {
    if (!window.confirm(`Are you sure you want to deactivate user "${user.username}"?`)) {
      return;
    }

    try {
      await userAPI.deactivateUser(id);
      toast.success(`User "${user.username}" deactivated`);
      navigate('/');
    } catch (error) {
      toast.error('Failed to deactivate user');
    }
  };

  if (isLoading) return <LoadingSpinner text="Loading user details..." />;

  if (error) {
    return (
      <div className="text-center py-8">
        <div className="text-red-600 mb-4">
          <p>Error loading user: {error.message}</p>
        </div>
        <button 
          onClick={() => refetch()}
          className="btn-primary mr-4"
        >
          Try Again
        </button>
        <button 
          onClick={() => navigate('/')}
          className="btn-secondary"
        >
          Back to Users
        </button>
      </div>
    );
  }

  if (!user) return null;

  return (
    <div className="max-w-4xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={() => navigate('/')}
          className="flex items-center text-gray-600 hover:text-gray-800 mb-4"
        >
          <ArrowLeftIcon className="w-5 h-5 mr-2" />
          Back to Users
        </button>
        
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {user.fullName}
            </h1>
            <p className="text-gray-600 mt-1">User Details</p>
          </div>
          
          <div className="flex items-center space-x-3">
            <Link 
              to={`/users/${user.id}/edit`}
              className="btn-primary flex items-center space-x-2"
            >
              <PencilIcon className="w-4 h-4" />
              <span>Edit</span>
            </Link>
            
            <button 
              onClick={handleDelete}
              className="btn-danger flex items-center space-x-2"
            >
              <TrashIcon className="w-4 h-4" />
              <span>Deactivate</span>
            </button>
          </div>
        </div>
      </div>

      {/* User Information Card */}
      <div className="card mb-6">
        <div className="flex items-start space-x-6">
          {/* Avatar */}
          <div className="flex-shrink-0">
            <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
              <UserIcon className="w-10 h-10 text-white" />
            </div>
          </div>
          
          {/* Basic Info */}
          <div className="flex-1">
            <div className="flex items-center space-x-3 mb-3">
              <h2 className="text-2xl font-semibold text-gray-900">
                {user.fullName}
              </h2>
              
              <div className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
                user.isActive 
                  ? 'bg-green-100 text-green-800' 
                  : 'bg-gray-100 text-gray-800'
              }`}>
                {user.isActive ? (
                  <CheckBadgeIcon className="w-4 h-4 mr-1" />
                ) : (
                  <XCircleIcon className="w-4 h-4 mr-1" />
                )}
                {user.isActive ? 'Active' : 'Inactive'}
              </div>
            </div>
            
            <div className="space-y-2">
              <div className="flex items-center text-gray-600">
                <UserIcon className="w-5 h-5 mr-3 text-gray-400" />
                <span className="font-medium mr-2">Username:</span>
                <span className="font-mono bg-gray-100 px-2 py-1 rounded">
                  @{user.username}
                </span>
              </div>
              
              <div className="flex items-center text-gray-600">
                <EnvelopeIcon className="w-5 h-5 mr-3 text-gray-400" />
                <span className="font-medium mr-2">Email:</span>
                <a 
                  href={`mailto:${user.email}`}
                  className="text-blue-600 hover:text-blue-700"
                >
                  {user.email}
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Timestamps Card */}
      <div className="card mb-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Timeline</h3>
        
        <div className="space-y-4">
          <div className="flex items-center space-x-4">
            <CalendarIcon className="w-5 h-5 text-gray-400" />
            <div>
              <p className="font-medium text-gray-900">Created</p>
              <p className="text-gray-600 text-sm">
                {new Date(user.createdAt).toLocaleString()}
              </p>
            </div>
          </div>
          
          {user.updatedAt !== user.createdAt && (
            <div className="flex items-center space-x-4">
              <CalendarIcon className="w-5 h-5 text-gray-400" />
              <div>
                <p className="font-medium text-gray-900">Last Updated</p>
                <p className="text-gray-600 text-sm">
                  {new Date(user.updatedAt).toLocaleString()}
                </p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* System Information */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">System Information</h3>
        
        <div className="grid gap-4 md:grid-cols-2">
          <div>
            <p className="font-medium text-gray-700">User ID</p>
            <p className="text-gray-900 font-mono">{user.id}</p>
          </div>
          
          <div>
            <p className="font-medium text-gray-700">Account Status</p>
            <p className={`font-medium ${
              user.isActive ? 'text-green-600' : 'text-gray-600'
            }`}>
              {user.isActive ? 'Active Account' : 'Inactive Account'}
            </p>
          </div>
          
          <div>
            <p className="font-medium text-gray-700">Profile Completion</p>
            <div className="flex items-center space-x-2">
              <div className="flex-1 bg-gray-200 rounded-full h-2">
                <div 
                  className="bg-blue-600 h-2 rounded-full" 
                  style={{ width: '100%' }}
                ></div>
              </div>
              <span className="text-sm text-gray-600">100%</span>
            </div>
          </div>
          
          <div>
            <p className="font-medium text-gray-700">Data Source</p>
            <p className="text-gray-900">Java 21 + H2 Database</p>
          </div>
        </div>
      </div>

      {/* Actions Footer */}
      <div className="mt-6 flex items-center justify-center space-x-4 text-sm text-gray-500">
        <p>Powered by Java 21 Virtual Threads</p>
        <span>•</span>
        <p>Cached with Redis</p>
      </div>
    </div>
  );
};

export default UserDetail;