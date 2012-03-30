/**
 * This class holds the Error Code and Message Mapping, as well as Error Field Code and Name Mapping.
 */
public without sharing class ErrorCodeMapping {
	
	/* Error code and message mapping */
	public static Map<String, String> VALUES = new Map<String, String> {
		/* HPM General Errors */
		'GeneralSystemError' => 'General system error(s) have occurred', 
		'BusinessValidationError' => 'Business validation error(s) have occurred', 
		'GatewayTransactionError' => 'Gateway transaction error(s) have occurred', 
    'HostedPageFieldValidationError' => 'Field validation error(s) have occurred', 
    
    /* HPM Field Validation Errors */
    'NullValue' => 'Field is required but no value has been entered', 
    'InvalidFormat' => 'Format of value does not match its definition', 
    'ExceededMaxLength' => 'Length of value entered exceeds the maximum length', 
    'InvalidCallbackSecurity' => 'The transaction is invalid', 
    
    /* SFDC Errors */
    'Sfdc.ErrorLoadingFrame' => 'An error occurred while loading Payment Method Page frame. ',
    'Sfdc.NoConfiguration' => 'There is no \"Zuora HPM Setting\" record found in HPM custom setting.  Please create it first.', 
    'Sfdc.InvalidConfiguration' => 'Please enter a valid value for the following field(s) in the HPM custom setting:', 
    'Sfdc.InvalidField' => 'Please enter a valid value for the following field(s): '
	}; 
	
	/* Error field code and name mapping */
  public static Map<String, String> ERROR_FIELD_MAPPING = new Map<String, String> {
    'errorField_creditCardType' =>  'Card Type',
    'errorField_creditCardNumber' =>  'Card Number',
    'errorField_creditCardExpirationMonth' =>  'Expiration Month',
    'errorField_creditCardExpirationYear' =>  'Expiration Year',
    'errorField_cardSecurityCode' =>  'CVV',
    'errorField_creditCardHolderName' =>  'Cardholder Name',
    'errorField_creditCardCountry' =>  'Country',
    'errorField_creditCardAddress1' =>  'Address 1',
    'errorField_creditCardAddress2' =>  'Address 2',
    'errorField_creditCardCity' =>  'City',
    'errorField_creditCardState' =>  'State',
    'errorField_creditCardPostalCode' =>  'Postal Code',
    'errorField_phone' =>  'Contact Phone Number',
    'errorField_email' =>  'Email Address'
    }; 
}