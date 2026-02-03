import type { GroupUser } from "$lib/User/interfaces";

export interface proposal {
  title: string;
  description: string;
  id: number;
  created_by: number;
  poll: number;
  blockchain_id?: number;
  attachments: { file: string; file_name: string }[];
  score: number;
}

export interface timeProposal {
  attachments: null | string;
  blockchain_id: null | number;
  created_by: GroupUser
  description: string | null;
  end_date: string
  id: number
  poll: number
  score: null | number;
  start_date: string;
  title: null | string;
  preliminary_score: number;
}

export interface poll {
  attachments: { file: string }[];
  allow_fast_forward: boolean;
  created_by: GroupUser;
  created_at: number;
  description: string;
  dynamic: boolean;
  end_date: string;
  finished: boolean;
  id: number;
  participants: number;
  poll_type: number;
  result: boolean;
  start_date: string;
  tag_id: number;
  tag_name: string;
  title: string;
  group_id: number;
  proposal_end_date: string;
  vote_start_date: string;
  prediction_end_date: string;
  delegate_vote_end_date: string;
  area_vote_end_date: string;
  prediction_statement_end_date: string;
  prediction_bet_end_date: string;
  vote_end_date: string;
  blockchain_id: number | null;
  group_name?: string;
  group_image?: string;
  joined: boolean;
  group_joined: boolean;
  total_comments: number;
  total_proposals: number;
  total_predictions: number;
  pinned: boolean;
  public: boolean;
  work_group_id?: number | null;
  work_group_name?: string | null;
  interval_mean_absolute_correctness: string | null;

  // Status on calculating predictions.  1 is done, 2 is in progress, 0 is not started
  status_prediction: 0 | 1 | 2;

  // Status on calculating votes. -1 failed quorum, 0 is not started, 1 is done, 2 is in progress,
  status: -1 | 0 | 1 | 2;
}

export interface votings {
  author: number;
  author_delegate: number | null;
  priority: number;
  proposal: number;
  score: number;
}

export interface Filter {
  public: boolean;
  finishedSelection: 'all' | 'unfinished' | 'finished';
  search: string;
  order_by: 'pinned' | 'created_at_asc' | 'created_at_desc';
  tag: number | null;
  workgroup: number | null;
  from: string;
  to: string;
  status: -1 | 0 | 1 | null;
}

export type Phase =
  | 'pre_start'
  | 'area_vote'
  | 'proposal'
  | 'prediction_statement'
  | 'prediction_bet'
  | 'delegate_vote'
  | 'vote'
  | 'result'
  | 'prediction_vote'
  | 'schedule';

export interface Comment {
  author_id: number;
  author_name: string;
  author_profile_image: string | null;
  parent_id: number | null;
  reply_depth: number;
  message: string | null;
  score: number;
  being_edited: boolean;
  being_replied: boolean;
  being_reported: boolean;
  being_edited_message?: string;
  id: number;
  //False if comment has been deleted
  active: boolean;
  edited: boolean;
  attachments: { file: string | File }[];
  user_vote: boolean | null;
}

export interface Post {
  created_at: string;
  created_by: {
    permission_id: number | null;
    permission_name: string;
  };
  description: string;
  group_joined: boolean;
  id: number;
  related_model: string;
  title: string;
  updated_at: string;
  user_vote: boolean | null;
}

export interface CommentEdited { }

export enum InfoToGet { 'group', 'home', 'public', 'delegate', 'user' }
