addEventListener("fetch", event => {
  event.respondWith(fetchAndApply(event.request));
});

async function fetchAndApply(request) {
  return new Response(
    `
    <html>
      <body style="background-color: ${
        process.env.COLOR
      }; color: white; font-size: 48px; text-align: center;">
        Hello world from the ${process.env.COLOR} color running version ${
      process.env.WORKER_VERSION
        ? process.env.WORKER_VERSION
        : "use s3 to enable versioning"
    }
      </body>
    </html>
  `,
    {
      headers: new Headers({
        "Content-Type": "text/html"
      })
    }
  );
}
