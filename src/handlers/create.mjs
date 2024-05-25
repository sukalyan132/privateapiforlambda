export const handler = async (event) => {
    console.log("Event===", JSON.stringify(event, null, 2))
    if (event.httpMethod !=="POST") {
        throw new Error(`Expecting POST method, received ${event.httpMethod}`);
    }

    const parsedBody = JSON.parse(event.body || {})
    const now = new Date().toISOString()
   
    let response;
    try {
        console.log("Success, claim created")
        response = {
            statusCode: 201,
            body: "Success",
        }

            
        } catch (err) {
            console.log("Error", err)
            response = {
                statusCode: err.statusCode || 500,
                body: JSON.stringify({err})
            }
        }
    console.log("response===")
    return response
}
