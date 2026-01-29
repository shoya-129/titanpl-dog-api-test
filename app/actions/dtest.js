const KEY = "dog:image";

export const dtest = () => {
    let entry = t.shareContext.get(KEY);

    // first request → fetch
    if (!entry) {
        const res = drift(
            t.fetch("https://dog.ceo/api/breeds/image/random")
        );

        const data = JSON.parse(res.body);

        entry = { url: data.message };
        t.shareContext.set(KEY, entry);
    }

    // always reuse same dog
    return t.response.json(entry);
};
