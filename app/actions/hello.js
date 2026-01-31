import { ui } from "@t8n/ui"

export const hello = () => {
    // fetch dog every request
    // eslint-disable-next-line titanpl/drift-only-titan-async
    const res = drift(
        t.fetch("https://dog.ceo/api/breeds/image/random")
    );

    const data = JSON.parse(res.body);

    return ui.render("static/index.html", { dog_image: data.message })
};
