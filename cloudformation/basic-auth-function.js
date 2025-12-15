function handler(event) {
    var request = event.request;
    var headers = request.headers;

    // Basic認証の認証情報 (nta2025:nta2025)
    var authString = "Basic bnRhMjAyNTpudGEyMDI1";

    if (
        typeof headers.authorization === "undefined" ||
        headers.authorization.value !== authString
    ) {
        return {
            statusCode: 401,
            statusDescription: "Unauthorized",
            headers: {
                "www-authenticate": { value: "Basic realm=\"Enter credentials\"" }
            }
        };
    }

    return request;
}
