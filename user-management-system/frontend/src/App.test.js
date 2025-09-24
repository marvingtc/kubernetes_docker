import React from 'react';
import { render, screen } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { BrowserRouter } from 'react-router-dom';
import App from './App';

// Mock react-hot-toast to avoid issues in tests
jest.mock('react-hot-toast', () => ({
  toast: {
    success: jest.fn(),
    error: jest.fn(),
  },
  Toaster: () => <div data-testid="toaster" />,
}));

// Create a test query client
const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
      mutations: {
        retry: false,
      },
    },
  });

const renderWithProviders = (ui, { queryClient = createTestQueryClient() } = {}) => {
  return render(
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        {ui}
      </BrowserRouter>
    </QueryClientProvider>
  );
};

test('renders user management header', () => {
  renderWithProviders(<App />);
  const headerElement = screen.getByText(/User Management/i);
  expect(headerElement).toBeInTheDocument();
});

test('renders java 21 subtitle', () => {
  renderWithProviders(<App />);
  const subtitleElement = screen.getByText(/Powered by Java 21/i);
  expect(subtitleElement).toBeInTheDocument();
});

test('renders toaster component', () => {
  renderWithProviders(<App />);
  const toasterElement = screen.getByTestId('toaster');
  expect(toasterElement).toBeInTheDocument();
});