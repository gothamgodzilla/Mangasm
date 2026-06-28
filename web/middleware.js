export default function middleware(request) {
  const host = request.headers.get('host')?.split(":")[0] ?? "";
  if (host === "ios.mangasm.app") {
    return new Response(null, {
      headers: { "x-middleware-rewrite": "/ios.html" },
    });
  }
}

export const config = {
  matcher: "/:path*",
};