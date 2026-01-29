export const dtest = () => {
    const res = drift(
        t.fetch("https://dog.ceo/api/breeds/image/random")
    );

    const data = JSON.parse(res.body);

    return t.response.json({
        url: data.message
    });
};
