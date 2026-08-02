import { QueryClient } from '@tanstack/react-query';

/** Uygulama genelinde paylaşılan TanStack Query istemcisi. */
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});
