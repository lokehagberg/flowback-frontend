<script lang="ts">
    export let user:any
    import DefaultPFP from '$lib/assets/Default_pfp.png';
</script>

<img src={user.profile_image ? `${import.meta.env.VITE_API}${user.profile_image}` : DefaultPFP} alt="avatar" class="w-10 h-10 rounded-full" />