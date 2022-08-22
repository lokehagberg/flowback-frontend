<script>
	import Proposal from '../lib/Poll/Proposal.svelte';
	import Header from '$lib/Header/Header.svelte';

    let abstained = [
        {title:"Nuclear Option", description:`Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`},
        {title:"Geothermal Power explosion", description:`Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`},
        {title:"Spread evil pollen", description:`Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`},
    ]

    let ranked = [
        {title:"Nuclear Option", description:`Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`},
        {title:"Geothermal Power explosion", description:`Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`},
        {title:"Spread evil pollen", description:`Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`},
    ]
</script>

<Header />
<h1>Destroy Lithuania</h1>

<div class="flex gap-8 p-10 m-10 bg-gray-200">
	<div class="flex flex-col gap-6 w-1/2">
		<div>Abstain</div>
        {#each abstained as proposal}
            <Proposal title={proposal.title} description={proposal.description} />
        {/each}
	</div>
	<div class="flex flex-col gap-6 w-1/2">
		<div>Rank</div>
        {#each ranked as proposal}
            <Proposal title={proposal.title} description={proposal.description} />
        {/each}

	</div>
</div>
