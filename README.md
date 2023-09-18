# sinatra_ebay

Product
Sell APIs
Browse API
Buy APIs
Order API
This is a quick guide to illustrate the steps to get you started with OAuth for getting an User access token 
 

Getting the values needed for requesting user token 
 
  Retrieve your app's OAuth Credentials from Application Keys page and OAuth enabled RuName values of your App from User tokens page:

      client_id         - App ID (Client ID)

      clientSecret    - Cert ID (Client Secret)

      redirectUri      - OAuth Enabled RuName for the clientId

      redirectUrl      - Auth Accepted URL associated with the redirectUri

      A list of OAuth Scope required for access to the REST interfaces you plan to call.


# OAuth Token Flow

### Step 1. Get the user permission and obtain authorize code for your clientId

```

  https://auth.sandbox.ebay.com/oauth2/authorize?
  client_id=<app-client-id-value>& 
  locale=<locale-value>&          // optional
  prompt=login                    // optional
  redirect_uri=<app-RuName-value>&
  response_type=code&
  scope=<scopeList>&              // a URL-encoded string of space-separated scopes
  state=<custom-state-value>&     // optional

```



NOTE. 
  1. multiple OAuth scopes must be separated in the string with spaces and then URL-encode the list of the scopes
  2.  Pass prompt parameter and set to login in order to force an user to login in when you redirect them to grant application access page, even if they already have an existing user session

 Below is an example redirectUrl after the user grants permission:
>      https://signin.ebay.com/ws/eBayISAPI.dll?ThirdPartyAuthSucessFailure&isAuthSuccessful=true&state=null&code=v%5E1......EyODQ%3D


      <URL-decoded-auth-code>: URL decode the returned code value (http://meyerweb.com/eric/tools/dencoder/):
            An example URL-decoded-auth-code:  v^1.1#i^1#r^1#p^3#I^3#f^0#t^Ul4xXzE0QzJGQ0I2RDA2NENDMUY4MDkwRjQ3NDE3MzdENzU2XzJfMSNFXjEyODQ=


### Step 2. Exchange the authorization code for a user token and refresh_token:
  <B64-encoded-oauth-credentials>: Base64 encode the following: <your_client_id>:<your_client_secret>  (https://www.base64encode.org/)

  The following example call requests access token for the sandbox

```
  POST /identity/v1/oauth2/token HTTP/1.1
  Host: api.sandbox.ebay.com
  Authorization: Basic <B64-encoded-oauth-credentials>
  Content-Type: application/x-www-form-urlencoded
  
  grant_type=authorization_code&code=<URL-decoded-auth-code>&redirect_uri=<your_redirect_uri>
```

A successful response to the request containing access_token, expires_in,refresh_token and refresh_token_expires_in values:

```
  {
   "access_token": "v^1.1#i^1#r^0#I^3#p^3#...AAAOVXe2xTVRhf121kjo0YUGDxUS5v5LbnPnrbe0Mr3YO0uE",
   "token_type": "User Access Token",
   "expires_in": 7200,
   "refresh_token": "v^1.1#i^1#p^3#f^0#I^3#r^1#t^Ul4yX0Y0OUY1RjRENTU2NDZENTBFQ0E4ODg3MzE2Q0RFQjM2XzdfMSNFXjI2MA==",
   "refresh_token_expires_in": 47304000
  } 

```

### Step 3. When the access token expires, use the refresh_token obtained in the step 2 to generate a new access token.  

```
  HTTP headers:
   Content-Type = application/x-www-form-urlencoded
   Authorization = Basic <B64-encoded-oauth-credentials>
 Request body:
   grant_type=refresh_token&refresh_token=<refresh_token value obtained in the step 2>&scope=<URL-encoded-scope-name(s)>

NOTE.URL-encoded-scope-name(s) must match the ones appended to the signin url in the Step 1.

```

```
  POST /identity/v1/oauth2/token HTTP/1.1
  Host: api.sandbox.ebay.com
  Authorization: Basic <B64-encoded-oauth-credentials>
  Content-Type: application/x-www-form-urlencoded
  
  grant_type=refresh_token
  &refresh_token=v^1.1#i^1#p^3#f^0#I^3#r^1#t^Ul4yX0Y0OUY1RjRENTU2NDZENTBFQ0E4ODg3MzE2Q0RFQj
  M2XzdfMSNFXjI2MA==
  &scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fscope%2Fsell%40user
```

 eBay mints a fresh access token in response similar to the following:

```
  {
      "access_token": "v^1.1#i ... AjRV4yNjA=",
      "token_type":"User Access Token",
      "expires_in": 7200,
      "refresh_token": "N/A"
  }

```

## Special Notes: 

You can either use [OmniAuth eBay Build Status](https://github.com/TheGiftsProject/omniauth-ebay) for Step 1

```
  gem 'omniauth-ebay'
```

> The consent request If the user grants consent by clicking the "I Agree" button on the Grant Application Access page, eBay redirects them back to the seller's Accept URL page (configured with the seller's RuName). The redirect back to your application includes an authorization code , which indicates the user's consent.

/* The redirect to your Accept URL page with the appended authorization code and state value */

```
  https://www.example.com/acceptURL.html?
  state=<client_supplied_state_value>&
  code=v%5E1.1% ... NjA%3D&
  expires_in=299
```

![alt text](public/images/image.jpg)


The example above shows how the authorization code value is returned in the code parameter. The authorization code is tied a single user and you exchange the code for a User access token that is also tied to that user.


You can either use [[WIP] EbayAPI](https://github.com/ebaymag/ebay_api) for Step 3



## Reference 

  1.  Getting user consent (https://developer.ebay.com/api-docs/static/oauth-consent-request.html)
  2.  Exchanging the authorization code for a User access token(https://developer.ebay.com/api-docs/static/oauth-auth-code-grant-request.html)
  3.  Using a refresh token to update a User access token (https://developer.ebay.com/api-docs/static/oauth-refresh-token-request.html)
  4.  Quick OAuth Guide (https://developer.ebay.com/support/kb-article?KBid=5075)
  


      
