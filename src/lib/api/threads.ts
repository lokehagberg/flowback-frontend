import { apiClient } from './client';
import type { ApiResponse } from './types';
import type { Thread } from '$lib/Group/interface';

export class ThreadsApi {
  /**
   * Fetches threads for a specific group
   */
  static async getGroupThreads(groupId: string, threadIds: number[], orderBy: string): Promise<ApiResponse<Thread>> {
    return apiClient<ApiResponse<Thread>>(
      `group/thread/list?group_ids=${groupId}&limit=1000&order_by=pinned,${orderBy}&id_list=${threadIds.join(',')}`
    );
  }

  /**
   * Fetches threads across all groups (for home feed)
   */
  static async getHomeThreads(orderBy: string): Promise<ApiResponse<Thread>> {
    return apiClient<ApiResponse<Thread>>(
      `group/thread/list?group_ids=1,2,3,4&order_by=${orderBy}`
    );
  }
} 