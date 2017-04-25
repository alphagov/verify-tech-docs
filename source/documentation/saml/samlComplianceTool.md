## Run SAML compliance tests


The purpose of SAML compliance tests is to ensure that the service
you're building is compliant with the [SAML
profile](https://www.gov.uk/government/publications/identity-assurance-hub-service-saml-20-profile).
This guarantees that:

* your service will work with GOV.UK Verify
* user data will remain secure within the GOV.UK Verify federation

Your service and matching service need to consume and produce SAML
messages in a variety of different scenarios. The SAML compliance tool
allows you to test and prove that your service and matching service can
consume and produce all required SAML messages.

The compliance tool provides clear error messages. These will help with
iterative development of your service. We advise you to use the
compliance tool as part of your continuous integration pipeline. This
ensures that any changes maintain backwards compatibility.

Before running SAML compliance tests, [install](#install-the-matching-service-adapter) and [configure](#configure-the-matching-service-adapter) your MSA.

Use the SAML compliance test to:

* [test your service](#test-your-service-with-the-saml-compliance-tool)
* [test your matching service](#test-your-matching-service-with-the-saml-compliance-tool)

After SAML compliance tests, you can run
[end-to-end testing](#run-end-to-end-testing) in the integration environment.

### Test your service with the SAML compliance tool


To use the compliance tool, you need configuration data (see step 4).
Generate a new set of configuration data for every test run.

1. On completion of a successful [Stage 3](http://alphagov.github.io/identity-assurance-documentation/stage3/Stage3.html) gate review, your GOV.UK Verify engagement lead will give you access to the compliance tool.
1. Send the IP addresses of your hosts to the GOV.UK Verify support team: <idasupport+onboarding@digital.cabinet-office.gov.uk>. We will add a firewall rule allowing access to the compliance tool.

    <a name="generate-self-signed-certificates"></a>


1. Generate self-signed certificates for use with the compliance tool only.
1. POST the following JSON to the SAML compliance tool URL ([https://compliance-tool-reference.ida.digital.cabinet-office.gov.uk/rp-test-data](https://compliance-tool-reference.ida.digital.cabinet-office.gov.uk/rp-test-data)):
    
    ```
        Content-Type: application/json
        {
            "serviceEntityId":"[entityID for your service]",
            "assertionConsumerServiceUrl":"[assertion consumer service URL: this is the URL that will consume responses from the GOV.UK Verify hub]",
            "signingCertificate":"[Base64-encoded X509 signing certificate for your service]",
            "encryptionCertificate":"[Base64-encoded X509 encryption certificate for your service]",
            "expectedPID":"[expected persistent identifier: this is the user id that the Matching Service Adapter returns in an assertion]",
            "matchingServiceEntityId":"[entityID for your Matching Service Adapter]",
            "matchingServiceSigningPrivateKey":"[Base64-encoded private signing key for the Matching Service Adapter, see below]",
            "userAccountCreationAttributes":["optional", "list", "of", "attributes", "the", "government", "service", "requires", "for", "new", "user", "account", "creation", "see", "below"],
            "useSimpleProfile":"[optional, to use a simpler SAML profile that works with Shibboleth - defaults to false]"
        }
    ``` 

    Replace the square brackets and their contents with your configuration data, taking account of the following:
     * the keys and certificates in the configuration data must be single-line strings of Base64-encoded data without the header and footer `BEGIN CERTIFICATE` and `END CERTIFICATE`
     * `matchingServiceSigningPrivateKey`: this is required because the compliance tool sends a response to your service which contains an assertion signed by the Matching Service Adapter

        This key must be a Base-64 encoded version of your PKCS#8 signing key. To convert a key named `test_primary_signing.pk8`, run:
        
        ```
        base64 test_primary_signing.pk8
        ```
     * `userAccountCreationAttributes`: provide this only if you want to test [new user account creation](#create-user-accounts) – select from the [full list of attributes](#list-attributes)

1. You receive an empty response with ```200 OK``` status.
1. Make sure that your MSA is pointing at the URLs for the compliance tool (`metadata:` `url`) and the hub (`hub:` `ssoUrl`). These are the defaults in the `test-config.yml` file for non-production environments.
1.  Generate an authentication request and POST it to the compliance
    tool's SSO URI. Follow the redirect in the response to retrieve the
    result.

    > **Note:** The SAML authentication requests signed by the government service must use RSA-SHA256 for the [signature method algorithm](<https://www.w3.org/TR/xmldsig-core/#sec-SignatureMethod>) and SHA256 for the [digest method algorithm](<https://www.w3.org/TR/xmldsig-core/#sec-DigestMethod>). These are required to comply with the [Identity Assurance Hub Service SAML 2.0 Profile](<https://www.gov.uk/government/publications/identity-assurance-hub-service-saml-20-profile>). 

    <details>
    <summary>
    Example of a SAML authentication request
    </summary>

    <pre>
      &lt;?xml version="1.0" encoding="UTF-8"?&gt;
      &lt;saml2p:AuthnRequest ...&gt;
        &lt;saml2:Issuer xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity"&gt;http://www.test-rp.gov.uk/SAML2/MD&lt;/saml2:Issuer&gt;
        &lt;ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#"&gt;
          &lt;ds:SignedInfo&gt;
            &lt;ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/&gt;
            <b>&lt;ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/&gt;</b>
            &lt;ds:Reference URI="#_60f75dc5-f9eb-43cf-adfc-5814016a626c"&gt;
              &lt;ds:Transforms&gt;
                &lt;ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/&gt;
                &lt;ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/&gt;
              &lt;/ds:Transforms&gt;
              <b>&lt;ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/&gt;</b>
              &lt;ds:DigestValue&gt;O+LkTbydEWNPSLThcblzSqd/BvlGAI0dWwGVgd6ixkE=&lt;/ds:DigestValue&gt;
            &lt;/ds:Reference&gt;
          &lt;/ds:SignedInfo&gt;
          &lt;ds:SignatureValue&gt;
      O8x8ILlqoiCKg8LMSqlajyX5JhLDxHSltUXYAalGnFb0L41Up5hQuFrEXBNxfNiUo3ChlZA+FIWw
      WkK5OSSqqJQ9IqgUFUapDVZUewerOGLQ/Qw80linrbc24w21JIWDnpoT8qrdt+c9EgkQTvKrwDmf
      JfXUcbTCvuhnOTVrG/5Fv64sruBu9CVTSnvj/Jvy1bwK2HsvMmxrAO8og+iFvMx1KB7YCG1Puj/Z
      frJRKYU3QgAehUR0hrUj1ReVGV4cx1Yy7FhUKnYpdsYRVxpv1McwkDXHVs5iao+0vv7rLGLw9U1d
      a7lBaFhC2AT1wi+ogaO8nzZ/d3G6p0tHrMSqQA==
          &lt;/ds:SignatureValue&gt;
        &lt;/ds:Signature&gt;
      &lt;/saml2p:AuthnRequest&gt;
    </pre>


1.  If the result contains `PASSED`, access the URI provided in
    `responseGeneratorLocation`. A list of test scenarios is displayed.
1.  Access the `executeUri` for each test scenario you want to execute.
    The following test scenarios are provided:
    * Basic successful match
    * Basic no match
    * No authentication context (this is when the user cancels the process)
    * Authentication failed
    * Requester error (this is when the request is invalid)
    * Account creation

   The above scenarios are the possible responses for step 8 in the [SAML message flow](#how-saml-works-with-gov-uk-verify).

### Test your matching service with the SAML compliance tool


1. To set up the SAML compliance tool for matching service tests, POST the following JSON (via curl or Postman, for example) to the SAML compliance tool URL ([https://compliance-tool-reference.ida.digital.cabinet-office.gov.uk/ms-test-run](https://compliance-tool-reference.ida.digital.cabinet-office.gov.uk/ms-test-run)):
    
    ```
     Content-Type: application/json
       {
       "matchingServiceEntityId": "[entityID of the matching service]",
       "serviceEntityId": "[entityID of the transaction (service)]",
       "matchingServiceEndpoint": "[the matching service's endpoint]",
       "matchingServiceSigningCertificate": "[signing certificate to verify the response]",
       "matchingServiceEncryptionCertificate": "[encryption certificate to encrypt the assertions]"
       }
    ```

1. You receive a response similar to the following:

        Status 201 Created
        Location: .../ms-test-run/8fd7782f-efac-48b2-8171-3e4da9553d19

1. POST your test [matching dataset](#glossary-matching-dataset) (see example below) to the `Location` field in the above response (`.../ms-test-run/8fd7782f-efac-48b2-8171-3e4da9553d19` in the above example). <details>
   <summary>
   Example of a test matching dataset
   </summary>

        {
            "levelOfAssurance": "LEVEL_2",
            "persistentId": "93E5910B-F4C2-4561-AEC5-C878AFEF25A3",
            "firstName": {
                "value": "Joe",
                "to": "",
                "from": "",
                "verified": true
            },
            "middleNames": {
                "value": "Bob Rob",
                "to": "",
                "from": "",
                "verified": true
            },
            "surnames": [
                {
                    "value": "Fred",
                    "to": "2010-01-20",
                    "from": "1980-05-24",
                    "verified": true
                },
                {
                    "value": "Dou",
                    "to": "",
                    "from": "2010-01-20",
                    "verified": true
                }
            ],
            "gender": {
                "value": "Male",
                "to": "",
                "from": "",
                "verified": true
            },
            "dateOfBirth": {
                "value": "1980-05-24",
                "to": "",
                "from": "",
                "verified": true
            },
            "addresses": [
                {
                    "lines": ["123 George Street"],
                    "postCode": "GB1 2PP",
                    "internationalPostCode": "GB1 2PP",
                    "uprn": "7D68E096-5510-B3844C0BA3FD",
                    "toDate": "2005-05-14",
                    "fromDate": "1980-05-24",
                    "verified": true
                },
                {
                    "lines": ["10 George Street"],
                    "postCode": "GB1 2PF",
                    "internationalPostCode": "GB1 2PF",
                    "uprn": "833F1187-9F33-A7E27B3F211E",
                    "toDate": null,
                    "fromDate": "2005-05-14",
                    "verified": true
                }
            ],
            "cycle3Dataset": {
                "key": "drivers_licence",
                "value": "4C22DA90A18A4B88BE460E0A3D975F68"
            }
        }

    where:
      * `persistentId` is mandatory
      * you must supply at least one other value in addition to `persistentId`
      * the values of `addresses` and `surnames` are arrays
      * fields have optional `from` and `to` attributes in which you can capture historical values – for example, if the user has changed their surname, there's an additional entry for the old surname with the `from` and `to` values defining the period for which the name was valid; the new surname only has the `from` attribute, containing the date from which it was valid
      * the `addresses` field that holds the current address contains a `fromDate` attribute for the date from which the address is valid; past addresses also contain the `toDate` attribute
      * the `cycle3Dataset` field is only present for a cycle 3 matching attempt
      * the `uprn` (Unique Property Reference Number) is a unique reference for each property in Great Britain, ensuring accuracy of address data. This is an optional attribute that can contain up to 12 characters and should not have any leading zeros
   </details>

1. When the SAML compliance tool receives your test matching dataset, it will POST an attribute query to your Matching Service Adapter. This corresponds to step 4 in the [SAML message flow](#how-saml-works-with-gov-uk-verify).
1. Your Matching Service Adapter validates the query and sends a POST with a JSON request containing your test matching dataset to your local matching service. This corresponds to step 5 in the [SAML message flow](#how-saml-works-with-gov-uk-verify).
