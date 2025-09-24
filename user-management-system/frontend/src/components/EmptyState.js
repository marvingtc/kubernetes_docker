import React from 'react';

const EmptyState = ({ 
  icon: Icon,
  title,
  description,
  actionButton,
  className = ""
}) => {
  return (
    <div className={`text-center py-12 ${className}`}>
      {Icon && (
        <Icon className="w-16 h-16 text-gray-300 mx-auto mb-4" />
      )}
      
      <h3 className="text-lg font-medium text-gray-900 mb-2">
        {title}
      </h3>
      
      {description && (
        <p className="text-gray-600 mb-4 max-w-md mx-auto">
          {description}
        </p>
      )}
      
      {actionButton && (
        <div className="mt-6">
          {actionButton}
        </div>
      )}
    </div>
  );
};

export default EmptyState;