import cloudflareEdgeProxy from "cloudflare-edge-proxy";
import { config } from "./config";

const proxy = cloudflareEdgeProxy(config);

addEventListener("fetch", event => {
  event.respondWith(proxy(event));
});
