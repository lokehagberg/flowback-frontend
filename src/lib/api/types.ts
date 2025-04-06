export interface ApiResponse<T> {
  results: T[];
  next: string | null;
  previous: string | null;
}

export interface PollsParams {
  group_ids?: string;
  order_by?: string;
  limit?: number;
  title__icontains?: string;
  tag_id?: number;
  end_date__lt?: string;
  end_date__gt?: string;
  public?: boolean;
} 