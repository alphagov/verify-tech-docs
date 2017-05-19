## Install the Matching Service Adapter

**Prerequisite:** The Matching Service Adapter (MSA) requires Java 8. Make sure you have the latest version of the Java Runtime Environment (JRE) installed.

1. When you have successfully completed a gate review for [Stage 3: Planning](http://alphagov.github.io/identity-assurance-documentation/stage3/Stage3.html), you can download and install the MSA. If you don't already have a link to the secure site where you can download the MSA, email [<idasupport+onboarding@digital.cabinet-office.gov.uk>](mailto:idasupport+onboarding@digital.cabinet-office.gov.uk).
1. Download the MSA zip file to your host. It contains:
    * a jar (java archive) file
    * [truststore](#glossary-truststore) files for non-production environments (the SAML compliance tool and the integration environment) - `test_ida_hub.ts` and `test_ida_metadata.ts`
 * truststore files for the production environment - `prod_ida_hub.ts` and `prod_ida_metadata.ts`
 * a sample YAML configuration file for non-production environments  - `test-config.yml`
 * a sample YAML configuration file for the production environment  - `prod-config.yml`

1. Verify the shasum of the zipfile:

        # On mac and linux:
        shasum -a 256 ida-msa-2.0.0-580

        # On windows (powershell):
        Get-FileHash ida-msa-2.0.0-580 -Algorithm SHA256

    The sha256 for `ida-msa-561.zip` should be:

    > 50b8d91286ab5d6a5a4bde8844a8569c6e20ecdabe39e5df8d284c73b9b3b415


1. To extract the files, run the following command:

        unzip ida-msa-[MSA build number].zip

1. Optionally, move the truststore files to the environment where you want to use the MSA:

        mv prod_ida_hub.ts prod_ida_metadata.ts [path to truststore directory in the production environment]
        mv test_ida_hub.ts test_ida_metadata.ts [path to truststore directory in the integration environment]


    where `[path to truststore directory...]` is the location of the truststore – you specify this when configuring the MSA (see the  `trustStore:` fields in the [YAML file](#yaml-configuration-file)).

### Versioning

Typically, GOV.UK Verify releases a new version of the MSA every 2 or 3 months. Some releases are essential updates and we
may remove support for older versions. To keep updated, contact the
[GOV.UK Verify support
team](mailto:idasupport+onboarding@digital.cabinet-office.gov.uk) to
ensure you are on the Matching Service Adapter email distribution list.

## Obtain certificates for your Matching Service Adapter

Your MSA needs a signing certificate and an
encryption certificate. You must use different certificates for each
environment.

To obtain certificates:

* [generate self-signed certificates](#generate-self-signed-certificates) for use with the compliance tool
* [request certificates](#request-certificates) from the IDAP certificate authority for the integration and production environments

## Configure the Matching Service Adapter

### Create a YAML configuration file

When you [start the MSA](#start-the-matching-service-adapter), you need
to supply a YAML configuration file.

The MSA zip file contains two sample YAML configuration files:

* `test-config.yml` for the SAML compliance tool and the integration environment
* `prod-config.yml` for the production environment 


<a name="yaml-configuration-file"></a>

[Adapt the YAML configuration file](#adapt-the-yaml-configuration-file) where required. 

<details>
<summary>
Example of the `test-config.yml` file
</summary>


    # Configure the matching service adapter's server settings here.
    # See http://www.dropwizard.io/1.0.5/docs/manual/configuration.html#servers 
    # for more information.
    server:
      # Ports on which to listen for normal connections.
      # See http://www.dropwizard.io/1.0.5/docs/manual/configuration.html#connectors
      # for information on HTTPS and TLS connections.
      applicationConnectors:
        - type: http
          port: 8080
      # Ports on which to listen for admin tasks.
      # This can probably be set to the above port+1.
      adminConnectors:
        - type: http
          port: 8081

    # Add information about your matching service adapter (MSA) here.
    matchingServiceAdapter:
      # The entityId is used for SAML communication with Verify.
      entityId: my-entity-id
      # The externalUrl is the internet-facing URL for your MSA.
      externalUrl: http://service.gov.uk/matching-service/POST

    # Configure the URLs for your local matching service here.
    localMatchingService:
      # The matchUrl is where the MSA should post user attributes on a successful match
      matchUrl: http://service.gov.uk/local-matching/match
      # The accountCreationUrl is where the MSA should post attributes for unknown users
      accountCreationUrl: http://service.gov.uk/local-matching/create-account

    # Configure the key pairs used by your MSA for signing SAML messages here.
    signingKeys:
      # The primary signing key is used to sign all messages to Verify.
      primary:
        publicKey:
          # The certificate (.crt) containing the primary public signing key:
          certFile: test_primary_signing.crt
          # The common name (CN) of that certificate:
          name: Test MSA Signing
        privateKey:
          # The PK8 (.pk8) containing the primary private signing key:
          keyFile: test_primary_signing.pk8
      # The public part of the secondary signing key is published in the MSA's metadata 
      # during key rollovers but is otherwise unused by the MSA.
      secondary:
        publicKey:
          certFile: test_secondary_signing.crt
          name: Test Another MSA Signing
        privateKey:
          keyFile: test_secondary_signing.pk8

    # Configure the key pairs used by your MSA for encrypting and decrypting SAML
    # messages here. You can configure up to 2 encryption keys at a time and the MSA
    # will attempt decryption with both. Only the first key will be used for encryption.
    encryptionKeys:
      - publicKey:
          certFile: test_msa_encryption_1.crt
          name: Test MSA Encryption 1
        privateKey:
          keyFile: test_msa_encryption_1.pk8
      - publicKey:
          certFile: test_msa_encryption_2.crt
          name: Test MSA Encryption 2
        privateKey:
          keyFile: test_msa_encryption_2.pk8

    # Settings for connecting with the hub can be configured here
    # if necessary.
    hub:
      ssoUrl: https://compliance-tool-reference.ida.digital.cabinet-office.gov.uk/SAML2/SSO
      trustStore:
        path: test_ida_hub.ts
        password: puppet

    # Settings for obtaining Verify's metadata can be configured here.
    metadata:
      url: https://compliance-tool-reference.ida.digital.cabinet-office.gov.uk/SAML2/metadata/federation
      trustStore:
        path: test_ida_metadata.ts
        password: puppet

    ## Options to add additional logging. By default, logs will be output to console.
    ## See http://www.dropwizard.io/1.0.5/docs/manual/configuration.html#logging
    ## for more information.
    #logging:
    #  level: INFO
    #  appenders:
    #    - type: file
    #      currentLogFilename: apps-home/test-rp-msa.log
    #      archivedLogFilenamePattern: apps-home/test-rp-msa.log.%d.gz
    #      logFormat: '%-5p [%d{ISO8601,UTC}] %c: %X{logPrefix}%m%n%xEx'
    #    - type: console
    #      logFormat: '%-5p [%d{ISO8601,UTC}] %c: %X{logPrefix}%m%n%xEx'
</details>

### Adapt the YAML configuration file

Make the following changes to the YAML configuration file according to the environment where you want to use the MSA. Variations are indicated for the SAML compliance tool and integration and production environments.


#### In the field `server:`

1. Enter port numbers for the server application (`applicationConnectors`) and admin ports (`adminConnectors`).

   > **Note:** If the MSA will be handling SSL termination (typically this will be handled by a proxy or load balancer like HAProxy), or if you don't trust the network between the SSL termination endpoint and the MSA, then specify `https` rather than `http` for the type of connection. For more information, see the guidance in the [DropWizard configuration manual](<http://dropwizard.github.io/dropwizard/1.0.5/docs/manual/configuration.html#https>).


#### In the field `matchingServiceAdapter:`


1. Enter the [entityID](#glossary-entityID) for the MSA in `entityId`. This should reflect the name of your service, for example `https://<service name>/MSA`

    > **Note:** It's good practice to use the MSA's URI (where the hub will send matching requests) as its entityID, but this isn't mandatory.

2. Enter the URI for your MSA in `externalUrl:`

#### In the field `localMatchingService:`

4. Enter the URI for your local matching service in `matchUrl:`

5. If you're creating new user accounts when a match isn't found (see [create user accounts](#create-user-accounts)), enter the user account creation URI in `accountCreationUrl:`

#### In the field `signingKeys:`

6. Enter the paths of the primary SAML signing keys and certificates for your MSA in `primary:`
   * for the compliance tool, [generate self-signed certificates](#generate-self-signed-certificates)
   * you'll use different keys and certificates for the integration and production environments - see [Request certificates](#request-certificates).

   > **Note:** To convert a private key to PKCS#8 DER format, run the following command: `openssl pkcs8 -topk8 -nocrypt -in server.key -out server.pk8 -outform DER`


#### In the field `encryptionKeys:`

7. Enter the paths and names of the encryption keys and certificates for your MSA in `encryptionKeys`.  The names are used to identify the certificates in the metadata so should be meaningful and unique, for example, `signing_1` and `encryption_1`.

#### In the field `hub:`

8. In `trustStore:` `path:` , specify the path to your hub truststore file for the appropriate environment:
  * for the SAML compliance tool and the integration environment, use the provided `test_ida_hub.ts` file (this is the default setting in the `test-config.yml` file)
  * for the production environment, use the provided `prod_ida_hub.ts` file (this is the default setting in the `prod-config.yml` file)

#### In the field `metadata:`

9. Edit the `url:` value and specify the location where the MSA accesses the SAML metadata:
  * for the SAML compliance tool, use the default setting in the `test-config.yml` file
  * for the integration environment, enter: `https://www.integration.signin.service.gov.uk/SAML2/metadata/federation` in the `test-config.yml` file
  * for the production environment, use the default setting in the `prod-config.yml` file

10. In `trustStore:` `path:`, specify the path to your metadata truststore file for the appropriate environment:
  * for the SAML compliance tool and the integration environment, use the provided `test_ida_metadata.ts` file (this is the default setting in the `test-config.yml` file)
  * for the production environment, use the provided `prod_ida_metadata.ts` file (this is the default setting in the `prod-config.yml` file)


## Start the Matching Service Adapter

To start using the MSA, run the following command,
supplying the path to your configuration file:

    java -jar [filename].jar server [path to configuration file].yml

You can now run
[SAML compliance tests between the hub and your Matching Service Adapter](#test-your-matching-service-with-the-saml-compliance-tool).
To help [build your local matching service](#build-a-local-matching-service), you can use the
[example of the JSON request](#json-request) that the Matching Service
Adapter posts to your service.

## Monitoring



When the MSA is installed in your [integration or production environment](#gov-uk-verify-environments), health checks run every 60 seconds to ensure that the Matching Service Adapter is functioning correctly. They test:

* connectivity
* that the Matching Service Adapter accepts the hub signature
* that the hub accepts the Matching Service Adapter signature

## Configure HTTPS Proxies

The Matching Service Adapter supports HTTP and HTTPS proxies configured
by Java properties.

For information on configuring HTTPS proxies, see
[<http://docs.oracle.com/javase/8/docs/technotes/guides/net/proxies.html>](http://docs.oracle.com/javase/8/docs/technotes/guides/net/proxies.html).

## Secure your Matching Service Adapter

### Matching Service Adapter TLS certificates

The table below shows the root certificate authorities that GOV.UK Verify trusts for HTTPS connections to your matching service in the [integration and production environments](#gov-uk-verify-environments).

|Root certificate authority |Common name |X509v3 subject key identifier |
|:---|:---|:---|
|AddTrust External CA Root |AddTrust External CA Root |AD:BD:98:7A:34:B4:26:F7:FA:C4:26:54:EF:03:BD:E0:24:CB:54:1A |
|GeoTrust Global CA |GeoTrust Global CA |C0:7A:98:68:8D:89:FB:AB:05:64:0C:11:7D:AA:7D:65:B8:CA:CC:4E |
|QuoVadis Root CA 2 | QuoVadis Root CA 2 |1A:84:62:BC:48:4C:33:25:04:D4:EE:D0:F6:03:C4:19:46:D1:94:6B|

> **Note:** For the SAML compliance tool, use [self-signed certificates](#generate-self-signed-certificates).

If you want to use a root certificate authority for your matching
service that isn’t in the above table, raise a ticket with us by sending
an email to <idasupport+onboarding@digital.cabinet-office.gov.uk>. We’ll
review your chosen root certificate authority before adding it to this
list.

When you raise a ticket, indicate the chain of trust with your SSL/TLS
certificate. You will also need the chain of trust when you configure
your server.

### Connect your Matching Service Adapter to the internet securely

Your Matching Service Adapter must only respond to matching requests
from the GOV.UK Verify hub, otherwise there’s a risk of user data being
compromised.

The Matching Service Adapter checks that matching service requests are
genuine by checking their cryptographic signatures.

To ensure that only the GOV.UK Verify hub can access the Matching
Service Adapter, make sure your Matching Service Adapter:

* is only exposed as HTTPS endpoints
* only uses strong recent versions of TLS (for example TLS 1.2); turn off obsolete and insecure versions (for example SSLv1, SSLv2, and SSLv3)
* supports multiple strong cipher suites

  > **Note:** GOV.UK Verify will remove support for TLS cipher suites if serious
  > weaknesses become known. Having multiple suites provides
  > resilience.

* allows requests and health checks only from the IP addresses of hub services provided by your engagement lead

  > **Note:** Each Matching Service Adapter should communicate with only 1 hub
  > service (SAML compliance tool, integration environment, or production environment).


