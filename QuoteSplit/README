/*    Copyright (c) 2012 Zuora, Inc.
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy of 
 *   this software and associated documentation files (the "Software"), to use copy, 
 *   modify, merge, publish the Software and to distribute, and sublicense copies of 
 *   the Software, provided no fee is charged for the Software.  In addition the
 *   rights specified above are conditioned upon the following:
 *
 *   The above copyright notice and this permission notice shall be included in all
 *   copies or substantial portions of the Software.
 *
 *   Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
 *   or promote products derived from this Software without specific prior written
 *   permission from Zuora, Inc.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
 *   ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
 *   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

Zuora Z-Force Sample Code Package: Quote Split

INTRODUCTION
------------

This Z-Force Sample Code package provides a reference implementation that split single Quote(MasterQuote) into two Quotes(SubQuote) and sending to Z-Billing.

USE CASES
---------
a. The customers have two categories of Rate Plans ("Regular" and "Power") that need to send to Z-Billing according to the categories but to track using one Quote on SFDC called MasterQuote. 
b. Correspondingly to the two categories, there could be two SubQuotes. In this sample code, we can send two SubQuotes simultaneously to Z-Billing (only if there are two different categories of Rate Plans selected for the Quote), 
   and there will be two Subscriptions generated after sending to Z-Billing. 
c. The Subscription(s) will generated on single existing Billing Account;
d. The Subscription Zuora ID(s) will be written back to the SubQuote(s) then roll up to the MasterQuote, among which, the "Regular" Subscription's ID will be stored in MasterQuote's zqu__ZuoraSubscriptionID__c, 
   and the "Power" Subscription's ID will be stored in the MasterQuotes' Extended_Zuora_Subscription_ID__c.
e. The SubQuote(s) will be deleted after subscribing, and only MasterQuote will be persisted.

PRE-REQUISITES
-------------
1. This sample code package is an unmanaged package that depends on the following Z-Force managed packages: 
- Z-Force 360 Version 2.3
- Z-Force Quotes Version 5.5

2. If you do not have Force.com Migration Tool already installed, please follow the instructions below: 

1). Visit http://java.sun.com/javase/downloads/index.jsp and install Java JDK, Version 6.1 or greater on the deployment machine.
2). Visit http://ant.apache.org/ and install Apache Ant, Version 1.6 or greater on the deployment machine.
3). Set up the environment variables (such as ANT_HOME, JAVA_HOME, and PATH) as specified in the Ant Installation Guide at http://ant.apache.org/manual/install.html.
4). Log in to Salesforce on your deployment machine. Click Your Name | Setup | Develop | Tools, then click Force.com Migration Tool.
5). Unzip the downloaded file to the directory of your choice. The Zip file contains a Jar file containing the ant tasks: ant-salesforce.jar
6). Copy the ant-salesforce.jar file from the unzipped file into the ant lib directly.  The ant lib directly is located in the root folder of your Ant installation. 

INSTALLATION-INSTRUCTIONS
-------------------------

You can choose two approaches, the first one is by "ant deploy":

1. Open build.properties, and specify the login credentials for your Salesforce.com organization: 

sf.username=
sf.password= 

Please note that the password should be your login password concatenated with the security token.

2. Navigate to Z-Force/QuoteSplit folder, and type: 
ant deploy

This will deploy the sample code unmanaged package into your Salesforce.com organization.  

And the second approach is by installation:

1. Install this sample code package using the following Force.com Installation URL: 

Z-Quotes Quote Split V 1.3
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tE0000000HQcY

This will install sample code unmanaged package into your Salesforce.com organization.

PACKAGE CONTENTS 
----------------

Fields (3)
Component Name                                               Parent Object                      Component Type                Description
Extended Zuora Subscription ID                                  Quote                           Custom Field                  Store the Subscription ID of Power Category
Category                                                    Product Rate Plan                   Custom Field                  The flag to mark the Category of the ProductRatePlan
Master Quote                                                    Quote                           Custom Field                  Store the Master Quote ID


Code (3)
Component Name                                               Parent Object                       Component Type               Description
ExtendedZQuoteUtil                                                                                Apex Class                  The reference implementation that split single Quote(MasterQuote) into two Quotes(SubQuote) and sending to Z-Billing.
SendToZBillingPreviewController                                                                   Apex Class                  The entry page' controller which is to call ExtendedZQuoteUtil.sendToZBilling.
ExtendedTestDataSetup                                                                             Apex Class                  Setup test data for apex unit test.

Pages (1)
Component Name                                               Parent Object                       Component Type               Description
SendToZBillingPreview                                                                             Visualforce Page            The entry page which is to call ExtendedZQuoteUtil.sendToZBilling.


Resources (1)
Component Name                                               Parent Object                       Component Type               Description
Send to Z-Billing (Quote Split)                                  Quote                             Button or Link             The link to SendToZBillingPreview page. 

OPERATION MANUAL
---------------
1. Sync the product catalog from Z-Billing as usual, then check the Product Rate Plans, choose part of the records and set the Category__c field on the records. 
   Currently we support two categories "Power" or "Regular";
2. Create an Opportunity;
3. On the Opportunity, create a New Subscription Quote as MasterQuote and select products, either from "Power" or "Regular" category, for that Quote, 
   in another word, you can choose Product Rate Plans which belong to different Categories for the MasterQuote;
4. In the Quote Detail page, click "Send to Z-Billing(Quote Split)" button to enter the SendToZBillingPreview page;
5. In the SendToZBillingPreview, choose an existing Billing Account in Z-Billing(If there's no existing Billing Account, please prepare at least one in Z-Billing System).
6. Click Button "Send to Z-Billing" to complete subscribe call. 
7. After that, you can verify the result in both SFDC and Z-Billing. In SFDC, the Quote object's zqu__ZuoraSubscriptionID__c or Extended_Zuora_Subscription_ID__c (or Both) should be populated with the Subscription ID(s) of SubQuote(s).
   And In Z-Billing, the corresponding Subscription record(s) should be generated already.