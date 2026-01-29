// const { fs } = t.core;

// // preload template once
// const TEMPLATE = fs.readFile("./static/index.html") || "<h1>No Template</h1>";
// // renderer
// function render(template, data) {
//     let out = template;
//     for (const k in data) {
//         out = out.replaceAll(`tpl{{${k}}}`, data[k]);
//     }
//     return out;
// }

export const hello = () => {
    // fetch dog every request
    // const res = drift(
    //     t.fetch("https://dog.ceo/api/breeds/image/random")
    // );

    // const data = JSON.parse(res.body);

    // const html = render(TEMPLATE, {
    //     name: "Shoya",
    //     dog_image: data.message
    // });

    // return t.response.html(html);

    return "hii"
};
