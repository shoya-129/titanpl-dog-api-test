const KEY = "dog:image";
const MAX = 10;

export const dtest = () => {
    let entry = t.shareContext.get(KEY);

    // FIRST EVER
    if (!entry) {
        return refresh();
    }

    // already refreshing → just reuse old
    if (entry.refreshing) {
        entry.uses++;
        return t.response.json(entry);
    }

    // normal hit
    entry.uses++;

    // limit reached → trigger background refresh
    if (entry.uses >= MAX) {
        entry.refreshing = true;
        t.shareContext.set(KEY, entry);

        // drift fetch (only first one matters)
        const res = drift(
            t.fetch("https://dog.ceo/api/breeds/image/random")
        );

        const data = JSON.parse(res.body);

        const newEntry = {
            url: data.message,
            uses: 1,
            refreshing: false
        };

        t.shareContext.set(KEY, newEntry);

        return t.response.json(newEntry);
    }

    // normal response
    return t.response.json(entry);
};

function refresh() {
    const res = drift(
        t.fetch("https://dog.ceo/api/breeds/image/random")
    );

    const data = JSON.parse(res.body);

    const entry = {
        url: data.message,
        uses: 1,
        refreshing: false
    };

    t.shareContext.set(KEY, entry);

    return t.response.json(entry);
}
