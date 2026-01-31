import t from "../titan/titan.js";






t.get("/d").action("dtest")

t.get("/hello").action("hello")

t.get("/").reply("Ready to land on Titan Planet 🚀");

t.start(5100, "Titan Running!", 30, 16);
