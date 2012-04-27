/**
* Rest code for invoking subscribe sample code
* the rest url mapping is /SampleCodeForApi/subscribe
*/
@RestResource(urlMapping='/SampleCodeForApi/subscribe')
global class SubscribeSampleCodeRestController{
	  /*
	  * params:
	  * 1. accountId: ID of zuora billing account, will be used to create subscription for this account
	  * 2. enablePreview: Flag to enable preview mode( 'true' or 'false' )
	  */
    @HttpGet
    global static Boolean invokeSubscribeSample(){
        RestRequest request = RestContext.request;
        SubscribeCallSampleCode subcall = new SubscribeCallSampleCode();
        String enablePreview = request.params.get('enablePreview');
        String accountId = request.params.get('accountId');
        
        if( accountId == null || accountId.trim().equals('') ){
            if( enablePreview.equalsIgnoreCase( 'true' )  ){
                return subcall.previewSubscriptionWithExistingAccount( accountId );
            }
            else{
                return subcall.createSubscriptionWithExistingAccount( accountId );
            }
        }
        else{
            if( enablePreview.equalsIgnoreCase( 'true' )  ){
                return subcall.previewSubscription();
            }
            else{
                return subcall.createSubscription();
            }
        }     
        
    }
   

}