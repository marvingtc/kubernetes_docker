import React from 'react';
import { useQuery } from 'react-query';
import { 
  HeartIcon, 
  ServerIcon, 
  CircleStackIcon,
  CpuChipIcon 
} from '@heroicons/react/24/outline';
import { toast } from 'react-hot-toast';

import { healthAPI } from '../services/api';
import LoadingSpinner from './LoadingSpinner';

const HealthDashboard = () => {
  // Health status query
  const { 
    data: healthData, 
    isLoading: healthLoading 
  } = useQuery(
    'health', 
    () => healthAPI.getHealth().then(res => res.data),
    { 
      refetchInterval: 30000, // Refresh every 30 seconds
      onError: () => toast.error('Failed to fetch health status')
    }
  );

  // Cache stats query
  const { 
    data: cacheData, 
    isLoading: cacheLoading 
  } = useQuery(
    'cache-stats', 
    () => healthAPI.getCacheStats().then(res => res.data),
    { 
      refetchInterval: 10000, // Refresh every 10 seconds
      onError: () => toast.error('Failed to fetch cache stats')
    }
  );

  // Redis ping query
  const { 
    data: redisData, 
    isLoading: redisLoading 
  } = useQuery(
    'redis-ping', 
    () => healthAPI.pingRedis().then(res => res.data),
    { 
      refetchInterval: 15000, // Refresh every 15 seconds
      retry: 1,
      onError: () => console.warn('Redis ping failed (expected in some environments)')
    }
  );

  const StatusCard = ({ title, icon: Icon, status, data, isLoading, color = 'blue' }) => {
    const colorClasses = {
      blue: 'border-blue-200 bg-blue-50',
      green: 'border-green-200 bg-green-50',
      red: 'border-red-200 bg-red-50',
      yellow: 'border-yellow-200 bg-yellow-50'
    };

    const iconColors = {
      blue: 'text-blue-600',
      green: 'text-green-600',
      red: 'text-red-600',
      yellow: 'text-yellow-600'
    };

    return (
      <div className={`rounded-lg border p-6 ${colorClasses[color]}`}>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
          <Icon className={`w-6 h-6 ${iconColors[color]}`} />
        </div>
        
        {isLoading ? (
          <LoadingSpinner size="sm" />
        ) : (
          <div className="space-y-2">
            <div className={`inline-flex items-center px-2 py-1 rounded-full text-sm font-medium ${
              status === 'UP' ? 'bg-green-100 text-green-800' :
              status === 'DOWN' ? 'bg-red-100 text-red-800' :
              'bg-yellow-100 text-yellow-800'
            }`}>
              {status || 'Unknown'}
            </div>
            
            {data && (
              <div className="mt-3 space-y-1">
                {Object.entries(data).map(([key, value]) => (
                  <div key={key} className="flex justify-between text-sm">
                    <span className="text-gray-600 capitalize">
                      {key.replace(/([A-Z])/g, ' $1').trim()}:
                    </span>
                    <span className="font-mono text-gray-900">
                      {typeof value === 'object' ? JSON.stringify(value) : String(value)}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="max-w-6xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">System Health</h1>
        <p className="text-gray-600">
          Monitor your Java 21 User Management System
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3 mb-8">
        {/* Application Health */}
        <StatusCard
          title="Application"
          icon={HeartIcon}
          status={healthData?.status}
          data={healthData ? {
            java: `${healthData.java?.version} (${healthData.java?.vendor})`,
            spring: healthData.spring?.version,
            profile: healthData.spring?.profile,
            virtualThreads: healthData.java?.virtualThreadsEnabled ? 'Enabled' : 'Disabled'
          } : null}
          isLoading={healthLoading}
          color={healthData?.status === 'UP' ? 'green' : 'red'}
        />

        {/* Cache Status */}
        <StatusCard
          title="Cache System"
          icon={CircleStackIcon}
          status={healthData?.cache?.enabled ? 'Enabled' : 'Disabled'}
          data={healthData?.cache ? {
            caches: healthData.cache.caches?.length || 0,
            names: healthData.cache.caches?.join(', ') || 'None'
          } : null}
          isLoading={healthLoading}
          color={healthData?.cache?.enabled ? 'green' : 'yellow'}
        />

        {/* Redis Status */}
        <StatusCard
          title="Redis"
          icon={ServerIcon}
          status={redisData?.redis === 'connected' ? 'Connected' : 'Disconnected'}
          data={redisData ? {
            response: redisData.response || redisData.error
          } : null}
          isLoading={redisLoading}
          color={redisData?.redis === 'connected' ? 'green' : 'red'}
        />
      </div>

      {/* Java 21 Features */}
      <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg border border-blue-200 p-6 mb-8">
        <div className="flex items-center mb-4">
          <CpuChipIcon className="w-6 h-6 text-blue-600 mr-3" />
          <h2 className="text-xl font-semibold text-gray-900">Java 21 Features</h2>
        </div>
        
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {[
            { name: 'Virtual Threads', enabled: healthData?.java?.virtualThreadsEnabled },
            { name: 'Pattern Matching', enabled: true },
            { name: 'Records', enabled: true },
            { name: 'String Templates', enabled: true }
          ].map((feature) => (
            <div key={feature.name} className="flex items-center space-x-2">
              <div className={`w-3 h-3 rounded-full ${
                feature.enabled ? 'bg-green-500' : 'bg-gray-300'
              }`}></div>
              <span className="text-sm text-gray-700">{feature.name}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Cache Statistics */}
      {cacheData && cacheData.length > 0 && (
        <div className="bg-white rounded-lg shadow-sm border p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Cache Statistics</h2>
          
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-2 px-4 font-medium text-gray-700">Cache Name</th>
                  <th className="text-left py-2 px-4 font-medium text-gray-700">Hit Count</th>
                  <th className="text-left py-2 px-4 font-medium text-gray-700">Miss Count</th>
                  <th className="text-left py-2 px-4 font-medium text-gray-700">Hit Ratio</th>
                </tr>
              </thead>
              <tbody>
                {cacheData.map((cache, index) => (
                  <tr key={index} className="border-b border-gray-100">
                    <td className="py-2 px-4 font-mono text-sm">{cache.cacheName}</td>
                    <td className="py-2 px-4 text-sm">{cache.hitCount}</td>
                    <td className="py-2 px-4 text-sm">{cache.missCount}</td>
                    <td className="py-2 px-4 text-sm">
                      {cache.hitRatio ? `${(cache.hitRatio * 100).toFixed(1)}%` : 'N/A'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* System Information */}
      <div className="mt-6 text-center text-sm text-gray-500">
        <p>Auto-refreshes every 30 seconds • Built with React + Java 21</p>
      </div>
    </div>
  );
};

export default HealthDashboard;