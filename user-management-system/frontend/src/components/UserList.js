import React, { useState } from 'react';
import { useQuery, useQueryClient } from 'react-query';
import { Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { 
  UserIcon, 
  PencilIcon, 
  TrashIcon, 
  MagnifyingGlassIcon,
  PlusIcon
} from '@heroicons/react/24/outline';

import { userAPI } from '../services/api';
import LoadingSpinner from './LoadingSpinner';

const UserList = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [isSearching, setIsSearching] = useState(false);
  const queryClient = useQueryClient();

  // Query for all users
  const { 
    data: users = [], 
    isLoading, 
    error, 
    refetch 
  } = useQuery(
    'users', 
    () => userAPI.getAllUsers().then(res => res.data),
    {
      refetchOnWindowFocus: false,
    }
  );

  // Search users
  const handleSearch = async (e) => {
    e.preventDefault();
    if (!searchTerm.trim()) {
      refetch();
      return;
    }

    setIsSearching(true);
    try {
      const response = await userAPI.searchUsers(searchTerm);
      queryClient.setQueryData('users', response.data);
      toast.success(`Found ${response.data.length} users`);
    } catch (error) {
      toast.error('Search failed');
      console.error('Search error:', error);
    } finally {
      setIsSearching(false);
    }
  };

  // Clear search
  const clearSearch = () => {
    setSearchTerm('');
    refetch();
  };

  // Delete user
  const handleDelete = async (userId, username) => {
    if (!window.confirm(`Are you sure you want to deactivate user "${username}"?`)) {
      return;
    }

    try {
      await userAPI.deactivateUser(userId);
      toast.success(`User "${username}" deactivated`);
      refetch();
    } catch (error) {
      toast.error('Failed to deactivate user');
      console.error('Delete error:', error);
    }
  };

  if (isLoading) return <LoadingSpinner />;

  if (error) {
    return (
      <div className="text-center py-8">
        <div className="text-red-600 mb-4">
          <p>Error loading users: {error.message}</p>
        </div>
        <button 
          onClick={() => refetch()}
          className="btn-primary"
        >
          Try Again
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Users</h1>
          <p className="text-gray-600 mt-1">
            Manage your users with Java 21 backend
          </p>
        </div>
        
        <Link 
          to="/users/new"
          className="btn-primary flex items-center space-x-2"
        >
          <PlusIcon className="w-5 h-5" />
          <span>Add User</span>
        </Link>
      </div>

      {/* Search */}
      <div className="bg-white rounded-lg shadow-sm border p-4 mb-6">
        <form onSubmit={handleSearch} className="flex space-x-4">
          <div className="flex-1 relative">
            <MagnifyingGlassIcon className="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Search users by name..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input-field pl-10"
            />
          </div>
          
          <button 
            type="submit" 
            disabled={isSearching}
            className="btn-primary"
          >
            {isSearching ? 'Searching...' : 'Search'}
          </button>
          
          {searchTerm && (
            <button 
              type="button"
              onClick={clearSearch}
              className="btn-secondary"
            >
              Clear
            </button>
          )}
        </form>
      </div>

      {/* Users Count */}
      <div className="mb-4">
        <p className="text-sm text-gray-600">
          {users.length} user{users.length !== 1 ? 's' : ''} found
        </p>
      </div>

      {/* Users Grid */}
      {users.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg shadow-sm">
          <UserIcon className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            No users found
          </h3>
          <p className="text-gray-600 mb-4">
            {searchTerm ? 'Try a different search term' : 'Get started by creating your first user'}
          </p>
          {!searchTerm && (
            <Link to="/users/new" className="btn-primary">
              Add First User
            </Link>
          )}
        </div>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {users.map((user) => (
            <div 
              key={user.id} 
              className="bg-white rounded-lg shadow-sm border hover:shadow-md transition-shadow p-6"
            >
              {/* User Info */}
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-gray-900 mb-1">
                    {user.fullName}
                  </h3>
                  <p className="text-gray-600 text-sm mb-1">@{user.username}</p>
                  <p className="text-gray-500 text-sm">{user.email}</p>
                </div>
                
                <div className={`px-2 py-1 rounded-full text-xs font-medium ${
                  user.isActive 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-gray-100 text-gray-800'
                }`}>
                  {user.isActive ? 'Active' : 'Inactive'}
                </div>
              </div>

              {/* Timestamps */}
              <div className="text-xs text-gray-500 mb-4 space-y-1">
                <p>Created: {new Date(user.createdAt).toLocaleDateString()}</p>
                {user.updatedAt !== user.createdAt && (
                  <p>Updated: {new Date(user.updatedAt).toLocaleDateString()}</p>
                )}
              </div>

              {/* Actions */}
              <div className="flex items-center justify-between">
                <Link 
                  to={`/users/${user.id}`}
                  className="text-blue-600 hover:text-blue-700 text-sm font-medium"
                >
                  View Details
                </Link>
                
                <div className="flex items-center space-x-2">
                  <Link 
                    to={`/users/${user.id}/edit`}
                    className="p-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded"
                    title="Edit user"
                  >
                    <PencilIcon className="w-4 h-4" />
                  </Link>
                  
                  <button 
                    onClick={() => handleDelete(user.id, user.username)}
                    className="p-2 text-gray-600 hover:text-red-600 hover:bg-red-50 rounded"
                    title="Deactivate user"
                  >
                    <TrashIcon className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default UserList;