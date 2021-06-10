const PrettyError = require("pretty-error")

console.log(new PrettyError().render(new Error("some error")))
