'use strict'

import { PutCommand } from "@aws-sdk/lib-dynamodb";
import { randomUUID } from "crypto";

const tableName = process.env.DYNAMODB_TABLE_NAME  

export const handler = async (event) => {
    console.log("Event===", JSON.stringify(event, null, 2))
    if (event.httpMethod !=="POST") {
        throw new Error(`Expecting POST method, received ${event.httpMethod}`);
    }

    const {memberId, policyId, memberName} = event.queryStringParameters

    const parsedBody = JSON.parse(event.body || {})
    const now = new Date().toISOString()
    const claimId = randomUUID()
   
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
