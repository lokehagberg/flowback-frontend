<script>
  import HeaderIcon from './HeaderIcon.svelte';
  //Temporary fix due to bug with Sveltekit, it should be "import {faHome, faGlobeEurope, ...} from @fortawesome/free-solid-svg-icons"
  import { faHome } from "@fortawesome/free-solid-svg-icons/faHome"
  import { faGlobeEurope } from "@fortawesome/free-solid-svg-icons/faGlobeEurope"
  import { faUserFriends } from "@fortawesome/free-solid-svg-icons/faUserFriends"
  import { faCalendarWeek } from "@fortawesome/free-solid-svg-icons/faCalendarWeek"
  import { faChartBar } from "@fortawesome/free-solid-svg-icons/faChartBar"
  import { faList } from "@fortawesome/free-solid-svg-icons/faList"

  function logOut() {
	localStorage.removeItem("token")
	window.location.href = "/"
  }
</script>

<div class="flex justify-between items-center p-4 bg-white">
	<img src="Logo.png" class="w-32" alt="flowback logo" />
	<div class="flex gap-8">
		<HeaderIcon icon={faHome} text="Home"/>
		<HeaderIcon icon={faGlobeEurope} text="Public"/>
		<HeaderIcon icon={faUserFriends} text="Groups"/>
		<HeaderIcon icon={faCalendarWeek} text="Schedule"/>
		<HeaderIcon icon={faChartBar} text="Prediction"/>
		<HeaderIcon icon={faList} text="Kanban"/>

	</div>
	<div on:click={logOut}>Log Out</div>
</div>

