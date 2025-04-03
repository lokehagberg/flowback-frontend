import { apiClient } from './client';
import type { timeProposal } from '$lib/Poll/interface';
import type { ApiResponse } from './types';

interface ProposalVote {
  proposal: number;
}

interface CreateProposalData {
  start_date: Date;
  end_date: Date;
}

export class ProposalsApi {
  static async getProposals(pollId: string): Promise<ApiResponse<timeProposal>> {
    return apiClient<ApiResponse<timeProposal>>(`group/poll/${pollId}/proposals?limit=10000`);
  }

  static async getVotes(pollId: string): Promise<ApiResponse<ProposalVote>> {
    return apiClient<ApiResponse<ProposalVote>>(`group/poll/${pollId}/proposal/votes`);
  }

  static async createProposal(pollId: string, data: CreateProposalData): Promise<void> {
    await apiClient(`group/poll/${pollId}/proposal/create`, {
      method: 'POST',
      body: data
    });
  }

  static async updateVotes(pollId: string, proposals: number[]): Promise<void> {
    await apiClient(`group/poll/${pollId}/proposal/vote/update`, {
      method: 'POST',
      body: { proposals }
    });
  }
} 