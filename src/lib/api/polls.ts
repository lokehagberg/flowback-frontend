import { apiClient } from './client';
import type { ApiResponse, PollsParams } from './types';
import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';

export class PollsApi {
  /**
   * Fetches all available workgroups (Used only for "one group" flowback)
   */
  static async getWorkGroups(): Promise<ApiResponse<WorkGroup>> {
    return apiClient<ApiResponse<WorkGroup>>('group/1/list');
  }
} 
