const { fs } = t.core;

// preload template once
const root = globalThis.__titan_root || ".";
let TEMPLATE = null;
function getTemplate() {
    if (TEMPLATE) return TEMPLATE;
    try {
        TEMPLATE = fs.readFile(root + "/static/index.html") || fs.readFile(root + "/app/static/index.html");
    } catch (e) {
        t.log("Template load error:", e);
    }
    return TEMPLATE || "<h1>No Template (Load Failed)</h1>";
}
// renderer
function render(template, data) {
    let out = template;
    for (const k in data) {
        out = out.replaceAll(`tpl{{${k}}}`, data[k]);
    }
    return out;
}

export const hello = () => {
    // fetch dog every request
    const res = drift(
        t.fetch("https://dog.ceo/api/breeds/image/random")
    );

    const data = JSON.parse(res.body);

    const html = render(getTemplate(), {
        name: "Shoya",
        dog_image: data.message
    });

    return t.response.html(html);
};
