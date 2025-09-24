import React from 'react';
import { getInitials } from '../utils/validation';

const Avatar = ({ 
  user, 
  size = 'md', 
  className = '', 
  showStatus = true 
}) => {
  const sizeClasses = {
    xs: 'w-6 h-6 text-xs',
    sm: 'w-8 h-8 text-sm',
    md: 'w-10 h-10 text-base',
    lg: 'w-16 h-16 text-xl',
    xl: 'w-20 h-20 text-2xl'
  };

  const initials = getInitials(user?.fullName || user?.username);
  
  // Generate consistent color based on user ID or username
  const getAvatarColor = (user) => {
    const colors = [
      'bg-blue-500',
      'bg-green-500', 
      'bg-purple-500',
      'bg-pink-500',
      'bg-indigo-500',
      'bg-yellow-500',
      'bg-red-500',
      'bg-teal-500'
    ];
    
    const hash = (user?.id || user?.username || '').toString();
    const index = hash.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
    return colors[index % colors.length];
  };

  return (
    <div className={`relative inline-block ${className}`}>
      <div 
        className={`
          ${sizeClasses[size]} 
          ${getAvatarColor(user)}
          rounded-full 
          flex 
          items-center 
          justify-center 
          text-white 
          font-semibold
          select-none
        `}
        title={user?.fullName || user?.username}
      >
        {initials}
      </div>
      
      {showStatus && user && (
        <div 
          className={`
            absolute 
            -bottom-0 
            -right-0 
            w-3 
            h-3 
            rounded-full 
            border-2 
            border-white
            ${user.isActive ? 'bg-green-500' : 'bg-gray-400'}
          `}
          title={user.isActive ? 'Active' : 'Inactive'}
        />
      )}
    </div>
  );
};

export default Avatar;