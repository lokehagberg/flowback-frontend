<script lang="ts">
  import Button from '$lib/Generic/Button.svelte';
  import Fa from 'svelte-fa';
  import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';

  export let displayForm: boolean;
  export let selectedProposal: any;
  export let resetScroll: boolean;
</script>

<div class="md:hidden">
  <Button
    buttonStyle="primary-light"
    onClick={() => {
      displayForm = false;
      selectedProposal = null;
      resetScroll = true;
    }}
  >
    <Fa icon={faArrowLeft} />
  </Button>
</div>
