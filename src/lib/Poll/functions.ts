import { fetchRequest } from '$lib/FetchRequest';
import { _ } from 'svelte-i18n';
import {
  groupUserStore,
  groupUserPermissionStore
} from '$lib/Group/interface';
import { get } from 'svelte/store';
import type { Phase, poll } from './interface';
import { DATE_POLL_PHASE_CONFIG, TEXT_POLL_PHASE_CONFIG } from './phases';
import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';

export const formatDate = (dateInput: string) => {
  const date = new Date(dateInput);
  // TODO: Fix hardcoded swedish localization
  return `${date.getDay()}/${date.getMonth()} ${date.getFullYear()} klockan ${date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
    }:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
};

// TODO: Fix this mess
export const getPhase = (poll: poll): Phase => {
  if (poll.phase === 'schedule') return 'proposal'
  else if (poll.phase === 'area_vote') return 'proposal'
  else if (poll.phase === 'prediction_statement') return 'prediction_bet'
  else if (poll.phase === 'prediction_vote') return 'result'
  //@ts-ignore
  else return poll.phase

};

// TODO: REMOVE
export const dateLabels = TEXT_POLL_PHASE_CONFIG.filter(p => p.endDateField !== null).map(p => p.label);

// TODO: REMOVE
export const getPhaseUserFriendlyName = (phase: Phase) =>
  TEXT_POLL_PHASE_CONFIG.find(p => p.phase === phase)?.label ?? '';

// TODO: REMOVE
export const getPhaseUserFriendlyNameWithNumber = (phase: Phase, poll_type: number = 4) => {
  if (poll_type === 4) {
    const idx = TEXT_POLL_PHASE_CONFIG.findIndex(p => p.phase === phase);
    const label = TEXT_POLL_PHASE_CONFIG[idx]?.label ?? '';
    return label ? `${idx + 1}. ${label}` : '';
  } else if (poll_type === 3) {
    switch (phase) {
      case 'area_vote':
        return '1. Date Voting';
      case 'result':
        return '2. Results';
      default:
        return '';
    }
  }
  return '';
};

//TODO: To prevent many API calls, use svelte stores to transfer information between files about groups
export const getGroupInfo = async (id: number | string) => {
  id = Number(id);
  const { res, json } = await fetchRequest('GET', `group/list?id=${id}`);
  return { res, json };
};


export const nextPhase = async (poll: poll, phase: Phase) => {
  let _phase: Phase = 'pre_start';

  if (poll.poll_type === 4) {
    const idx = TEXT_POLL_PHASE_CONFIG.findIndex(p => p.phase === phase);
    const next = TEXT_POLL_PHASE_CONFIG[idx + 1];
    _phase = next?.phase;
  }

  // Date Poll
  else if (poll.poll_type === 3) _phase = 'result';


  const { res, json } = await fetchRequest(
    'POST',
    `group/poll/${poll.id}/fast_forward`,
    {
      phase: _phase
    }
  );

  if (!res.ok) {
    ErrorHandlerStore.set({
      message: "Something went wrong when trying to move to the next phase", success: false
    })
    return phase;
  }

  return _phase
};

export const imacFormatting = (imac: number | string) => {
  imac = Number(imac)
  return `${(imac * 100).toFixed(0)}%`
}

export const getMultipleOptions = (
  phase: Phase,
  poll: poll,
  functions: any[],
  fast_forward: any,
  permissions = get(groupUserPermissionStore),
  groupUser = get(groupUserStore)
) => {

  const options = {
    labels: [get(_)('Delete Poll'), get(_)('Report Poll')],
    functions
  }

  const canFastForward = phase !== 'result' &&
    poll?.allow_fast_forward &&
    (permissions?.poll_fast_forward || groupUser?.is_admin)

  if (canFastForward) {
    options.labels.push(get(_)('Fast Forward'))
    options.functions.push(fast_forward)
  }

  return options;
}
