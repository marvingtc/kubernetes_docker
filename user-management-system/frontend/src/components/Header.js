import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { UserIcon, HeartIcon } from '@heroicons/react/24/outline';

const Header = () => {
  const location = useLocation();

  const isActive = (path) => location.pathname === path;

  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo and Title */}
          <div className="flex items-center space-x-3">
            <UserIcon className="w-8 h-8 text-blue-600" />
            <div>
              <h1 className="text-xl font-bold text-gray-900">
                User Management
              </h1>
              <p className="text-xs text-gray-500">
                Powered by Java 21 + Virtual Threads
              </p>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex items-center space-x-6">
            <Link
              to="/"
              className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                isActive('/') 
                  ? 'bg-blue-100 text-blue-700' 
                  : 'text-gray-600 hover:text-blue-600'
              }`}
            >
              Users
            </Link>
            
            <Link
              to="/users/new"
              className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                isActive('/users/new') 
                  ? 'bg-blue-100 text-blue-700' 
                  : 'text-gray-600 hover:text-blue-600'
              }`}
            >
              Add User
            </Link>

            <Link
              to="/health"
              className={`flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                isActive('/health') 
                  ? 'bg-green-100 text-green-700' 
                  : 'text-gray-600 hover:text-green-600'
              }`}
            >
              <HeartIcon className="w-4 h-4" />
              <span>Health</span>
            </Link>
          </nav>
        </div>
      </div>
    </header>
  );
};

export default Header;