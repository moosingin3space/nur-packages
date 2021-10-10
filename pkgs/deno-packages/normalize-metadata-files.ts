if (Deno.args.length != 1) {
    console.error("Please specify the metadata to normalize.");
}
const text = await Deno.readTextFile(Deno.args[0]);
const obj = JSON.parse(text);
const targetObj = {
    url: obj.url,
    headers: {
        'content-type': obj.headers['content-type'],
        'x-typescript-types': obj.headers['x-typescript-types'],
        'location': obj.headers['location'],
    },
};
await Deno.writeTextFile(Deno.args[0], JSON.stringify(targetObj));