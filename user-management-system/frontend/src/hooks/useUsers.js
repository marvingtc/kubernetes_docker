import { useQuery, useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { userAPI } from '../services/api';

export const useUsers = () => {
  return useQuery(
    'users',
    () => userAPI.getAllUsers().then(res => res.data),
    {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: 2,
      onError: (error) => {
        toast.error('Failed to load users');
        console.error('Users query error:', error);
      }
    }
  );
};

export const useUser = (id) => {
  return useQuery(
    ['user', id],
    () => userAPI.getUserById(id).then(res => res.data),
    {
      enabled: Boolean(id),
      staleTime: 5 * 60 * 1000,
      retry: 2,
      onError: (error) => {
        if (error.response?.status !== 404) {
          toast.error('Failed to load user');
        }
        console.error('User query error:', error);
      }
    }
  );
};

export const useCreateUser = () => {
  const queryClient = useQueryClient();
  
  return useMutation(
    (userData) => userAPI.createUser(userData),
    {
      onSuccess: (response) => {
        queryClient.invalidateQueries('users');
        toast.success(`User "${response.data.username}" created successfully`);
      },
      onError: (error) => {
        const message = error.response?.data?.message || 
                       error.response?.data?.validationErrors ||
                       'Failed to create user';
        
        if (typeof message === 'object') {
          Object.values(message).forEach(msg => toast.error(msg));
        } else {
          toast.error(message);
        }
      }
    }
  );
};

export const useUpdateUser = () => {
  const queryClient = useQueryClient();
  
  return useMutation(
    ({ id, userData }) => userAPI.updateUser(id, userData),
    {
      onSuccess: (response, variables) => {
        queryClient.invalidateQueries('users');
        queryClient.invalidateQueries(['user', variables.id]);
        toast.success(`User "${response.data.username}" updated successfully`);
      },
      onError: (error) => {
        const message = error.response?.data?.message || 
                       error.response?.data?.validationErrors ||
                       'Failed to update user';
        
        if (typeof message === 'object') {
          Object.values(message).forEach(msg => toast.error(msg));
        } else {
          toast.error(message);
        }
      }
    }
  );
};

export const useDeleteUser = () => {
  const queryClient = useQueryClient();
  
  return useMutation(
    (id) => userAPI.deactivateUser(id),
    {
      onSuccess: (_, deletedId) => {
        queryClient.invalidateQueries('users');
        queryClient.removeQueries(['user', deletedId]);
        toast.success('User deactivated successfully');
      },
      onError: (error) => {
        toast.error('Failed to deactivate user');
        console.error('Delete user error:', error);
      }
    }
  );
};

export const useSearchUsers = () => {
  const queryClient = useQueryClient();
  
  return useMutation(
    (searchTerm) => userAPI.searchUsers(searchTerm),
    {
      onSuccess: (response, searchTerm) => {
        // Update the users cache with search results
        queryClient.setQueryData('users', response.data);
        toast.success(`Found ${response.data.length} users matching "${searchTerm}"`);
      },
      onError: (error) => {
        toast.error('Search failed');
        console.error('Search error:', error);
      }
    }
  );
};