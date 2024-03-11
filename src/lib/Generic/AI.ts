import { fetchRequest } from "$lib/FetchRequest";

// const getAI = async () => {
//     const { res, json } = await fetchRequest('POST', 'ai/titles', { prompt });
//     poll_titles = json.titles;
//     areas = json.areas;
// };

// const generatePoll = async () => {
//     const { res, json } = await fetchRequest('POST', 'ai/poll', {
//         area: area_selected,
//         title: title_selected
//     });
    
//     poll = json;
// };

export const getProposals = async (prompt:string) => {
    const { res, json } = await fetchRequest('POST', 'ai/proposal', {
        prompt    
})
    return json.proposal
}